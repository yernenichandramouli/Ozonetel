import { LightningElement, api, track } from 'lwc';
import GetSelfHelpLinklc from '@salesforce/apex/SelfHelplinkController.GetSelfHelpLink';
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
        console.log('handleClick here is');
        this.fetchLoad = true;
        GetSelfHelpLinklc({ caseId: this.recordId}).then(data => {
            console.log('insdied get');
            if (data) {
                console.log('data -->' + data);
                if (data == 'Apex Error' || data == 'No case Found' || data == 'No API Response') {
                    this.fetchLoad = false;
                    this.showUpdMsg = true;
                    this.notifType = 'error';
                    this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code->' + data;
                } else {
                    this.apiRespBody = data;
                    this.showresp = true;
                    console.log('apiRespBody-->' + this.apiRespBody);
                    this.fetchLoad = false;
                    this.finalUrl = 'https://s.redbus.com/'+this.apiRespBody;
                    console.log('short-->'+this.finalUrl);
                                    }
            } else if (error) {
                this.fetchLoad = false;
                this.showUpdMsg = true;
                this.notifType = 'error';
                this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code-> JS Failed';
                console.log('data error  details->' + error);
            }
        }).catch(error => {
    
        })
    }
}