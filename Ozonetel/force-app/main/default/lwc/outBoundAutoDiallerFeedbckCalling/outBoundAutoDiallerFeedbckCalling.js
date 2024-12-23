import { LightningElement, track,wire} from 'lwc';
import GetbusHrFedBkList from '@salesforce/apex/OutboundAutoDiallerFeedbackCalling.getDetails';
import CallingTocustomer from '@salesforce/apex/OutboundAutoDiallerFeedbackCalling.callToCustomer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';


export default class OutBoundAutoDiallFdbckCalling extends NavigationMixin(LightningElement) {
    channelName = '/event/CZentrix_Info_Refresh__e';
    subscription = {};

    @track error;
    //@track busHireFeedBackList = [];
    @track busHireRNRList = [];
    @track busHireCallBackList = [];
    @track busHireNewRNRList = [];
    @track tempArrayList = [];
    @track sortedList = [];
    @track count = 0;
    @track customerName;
    @track phone;
    @track boId;
    @track boName;
    @track callStatus;
    @track destination;
    @track source;
    @track recordlink;
    @track busHireRecordId;
    @track TypeOptions;
    @track idToRemove;
    @track updateType;
    @track fields = [
        { label: 'Customer Name', fieldName: 'Customer_Name__c' },
        { label: 'Phone', fieldName: 'Phone_No__c' },
        { label: 'Bo Name', fieldName: 'BO_Name__c' },
        { label: 'Bo Id', fieldName: 'BO_id__c' },
        { label: 'Status', fieldName: 'Call_Disposition_Status__c' },
        { label: 'Source', fieldName: 'Source__c' },
        { label: 'Destination', fieldName: 'Destination__c'},
        {label: 'Record Link', fieldName: 'Name'}
    ];
    get options() {
        return [
            { label: 'Off Line', value: 'offline' },
            { label: 'Ready', value: 'Ready' },
        ];
    }
    timer;

connectedCallback(){
   //this.onLoadassignment();
   this.handleSubscribe();
}
handleSubscribe() {
    subscribe(this.channelName, -1, this.messageCallback).then(response => {
    //Response contains the subscription information on subscribe call
    console.log('-Subscription request sent to: ', JSON.stringify(response.channel));
    this.subscription = response;
  
    });
}  
handleUnsubscribe() {
    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, response => {
        console.log('-unsubscribe() response:- ', JSON.stringify(response));
        // Response is true for successful unsubscribe
    });
}


messageCallback = (response) => {
    console.log('---72---');
   this.updateType=response.data.payload.Update_Type__c;
   console.log('---80---'+this.updateType);
   let count = 9;
   if(this.updateType=='Feedback calling Real Time'){
   this.timer = setInterval(() => {
        if (!count) {
          clearInterval(this.timer);
        } else {
          count--;
          this.template.querySelector(".timer").innerHTML = count;
          if(count==8){
             console.log('===recorscassign==');
               this.assignRecords();
          }
          
          if(count==1){
            console.log('===0 calling==');
              this.diallingToBo();
         }

        }
      }, 1000);

   }else{
    this.disconnectedCallback();
   }
}

handleChange(event) {
    this.value = event.detail.value;
    console.log('--value--'+this.value);
    let count = 8;
    if(this.value=='Ready'){
        this.timer = setInterval(() => {
            if (!count) {
              clearInterval(this.timer);
            } else {
              count--;
              this.template.querySelector(".timer").innerHTML = count;
              if(count==7){
                 console.log('===assignRecords==');
                   this.assignRecords();
              }

            
              if(count==1){
                console.log('===0 calling==');
                  this.diallingToBo();
             }

            }
          }, 1000);

    }else{
        this.disconnectedCallback();
    }
}
 
