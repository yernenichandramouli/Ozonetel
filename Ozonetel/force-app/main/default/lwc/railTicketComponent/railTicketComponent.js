import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TICKET_EMAIL from '@salesforce/schema/Order_Items__c.Email__c';
import TICKET_PHONE from '@salesforce/schema/Order_Items__c.Mobile__c';
import railsTicketCtrl from '@salesforce/apex/SendRailsTicketController.SendTicketDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const fields = [TICKET_EMAIL, TICKET_PHONE];

export default class RailTicketComponent extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    transaction;
    get fetchEmail() {
        return getFieldValue(this.transaction.data, TICKET_EMAIL);
    }
    get fetchphNumber() {
        return getFieldValue(this.transaction.data, TICKET_PHONE);
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