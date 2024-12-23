/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import ISSUE_TYPE_FIELD from '@salesforce/schema/Case.Issue_Type__c';
import SUB_ISSUE_TYPE_FIELD from '@salesforce/schema/Case.Issue_Sub_Category__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import CBR_FIELD from '@salesforce/schema/Case.Does_Customer_Require_CallBack__c';
import CBT_FIELD from '@salesforce/schema/Case.Call_Back_Time__c';
import PRIORITY from '@salesforce/schema/Case.Priority';
import CASEORIGIN from '@salesforce/schema/Case.Origin';
import TRANS_FIELD from '@salesforce/schema/Case.Transaction_ID__c';
import DESCR_P from '@salesforce/schema/Case.Description_P__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CreateCase from "@salesforce/apex/CreateCaseCtrl.CreateCase";
import DuplicateCheck from "@salesforce/apex/CreateCaseCtrl.DuplicateCheck";
import USER_ID from '@salesforce/user/Id';
import COUNTRY_FIELD from '@salesforce/schema/Case.Country__c';
import BUSINESS_TYPE from '@salesforce/schema/Case.Business_Type__c';
import { NavigationMixin } from 'lightning/navigation';

const fields = [
    'Order_Item__c.id',
    'Order_Item__c.name'
];

export default class CaseCreation extends NavigationMixin(LightningElement) {
    @track controllingValues = [];
    @track dependentValues = [];
    @track statusValues = [];
    @track countryValues = [];
    @track businessTypeValues = [];
    @track priorityValues=[];
    @track caseOriginValues=[];
    @track csLoad = false;
    //  @track issueType = ISSUE_TYPE_FIELD;
    @track subIssueType = SUB_ISSUE_TYPE_FIELD;
    @track selectedCountry;
    @track selectedState;
    @api tranRecId;
    @api recordId;
    @track objUser = {};
    @track issueTypeValues;
    @track issueTypeValuesA;
    @track userCountry = 'India';
    @track userBusinessType ;
    @track trnValue;
    @track saveBt = false;
    @track ordId='';
    @track tripId='';
    @track csRecord = {
        Status: STATUS_FIELD,
        Issue_Type__c: ISSUE_TYPE_FIELD,
        Issue_Sub_Category__c: SUB_ISSUE_TYPE_FIELD,
        Description: DESCRIPTION_FIELD,
        Country__c: COUNTRY_FIELD,
        Business_Type__c: BUSINESS_TYPE,
        Does_Customer_Require_CallBack__c: CBR_FIELD,
        Call_Back_Time__c: CBT_FIELD,
        Priority : PRIORITY,
        Case_origin :CASEORIGIN,
        Description_p:DESCR_P
    };
    handlePriorityChange(event){
        this.csRecord.priority = event.target.value;
    }
    handleCaseOriginChange(event){
        this.csRecord.Case_origin = event.target.value;
    }
    handleStatusChange(event) {
        this.csRecord.Status = event.target.value;
        window.console.log('Status ==> ' + this.csRecord.Status);
    }
    handleCountryChange(event) {
        this.csRecord.Country__c = event.target.value;
        window.console.log('Country__c ==> ' + this.csRecord.Country__c);
    }
    handleBusinessTypeChange(event) {
        this.csRecord.Business_Type__c = event.target.value;
    }
    handleIssueTypeChange(event) {
        this.csRecord.Issue_Type__c = event.target.value;
    }   
    handleSubIssueTypeChange(event) {
        this.csRecord.Issue_Sub_Category__c = event.target.value;
    }
    handleDescriptionChange(event) {
        console.log('changing ');
        this.csRecord.Description = event.target.value;
        console.log('desc-->' + this.csRecord.description);
    }
    handleDescriptionPChange(event){
        this.csRecord.Description_P = event.target.value;
    }
    handleCBRChange(event) {
        this.csRecord.Does_Customer_Require_CallBack__c = event.target.checked;
       console.log('cbx->' + event.target.value);
    }
    handleCBTChange(event) {
        this.csRecord.Call_Back_Time__c = event.target.value;
        console.log('cbt->' + this.csRecord.Call_Back_Time__c);
    }

    // using wire service getting current user data
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Business_Type__c', 'User.Country'] })
    userData({ error, data }) {
        if (data) {
            window.console.log('data ====> ' + JSON.stringify(data));
            let objCurrentData = data.fields;
            this.userCountry = objCurrentData.Country.value;
            this.userBusinessType = objCurrentData.Business_Type__c.value;
        }
        else if (error) {
            window.console.log('error ====> ' + JSON.stringify(error))
        }
    }

    @wire(getRecord,{recordId:'$tranRecId', fields: ['Order_Items__c.Order_Id__c','Order_Items__c.Name']})
    TransactionData({error, data}){
        if(data){
            window.console.log('data ====> ' + JSON.stringify(data));
            let ordData = data.fields;
            this.ordId=ordData.Name.value;
            this.tripId=ordData.Order_Id__c.value;
        }
        else if(error){
            window.console.log('error ====> ' + JSON.stringify(error))
        }
    }


