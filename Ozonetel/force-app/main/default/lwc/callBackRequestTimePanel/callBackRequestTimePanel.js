import { LightningElement , wire , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCallBackCases from '@salesforce/apex/CallBackRequestTimeCntrl.getCallBackReqCases';
//import { CloseActionScreenEvent } from 'lightning/actions';

export default class CallBackRequestTimePanel extends NavigationMixin(LightningElement){
    @track caseList = [];
    @track timeDifference = '';
    @track activetabContent='test';
 
    goToCase(event, component) {
                
        let caseId = event.target.getAttribute("data-id");
        console.log(caseId);
    
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        }, false);
    }


    

    tabChangeHandler(event) {
    console.log('>>>>>tba>>>>')
    console.log('eventval', event.target.value);
    this.activetabContent  =  event.target.value;
    console.log('---v--'+this.activetabContent);
    this.fetchSelectedTabCases();
    }

    fetchSelectedTabCases(){
        console.log('inside fetchSel');
        getCallBackCases({
            selectedTabVal:this.activetabContent
        })
        .then(result=>{
            if(result.Error){
                console.log("erroorr");
            }else{
                console.log('>>result--'+this.result); 
                this.caseList=result;
                console.log('>>caseList--'+JSON.stringify(this.caseList)); 
                this.caseList = result.map(caseItem => ({ ...caseItem, timeDifference: '' , accountName: ''}));
                this.caseList.forEach(caseItem => {
                    if(caseItem.Account) {
                        caseItem.accountName = caseItem.Account.Name;
                        console.log('accName==',caseItem.accountName);
                    }
                    else {
                        caseItem.accountName = '';
                    }
                })

                this.calculateTimeDifferences(); 
                console.log('caseLIst======', JSON.stringify(this.caseList));
                
            }
                
      })
      .catch(error => {
      });
      
      
    }


    calculateTimeDifferences() {
        let currentTime = new Date();

        console.log('>>>time--'+currentTime);
        let oneDay = 24 * 60 * 60 * 1000; // One day in milliseconds

        this.caseList.forEach(caseItem => {
            let hoursToAdd = 5; // Example: Add 2 hours
            let minutesToAdd = 30;
            let calldateTimeField=new Date(caseItem.CallBack_Requested_Time__c);
            calldateTimeField.setHours(calldateTimeField.getHours());
            calldateTimeField.setMinutes(calldateTimeField.getMinutes());

            let caseDateTime = new Date(calldateTimeField); // Replace with your DateTime field API name
            console.log('caseDateTime==='+caseDateTime);
            console.log('currentTime ==='+currentTime);
            let timeDifference = caseDateTime - currentTime;
            console.log('--callTime--'+caseDateTime);
            console.log('--timeDiff--'+timeDifference);

            if(caseDateTime < currentTime) {
                caseItem.isExpired = true;
            }
        
            let hours, minutes, seconds;
            if (timeDifference > 0){
                hours = Math.floor(timeDifference / 3600000);
                minutes = Math.floor((timeDifference % 3600000) / 60000);
                seconds = Math.floor((timeDifference % 60000) / 1000);
            }
            else {
                hours = Math.ceil(timeDifference / 3600000);
                minutes = Math.ceil((timeDifference % 3600000) / 60000);
                seconds = Math.ceil((timeDifference % 60000) / 1000);
            }

            console.log('--hrs-->>'+hours);
            console.log('the isExp var'+caseItem.isExpired);

            if( hours > 24 ) {

                hours = timeDifference / 3600000;
                let days = Math.floor(hours / 24);
                let h1 = hours - days*24;
                hours = Math.floor(hours - (days * 24));
                minutes = Math.floor((h1 - hours)*60);
                caseItem.timeDifference = `${days}d ${hours}h ${minutes}m`;

            }

            else if ( hours < -24 ) {

                hours = timeDifference / 3600000;
                let days = Math.ceil(hours / 24);
                let h1 = hours - days*24;
                hours = Math.ceil(hours - (days * 24));
                minutes = Math.ceil((h1 - hours)*60);
                caseItem.timeDifference = `${days}d ${hours}h ${minutes}m`;
                console.log('timediff',caseItem.timeDifference);

            }

            else {

                caseItem.timeDifference = `${hours}h ${minutes}m ${seconds}s`;
            }

    
        });

    // Force a reactivity update after calculating time differences
        this.caseList = [...this.caseList];
    }

}