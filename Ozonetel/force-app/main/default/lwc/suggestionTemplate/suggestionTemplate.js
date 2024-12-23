/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import CURRENTUSERID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import SugTemplate from '@salesforce/apex/SuggestionTemplate.GetTemplate';
import SearchTemplates from '@salesforce/apex/SuggestionTemplate.SearchTemplates';
import SaveCaseComment from '@salesforce/apex/SuggestionTemplate.SaveCaseComment';
import mergeTemplateValues from '@salesforce/apex/FieldMergeUtil.replaceMergeFieldsWithValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SuggestionTemplate extends LightningElement {

    userId = CURRENTUSERID;
    @api recordid;
    @api objectApiName;
    @track issueType;
    @track subIssueType;
    @track sugTemplateVal;
    @track selectedTemplate;
    @track showoptions = true;
    @track searchString = '';
    @track searchRecords;
    @track searchRecValues;
    @track selTV;
    @track saveBtLoad = false;
    @track showErrMsg = false;
    @track notifType;
    @track notifMsg;
    @track saveBt = false;
    @track reCreateBt = false;
    @track allTemplates = [];
    @track selTemplate;
    @track partner;
    @track countryVal;
    @track busnsType;	
    @track hideSugTemp = false;
    @track stc = false;
    @track rtb = false;

    @wire(getRecord, {
        recordId: '$recordid',
        fields:
            ['Case.Issue_Type__c',
                'Case.Issue_Sub_Category__c', 'Case.Partner__c', 'Case.Country__c', 'Case.Business_Type__c']
    }) loadCustomer({ error, data }) {
        if (error) {
            console.log('error:',
                error.body.errorCode,
                error.body.message);
        } else if (data) {
            this.issueType = data.fields.Issue_Type__c.value;
            this.subIssueType = data.fields.Issue_Sub_Category__c.value;
            this.partner = data.fields.Partner__c.value;
            this.countryVal = data.fields.Country__c.value;
            this.busnsType = data.fields.Business_Type__c.value;

            if (this.partner != 'Amazon' && (this.countryVal == 'India' || this.countryVal == null)) {
                this.hideSugTemp = true;
            }
        }
    }
    @wire(SugTemplate, {country: '$countryVal',busType: '$busnsType',issue: '$issueType', subIssue: '$subIssueType' })
    wiredSugTemplate({ error, data }) {
        if (data) {
            console.log('data1->' + data)
            console.log('data-->' + JSON.stringify(data));
            if (data == null || data == '') {
                //  this.sugTemplateVal = 'No Suggestion available for this issue type';
            } else {
                console.log('data results-->' + data[0].Id);
                // this.sugTemplateVal = data[0].Suggestion_Template__c;
                let optionsValues = [];
                for (let d of Object.values(data)) {
                    console.log('d->' + d);
                    optionsValues.push({ label: d.Template_Name__c, value: d.Suggestion_Template__c });
                    //this.allTemplates.push(d.Template_Name__c);
                }
                this.allTemplates = optionsValues;
                console.log('at->' + this.allTemplates)
            }
        } else if (error) {
            console.log('error-->' + error);
        }
    }

    handleKeyChange(event) {

        this.searchString = event.target.value;
        this.searchRecords = '';
        if (this.searchString == null || this.searchString == '') {
            this.searchRecords = '';
            this.showoptions = false;
        } else {
            SearchTemplates({country: '$countryVal', busType: '$busnsType', template: this.searchString })
                .then(result => {
                    if (result) {
                        console.log('res-->' + result);
                        this.showoptions = true;
                        this.searchRecords = JSON.parse(JSON.stringify(result));
                        console.log('se-->' + JSON.stringify(this.searchRecords));
                        console.log('se id-->' + this.searchRecords[0].Issue_Type__c);
                        /*  let objCurrentData = this.searchRecords;
                          console.log('oobj-->' + objCurrentData);
                          searchRecValues = objCurrentData.Id;
                          console.log('searchRecValues-->' + searchRecValues)*/
                    } else {
                        this.showoptions = false;
                        this.searchRecords = false;
                    }
                }).catch(error => {
                    console.log('exception e..' + error);
                });
        }
    }

    handleSelect(event) {
        console.log('tkid rec-->' + event.currentTarget.dataset.record);
        //  this.selectedTemplate = event.detail.Name;
        this.sugTemplateVal = event.currentTarget.dataset.record;
        var mergedTemplate = this.mergeSuggestedTemplateFieldValues(this.sugTemplateVal);
        console.log('::: mergedTemplate2 = '+mergedTemplate);
        this.showoptions = false;
    }

    handleSelectRedio(event) {
        this.sugTemplateVal = event.detail.value;
        console.log('::: Inside handleSelectRedio' +this.sugTemplateVal);
        var mergedTemplate = this.mergeSuggestedTemplateFieldValues(this.sugTemplateVal);
        console.log('::: mergedTemplate = '+mergedTemplate);
        this.showoptions = false;
    }
    commentValue(event) {
        console.log('comment va-->' + event.target.value);
        this.sugTemplateVal = event.target.value;
    }

    handleSave() {
        this.saveBtLoad = true;
        console.log('val-->' + this.sugTemplateVal);
        if (this.sugTemplateVal.length > 10) {

            SaveCaseComment({ csId: this.recordid, comment: this.sugTemplateVal, isSTC: this.stc, isRTB: this.rtb })
                .then(result => {
                    var resp = result;
                    this.saveBtLoad = false;
                    this.showErrMsg = true;
                    this.saveBt = true;
                    this.reCreateBt = true;

                    if(result =='Success'){
                        this.notifType = 'success';
                        this.notifMsg = 'Case Commente Created Successfully';
                        const selectedEvent = new CustomEvent("progressvaluechange", {
                            detail: true
                        });
                        this.dispatchEvent(selectedEvent);    
                    }
                    else{
                        this.notifType = 'error';
                        this.notifMsg = result;
                    }


                }).catch(error => {
                    this.saveBtLoad = false;
                    this.showErrMsg = true;
                    this.notifType = 'error';
                    this.notifMsg = 'Failed to create comment!! Please try again.';

                    console.log('exception e..' + error);
                });
        } else {
            this.saveBtLoad = false;
            this.showErrMsg = true;
            this.notifType = 'error';
            this.notifMsg = 'Please add a comment more than 10 Characters.';
        }

    }

    ReCreate() {
        this.showErrMsg = false;
        this.notifType = '';
        this.notifMsg = '';
        this.sugTemplateVal = '';
        this.saveBt = false;
        this.reCreateBt = false;
    }
    handleSTC(event){
        this.stc=event.target.checked;
    }
    handleRTB(event){
        this.rtb=event.target.checked;
    }

    mergeSuggestedTemplateFieldValues(templateToMerge){
        console.log('::: templateToMerge' +templateToMerge);
        mergeTemplateValues({
            stringToMerge:templateToMerge,
            // recordId:JSON.stringify(this.recordid)
            recordId:this.recordid
        })
        .then(result=>{
            this.sugTemplateVal = result;
            // this.sugTemplateVal.replace(/{([^}]*)}/g, '<b>$1</b>');
            console.log('::: result JSON = '+this.sugTemplateVal);
        })
        .catch(error => {
            console.log('Error '+error.message);
        });
    }

}