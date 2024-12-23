import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import escalateToOndc from '@salesforce/apex/ondcCreateIssueCtrl.createOndcCase';

export default class EscalateToOndcCmp extends LightningElement {
    @api recordId;
    @track processingMode = 'pester';

    @api invoke() {
        console.log("recordId== " +this.recordId);
        this.raiseOndcCase();
    }
    

    raiseOndcCase(){
        this.startToast('Processing..','Please wait.','info',this.processingMode);
        escalateToOndc({caseId: this.recordId, isEscalated:true})
        .then(result => {
            this.processingMode ='dismissible';
            console.log(':: resultMsg = '+JSON.stringify(result));
            if(result.isError){
                this.startToast('Error Occured!!',result.errorMsgToShw,'error');
            }
            if(result.isSuccess){
                this.startToast('Success!!',result.successMsgToShw,'success');
            }
            window.location.reload();
        })
        .catch(error => {
            console.log(':: ErrMsg = '+JSON.stringify(error));
            this.startToast('Error Occured!!',error,'error');
        });
    }

    startToast(title,msg,varErr){
        let event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varErr,
        });
        this.dispatchEvent(event);
    }
}