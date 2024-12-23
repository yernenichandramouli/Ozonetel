import { LightningElement,api,track } from 'lwc';
import sendFeedbackEmail from '@salesforce/apex/BusHireSendFeedbackEmail.sendFeedbackEmail';
export default class BusHireFeedbackMailSend extends LightningElement {
@api recordId;
@track success;
@track message;
connectedCallback() {
    sendFeedbackEmail({
        Lid:this.recordId
    })
    .then(data=>{
        if(data=='success'){
            this.success=true;
            this.message='Feedback mail sent succesfully';
        }
        else if(data =='status error'){
            this.success=false;
            this.message='Feedback mail can send only when the status is converted'           

        }
        else{
            this.success=false;
            this.message=data;    
        }
    })
  }   
}