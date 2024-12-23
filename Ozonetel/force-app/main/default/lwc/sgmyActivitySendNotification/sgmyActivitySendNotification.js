/**
 * **********************************************************************************************************
 * Lightning Web Component   :   sgmyActivitySendNotification
 * Includes                  :   sgmyActivitySendNotification.html, sgmyActivitySendNotification.js, sgmyActivitySendNotification.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2023-Oct-13
 * @description  This component "sgmyActivitySendNotification" is created to send ticket notification for SGMY Activites.
 * @JiraId       CRM-1502
 */

import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BOOKING_NUMBER from '@salesforce/schema/Activities__c.Booking_User_Mobile__c';
import BOOKING_EMAIL from '@salesforce/schema/Activities__c.Booking_User_Email__c';
import invokeNotification from '@salesforce/apex/sendSgmyActvtyNotificationCtrl.sendNotification';
const fields = [BOOKING_NUMBER, BOOKING_EMAIL];

export default class SgmyActivitySendNotification extends LightningElement {
    @api recordId;
    @track errorMessage;
    @track alternatePhone;
    @track alternateEmailId;
    @track bookingEmailId;
    @track bookingPhoneNumber;
    @track notificationType = 'None';
    @track isNotificationSent = false;
    @track successMessage;
    @track isError = false;
    @track showOtherNumber = false;
    @track showOtherEmail = false;
    @track isLoading = false;
    @track countryCode;

    get notificationTypeOptions() {
        return [
            { label: '--None--', value: 'None' },
            { label: 'Email', value: '2' },
            { label: 'Email & WhatsApp', value: '3' },
        ];
    }

    get countryCodeOptions(){
        return [{label:'--None--',value:'None'},{label:'MY (+60)',value:'60'},{label:'SG (+65)',value:'65'}, {label:'Ind (+91)',value:'91'}];
    }
    

    @wire(getRecord, { recordId: '$recordId', fields })
    activity;
    get bookingNumber() {
        return getFieldValue(this.activity.data, BOOKING_NUMBER);
    }
    get bookingEmail() {
        return getFieldValue(this.activity.data, BOOKING_EMAIL);
    }

    handleOnChange(event){
        if(event.target.dataset.fieldName!==undefined){
            if(event.target.dataset.fieldName==='send_other_phone'){
                this.showOtherNumber = event.target.checked;
            }
            if(event.target.dataset.fieldName==='send_other_Email'){
                this.showOtherEmail = event.target.checked;
            }
            if(event.target.dataset.fieldName==='notification_type'){
                this.notificationType= event.target.value;
            }
            if(event.target.dataset.fieldName==='country_code'){
                this.countryCode= event.target.value;
            }
        }
    }

    sendNotoifcation(event){
        var inp;
        this.isLoading = true;
        inp=this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element){
            if(element.name==="other phone"){
                this.alternatePhone=element.value;
            }
            if(element.name==="other email"){
                this.alternateEmailId=element.value;
            }

            if(element.name==="booking mobile"){
                this.bookingPhoneNumber=element.value;
            }
            
            if(element.name==="booking email"){
                this.bookingEmailId=element.value;
            }
        },this);

        console.log(':: mobileNumberTobeSent = '+this.countryCode+this.alternatePhone);
        if(this.stepSpecificValidations()){
            let mobileNumberTobeSent;
            let emailIdTobeSent;

            if(this.showOtherNumber){
                mobileNumberTobeSent=this.countryCode+this.alternatePhone;
                
            }else{
                mobileNumberTobeSent = this.bookingPhoneNumber;
            }

            if(this.showOtherEmail){
                emailIdTobeSent = this.alternateEmailId;
            }else{
                emailIdTobeSent = this.bookingEmailId;
            }

            invokeNotification({ activityId: this.recordId, mobileNumber: mobileNumberTobeSent, emailId: emailIdTobeSent, notifyThrough: this.notificationType})
            .then(response => {
                this.isLoading = false;
                if(response.isError){
                    this.isError = true;
                    this.errorMessage = response.DetailedMessage;
                }else{
                    this.isNotificationSent = true;
                    this.successMessage = response.statusMessage;
                }
                console.log('::: Success Response APex:::'+response.isError);
            }).catch(error => {
                this.isLoading = false;
                this.isError = true;
                this.errorMessage = error.body.message;
                console.log('::: Success Response APex Exception:::'+error.body.message);
            });
        }
        // this.isLoading = false;
    }

    stepSpecificValidations(){
        if(this.notificationType===undefined || this.notificationType===null || this.notificationType==='None'){
            this.errorMessage = 'Please select notfication type.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.showOtherNumber && (this.alternatePhone===undefined || this.alternatePhone===null || this.alternatePhone==='')){
            this.errorMessage = 'Please enter alternate mobile number.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.showOtherEmail && (this.alternateEmailId===undefined || this.alternateEmailId===null || this.alternateEmailId==='')){
            this.errorMessage = 'Please enter alternate EmailId.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        this.errorMessage ='';
        this.isError = false;
        // this.isLoading = false;
        return true;
    }

}