    /*   @wire(getRecord, { recordId: '$tranRecId', fields: FIELDS })
       getRequisition({ error, data }) {
           console.log('t id-->' + this.tranRecId);
           console.log('out side -->' + JSON.stringify(data));
           console.log('error-->' + error);
           if (data) {
               console.log('insdie' + data.fields.Order_Item__c.value);
               if (data.fields.Order_Item__c.value == null) {
                   //test
               }
           }
       }*/


    /* @wire(getRecord, {
         recordId: 'a0C0p000000S8ZmEAK',
         fieldsF
     }) Order_Item__c;
  */
    @wire(getRecord, {
        recordId: '$tranRecId',
        fields
    }) Order_Item__c;
    get nameTT() {
        console.log('tranRecId-->' + this.tranRecId);
        console.log('data->' + JSON.stringify(this.Order_Item__c));
        console.log('data 2->' + this.Order_Item__c.data);
        console.log('name here' + this.fields);
        /*console.log('data->' + this.Order_Item__c.data);
        console.log('f->' + this.Order_Item__c.data.FIELDS);
        console.log('n->' + this.Order_Item__c.data.FIELDS.name);
        return this.Order_Item__c.data.FIELDS.name.value;*/
    }
    @wire(getRecord, { recordId: '$tranRecId', fields: fields })
    getRequisition({ error, data }) {
        console.log('out side -->' + JSON.stringify(data));
        if (data) {
            // this.trnValue = data.fields.Order_Item__c.name.value;
            console.log('insdie' + data.fields.Order_Item__c.value);
            if (data.fields.Order_Item__c.value == null) {
                //
            }
            // this.requisition = data;
        }
    }

    @wire(getRecord, { recordId: '$tranRecId', fields })
    wiredProperty(value) {
        console.log('hhhl' + JSON.stringify(value));
        console.log('dfdfd' + JSON.stringify(value.data));
        if (value.data) {
            console.log('' + JSON.stringify(value.data));
            //
        } else if (value.error) {
            console.log("ERROR: ", value.error)
        }
    }

