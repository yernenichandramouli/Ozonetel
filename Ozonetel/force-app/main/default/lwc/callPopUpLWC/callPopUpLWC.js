/* eslint-disable vars-on-top */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchCallDet from '@salesforce/apex/CallPopUpControllerLtng.fetchLatestCallDet';
import redUrl from '@salesforce/apex/CallPopUpControllerLtng.getRedirectionUrl';

import Mobile_FIELD from '@salesforce/schema/Call_Details__c.Mobile_Number__c';
import AgentId_FIELD from '@salesforce/schema/Call_Details__c.Agent_Id__c';

import Lan_FIELD from '@salesforce/schema/Call_Details__c.Language__c';
//import Men_FIELD from '@salesforce/schema/Call_Details__c.Menu_Options__c';
import OrderUuid_FIELD from '@salesforce/schema/Call_Details__c.OrderUuid__c';
//import Trip_FIELD from '@salesforce/schema/Call_Details__c.Trip_Id__c';
import HFT_FIELD from '@salesforce/schema/Call_Details__c';
import Remarks_FIELD from '@salesforce/schema/Call_Details__c.Remarks__c';

const accFields = [
    {
        label: 'Customer Name', fieldName: 'nameUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_top'
        }
    },
    { label: 'Mobile', fieldName: 'PersonMobilePhone' },
    { label: 'Email', fieldName: 'PersonEmail' },
    { label: 'Signed in User', fieldName: 'Signed_in_User__c' },
    { label: 'User Id', fieldName: 'User_Id__c ' },
]

const caseFields = [
    {
        label: 'Case Number', fieldName: 'csUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' },
            target: '_top'
        }
    },
    { label: 'Transaction Name', fieldName: 'Transaction_id__r.Name' },
    { label: 'Issue Type', fieldName: 'Issue_Type__c' },
    { label: 'Issue Sub Type', fieldName: 'Issue_Sub_Category__c' },
    { label: 'DOJ', fieldName: 'Date_Of_Journey_New__c' },
    { label: 'TIN', fieldName: 'TIN_No__c' },
    { label: 'Issue Sub Type', fieldName: 'Total_Ticket_Amount__c' },
    { label: 'DOJ', fieldName: 'Service_Provider_Name__c' },
    { label: 'Source', fieldName: 'Source__c' },
    { label: 'Destination', fieldName: 'Destination__c' },
]

const itemFields = [
    {
        label: 'Transaction Id', fieldName: 'itemUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_top'
        }
    },
    {
        label: 'Trip Id',
        type: 'button',
        initialWidth: 90,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View',
            disabled: false,
            label: { fieldName: 'Order_Id__c' },
            name: { fieldName: 'Order_Id__c' },

        }
    },
    {
        label: 'Trip Id', fieldName: 'ordUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Order_Id__c' },
            target: '_top'
        }
    },

    { label: 'TIN', fieldName: 'Order_Item_Reference_No__c' },
    { label: 'Transaction Status', fieldName: 'Transaction_Status__c' },
    { label: 'Source-Destination', fieldName: 'Source_Destination__c' },
    { label: 'BO Name', fieldName: 'Service_Provider_Name__c' },
    { label: 'Seat NoIssue Sub Type', fieldName: 'Seat_No__c' },
]

export default class CallPopup extends NavigationMixin(LightningElement) {
    @track objFields = [HFT_FIELD, Mobile_FIELD, Lan_FIELD, OrderUuid_FIELD,Remarks_FIELD];
    @track recId;
    @track callDet;
    @track isLoading;
    @track casesData;
    @track oritemsData;
    @track accountData;

    @track accntColumns = accFields;
    @track caseColumns = caseFields;
    @track tranColums = itemFields;
    @track selRec;
    //  @api mobile;
    @track showCaseCreation = false;
    @api recordId;
    @track hftName;
    @track isBusTransaction;

    handleRowAction(event) {
        window.console.log('event ====> ' + JSON.stringify(event.detail));
        let actionName = event.detail.row.Order_Id__c;
        const row = event.detail.row;
        this.selRec = row;

        redUrl({ 'oId': actionName })
            .then(result => {

                const urlWithParameters = result;
                console.log('urlWithParameters...' + urlWithParameters);
                /*  this[NavigationMixin.GenerateUrl]({
                      type: 'standard__webPage',
                      attributes: {
                          url: urlWithParameters
                      }
                  },false).then(generatedUrl => {
                      window.open(generatedUrl);
                  }); */

                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: urlWithParameters
                    }
                }, false);


                /*  },true).then(generatedUrl => {
                      window.open(generatedUrl);
                  });*/

            })
            .catch(error => {
                console.log('exception e..' + error);
                var errorMsg;
                if (Array.isArray(error.body)) {
                    console.log('Multiple Errors..')
                    this.errorMsg = error.body.map(e => e.message).join(', ');
                } else if (error.body !== undefined && typeof error.body.message === 'string') {
                    console.log('Single error')
                    this.errorMsg = error.body.message;
                }
            });

    }

    @wire(fetchCallDet, { clDetId: '$recordId' })
    wiredfetchCallDet({ error, data }) {
        console.log('mobile.....' + this.mobile);
        if (data) {
            console.log('wiredfetchCallDet...' + data);
            if (data !== undefined) {
                var orderUuid;
                this.callDet = JSON.parse(data);
                this.isLoading = true;
                if (this.callDet.calDet !== undefined && this.callDet.calDet.Id !== undefined) {
                    this.recId = this.callDet.calDet.Id;
                    console.log('this.recId....' + this.recId);
                    orderUuid = this.callDet.calDet.OrderUuid__c;
                    this.isBusTransaction = this.callDet.isBusTransaction;
                    console.log('isBusTransaction..' + this.isBusTransaction);

                }

                this.accountData = this.callDet.listAcc.map(record => Object.assign(
                    { "nameUrl": '/' + record.Id },
                    record));

                this.casesData = this.callDet.listCase.map(record => Object.assign(
                    { "csUrl": '/' + record.Id },
                    record));

                this.oritemsData = this.callDet.listOrd.map(record => Object.assign(
                    { "ordUrl": '/' + record.Id, "itemUrl": '/' + record.Id, "msr": record.Order_Id__c },
                    record));

                if (this.oritemsData.length === 0 && orderUuid !== undefined) {
                    this.oritemsData.push({ "Order_Id__c": orderUuid });
                }

                if (this.oritemsData.length > 0)
                    this.hftName = this.oritemsData[0].HFT__c;

                if (this.accountData.length === 0)
                    this.showCaseCreation = true;
            }

            else {
                console.log('Invalid Data Received..' + data);
            }

        }

        else if (error) {

            var errorMsg;
            if (Array.isArray(error.body)) {
                this.errorMsg = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errorMsg = error.body.message;
            }
            console.log('error while fetching data..' + this.errorMsg);
        }
    }

    openCaseCreationPage(event) {
        console.log('case creation page..');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/ChatCaseCreationPage?Source=callpopup'
            }
        }, false)

        /*
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/ChatCaseCreationPage'
            }
        }).then(generatedUrl => {
            console.log('open generatedUrl' + generatedUrl);
            window.open(generatedUrl);
        }); 

        window.open('/apex/ChatCaseCreationPage?Source=callpopup');*/
    }

}