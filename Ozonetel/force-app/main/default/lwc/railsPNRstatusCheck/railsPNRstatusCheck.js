import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import railsPNRstatusCheck from '@salesforce/apex/RailsPNRstatusCheckCntrl.GetRailsPNRstatus';
export default class RailsPNRstatus extends LightningElement { 

    @api recordId;
    @track apiRespBody;
    @track errorCod;
    @track success;
    @track isShowResp;
    @track isError = false;
    @track errordtlMessage;
    @track errorMsg;
    @track pnrNo;
    @track trainNo;
    @track journyClass;
    @track chartstatus;
    @track quota;
    @track source;
    @track destination;
    @track trainName;
    @track doj;

    @track psngrfields = [{
        label: 'Name',
        fieldName: 'name',
        hideDefaultActions: true
    },
    {
        label: 'Current Status',
        fieldName: 'currentStatus',
        hideDefaultActions: true
    },
    {
        label: 'Current CoachId',
        fieldName: 'currentCoachId',
        hideDefaultActions: true
    },
    {
        label: 'Current BerthNo',
        fieldName: 'currentBerthNo',
        hideDefaultActions: true
    },

    ];
    
    @wire(railsPNRstatusCheck, {
        ordItemId: '$recordId'
    })
    wireMethod({
        error,
        data
    }) {
        console.log('--recordId -->' + this.recordId);
        if (data) {
            this.apiRespBody = JSON.parse(data);
            console.log('--resp data -->' + JSON.stringify(this.apiRespBody));
            console.log('=== this.strResp==' + this.strResp);
            if (data != null && data != '') {
                this.apiRespBody = JSON.parse(data);
                this.errorCod = JSON.stringify(this.apiRespBody.errorcode);
                if (this.errorCod != null && this.errorCod != '') {
                    this.isError = true;
                    this.isShowResp = false;
                    this.errordtlMessage = JSON.stringify(this.apiRespBody.detailedmsg);
                    this.errorMsg = JSON.stringify(this.apiRespBody.errormsg);
                    console.log('----if= -->');
                } else {
                    console.log('----else= -->');
                    var respObj = JSON.parse(data);
                    this.isShowResp = true;
                    this.pnrNo = this.apiRespBody.pnrNo;
                    this.chartstatus = this.apiRespBody.chartStatus;
                    this.journyClass = this.apiRespBody.journeyClass;
                    this.quota = this.apiRespBody.quota;
                    this.source = this.apiRespBody.srcName;
                    this.destination = this.apiRespBody.dstName;
                    this.trainName=this.apiRespBody.trainName;
                    this.trainNo = this.apiRespBody.trainNumber;
                    this.doj=this.apiRespBody.departureTime;
                    this.strResp = this.apiRespBody.passengers;
                   
                }
            }
        }
    }
}