    /*  @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD })
      CountryPicklistValuesV({ error: data }) {
          console.log('dt-->' + JSON.stringify(data));
          //
      }*/


    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: BUSINESS_TYPE })
    BusinessPicklistValues;

    // Account object info
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    // Picklist values based on record type
    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    countryPicklistValues({ error, data }) {
        if (data) {
            this.csRecord.Does_Customer_Require_CallBack__c = false;
            this.csRecord.Call_Back_Time__c =' ';
            this.csRecord.priority='Medium';
            this.error = null;
            let countyOptions = [{ label: '--None--', value: '--None--' }];
            let countyOptionsV = [{ label: '--None--', value: '--None--' }];
            let businessTypeOptions = [{ label: '--None--', value: '--None--' }];
            let caseOriginValuesV=[];
            let priorityValuesV=[];
            // Account Country Control Field Picklist values
            data.picklistFieldValues.Issue_Type__c.values.forEach(key => {
                countyOptions.push({
                    label: key.label,
                    value: key.value
                })
            });
            data.picklistFieldValues.Country__c.values.forEach(key => {
                countyOptionsV.push({
                    label: key.label,
                    value: key.value
                })
            });
            data.picklistFieldValues.Business_Type__c.values.forEach(key => {
                businessTypeOptions.push({
                    label: key.label,
                    value: key.value
                })
            });
            data.picklistFieldValues.Priority.values.forEach(key => {
                priorityValuesV.push({
                    label: key.label,
                    value: key.value
                })
            });
            data.picklistFieldValues.Origin.values.forEach(key => {
                caseOriginValuesV.push({
                    label: key.label,
                    value: key.value
                })
            });

//            this.csRecord.Country__c = 'Peru';
//            this.csRecord.Business_Type__c = 'Peru-Bus';
            this.csRecord.Country__c = this.userCountry;
            this.csRecord.Business_Type__c = this.userBusinessType;
            this.csRecord.Case_origin='InBound Call';
            this.csRecord.Description ='';
            this.csRecord.Description_P ='';
            this.countryValues = countyOptionsV;
            this.controllingValues = countyOptions;
            this.businessTypeValues = businessTypeOptions;
            this.priorityValues = priorityValuesV;
            this.caseOriginValues = caseOriginValuesV;
            let stateOptions = [{ label: '--None--', value: '--None--' }];

            this.issueTypeValues = data.picklistFieldValues.Issue_Type__c.controllerValues;
            let depOptions = [];
            depOptions = data.picklistFieldValues.Issue_Type__c.values;

            let dependValues = [];

            depOptions.forEach(conValues => {
                if (conValues.validFor[0] === this.issueTypeValues[this.userBusinessType]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

            this.issueTypeValuesA = dependValues;
            // Account State Control Field Picklist values
            this.controlValues = data.picklistFieldValues.Issue_Sub_Category__c.controllerValues;
            // Account State dependent Field Picklist values
            this.totalDependentValues = data.picklistFieldValues.Issue_Sub_Category__c.values;
            this.totalDependentValues.forEach(key => {
                stateOptions.push({
                    label: key.label,
                    value: key.value
                })
            });

            this.dependentValues = stateOptions;

            let statusOptions = [{ label: '--None--', value: '--None--' }];
            this.totalStatusValues = data.picklistFieldValues.Status.values;
            this.totalStatusValues.forEach(key => {
                statusOptions.push({
                    label: key.label,
                    value: key.value
                })
            });

            this.statusValues = statusOptions;

        }
        else if (error) {
            this.error = JSON.stringify(error);
        }

    }
    IssueTypePickListValues(event) {
        // Selected Country Value
        this.selectedCountry = event.target.value;
        console.log('sel cou->' + this.selectedCountry);
        this.isEmpty = false;
        let dependValues = [];

        if (this.selectedCountry) {
            // if Selected country is none returns nothing
            if (this.selectedCountry === '--None--') {
                this.isEmpty = true;
                dependValues = [{ label: '--None--', value: '--None--' }];
                this.selectedCountry = null;
                this.selectedState = null;
                return;
            }

            // filter the total dependent values based on selected country value 
            this.totalDependentValues.forEach(conValues => {
                if (conValues.validFor[0] === this.controlValues[this.selectedCountry]) {
                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

            this.dependentValues = dependValues;
            this.csRecord.Issue_Type__c = event.target.value;
        }
    }

    handleStateChange(event) {
        this.selectedState = event.target.value;
    }
    handleProceed(){
    this.csLoad = true;
    console.log('save--');
    const fields = {};

    fields[ISSUE_TYPE_FIELD.fieldApiName] = this.csRecord.Issue_Type__c;
    fields[SUB_ISSUE_TYPE_FIELD.fieldApiName] = this.csRecord.Issue_Sub_Category__c;
    fields[STATUS_FIELD.fieldApiName] = this.csRecord.Status;
    fields[DESCRIPTION_FIELD.fieldApiName] = this.csRecord.description;
    fields[CBR_FIELD.fieldApiName] = this.csRecord.Does_Customer_Require_CallBack__c;
    fields[CBT_FIELD.fieldApiName] = this.csRecord.Call_Back_Time__c;
    fields[TRANS_FIELD.fieldApiName] = this.tranRecId;
    fields[PRIORITY.fieldApiName] = this.csRecord.priority;
    fields[BUSINESS_TYPE.fieldApiName]=this.csRecord.Business_Type__c
 //   fields[DESC_P.fieldApiName] = this.csRecord.description_p;
    fields[CASEORIGIN.fieldApiName] = this.csRecord.Case_origin;
     CreateCase({ cs: fields })
    .then(data => {
        console.log('saved???');
        this.csLoad = false;
        this.saveBt = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                        recordId: data.Id,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
        }, false);
            
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Case created',
                variant: 'success',
            }),
         );
        const closeCaseCreate = new CustomEvent('save');
        this.dispatchEvent(closeCaseCreate);
    })
    .catch(error => {
        this.csLoad = false;
        this.error = JSON.stringify(error);
        console.log('error-->' + this.error);
        this.dispatchEvent(
        new ShowToastEvent({
            title: 'Failed',
            message: 'Case Creation Failed->' + this.error,
            variant: 'error',
        }),
        );
    });
}    
    handleSave() {
        this.csLoad = true;
        console.log('save--');
        const fields = {};
        fields[ISSUE_TYPE_FIELD.fieldApiName] = this.csRecord.Issue_Type__c;
        fields[SUB_ISSUE_TYPE_FIELD.fieldApiName] = this.csRecord.Issue_Sub_Category__c;
        fields[STATUS_FIELD.fieldApiName] = this.csRecord.Status;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.csRecord.Description;
        fields[CBR_FIELD.fieldApiName] = this.csRecord.Does_Customer_Require_CallBack__c;
        fields[CBT_FIELD.fieldApiName] = this.csRecord.Call_Back_Time__c;
        fields[TRANS_FIELD.fieldApiName] = this.tranRecId;
        fields[PRIORITY.fieldApiName] = this.csRecord.priority;
        fields[BUSINESS_TYPE.fieldApiName]=this.csRecord.Business_Type__c
        fields[CASEORIGIN.fieldApiName] = this.csRecord.Case_origin;
        CreateCase({ cs: fields })
        .then(data => {
            console.log('saved???');
            this.csLoad = false;
            this.saveBt = true;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: data.Id,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            }, false);
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case created',
                    variant: 'success',
                }),
             );
             const closeCaseCreate = new CustomEvent('save');
             this.dispatchEvent(closeCaseCreate);

         })
        .catch(error => {
            this.csLoad = false;
            this.error = JSON.stringify(error);
            console.log('error-->' + this.error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: 'Case Creation Failed->' + this.error,
                    variant: 'error',
                }),
            );
        });

//        let recordInput = { apiName: CASE_OBJECT.objectApiName, fields }
//        console.log('csRecord-->' + JSON.stringify(recordInput));
 //       createRecord(recordInput)
    }


}