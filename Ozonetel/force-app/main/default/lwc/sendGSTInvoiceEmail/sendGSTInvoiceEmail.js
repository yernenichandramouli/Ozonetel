import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import invokeGSTInvoice from '@salesforce/apex/GSTregulationSMSController.GetTicketDetails';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import reference to the object and the fields
import GET_EMAILID from "@salesforce/schema/Order_Items__c.Email__c";

const fields = [GET_EMAILID];
export default class EditRecordScreenAction extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track disbaleEmailField;
    @track disbaleNewEmailField = false;
    @track isLoading;
    @track finalEmailValue;
    @track isSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields}) transaction;

    connectedCallback(){
        console.log('::: Record ID will not populate ::::: ', this.recordId);
    }
    renderedCallback() {
        console.log('::: RederCallback RecordID ::::: ',this.recordId);
        console.log('::: TransactionData ::::: ',this.transaction.data);
        this.disbaleEmailField= true;
    }

    //4. Fetch the field values from the record
    get emailValue() {
        return getFieldValue(this.transaction.data, GET_EMAILID);
    }

    // Handle CheckBox Change
    handleCheckboxChange(event){
        this.disbaleNewEmailField=event.target.checked;
    }

    // close quick action
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // function to check invoke apex class
    handleSendClick(event){
        this.isSpinner = true;
        if(this.disbaleNewEmailField){
            this.finalEmailValue = this.template.querySelector('[data-newemail="newemail"]').value;
        }else{
            this.finalEmailValue = this.template.querySelector('[data-oldemail="oldemail"]').value;
        }
        console.log('::: finalEmailValue ::::: ',this.finalEmailValue);

        invokeGSTInvoice({ordItemId:this.recordId, EmailId: this.finalEmailValue})
        .then((result) => {
            if(result=='GST SMS has been sent successfully'){
                this.displayToastSuccess();
            }else if(result == 'No API Response' || result == 'Apex Error' || result == 'No Tin Found'){
                this.displayToastError();
            }
            this.closeAction();
            console.log(':::: Apex Response::::'+result);
        })
        .catch((error) => {
            console.error('Error: \n ', error);
        })
        .finally(()=>{
            this.isSpinner = false;
        });
    }

    displayToastError() {
        const toastEvt = new ShowToastEvent({
            title: 'Error',
            message: 'Invoice cannot be generated. Please get in touch with the BO directly.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }

    displayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'success',
            message: 'Success, GST Invoice sent successfully.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}