import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SendFedBckHelpLink from '@salesforce/apex/OutBoundFdbckCallingNotification.SendFdbckLink';
export default class SelfHelpLink extends LightningElement {


    @api recordId;
    @track showUpdMsg;
    @track notifType;
    @track notifMsg;
    @track apiRespBody;
    @track apiRespdata;
    @track finalUrl;
    @track fetchLoad = false;
    @track showresp= false;
    handleClick(event) {
        console.log('Feedback handleClick here is');
        this.fetchLoad = true;
        SendFedBckHelpLink({ recordId: this.recordId}).then(data => {
            console.log('insdied get');
            if (data) {
                console.log('data -->' + data);
               
                if (data == 'Apex Error' || data == 'No case Found' || data == 'No API Response') {
                    this.apiRespBody = data;
                    this.fetchLoad = false;
                    this.showUpdMsg = true;
                    this.errordisplayToastSuccess();  
                } else {
                    this.apiRespBody = data;
                    this.showresp = true;
                    console.log('apiRespBody-->' + this.apiRespBody);
                    this.fetchLoad = false;
                    this.displayToastSuccess();            }
            } else if (error) {
                this.apiRespBody = data;
                this.fetchLoad = false;
                this.showUpdMsg = true;
                console.log('data error  details->' + error);
                this.errordisplayToastSuccess();  
            }
        }).catch(error => {
    
        })
    }

    displayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'success',
            message: this.apiRespBody,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    errordisplayToastSuccess() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: this.apiRespBody,
            variant: 'Error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}