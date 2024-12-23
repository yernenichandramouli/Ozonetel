import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TICKET_EMAIL from '@salesforce/schema/Order_Items__c.Email__c';
import TICKET_PHONE from '@salesforce/schema/Order_Items__c.Mobile__c';
import senRailsTicketCtrl from '@salesforce/apex/SendRailsTicketController.SendTicketDetails';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const fields = [TICKET_EMAIL, TICKET_PHONE];

export default class SendRailTicketCmp extends LightningElement {
    @api recordId;
    @track otherPhoneNo;
    @track otherEmailId;
    @track isPhoneChanged = false;
    @track isEmailChanged = false;
    @track btnDisable=false;
    @track isSendrailTicket=false;
    @track fetchLoad =false;


    @wire(getRecord, { recordId: '$recordId', fields })
    transaction;
    get fetchEmail() {
        return getFieldValue(this.transaction.data, TICKET_EMAIL);
    }
    get fetchphNumber() {
        return getFieldValue(this.transaction.data, TICKET_PHONE);
    }

    handlePhoneChange(event) {
        this.isPhoneChanged = event.target.checked;        
        console.log("handlePhoneChange: " +  this.isPhoneChanged);
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleEmailChange(event) {
        this.isEmailChanged = event.target.checked;        
        console.log("isEmailChanged: " + this.isEmailChanged);
    }

    onBtnClickSendTicket(event){
     console.log('>>>>>>btn clck>>>>');
   
if(this.isEmailChanged==true){
    console.log('--47 email--');
    this.fetchLoad = false;
    let emailId=this.template.querySelector(".email");
    let emailVal=emailId.value;
    
   
   
    console.log('-- emailId--'+emailId);
    console.log('-emailVal--'+emailVal);

    
    console.log('--57-');
    const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  console.log('---his.otherEmailId--'+this.otherEmailId)
    this.otherEmailId=emailVal;
     if(emailVal.match(emailRegex)){
        emailId.setCustomValidity("");
         this.fetchLoad = false;
         this.isSendrailTicket=true;
      console.log('---if---')
     }else{
        console.log('---elase---')

        this.isSendrailTicket=false;
        this.fetchLoad = false;
        emailId.setCustomValidity("Please enter valid email");
     }
     emailId.reportValidity();

    

  }

  if(this.isPhoneChanged==true){
    let phoneNbr=this.template.querySelector(".phone");
    let phoneVal=phoneNbr.value;
    this.otherPhoneNo=phoneVal;

     const phoneRegex=/^\d{10}$/;

     if( this.otherPhoneNo.match(phoneRegex)){
        phoneNbr.setCustomValidity("");
        this.fetchLoad = false;
         this.isSendrailTicket=true;

     }else{
        this.isSendrailTicket=false;
        this.fetchLoad = false;
        phoneNbr.setCustomValidity("Please enter valid phone");
     }
     phoneNbr.reportValidity();

    
} 

    if(this.isPhoneChanged==true && this.isEmailChanged==true && ((this.otherPhoneNo==undefined || this.otherPhoneNo=='')  || (this.otherEmailId==undefined || this.otherEmailId==''))){
       console.log('---12-1---');
        this.isSendrailTicket=false;
        this.fetchLoad = false;;
      
    }else if(this.isPhoneChanged==true && this.isEmailChanged==false){
          this.otherEmailId='';
    }else if(this.isPhoneChanged==false && this.isEmailChanged==true){
          this.otherPhoneNo='';
    }

    if(this.isPhoneChanged==false && this.isEmailChanged==false){
        this.isSendrailTicket=true;
        this.otherPhoneNo='';
        this.otherEmailId='';
    }

    console.log('----127---'+this.isSendrailTicket);

    if(this.isSendrailTicket){
        console.log('----127---');
        this.fetchLoad =true;
     senRailsTicketCtrl({ordItemId:this.recordId,otherPhoneno:this.otherPhoneNo,isOtherPhone:this.isPhoneChanged,otherEmail:this.otherEmailId,isOtherEmail:this.isEmailChanged})
     .then((result) => {
         if(result.includes('successfully')){
            this.fetchLoad = false;
             this.displayToastSuccess(result);
         }else if(result == 'No API Response' || result == 'Apex Error occured.' || result == 'Not Booked or Cannot send Ticket to this Transaction'){
            this.fetchLoad = false;
            this.displayToastError();
         }
     })
     .catch((error) => {
        this.fetchLoad = false;
         console.error('Error: \n ', error);
     });
    console.log('---otherPhoneno--'+ this.otherPhoneNo+'---otherEmailId--'+this.otherEmailId);
      }
    }

    displayToastSuccess(msg) {
        const event = new ShowToastEvent({
            title: 'success',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.btnDisable=true;
        this.dispatchEvent(event);
    }

    displayToastError() {
        const toastEvt = new ShowToastEvent({
            title: 'Error',
            message: 'Failed to send ticket, Please contact your System Administrator.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.btnDisable=true;
        this.dispatchEvent(toastEvt);
    }
    
}