disconnectedCallback() {
    this. handleUnsubscribe();
    clearInterval(this.timer);
  }

 /* onLoadassignment(){
     console.log('>>loadAssignment>>');
    GetbusHrFedBkList()
        .then(result => {
            console.log('---result--'+ JSON.stringify(result));
            this.busHireFeedBackList = result;
            this.tempArrayList = result;
        })
        .catch(error => {
                this.error = error;
                console.log('::: error Result ::::'+this.error);
                console.log('Error '+JSON.stringify(error));
        });
 }*/

    assignRecords(){
        GetbusHrFedBkList()
        .then(result => {
            this.tempArrayList = result;
            console.log('::: tempArrayList :::: ' +JSON.stringify(this.tempArrayList));

            this.count = this.tempArrayList.length;
            console.log('::: count Value :::: ' +this.count);
            if(this.count > 0){
                for(var i=0;i<this.tempArrayList.length;i++)
                {
                    console.log('::: Call Status :::: ' +this.tempArrayList[i].Call_Status__c);
                        if(this.tempArrayList[i].Call_Disposition_Status__c =='Callback Requested'){
                            this.busHireCallBackList.push(this.tempArrayList[i]);
                            break;
                        }else if(this.tempArrayList[i].Call_Disposition_Status__c =='New RnR'){
                            this.busHireNewRNRList.push(this.tempArrayList[i]);
                            break;
                        }else if(this.tempArrayList[i].Call_Disposition_Status__c =='RnR'){
                            this.busHireRNRList.push(this.tempArrayList[i]);
                            break;
                        }else{
                            this.sortedList.push(this.tempArrayList[i]);
                        }
                    }
                
                console.log(':: busHireNewRNRList ::: '+ JSON.stringify(this.busHireNewRNRList));
                console.log(':: busHireCallBackList ::: ' +JSON.stringify(this.busHireCallBackList)); 
                console.log(':: busHireRNRList ::: ' +JSON.stringify(this.busHireRNRList)); 
                console.log(':: sortedList ::: ' +JSON.stringify(this.sortedList)); 

                if(this.busHireCallBackList.length>0){
                    this.customerName= this.busHireCallBackList[0].Customer_Name__c
                    this.phone=this.busHireCallBackList[0].Phone_No__c;
                    this.boId=this.busHireCallBackList[0].BO_id__c;
                    this.boName=this.busHireCallBackList[0].BO_Name__c;
                    this.callStatus=this.busHireCallBackList[0].Call_Disposition_Status__c;
                    this.destination=this.busHireCallBackList[0].Destination__c;
                    this.source=this.busHireCallBackList[0].Source__c;
                    this.recordlink=this.busHireCallBackList[0].Name;
                    this.busHireRecordId=this.busHireCallBackList[0].Id;
                    this.idToRemove = this.busHireCallBackList[0].Id;
                    for(var i=0;i<this.busHireCallBackList.length;i++){
                        if (this.busHireCallBackList[i].Id == this.idToRemove) {
                            var removedObject = this.busHireCallBackList.splice(i,1);
                            removedObject = null;
                            break;
                        }
                    }
                }else if(this.busHireNewRNRList.length>0){
                    this.customerName= this.busHireNewRNRList[0].Customer_Name__c
                    this.phone=this.busHireNewRNRList[0].Phone_No__c;
                    this.boId=this.busHireNewRNRList[0].BO_id__c;
                    this.boName=this.busHireNewRNRList[0].BO_Name__c;
                    this.callStatus=this.busHireNewRNRList[0].Call_Disposition_Status__c;
                    this.destination=this.busHireNewRNRList[0].Destination__c;
                    this.source=this.busHireNewRNRList[0].Source__c;
                    this.recordlink=this.busHireNewRNRList[0].Name;
                    this.busHireRecordId=this.busHireNewRNRList[0].Id;
                    this.idToRemove = this.busHireNewRNRList[0].Id;
                    for(var i=0;i<this.busHireNewRNRList.length;i++){
                        if (this.busHireNewRNRList[i].Id == this.idToRemove) {
                            var removedObject = this.busHireNewRNRList.splice(i,1);
                            removedObject = null;
                            break;
                        }
                    }
                }else if(this.busHireRNRList.length>0){
                    this.customerName= this.busHireRNRList[0].Customer_Name__c
                    this.phone=this.busHireRNRList[0].Phone_No__c;
                    this.boId=this.busHireRNRList[0].BO_id__c;
                    this.boName=this.busHireRNRList[0].BO_Name__c;
                    this.callStatus=this.busHireRNRList[0].Call_Disposition_Status__c;
                    this.destination=this.busHireRNRList[0].Destination__c;
                    this.source=this.busHireRNRList[0].Source__c;
                    this.recordlink=this.busHireRNRList[0].Name;
                    this.busHireRecordId=this.busHireRNRList[0].Id;
                    this.idToRemove = this.busHireRNRList[0].Id;
                    for(var i=0;i<this.busHireRNRList.length;i++){
                        if (this.busHireRNRList[i].Id == this.idToRemove) {
                            var removedObject = this.busHireRNRList.splice(i,1);
                            removedObject = null;
                            break;
                        }
                    }
                }else if(this.sortedList.length>0){
                    this.customerName= this.sortedList[0].Customer_Name__c;
                    this.phone=this.sortedList[0].Phone_No__c;
                    this.boId=this.sortedList[0].BO_id__c;
                    this.boName=this.sortedList[0].BO_Name__c;
                    this.callStatus=this.sortedList[0].Call_Disposition_Status__c;
                    this.destination=this.sortedList[0].Destination__c;
                    this.source=this.sortedList[0].Source__c;
                    this.recordlink=this.sortedList[0].Name;
                    this.busHireRecordId=this.sortedList[0].Id;
                    this.idToRemove = this.sortedList[0].Id;
                    for(var i=0;i<this.sortedList.length;i++){
                        if (this.sortedList[i].Id == this.idToRemove) {
                            var removedObject = this.sortedList.splice(i,1);
                            removedObject = null;
                            break;
                        }
                    }
                }
            }else{
                    this.customerName= '';
                    this.phone='';
                    this.boId='';
                    this.boName='';
                    this.callStatus='';
                    this.destination='';
                    this.source='';
                    this.recordlink='';
                    this.busHireRecordId='';
                    this.idToRemove = '';
            }
            for(var i=0;i<this.tempArrayList.length;i++){
                if (this.tempArrayList[i].Id == this.idToRemove) {
                    var removedObject = this.tempArrayList.splice(i,1);
                    removedObject = null;
                    break;
                }
            }
            console.log(':: After busHireRNRList ::: '+ JSON.stringify(this.busHireRNRList));
            console.log(':: After busHireCallBackList ::: ' +JSON.stringify(this.busHireCallBackList)); 
            console.log(':: After sortedList ::: ' +JSON.stringify(this.sortedList)); 
        })
        .catch(error => {
            this.error = error;
            console.log('::: error Result ::::'+this.error);
            console.log('Error '+JSON.stringify(error));
        });
    } 
    viewRecord(event) {
        console.log(':::: Inside View Record ::::' +this.busHireRecordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.busHireRecordId,
                "objectApiName": "BusHire_Feedback_Calling__c",
                "actionName": "view"
            },
        });

    }

    diallingToBo(){
        console.log('...calling part....' );
        console.log('...RecrdId....'+this.idToRemove );
        CallingTocustomer({ recId: this.idToRemove })
        .then(result => {
            this.callConnectionStatus=result;
            console.log('>>>>callConnectionStatus>>' +this.callConnectionStatus);
            if(this.callConnectionStatus=='Call will be connect soon'){
            this.displayToastSuccess();
            }else{
                this.errordisplayToastSuccess();
            }
           
        }).catch(error => {
            // eslint-disable-next-line no-console
            console.log('exception e..' + error);

        });

    }


    displayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'success',
            message: this.callConnectionStatus,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    errordisplayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: this.callConnectionStatus,
            variant: 'Error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}