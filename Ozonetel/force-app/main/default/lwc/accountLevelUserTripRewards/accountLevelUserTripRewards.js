import { LightningElement,api,track } from 'lwc';
import getUserStreaks from '@salesforce/apex/TripRewardsCntrl.AccountStreaksByUserId';
export default class AccountLevelUserTripRewards extends LightningElement {

 @api  recordId;
 @track isLoading = false;
 @track useStreaksResponse = [];
 @track errorMsg;
 @track isError =false;

  connectedCallback() {
        this.isLoading = true;
        //User Streaks
       console.log('----Account Method User--'+this.recordId);
        getUserStreaks({
            accountId: this.recordId
         }).then(result => {
              this.isLoading = false;
              console.log('----result--' + JSON.stringify(result));
                if(result.hasOwnProperty('errorMessage')){
                    this.errorMsg = result.errorMessage; 
                    this.isError = true;
                }else{
                     this.errorMsg = result["Msg"];
                    if(this.errorMsg!=null){
                       this.isError = true;
                    }else{
                        this.isError = false;
                        console.log('----result--' + JSON.stringify(result));
                        //const  responseObj = JSON.parse(result);
                        this.useStreaksResponse = Object.values(result);
                    }
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.isError = true;
                console.error('Error fetching data', error);
            });
    

  }
}