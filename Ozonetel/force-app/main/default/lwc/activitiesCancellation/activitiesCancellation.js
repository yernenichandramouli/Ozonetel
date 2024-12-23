/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
// eslint-disable-next-line no-unused-vars
import { LightningElement, api, track, wire } from "lwc";
import isCancellable from "@salesforce/apex/ExperiencesCancellation.isCancellable";
import cancelActivity from "@salesforce/apex/ExperiencesCancellation.cancelActivity";
//import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from "@salesforce/apex";

const FIELDS = [
  'Activities__c.Activity_uuid__c',
  'Activities__c.Transaction_Status__c',
  'Activities__c.Total_Customer_Payable__c',
];


export default class ActivitiesCancellation extends LightningElement {
  @api greeting;
  @track clickedButtonLabel;
  @track isCanData;
  @track cancelledData;
  @api recordId;
  @api totalAmt;
  @api discount;
  @api refundAmt;
  @api cancellationCharges;
  @track isActivityCancellable = false;
  @api finalRefAmount = 0.0;
  @api baseFare;
  @api taxes;
  @api totalTktFare;
  @api amntPaidByCust;
  @api walletOfferAmt;
  @track isLoaded = false;
  @track showAnyMsg = false;
  @track notificationType;
  @track notificationMessage;
  @api isConfirmedTicket;
  @track showInitiateCancelBtn=true;
  @track showCancelTicketBtn=false;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  activity;

  get transStatus() {

   /* console.log('tsatus..' + this.activity);
    console.log('tsatus..da' + this.activity.data);
    console.log('check' + (this.activity.data !== undefined));
    return this.activity.data.fields.Transaction_Status__c.value;*/
    if (this.activity.data !== undefined && this.activity.data.fields !== undefined) {
      var traStatus = this.activity.data.fields.Transaction_Status__c.value;
      if (traStatus === 'CANCELLATION_SUCCESSFUL') {
        this.showInitiateCancelBtn = false;
        return 'This Ticket is Already Cancelled..!';

      }

      else if (traStatus === 'CONFIRMATION_FAILURE' || traStatus === 'DISCARDED' || traStatus === 'TENTATIVE_SUCCESSFUL') {
        this.showInitiateCancelBtn = false;
        return 'This Activity is Not Booked..Hence, You can not Cancel this Activity..!';
      }

    }
    return '';
  }

  checkTicketStatus(event) {
    console.log("checkTicketStatus..called");
    this.showAnyMsg = false;
    this.notificationType = undefined;
    this.notificationMessage = undefined;
    this.isLoaded = true;
    this.clickedButtonLabel = event.target.label;
    // eslint-disable-next-line no-console
    isCancellable({ recdId: this.recordId })
      .then(result => {
        
        this.isCanData = JSON.parse(JSON.parse(result));
        if (this.isCanData !== undefined && this.isCanData.success) {
          console.log("inside...");
          this.isActivityCancellable = this.isCanData.data.isCancellable;
          if (this.isActivityCancellable) {
            this.showInitiateCancelBtn = false;
            this.showCancelTicketBtn = true;
            this.isLoaded = false;
            this.discount = this.isCanData.data.paidPriceBreakup.discount.toFixed(2);
            this.totalTktFare = (parseFloat(this.isCanData.data.paidPriceBreakup.baseFare) + parseFloat(this.isCanData.data.paidPriceBreakup.taxes)).toFixed(2);
            this.baseFare = parseFloat(this.isCanData.data.paidPriceBreakup.baseFare).toFixed(2);
            this.taxes = this.isCanData.data.paidPriceBreakup.taxes.toFixed(2);
            this.amntPaidByCust = (this.totalTktFare - this.discount).toFixed(2);
            this.walletOfferAmt = this.isCanData.data.paidPriceBreakup.walletOffer.toFixed(2);
            var kk;
            for (kk of this.isCanData.data.refundDistribution.backToSource) {
              this.finalRefAmount = parseFloat(this.finalRefAmount) + parseFloat(kk.refundAmount.amount);
            }
            this.finalRefAmount = this.finalRefAmount.toFixed(2);
            this.cancellationCharges = (parseFloat(this.amntPaidByCust) - this.finalRefAmount - this.walletOfferAmt).toFixed(2);
          }
          else {
            this.showAnyMsg = true;
            this.notificationType = "error";
            this.notificationMessage = "Sorry!As per the cancellation policy this Activity can not be cancellable";

          }

        }
        else {
          this.isLoaded = false;
          this.showInitiateCancelBtn= true;
          this.showAnyMsg = true;
          this.notificationType = "error";
          this.notificationMessage = this.isCanData.error + "\n Detailed Error Message -" + this.isCanData.cause.cause.data.error_message;
        }
        this.isLoaded = false;
      })
      .catch(error => {
        console.log('iscancellable error'+JSON.stringify(error.body));
        var errorMsg;
        if (Array.isArray(error.body)) {
          this.errorMsg = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
          this.errorMsg = error.body.message;
        }
        console.log('Detailed error..' + this.errorMsg);
        this.showInitiateCancelBtn = true;
        this.isLoaded = false;
        this.showAnyMsg = true;
        this.notificationType = "error";
        this.notificationMessage = this.errorMsg;
      });

  }
  /*
  @wire(cancelActivity)
  wireCancelTicket({ error, data }) {
    if (data) {
      console.log("cancel data..." + data);
    } else if (error) {
      console.log("cancel error data..." + error);
    }
  }
  wireCancelTicketResult;

  @wire(cancelActivity, { recId: "a0t5D000001aMhK" })
  wireCancelTicket(result) {
    this.wireCancelTicketResult = result;
    console.log("result.." + result);
    if (result.data) {
      console.log("cancel data..." + result.data);
    } else if (result.error) {
      console.log("cancel error data..." + result.error);
    }
  }
  attemtCancellation() {
    console.log("attempt cancellation..");
    
    return refreshApex(this.wireCancelTicketResult);
  }*/

