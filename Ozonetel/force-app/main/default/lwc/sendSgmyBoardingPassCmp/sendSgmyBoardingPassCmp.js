/**
 * **********************************************************************************************************
 * Lightning Web Component   :   sendSgmyBoardingPassCmp
 * Includes                  :   sendSgmyBoardingPassCmp.html, sendSgmyBoardingPassCmp.js, sendSgmyBoardingPassCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      15 APR 2024
 * @description  This component is designed to offer agents the option to generate boarding passes for Singapore and Malaysia.
 * @JiraId       CRM-1649
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sendBoardingPass from '@salesforce/apex/sendSgmyBoardingPassCtrl.invokeBpardingPassApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Import reference to the object and the fields
import GET_EMAILID from "@salesforce/schema/Order_Items__c.Email__c";
const fields = [GET_EMAILID];

export default class SendSgmyBoardingPassCmp extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track disbaleEmailField;
    @track disbaleNewEmailField = false;
    @track isLoading;
    @track finalEmailValue;
    @track isSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields}) transaction;

    connectedCallback() {
        this.isLoading=true;
        console.log("====connectedCallback:recordId=====", this.recordId);
        this.sleep(1000).then(() => {
            console.log("====connectedCallback:recordId2=====", this.recordId);
            this.disbaleEmailField= true;
        });
    }

    sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    // Fetch the field values from the record
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

        sendBoardingPass({ordItemId:this.recordId, EmailId: this.finalEmailValue})
        .then((result) => {
            console.log(':::: ApexResponse::::'+JSON.stringify(result));
            if(result.isError){
                this.displayToastError(result.errorMessageToShow);
            }else if(result.boardingPassGenerated=== true && result.emailSent === true){
                this.displayToastSuccess();
            }else if(result.boardingPassGenerated === false){
                this.displayToastError('BoardingPass has not been generated for this transaction.');
            }
            this.closeAction();
        })
        .catch((error) => {
            console.error('Error: \n ', error);
        })
        .finally(()=>{
            this.isSpinner = false;
        });
    }

    displayToastError(msg) {
        const toastEvt = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }

    displayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'success',
            message: 'Success, Boarding Pass sent successfully.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}