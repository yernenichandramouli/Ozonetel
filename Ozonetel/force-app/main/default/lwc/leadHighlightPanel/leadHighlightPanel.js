import { LightningElement,api,wire,track } from 'lwc';
import GetDetails from '@salesforce/apex/HighLightPanelDataGet.LeadData';

export default class LeadHighlightPanel extends LightningElement {
    @api recordId;
    @track source='';destination='';CusUrl='';
    //@track firctQ;
    //@track thirdQ;
    @track dojStart;
    @track dojEnd;
    @wire(GetDetails, {lId:'$recordId' })
    wireMethod({error,data}){
        if(data){
            this.source=data.SrcCityName__c;
            this.destination=data.DestCityName__c;
            this.dojStart=data.DOJStart__c;
            this.dojEnd=data.DOJEnd__c;


        
        }
    }
}