import { LightningElement, track, wire, api } from 'lwc';
import sendNotificationLM from '@salesforce/apex/CaseButtons.SendCSATNotification';


export default class BushireCSATNotification extends LightningElement {

    @api recordId;
    @track showUpdMsg;
    @track apiRespBody;
    @track sendLoad;
    @track notifType;
    @track notifMsg;
    handleSendNotification() {
        console.log('called here 11');
        this.sendLoad = true;
        sendNotificationLM({ caseId: this.recordId, source: 'Case' }).then(data => {
            if (data) {
                console.log('dtt-->' + data);
                this.apiRespBody = JSON.parse(data);
                this.sendLoad = false;
                console.log('this.apiRespBody-->' + this.apiRespBody);
                console.log('this.apiRespBody 2-->' + this.apiRespBody.Response);
                console.log('this.apiRespBody data-->' + JSON.stringify(this.apiRespBody.Response.Data));
                this.showUpdMsg = true;
                this.notifType = 'success';
                this.notifMsg = JSON.stringify(this.apiRespBody.Response.Data);

            } else if (error) {
                this.sendLoad = false;
                this.notifType = 'error';
                this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code->' + data;

            }
        })
    }
}