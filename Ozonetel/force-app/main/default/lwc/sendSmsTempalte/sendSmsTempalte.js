import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SearchTemplates from '@salesforce/apex/SendSmsFromTemplate.SearchTemplates';
import sendSMS from '@salesforce/apex/SendSmsFromTemplate.sendSMS';
import getMobileNumber from '@salesforce/apex/SendSmsFromTemplate.getMobileNumber';
import BUSINESUNIT_FIELD from "@salesforce/schema/Case.Case_Business_Unit__c";
import BUSINESUNIT from "@salesforce/schema/Case.Business_Type__c";
import COUNTRY_FIELD from "@salesforce/schema/Case.Country__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
const fields = [BUSINESUNIT_FIELD,COUNTRY_FIELD, BUSINESUNIT];


export default class SendSmsTempalte extends LightningElement {
    @api recordId;
    @track searchText = '';
    @track isLoading = false;
    @track searchRecords = [];
    @track mapdata = [];
    @track mapTemplates = [];
    @track showRecords = false;
    @track selTemplateVal = '';
    @track selMessageContent = '';
    @track phnNumbers = [];
    @track options = [];
    @track selectedPhNum = '';
    @track value = '';
    @track isLoadingSendSms = false;
    @track selType;
    @track type;
    @track disTitleMsg;

    @wire(getRecord, { recordId: "$recordId", fields }) case;
    get businessUnit() {
        var bu = getFieldValue(this.case.data, BUSINESUNIT_FIELD);
        var businessUnitType = getFieldValue(this.case.data, BUSINESUNIT);
        var country = getFieldValue(this.case.data, COUNTRY_FIELD);
        if (bu == 'REDBUS_IN') {
            this.disTitleMsg = 'Send SMS';
        } else if (bu == 'REDBUS_SG' || bu == 'REDBUS_MY') {
            this.disTitleMsg = 'Send SMS/Whatsapp';
        }else if(businessUnitType =='L1 Support' && country == 'India'){
            this.disTitleMsg = 'Send SMS';
        }
        return this.disTitleMsg;
    }


    @wire(getMobileNumber, { caseId: '$recordId' })
    wireMethod({ error, data }) {
        if (data) {
            console.log(JSON.stringify(data));
            this.phnNumbers = data;
            console.log(this.phnNumbers.length);
            for (var i = 0; i < this.phnNumbers.length; i++) {
                console.log(this.phnNumbers[i]);
                this.options = [...this.options, { value: this.phnNumbers[i], label: this.phnNumbers[i] }];
            }
        }
    }

    handleKeyChange(event) {
        console.log('entered event->' + this.selType);
        console.log('record id' + this.recordId);
        this.searchText = event.target.value;
        this.showRecords = false;
        this.selTemplateVal = '';
        if (this.searchText == null || this.searchText == '') {
            this.showRecords = false;
            console.log('<<serach text is empty');
        }
        else {
            console.log('search text:>>> ' + this.searchText);
            this.isLoading = true;
            SearchTemplates({ template: this.searchText, type: this.selType })
                .then(result => {
                    if (result) {
                        console.log('<<<result' + JSON.stringify(result));
                        console.log('res>>>' + result);
                        if (result != null) {
                            this.showRecords = true;
                            this.searchRecords = result;
                        }
                        else
                            this.showRecords = false;
                    }
                    else
                        this.showRecords = false;
                })
            this.isLoading = false;

        }
    }
    handleSelect(event) {
        console.log('selected template >>' + event.currentTarget.dataset.record);
        //  this.selectedTemplate = event.detail.Name;
        this.selTemplateVal = event.currentTarget.dataset.record;
        this.showRecords = false;
        this.selMessageContent = '';
        for (var i = 0; i < this.searchRecords.length; i++) {
            if (this.searchRecords[i].DeveloperName == this.selTemplateVal) {
                this.selMessageContent = this.searchRecords[i].Message_Content__c;
            }
        }
    }
    commentValue(event) {
        console.log('comment va-->' + event.target.value);
        this.selMessageContent = event.target.value;
    }
    handleSend(event) {
        console.log('Message:>>> ' + this.selMessageContent);
        this.isLoadingSendSms = true;
        sendSMS({ caseId: this.recordId, msgContent: this.selMessageContent, mobileNum: this.selectedPhNum, type: this.selType })
            .then(result => {
                console.log('result' + result);
                console.log('res' + JSON.stringify(result));
                if (result) {
                    console.log('<<<result' + JSON.stringify(result));
                    console.log('res>>>' + result);
                    if (result != null) {

                        if (result == 'SMS sent successfully') {
                            this.isLoadingSendSms = false;
                            this.selMessageContent = '';
                            this.selectedPhNum = '';
                            this.seacrhText = '';
                            this.value = undefined;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'success',
                                    message: result,
                                    variant: 'success',
                                    mode: 'dismissable'
                                }),
                            );
                            this.isLoadingSendSms = false;
                        }
                        else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: result,
                                    variant: 'Error',
                                    mode: 'dismissable'
                                }),
                            );
                            this.isLoadingSendSms = false;
                        }
                    }
                    else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Failed',
                                message: 'Somthing went wrong. Please contact Admin',
                                variant: 'Failed',
                                mode: 'dismissable'
                            }),
                        );
                        console.log('error');
                        this.isLoadingSendSms = false;
                    }
                }
                else {
                    console.log('error');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed',
                            message: 'Somthing went wrong. Please contact Admin',
                            variant: 'Failed',
                            mode: 'dismissable'
                        }),
                    );
                    this.isLoadingSendSms = false;
                }
            })
            .catch(error => {
                console.log('error' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed',
                        message: 'Somthing went wrong. Please contact Admin',
                        variant: 'Failed',
                        mode: 'dismissable'
                    }),
                );
                this.isLoadingSendSms = false;
            });
    }
    handleNumberSelect(event) {
        console.log(event.detail.value);
        this.selectedPhNum = event.detail.value;
    }

    get wasms_options() {
        if (this.disTitleMsg == 'Send SMS') {
            return [
                { label: 'SMS', value: 'SMS' }
            ];
        } else if (this.disTitleMsg == 'Send SMS/Whatsapp') {
            return [
                { label: 'SMS', value: 'SMS' },
                { label: 'Whatsapp', value: 'Whatsapp' }
            ];
        }
    }

    handleTypeChange(event) {
        this.type = true;
        this.selType = event.target.value;
        console.log('event2-->' + this.selType);

    }
}