import { LightningElement, api, track } from 'lwc';
import sendWhatsappMessage from '@salesforce/apex/BusHireSendFeedbackEmail.sendWhatsappMessage';
export default class SendWhatsappMessage extends LightningElement {
@api recordId;
@track success;
@track message;
connectedCallback() {
    sendWhatsappMessage({
        Lid:this.recordId
    })
    .then(data=>{
        if(data=='success'){
            this.success=true;
            this.message='Whatsapp message sent succesfully';
        }
        else if(data =='status error'){
            this.success=false;
            this.message='Whatsapp message can send for non converted leads only.'           
        }
        else{
            this.success=false;
            this.message=data;    
        }
    })
  }
}