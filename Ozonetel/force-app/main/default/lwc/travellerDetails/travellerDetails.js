import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TRAVELLERDETAIL_FIELD from "@salesforce/schema/Order_Items__c.Traveller_Details__c";
import JOURNEYDETAIL_FIELD from "@salesforce/schema/Order_Items__c.Journey_Details__c";
import TRAINDETAIL_FIELD from "@salesforce/schema/Order_Items__c.Train_Details__c";
import CUSTOMERPRICEBK_FIELD from "@salesforce/schema/Order_Items__c.Customer_Price_Breakup__c";
import TRANSACTIONSTATUS_FIELD from "@salesforce/schema/Order_Items__c.Transaction_Status__c";
import getPassengerDetailsLM from '@salesforce/apex/TrainDetails.GetTrainDetails';



const fields = [TRAVELLERDETAIL_FIELD, JOURNEYDETAIL_FIELD, TRAINDETAIL_FIELD, CUSTOMERPRICEBK_FIELD, TRANSACTIONSTATUS_FIELD];

export default class TravellerDetails extends LightningElement {

    @api recordId;
    @track travellerList = [];
    @track journeyDetails = [];
    @track trainDetails = [];
    @track customerPriceBreakup = [];
    @track transaction;
    @track tranStatus;
    @track tdl;
    activeSections = ['A', 'B', 'C']
    @track showBlock = false;
    @track apiRespBody;
    passDetails = [];
    @track showSpinner = false;
    @wire(getRecord, { recordId: "$recordId", fields }) transaction;

    showDetails() {
        this.showSpinner = true;
        console.log('callshow');
        console.log('get-->' + this.transaction.data.fields.Traveller_Details__c.value);
        console.log('s--->' + this.transaction.data.fields.Transaction_Status__c.value);
        if (this.transaction.data.fields.Transaction_Status__c.value != 'GFT - Payment Debited but Ticket not Generated') {
            this.tranStatus = true;
        }
        console.log('st-->' + this.tranStatus)
        var trd = JSON.stringify(this.transaction.data.fields.Traveller_Details__c.value).replace(/\\/g, '')
        trd = trd.slice(1, -1)
        this.travellerList = JSON.parse(trd);

        var jd = JSON.stringify(this.transaction.data.fields.Journey_Details__c.value).replace(/\\/g, '');
        jd = jd.slice(1, -1)
        this.journeyDetails = JSON.parse(this.transaction.data.fields.Journey_Details__c.value);

        var td = JSON.stringify(this.transaction.data.fields.Train_Details__c.value).replace(/\\/g, '');
        td = td.slice(1, -1);
        this.trainDetails = JSON.parse(td);

        var cpb = JSON.stringify(this.transaction.data.fields.Customer_Price_Breakup__c.value).replace(/\\/g, '');
        cpb = cpb.slice(1, -1);
        this.customerPriceBreakup = JSON.parse(cpb);


        console.log('travellerList-->' + this.travellerList);

        getPassengerDetailsLM({ ordItemId: this.recordId, source: 'Transaction' }).then(data => {
            console.log('insdied get 2');
            if (data) {
                this.apiRespBody = JSON.parse(data);
                console.log('this.apiRespBody 3-->' + JSON.stringify(data));
                console.log('pnrNo->' + this.apiRespBody.pnrNo);
                this.passDetails = this.apiRespBody.passengerList;
                console.log('passDetails-->' + JSON.stringify(this.passDetails));
                this.showBlock = true;
                this.showSpinner = false;
            }
        }).catch(error => {

            console.log('error' + error);
        })
    }

    /*  handleClick(event) {
          console.log('handleClick here');
          this.fetchLoad = true;
          getPassengerDetailsLM({ ordItemId: this.recordId, source: 'Transaction' }).then(data => {
              console.log('insdied get');
              if (data) {
                  this.apiRespBody = data;
              }
          }
      }*/

    /*  get travellerDetail() {
          console.log('calling');
          /*  this.tdl = '[{ "travellerDetails": { "title": "Mr.", "seniorCitizenApplicable": false, "passengerICardFlag": false, "nationality": "INDIAN", "name": "Sumit", "gender": "MALE", "foodPreference": "", "berthPreference": "SL", "age": 31 }, "passengerNetFare": 100, "name": "1", "customerPriceBreakUp": [], "currentSeatDetails": { "currentStatusIndex": 1, "currentStatus": "CNF", "currentCoachId": "S7", "currentBerthNo": "65", "currentBerthCode": "LB", "currentBerthChoice": "LB" }, "bookingSeatDetails": { "bookingStatusIndex": 1, "bookingStatus": "CNF", "bookingCoachId": "S7", "bookingBerthNo": "65", "bookingBerthCode": "LB", "bookingBerthChoice": "LB" } }, { "travellerDetails": { "title": "Mr.", "seniorCitizenApplicable": false, "passengerICardFlag": false, "nationality": "INDIAN", "name": "Sumit", "gender": "MALE", "foodPreference": "", "berthPreference": "SL", "age": 31 }, "passengerNetFare": 10, "name": "2", "customerPriceBreakUp": [], "currentSeatDetails": { "currentStatusIndex": 2, "currentStatus": "RAC", "currentCoachId": "S7", "currentBerthNo": "65", "currentBerthCode": "LB", "currentBerthChoice": "LB" }, "bookingSeatDetails": { "bookingStatusIndex": 1, "bookingStatus": "CNF", "bookingCoachId": "S7", "bookingBerthNo": "65", "bookingBerthCode": "LB", "bookingBerthChoice": "LB" } } ]';
            console.log('tdl-->' + this.tdl);
         
          var result;
          if (this.transaction.data != null) {
              result = JSON.parse(JSON.stringify(this.transaction.data));
              console.log('result-->' + result);
              this.travellerList = result.Traveller_Details__c;
              console.log('trve-->' + this.travellerList);
          }*/
    /*   return getFieldValue(this.transaction.data, TRAVELLERDETAIL_FIELD);
   }*/
}