  cancelTransaction(event) {
    console.log("cancelTransaction..called" + event);
    this.showAnyMsg = false;
    this.notificationType = undefined;
    this.notificationMessage = undefined;
    this.isLoaded = true;
    // eslint-disable-next-line no-console
    cancelActivity({ recId: this.recordId })
      .then(result => {
        // eslint-disable-next-line no-unused-vars
        console.log('result type..'+typeof result);
        console.log('this.cancelledData..before' + result);
        this.cancelledData = JSON.parse(JSON.parse(result));
        console.log('this.cancelledData..data..' + typeof this.cancelledData+'data..'+this.cancelledData);
        console.log('IsNul..' + (this.cancelledData !== undefined));
       console.log('this.cancelledData..' + this.cancelledData.success);
       console.log("cancelResp..." + JSON.stringify(this.cancelledData));
        if (this.cancelledData !== undefined && this.cancelledData.success) {
          console.log(
            "inside..cancelActivity." + this.cancelledData.data.status
          );
          this.showCancelTicketBtn = false;
          this.isLoaded = false;
          this.showAnyMsg = true;
          this.notificationType = "success";
          this.notificationMessage = this.cancelledData.data.displayMessage + "\n Total Refunded Amount is - Rs." + this.cancelledData.data.refundAmount;
        }

        else if (this.cancelledData !== undefined && !this.cancelledData.success) {
          console.log('inside can fail');
          this.isLoaded = false;
          this.showAnyMsg = true;
          this.notificationType = "error";
          this.notificationMessage = this.cancelledData.error + "\n Detailed Error Message -" + this.isCanData.cause.error;

        }
      })
      .catch(error => {
        console.log('exception e..' + error);
        var errorMsg;
        if (Array.isArray(error.body)) {
          console.log('Multiple Errors..')
          this.errorMsg = error.body.map(e => e.message).join(', ');
        } else if (error.body!==undefined && typeof error.body.message === 'string') {
          console.log('Single error')
          this.errorMsg = error.body.message;
        }
        this.isLoaded = false;
        this.showAnyMsg = true;
        this.notificationType = "error";
        this.notificationMessage ='An Error occured -'+this.errorMsg;

      });
    console.log("cancelActivity end");
  }

  
  get notifcationThemeClass() {
    return (
      "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_" +
      this.notificationType
    );
  }

  get notifcationContainerClass() {
    return (
      "slds-icon_container slds-icon-utility-" +
      this.notificationType +
      " slds-m-right_x-small"
    );
  }

  get iconClass() {
    return (
      "/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#" +this.notificationType
    );
  }

}