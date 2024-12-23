/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable no-undef */
import { LightningElement, track, wire, api } from "lwc";
import Activity from './activity';
import getActivityDetails from "@salesforce/apex/ActivityDetails.getActivityDetails";
import getActivityAddOnDetails from "@salesforce/apex/ActivityDetails.getActivityAddOnDetails";
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Activities__c.Activity_uuid__c',
    'Activities__c.Transaction_Status__c',
    'Activities__c.Total_Customer_Payable__c',
    'Activities__c.Order_Item__c'
];

export default class ActivityDetails extends LightningElement {
    @track options;
    @track activitiesInfo;
    @track mockJson2;
    @track bShowModal = false;
    @track activityData;
    @track mockJson = '{ "success": true, "data": { "tnc": "<ul><li>All offers are inclusive of taxes &amp; service charges</li><li><em>All weekend deals will also be ", "thingsToCarry": [], "tips": [], "inclusions": [ "All prices are inclusive of taxes and service charge" ], "exclusions": [ "Tip and gratuities (optional)", "Offer may not be applicable on public holidays, gazetted holidays and black out days (New Years eve, Christmas, etc) " ], "howToRedeem": [ "You can present either a printed or a mobile voucher for this experience.", "Voucher is valid only on the date and time mentioned on the voucher. ", "In case there is a validity date mentioned on the voucher, then your voucher would be valid till the aforementioned date.\r\n\r\n" ], "schedule": [], "docsToCarry": [] } }';
    @track tnc;
    @track inclusions;
    @track exclusions;
    @track thingsToCarry;
    @track tips;
    @track howToRedeem;
    @track actLoad = false;
    @track inclusionsList = [];
    @track exclusionsList = [];
    @track howToRedeemList = [];
    @api sfrecordId2;
    @track actUUID;
    @track addOn = false;
    @track onlyActivity = false;
    @api recIdL;
    @wire(getRecord, { recordId: '$sfrecordId2', fields: FIELDS })
    wiredrecord({ error, data }) {
        console.log('data-->' + data);
        console.log('--wiered call--2' + this.sfrecordId2);
        if (data !== undefined) {
            console.log('--recordId--2' + this.sfrecordId2);
            console.log('data-->' + data);
            this.actUUID = data.fields.Activity_uuid__c.value;
            console.log('act uuid->' + this.actUUID);
            console.log('order Itme->' + data.fields.Order_Item__c.value);
            if (data.fields.Order_Item__c.value != null) {
                this.addOn = true;
                console.log('addOn->' + this.addOn);
            } else {
                this.onlyActivity = true;
            }
        }
    }

    @wire(getRecord, { recordId: '$recIdL', fields: FIELDS })
    getRequisition({ error, data }) {
        console.log('out side -->' + data);
        if (data) {
            console.log('data-->' + JSON.stringify(data));
            console.log('insdie' + data.fields.Activity_uuid__c.value);
            if (data.fields.Activity_uuid__c.value != null) {
                this.actUUID = data.fields.Activity_uuid__c.value;
                this.getActivityInfo();
            }
            // this.requisition = data;
        }
    }
    closeModal() {
        this.closeQuickAction();
        this.bShowModal = false;
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    /*   connectedCallback() {
           console.log('act-->' + this.onlyActivity);
           console.log('recIdL-->' + this.recIdL);
           console.log('recIddd--->' + JSON.stringify(this.recIddd));
           this.actUUID = this.recIdL.fields.Activity_uuid__c.value;
           console.log('act id-->' + this.actUUID);
           if (this.onlyActivity === true) {
               this.getActivityInfo();
           }
       }*/

    getActivityInfo() {
        // let data_list = [];
        // eslint-disable-next-line no-console
        console.log('coming here -->' + this.sfrecordId2);
        this.actLoad = true;
        getActivityDetails({ actId: this.actUUID })
            .then(result => {
                console.log('dfsdfs-->' + this.actUUID);
                // console.log('rec id-->' + this.activityT.data.fields.Transaction_Status__c.value);
                this.inclusionsList = [];
                this.exclusionsList = [];
                this.howToRedeemList = [];
                console.log('type of result..' + result);
                this.activityData = JSON.parse(result);
                this.activityData = JSON.parse(this.activityData);
                console.log('type of act..' + typeof this.activityData);
                // eslint-disable-next-line no-console
                console.log('data-->' + this.activityData);
                // eslint-disable-next-line no-console
                console.log(this.activityData.data);
                console.log('loop-->' + this.activityData.data.tnc);
                this.tnc = this.activityData.data.tnc;
                this.thingsToCarry = this.activityData.data.thingsToCarry;
                this.tips = this.activityData.data.tips;
                for (let v of Object.values(this.activityData.data.inclusions)) {
                    this.inclusionsList.push(v);
                }
                for (let v of Object.values(this.activityData.data.exclusions)) {
                    this.exclusionsList.push(v);
                }
                for (let v of Object.values(this.activityData.data.howToRedeem)) {
                    this.howToRedeemList.push(v);
                }

                this.bShowModal = true;
                this.actLoad = false;
            })
            .catch(error => {
                this.actLoad = false;
                // eslint-disable-next-line no-console
                console.log('exception e..' + error);

            });
    }
    getActivityAddOnInfo(event) {
        this.actLoad = true;
        getActivityAddOnDetails({ actId: this.actUUID })
            .then(result => {
                console.log('dfsdfs-->' + this.actUUID);
                console.log('result-->' + result);
                this.activityData = JSON.parse(result);
                this.activityData = JSON.parse(this.activityData);
                console.log('type of act..' + typeof this.activityData);
                console.log('success-->' + this.activityData.success);
                console.log('data json-->' + JSON.stringify(this.activityData.data[0]));
                console.log('data-->' + this.activityData.data[0].viewDetails.exclusions);
                this.inclusionsList = [];
                this.exclusionsList = [];
                this.howToRedeemList = [];
                this.tnc = this.activityData.data[0].viewDetails.tnc;
                this.thingsToCarry = this.activityData.data[0].viewDetails.thingsToCarry;
                this.tips = this.activityData.data[0].viewDetails.tips;
                for (let v of Object.values(this.activityData.data[0].viewDetails.inclusions)) {
                    this.inclusionsList.push(v);
                }
                for (let v of Object.values(this.activityData.data[0].viewDetails.exclusions)) {
                    this.exclusionsList.push(v);
                }
                for (let v of Object.values(this.activityData.data[0].viewDetails.howToRedeem)) {
                    this.howToRedeemList.push(v);
                }

                this.bShowModal = true;
                this.actLoad = false;
            }).catch(error => {
                this.actLoad = false;
                // eslint-disable-next-line no-console
                console.log('exception e..' + error);

            });
    }

}