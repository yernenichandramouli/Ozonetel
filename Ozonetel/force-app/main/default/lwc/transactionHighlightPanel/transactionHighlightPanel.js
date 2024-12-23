import { LightningElement, api,track,wire } from 'lwc';
import GetDetails from '@salesforce/apex/HighLightPanelDataGet.transactionData';
import getBoltBoId from '@salesforce/apex/HighLightPanelDataGet.validateBOIds';
import getStreakId from '@salesforce/apex/HighLightPanelDataGet.StreaksTripReward';
import connectedServiceData from '@salesforce/apex/HighLightPanelDataGet.fetchConnectedTransaction';
import getRtcsBos from '@salesforce/label/c.RTC_BO_IDS';
import { NavigationMixin } from 'lightning/navigation';



export default class TransactionHighlightPanel extends NavigationMixin(LightningElement) {
    @api recordId;
    @track amount =0;refundAmount = 0;status='';cancelDate;
    @track currency ='';
    @track showHft = false;
    @track showZqp = false;
    @track hft='';
    @track isBolt=false;
    @track busPassrltdTrans=false;
    @track busPassrltd='';
    @track zqpTimeDiff;
    @track isBoltBoId = false;
    @track fetchedRTCIds=getRtcsBos;
    @track rtcBOArray = [];
    @track businessUnit;
    @track isStreakIdCheck =false;
    @track streakStatus;
    @track isOfflineCancellation = false;
    @track assuranceServiceDetails=[];
    @track isRedRailStripGuarantee =false;
    @track isConnectedService = false;
    @track connectedTransactionData;

    @wire(GetDetails, {ordId:'$recordId' })
    wireMethod({error,data}){
        if(data){
            var dateOfIssue;
            this.amount = data.Total_Fare__c;
            this.refundAmount = data.Refund_Amount__c;
            this.status = data.Refund_Status__c;
            this.cancelDate = data.Cancelled_Time__c;
            this.currency = data.Payment_Currency__c;
            this.businessUnit = data.Business_Unit__c;
            this.streakStatus = data.StreakStatus__c;
            
            if((this.businessUnit==='REDRAILS_IN' || this.businessUnit==='REDBUS_RAILS_IN') && data.Assurance_Service__c!=null && data.Assurance_Service__c!=''){
              this.assuranceServiceDetails = this.strip = JSON.parse(data.Assurance_Service__c);
            const containsSeatGuarantee = this.assuranceServiceDetails.find(item => item.assuranceName?.includes('Seat Guarantee'));
                if (containsSeatGuarantee) {
                    this.isRedRailStripGuarantee =true;
                } else {
                    this.isRedRailStripGuarantee =false;
                }
            }

            if(data.HFT__c!=null && data.HFT__c!=''){
                this.showHft=true;
            this.hft=data.HFT__c;    
            }
            this.validateForBoltId();
            this.validateForStreakId();
            this.getConnectedTransaction();
            if((data.Related_To__c!=null && data.Related_To__c!='') || data.Item_Type__c=='COUPON'){
                this.busPassrltdTrans=true;
            }

            this.rtcBOArray=this.fetchedRTCIds.split(',');
            if(!this.rtcBOArray.includes(data.Service_Provider_Id__c)){
                const currentDate = new Date();
                dateOfIssue = new Date(data.Date_of_Issue_New__c);
                this.zqpTimeDiff = this.timeDiffernec_Minutes(currentDate, dateOfIssue);
                if(this.zqpTimeDiff!= null && this.zqpTimeDiff<=30 && this.businessUnit!=='REDRAILS_IN' && this.businessUnit!=='REDBUS_RAILS_IN'){
                    this.showZqp=true;
                }
            }

            if(this.businessUnit ==='REDBUS_ID' && data.isCancellableFromApi__c===false){
                this.isOfflineCancellation = true;
            }
        }
    }

    //To fetch time Difference in Min
    timeDiffernec_Minutes(dt2, dt1){
        var timeDiff = (dt2.getTime() - dt1.getTime())/1000;
        timeDiff /=60;
        return Math.abs(Math.round(timeDiff));
    }

    //check if BOLT Id
    validateForBoltId(){
        getBoltBoId({
            transactionId:this.recordId
        })
        .then(result=>{
            if(result.Error){
                this.isError=true;
                console.log('::: No Data Avialable :: ');
            }else{
                this.isBolt = result;
            }
            
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }

    //check if streakId
    validateForStreakId(){
        getStreakId({
            transactionId:this.recordId
        })
        .then(result=>{
            if(result.Error){
                this.isError=true;
                console.log('::: No Data Avialable :: ');
            }else{
                this.isStreakIdCheck = result;
            }
            
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }

    //To check for the connected transaction
    getConnectedTransaction(){
        connectedServiceData({
            transactionId:this.recordId
        })
        .then(result=>{
            console.log('::: Invalid Data :: '+JSON.stringify(result));
            if(result.Error){
                console.log('::: No Data Avialable :: ');
            }else if(result!=null && result!=undefined){
                this.isConnectedService=true;
                this.connectedTransactionData = result;
            }
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }

    navigateToRecord(event) {
        const transactionId = event.target.dataset.id;
        console.log(':: transactionId' +transactionId);
        // Create a PageReference object for navigating to a record page
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id, // Replace with the actual record ID
                objectApiName: 'Order_Items__c', // Replace with the object API name
                actionName: 'view'
            }
        };
        // Use the Navigate method to navigate to the specified record page
        this[NavigationMixin.Navigate](pageReference);
    }
    
}