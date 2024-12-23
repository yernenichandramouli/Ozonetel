/* eslint-disable no-script-url */
/* eslint-disable no-undef */
/* eslint-disable no-empty */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
  'Activities__c.Activity_Name__c',
  'Activities__c.Activity_Type__c',
  'Activities__c.Activity_uuid__c',
  'Activities__c.Voucher_Id__c',
  'Activities__c.Amount__c',
  'Activities__c.Discount_Value__c',
  'Activities__c.Voucher_Realization_Date__c',
  'Activities__c.No_of_vouchers__c',
  'Activities__c.Booking_user_Name__c',
  'Activities__c.Booking_User_Email__c',
  'Activities__c.Customer_Name__c',
  'Activities__c.Customer_Mobile_No__c',
  'Activities__c.Customer_Email_id__c',
  'Activities__c.Booking_User_Mobile__c',
  'Activities__c.Booking_UserUserid__c',
  'Activities__c.Date_Of_Purchase__c',
  'Activities__c.PNRs__c',
  'Activities__c.Order_Id__c',
  'Activities__c.No_of_Children__c',
  'Activities__c.Booking_Id__c',
  'Activities__c.No_of_Adults__c',
  'Activities__c.Sales_Channel__c',
  'Activities__c.Service_Provider_Id__c',
  'Activities__c.Service_Provider_Name__c',
  'Activities__c.OrderUuid__c',
  'Activities__c.Transaction_Status__c',
  'Activities__c.Order_Item_id__c',
  'Activities__c.Order_Item__c',
  'Activities__c.Order_Item_Uuid__c'

];

export default class addonRecordViewForm extends LightningElement {

  @api sfrecordId;
  @track recDetails;
  @track showform = false;
  @track finalReUrl = '';


  @wire(getRecord, { recordId: '$sfrecordId', fields: FIELDS })
  wiredrecord({ error, data }) {

    if (data !== undefined) {
      console.log('--recordId--' + this.sfrecordId);
      this.recDetails = data;
      this.showform = true;
      var transId = this.recDetails.fields.Order_Item__c.value;
      var transUuid = this.recDetails.fields.Order_Item_Uuid__c.value
      var redircedValue = '';

      if (transId !== null) {
        this.redircedValue = '/' + transId;
        this.finalReUrl = this.finalReUrl + this.redircedValue + "";
        console.log('::FinaltransId URL '+this.finalReUrl);
      }

      else if (transUuid !== null) {
        this.redircedValue = '/apex/SyncPollingPage?id=' + transUuid;
        this.finalReUrl = this.finalReUrl + this.redircedValue + "";
        console.log('::FinaltransUuid URL '+this.finalReUrl);
      }
    }
    else if (error) {
      this.recDetails = undefined;
    }

  }

}