import { LightningElement,api,wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import pgDetails from '@salesforce/apex/PG_Credentialscntrl.getPGdetails';
import callingDblogSummary from '@salesforce/apex/PG_Credentialscntrl.dblogToCapturedata';

export default class PgCredentialsCmp extends NavigationMixin(LightningElement) {

    @api recordId;
    @track apiRespBody=[];
    @track pglink;
    @track tin;
    @track pgname;
    @track countNO;
    @track errormsg;
    @track fetchLoad = false;
    @track showUpdMsg = false;

    handleClick(event) {
         console.log('>>>>>>'+this.recordId);
          this.fetchLoad = true;
        pgDetails({
            ordItemId: this.recordId
           })
             .then((result) => {
                console.log('---result>>>>'+result);
                this.apiRespBody = result;
                this.fetchLoad = false;
                console.log('>>34 data>>.  this.apiRespBody>>>'+JSON.stringify(result));
                this.pgname = (this.apiRespBody!==null && this.apiRespBody[0].pgName!==undefined && this.apiRespBody[0].pgName!==null && this.apiRespBody[0].pgName!=='')?this.apiRespBody[0].pgName:'No Data';
                this.pglink =(this.apiRespBody!==null && this.apiRespBody[0].pgLink!==undefined && this.apiRespBody[0].pgLink!==null && this.apiRespBody[0].pgLink!=='')?this.apiRespBody[0].pgLink:'No Data';
                this.errormsg = (this.apiRespBody!==null && this.apiRespBody[0].ErrorMsg!==undefined && this.apiRespBody[0].ErrorMsg!==null && this.apiRespBody[0].ErrorMsg!=='')?this.apiRespBody[0].ErrorMsg:'No Data';
                this.tinNo = (this.apiRespBody!==null && this.apiRespBody[0].tin!==undefined && this.apiRespBody[0].tin!==null && this.apiRespBody[0].tin!=='')?this.apiRespBody[0].tin:'No Data';
                if(this.pglink!=='No Data' && this.pglink!=='No Data' &&  this.errormsg!=='No link' &&  this.errormsg!=='No transcation' ){
                    console.log(':: url = '+this.pglink);
                    this.navigateToWebPage(this.pglink);
                    this.countNO='1';
                    this.dblogCapture();
                }else{
                    this.fetchLoad = false;
                    this.showUpdMsg = true;
                    this.notifType = 'error';
                    this.notifMsg = 'Something Went Wrong!! NO PG link found';
                    this.showErrorToast(this.notifMsg);
                }
    
                console.log('>>>>'+ this.pgname+'--error--'+ this.errormsg +'--link--'+ this.pglink);

             })
             .catch((error) => {
                 this.fetchLoad = false;
                console.log("Error " + JSON.stringify(error.message));
              });

              
    }

    navigateToWebPage(pgLinkUrl) {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: pgLinkUrl
            }
        },
        false
        );
    }

    dblogCapture(){
        console.log('--93-secondMethod--'+this.tinNo+'--'+this.pglink+'--'+this.countNO+'--'+this.pgname);
        callingDblogSummary({
            transactionId:this.tinNo,
            pgurl: this.pglink,
            pgCount:this.countNO,
            pgName:this.pgname
          })
          .then(result=>{
            console.log('---result--'+result);
          })
          .catch((error) => {
                
            console.log("Error " + JSON.stringify(error.message));
          });

        }

        showErrorToast(errorMessageToShow) {
          const evt = new ShowToastEvent({
              title: 'Error',
              message: errorMessageToShow,
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(evt);
      }
}