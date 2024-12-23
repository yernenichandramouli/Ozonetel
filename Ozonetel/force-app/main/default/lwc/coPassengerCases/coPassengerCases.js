import { LightningElement, track, wire, api } from 'lwc';
import GetDetailsLM from '@salesforce/apex/CoPassengerHandler.coPassengerCases';


export default class CoPassengerCases extends LightningElement {
    @api recordId;
    @track coPassDetails = [];
    @track showSection = false;
    @track apiRespBody = {};
    @track fetchLoad = false;
    @track showUpdMsg = false;
    @track notifType;
    @track notifMsg;

    handleClick(event) {
        console.log('handleClick here');
        this.fetchLoad = true;
        GetDetailsLM({ caseId: this.recordId, source: 'Case' }).then(result => {
            if (result) {
                console.log('res-->' + result);
                console.log('res js-->' + JSON.stringify(result));
                if (result == 'Apex Error' || result == 'No Tin Found' || result == 'No API Response') {
                    this.fetchLoad = false;
                    this.showUpdMsg = true;
                    this.notifType = 'error';
                    this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code 1->' + data;
                } else {
                    console.log('rec ordItemId d-->' + result);
                    this.fetchLoad = false;
                    this.coPassDetails = result;
                    //  this.coPassDetails = this.apiRespBody.data;
                    this.showSection = true;
                }
            } else {
                this.fetchLoad = false;
                this.showUpdMsg = true;
                this.notifType = 'error';
                this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code 2->' + result;

            }
        }).catch(error => {
            this.showUpdMsg = true;
            this.fetchLoad = false;
            this.notifType = 'error';
            this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code 3->' + error;
            console.log('errrr--->' + error);
        })
    }
}