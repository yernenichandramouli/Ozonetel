/**
 * **********************************************************************************************************
 * Lightning Web Component   :   sgmyBulkCaseCloseCmp
 * Includes                  :   sgmyBulkCaseCloseCmp.html, sgmyBulkCaseCloseCmp.js, sgmyBulkCaseCloseCmp.css, sgmyBulkCaseCloseCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2023-MAR-07
 * @description  Bulk close SGMY community Cases button
 * @JiraId       CRM-1337
 */
import { LightningElement, track, wire } from "lwc";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import getCaseList from '@salesforce/apex/SGMYBulkCloseCaseCtrl.getSGMYcaseList';
import closeCases from '@salesforce/apex/SGMYBulkCloseCaseCtrl.closeSelectedCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class SgmyBulkCaseCloseCmp extends LightningElement {
    @track showModalDialog = false;
    @track showTable = false;
    @track columns = [{ label: 'Case Number', fieldName: 'CaseNumber', sortable: true},{ label: 'Email', fieldName: 'SuppliedEmail'},{ label: 'Subject', fieldName: 'Subject'},{ label: 'Date/Time Opened', fieldName: 'CreatedDate'},{ label: 'CaseOwner', fieldName: 'CaseOwner'}];
    @track data = [];
    @track error;
    @track selectedCaseIds = [];
    @track picklistValues;
    @track isValid = true;
    @track selectedIssueType;
    @track caseCommentToInsert;
    @track wiredCaseList = [];
    @track disableButton = false;
    @track noRecords = false;

    //Fetch picklist values of issue type for SGMY HQ Bus Dev record Type.
    @wire(getPicklistValuesByRecordType, { objectApiName: 'Case', recordTypeId: '012C70000004I6x' }) 
    sgmyIssueTypePickListValues({error, data}) {
        if(data) {
            this.picklistValues = data.picklistFieldValues.Issue_Type__c.values;
            console.log('picklistValues '+this.picklistValues);
        }
        else if(error) {
            this.error=error;
        }
    }

    //Fetch case List to be displayed.

    @wire(getCaseList, {}) wiredGetActivityHistory(value) {
        // Hold on to the provisioned value so we can refresh it later.
        this.wiredCaseList = value;
        const { data, error } = value;
        if (data) {
            this.data = data;
            if(this.data.length>0 && this.data.length!==undefined){
                this.data = data.map((cc) => {
                    const caseWithOwner = {...cc}; // clone the original record
                    caseWithOwner.CaseOwner = cc.Owner.Name; // add the new property
                    return caseWithOwner;
                });
                console.log('this.dataLength '+this.data.length);
                console.log('this.data '+JSON.stringify(this.data));
                this.showTable = true;
            }else{
                this.noRecords=true;
                this.disableButton=true;
            }
        } else if (error) {
            this.noRecords=true;
            this.disableButton=true;
            this.error = JSON.stringify(error);
        }
    }

    handleClick(){
        this.showModalDialog=true;
    }

    getSelectedRows(){
        return this.template.querySelector('lightning-datatable').getSelectedRows();
    }

    closePopup(event){        
        this.showModalDialog = false;
    }

    //handle close case button.
    getSelectedRec(){
        var i;
        var arrayOfSelectedRows=[];
        var objectArray =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(objectArray.length==0){
            this.isValid=false;
            this.showToastMessage(this,'Warning','Please select the records to close','warning','dismissible');
        }else{
            for(i=0; i<objectArray.length; i++) {
                arrayOfSelectedRows.push(objectArray[i].Id);
            }
        }

        console.log('arrayOfSelectedRows ', arrayOfSelectedRows);
        
        //validation to check issue type
        if(this.template.querySelector('[data-field-name="Issue_Type"]').value==undefined || this.template.querySelector('[data-field-name="Issue_Type"]').value==''){
            this.isValid=false;
            this.showToastMessage(this,'Warning','Please select Issue Type','warning','dismissible');
        }else{
            this.isValid=true;
            this.selectedIssueType=this.template.querySelector('[data-field-name="Issue_Type"]').value;
        }

        //validation to check caseComment
        if(this.template.querySelector('[data-field-name="case_comment"]').value==undefined || this.template.querySelector('[data-field-name="case_comment"]').value==''){
            this.showToastMessage(this,'Warning','Please enter case comment','warning','dismissible');
            this.isValid=false;
        }else{
            this.caseCommentToInsert=this.template.querySelector('[data-field-name="case_comment"]').value;
        }
        console.log('SelectedIssueType ', this.selectedIssueType);

        if(this.isValid){
            this.disableButton = true;
            this.showToastMessage(this,'Information','Processing..','info','dismissible');
            closeCases({
                'CaseIds' : arrayOfSelectedRows,
                'IssueType' : this.selectedIssueType,
                'casecommentToInsert' : this.caseCommentToInsert
            })
            .then(result => {
                this.disableButton = false;
                if(result.error){
                    this.showToastMessage(this,'Error',+result.error,'Error','dismissible');
                    console.log('::: No Data Avialable :: ');              
                }else{
                    console.log('result '+result);
                    if(result==='success'){
                        this.template.querySelector('[data-field-name="case_comment"]').value='';
                        this.template.querySelector('[data-field-name="Issue_Type"]').value='';
                        this.showToastMessage(this,'Success','Case status updated successfully !!','Success','dismissible');
                    }else if(result==='No_Records'){
                        console.log(':: No_Records ::: '); 
                    }else{
                        this.showToastMessage(this,'Error',+result,'Error','dismissible');
                    }
                    return refreshApex(this.wiredCaseList);
                }
                
            })
            .catch(error => {
                this.error = error; 
            })
        }
    }

    handleRowAction(event){
        const row=event.detail.row;
        console.log(':: row ::: '+row); 
    }

    showToastMessage(cmp,title,message,variant,mode){
        cmp.dispatchEvent(
            new ShowToastEvent({
                title: message,
                message: '',
                variant: variant,
                mode: mode
            }),
        );
        cmp.isLoading = false;
    }
}