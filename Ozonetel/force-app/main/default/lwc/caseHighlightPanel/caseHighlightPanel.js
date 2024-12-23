import { LightningElement, api,wire,track } from 'lwc';
import GetDetails from '@salesforce/apex/HighLightPanelDataGet.caseData';

export default class CaseHighlightPanel extends LightningElement {
    @api recordId;
    @track amount =0;refundAmount = 0;status='';requireCallback=false;
    @track showHft=false;
    @track hft='';
    @track showInstantBolt=false;
    @track instantBolt='';
    time=0;
    @wire(GetDetails, {csId:'$recordId' })
    wireMethod({error,data}){
        if(data){
            this.amount = data.Total_Ticket_Amount__c;
            this.refundAmount = data.Refund_Amount__c;
            this.status = data.Refund_Status__c;
            this.requireCallback = data.Does_Customer_Require_CallBack__c;
            this.time= data.CallBack_Requested_Time__c;
            if(data.Case_Category__c!=null && data.Case_Category__c !=''){
              this.showInstantBolt=true;
              this.instantBolt=data.Case_Category__c;
            }
            if(data.HFT__c!=null && data.HFT__c !='')
            this.showHft = true;
            this.hft=data.HFT__c;
        }

       
    }
}