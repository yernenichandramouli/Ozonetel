import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchIGMCancelStatus from '@salesforce/apex/metroIGMCancellationCtrl.fetchCancellationStatus';
export default class FetchIGMRefundStatusCmp extends LightningElement {
    @api recordId;
    @track processingMode = 'pester';

    @api invoke() {
        console.log("recordId  " +this.recordId);
        this.fetchCancellationStatus();
    }
    

    fetchCancellationStatus(){
        this.startToast('Processing..','Please wait.','info',this.processingMode);
        fetchIGMCancelStatus({caseId: this.recordId})
        .then(result => {
            this.processingMode ='dismissible';
            console.log(':: resultMsg = '+JSON.stringify(result));
            if(result.isError){
                this.startToast('Error Occured!!',result,'error');
            }
            if(result.isSuccess){
                this.startToast('Success!!',result,'success');
            }
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