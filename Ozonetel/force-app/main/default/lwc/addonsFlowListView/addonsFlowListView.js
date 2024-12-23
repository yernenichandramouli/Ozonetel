/* eslint-disable no-script-url */
/* eslint-disable no-undef */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, track, wire } from "lwc";
import fetchAddons from "@salesforce/apex/AddOnsListViewOnTransaction.fetchAddons";
import checkIsCancellableStatus from "@salesforce/apex/AddOnsListViewOnTransaction.checkIsCancellableStatus";
import cancelSelectedAddons from "@salesforce/apex/AddOnsListViewOnTransaction.cancelSelectedAddons";
import { LightningNavigation } from 'lightning/navigation';


const columns = [
    {
        label: 'Id', fieldName: 'nameUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_top'
        } 
    },
    { label: 'Name', fieldName: 'Activity_Name__c' },
    { label: 'Type', fieldName: 'Activity_Type__c' },
    { label: 'Status', fieldName: 'Transaction_Status__c' },
    { label: 'VoucherId', fieldName: 'Voucher_Id__c' },
    { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
    { label: 'StartTime', fieldName: 'Service_Start_Time__c', type: 'date' },
    { label: 'Voucher Realization Date', fieldName: 'Voucher_Realization_Date__c', type: 'date' },
    { label: 'Activity Uuid', fieldName: 'Activity_uuid__c' }

];

const cancellableColumns = [
    { label: 'Id', fieldName: 'addOn.Name' },
    { label: 'Name', fieldName: 'addOn.Activity_Name__c' },
    { label: 'Type', fieldName: 'addOn.Activity_Type__c' },
    { label: 'Status', fieldName: 'addOn.Transaction_Status__c' },
    { label: 'VoucherId', fieldName: 'addOn.Voucher_Id__c' },
    { label: 'Amount', fieldName: 'addOn.Amount__c', type: 'currency' },
    { label: 'Activity Uuid', fieldName: 'addOn.Activity_uuid__c' },
    { label: 'IsCancellable', fieldName: 'isCancellable', type: 'boolean' },
    { label: 'Refundable Amount', fieldName: 'refundableAmnt', type: 'currency' },
    { label: 'Refundable Add', fieldName: 'addOn' },
    {label:'Cancellation Charges',fieldName:'cancellationCharges'}

];


export default class AddonsFlowListView extends LightningElement {
    @api sfrecordId;
    @track listAddonsData;
    @track listAddonsIsCanData;
    @track listcancelSeltedAddons = [];
    @track columns = columns;
    @track cancellableColumns = cancellableColumns;
    @track orItemEMail;
    @track orItemTin;
    @track showDefTable= false;
    @track showIsCanTable = false;
    @track showConfirmCancel;
    @track totalNoOfAddons;
    @track showErrMsg;
    @track notifType;
    @track notifMsg;
    @track isLoading;
    @track showNoRecMsg;

    @wire(fetchAddons, { recdId: '$sfrecordId' })
    wiredAddonsList({ error, data }) {
        if (data) {
            this.isLoading = true;
            this.listAddonsData = data.map(record => Object.assign(
                { "nameUrl": '/' + record.Id },                
                record
            ));

            this.totalNoOfAddons = this.listAddonsData.length;

            if (this.totalNoOfAddons > 0) {
                this.orItemEMail = this.listAddonsData[0].Order_Item__r.Email_Copy__c;
                this.orItemTin = this.listAddonsData[0].Order_Item__r.Order_Item_Reference_No__c;
                this.showDefTable = true;
                
            }
            else
                this.showNoRecMsg = true;

            for (let i = 0; i < this.totalNoOfAddons; i++) {

                if (this.listAddonsData[i].Transaction_Status__c === 'CONFIRMED' && this.listAddonsData[i].Order_Item__r.Business_Unit__c==='REDBUS_IN') {
                    this.showIsCanTable = true;
                }

            }

        }
        else if (error) {
            this.error = error;
            this.listAddonsData = undefined;
            this.showIsCanTable = false;
        }
        this.isLoading = false;
    }

    handleNavigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordid;
        if (recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Activities__c', // Replace with the actual object name
                    actionName: 'view'
                }
            });
        }
    }

    rowSelChangeEvent(event) {
        this.showConfirmCancel = false;
        this.listAddonsIsCanData.forEach(element => {
            if (element.addOn.Activity_uuid__c === event.currentTarget.dataset.id) {
                element.isSelect = event.target.checked;
            }

        });

        for (let i = 0; i < this.listAddonsIsCanData.length; i++) {

            if (this.listAddonsIsCanData[i].isSelect) {
                this.listcancelSeltedAddons.push(this.listAddonsIsCanData[i].addOn.Activity_uuid__c);
                this.showConfirmCancel = true;
            }

        }

    }

    selectDeselectAll(event) {
        if (event.target.checked) {
            this.listAddonsIsCanData.forEach(element => {
                if (element.isCancellable) {
                    element.isSelect = true;
                    this.showConfirmCancel = true;
                }

            });
        }
        else {
            this.listAddonsIsCanData.forEach(element => {
                if (element.isCancellable) {
                    element.isSelect = false;
                }
                this.showConfirmCancel = false;
            });
        }

    }

    checkIsCancellable(event) {
        this.isLoading = true;
        this.showDefTable = false;
        this.showIsCanTable = true;
        this.showErrMsg = false;
        console.log('this.isLoading.before.' + this.isLoading);
        checkIsCancellableStatus({ listAllAddOns: this.listAddonsData })
            .then(result => {



                this.listAddonsIsCanData = result;
                this.showIsCanTable = false;
                this.showConfirmCancel = false;
                this.isLoading = false;

            })
            .catch(error => {

                var errorMsg;
                if (Array.isArray(error.body)) {
                    this.errorMsg = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMsg = error.body.message;
                }
                console.log('proper error--->' + this.errorMsg);
               this.isLoading = false;
                this.showErrMsg = true;
                this.notifType = 'error';
                this.notifMsg = this.errorMsg;
            });
        console.log('this.isLoading.before.' + this.isLoading);
     //   this.isLoading = false;
        console.log('this.isLoading.end.' + this.isLoading);
    }

    cancelseltAddons(event) {
        this.isLoading = true;
        this.showErrMsg = false; 
        this.listcancelSeltedAddons = [];
        console.log('before..' + this.listcancelSeltedAddons)
        for (let i = 0; i < this.listAddonsIsCanData.length; i++) {

            if (this.listAddonsIsCanData[i].isSelect) {
                this.listcancelSeltedAddons.push(this.listAddonsIsCanData[i].addOn.Activity_uuid__c);
            }


        }
        console.log('after..' + this.listcancelSeltedAddons)
        cancelSelectedAddons({ listSelAddonUuid: this.listcancelSeltedAddons, toatlAddCnt: this.totalNoOfAddons, email: this.orItemEMail, tin: this.orItemTin })
            .then(result => {
                console.log('canclSeltAddonresult--->' + result);
                this.showConfirmCancel = false;
                this.showErrMsg = true;
                this.notifType = 'success';
                this.notifMsg = result;
                this.isLoading = false;

            })
            .catch(error => {
                console.log('canclSeltAddon error' + JSON.stringify(error.body));
                var errorMsg;
                if (Array.isArray(error.body)) {
                    this.errorMsg = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMsg = error.body.message;
                }

                this.showConfirmCancel = true;
                this.showErrMsg = true;
                this.notifType = 'error';
                this.notifMsg = this.errorMsg;
                this.isLoading = false;

            });

    }

}