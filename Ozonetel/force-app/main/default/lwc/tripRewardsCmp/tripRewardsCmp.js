import { LightningElement, api, wire, track } from 'lwc';
import getTranscationStreaks from '@salesforce/apex/TripRewardsCntrl.GetAllStreaksByTransId';
import getUserStreaks from '@salesforce/apex/TripRewardsCntrl.GetAllStreaksByUserId';
export default class TripRewards extends LightningElement {

@api recordId; 
@track jsonData;
@track dataKeys;
@track radioBtnVal;
@track selectedValue;
@track txns = [];
@track response = {};
@track useStreaksResponse = [];
@track isTransStreaksBtn =false;
@track isUserStreaksBtn = false;
@track isLoading = false;
@track errorMsg;
@track isError =false;


  @track options = [
    { label: 'Transcation Streaks', value: 'transcationStreaksBtn' },
    { label: 'User Streaks', value: 'userStraksBtn' },
  ];

 handleRadioChange(event) {
    this.selectedValue = event.target.value;
    this.radioBtnVal = this.selectedValue;
    console.log('--selectRadio--' + this.radioBtnVal);
  }

handleToProcessed() {
    console.log('==this.selectedValue=' + this.selectedValue);
    if (this.selectedValue == 'transcationStreaksBtn') {
        this.isLoading = true;
        this.isTransStreaksBtn=true;
        this.isUserStreaksBtn=false;
        this.methodTranscationsStreaks();
    }else if(this.selectedValue == 'userStraksBtn'){
        this.methodUserStreaks();
        this.isLoading = true;
        this.isUserStreaksBtn=true;
        this.isTransStreaksBtn =false;
    }else {
        this.isTransStreaksBtn=false;
        this.isUserStreaksBtn=false;
        alert('Please select one item');
    }
}

//User Streaks
 methodUserStreaks() {
       console.log('----Method User--'+this.recordId);
        getUserStreaks({
            ordItemId: this.recordId
         }).then(result => {
               this.isLoading = false;
                console.log('----result--' + JSON.stringify(result));
                if(result.hasOwnProperty('errorMessage')){
                    this.errorMsg = result.errorMessage; 
                    this.isError = true;
                }else{
                     console.log('>>>else-error--');
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
                 this.isError = true;
                console.error('Error fetching data', error);
        });
    }

//Transcations Streaks
  methodTranscationsStreaks() {
       console.log('----Method Trans--'+this.recordId);
        getTranscationStreaks({
            ordItemId: this.recordId
         }).then(result => {
            this.isLoading = false;
              let respObj = JSON.parse(result);
             if ("Msg" in respObj) {
                    this.errorMsg = respObj.Msg;
                    this.isError = true;
              }else if(result =='Error response-Please contact system administartor'|| result==='Try catch error' || result==='UserId or ItemUUid is blank- Please check once'){
                 this.errorMsg = result; 
                this.isError = true;
            }else{
                console.log('----result--' + JSON.parse(JSON.stringify(result)));
                this.isError = false;
                this.response = JSON.parse(result);
                const parsedResp = JSON.parse(result);
                this.txns = parsedResp.Txns;
            }
            })
            .catch(error => {
                 this.isError = true;
                 this.isLoading = false;
                console.error('Error fetching data', error);
         });
    }

}