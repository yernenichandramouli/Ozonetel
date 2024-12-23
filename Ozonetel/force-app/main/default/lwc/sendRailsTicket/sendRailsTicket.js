import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import railsTicketCtrl from '@salesforce/apex/SendRailsTicketController.SendTicketDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GET_STATUS from "@salesforce/schema/Order_Items__c.Transaction_Status__c";
const fields = [GET_STATUS];

export default class SendRailsTicket extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields}) transaction;

    @api invoke() {
        var status = getFieldValue(this.transaction.data, GET_STATUS);
        if(status!='Booked'){
            this.displayToastWarning();
        }else{
            this.invokeRailsTicketCtrl();
        }
    }

    invokeRailsTicketCtrl(){
        this.displayToastInfo();
        railsTicketCtrl({ordItemId:this.recordId})
        .then((result) => {
            if(result.includes('successfully')){
                this.displayToastSuccess(result);
            }else if(result == 'No API Response' || result == 'Apex Error occured.' || result == 'Cannot send Ticket to this Transaction'){
                this.displayToastError();
            }
        })
        .catch((error) => {
            console.error('Error: \n ', error);
        });
    }

    displayToastWarning() {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Transaction is not booked. Please book the transaction and retry.',
            variant: 'Warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    displayToastInfo() {
        const event = new ShowToastEvent({
            title: 'Info',
            message: 'Sending...',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    displayToastSuccess(msg) {
        const event = new ShowToastEvent({
            title: 'success',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    displayToastError() {
        const toastEvt = new ShowToastEvent({
            title: 'Error',
            message: 'Failed to send ticket, Please contact your System Administrator.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }

}