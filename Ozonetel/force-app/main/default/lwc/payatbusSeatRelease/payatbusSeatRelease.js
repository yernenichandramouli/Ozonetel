import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import payAtbusReleaseSeat from '@salesforce/apex/PayAtBusReleaseSeatCntrl.GetPayAtBusTrans';
export default class GetPaytBusTrans extends LightningElement {

    @api recordId;
    @api isError= false;
    @api apiRespBody;
    @api errorMsg;
    @api isSuccess=false;
    @api successMsg;
    @wire(payAtbusReleaseSeat, {
        ordItemId: '$recordId'
    })
    wireMethod({
        error,
        data
    }) {
        console.log('--recordId -->' + this.recordId);
        if (data) {
    
            if (data == 'Apex Error' || data == 'No case Found' || data == 'Seat Release will Not Supported for this Transcation' || data == 'Suported For Only Latam' || data == 'Failed to Release') {
                    this.isError = true;
                    this.errorMsg = data;
                    this.isSuccess=false;
                } else if(data == 'Seat Released successfully'){
                    this.isSuccess=true;
                    this.successMsg= data;
                    this.isError = false;     
                }else {
                  this.apiRespBody = JSON.parse(data);
                  console.log('-- data -->' + JSON.stringify(this.apiRespBody));
                   this.isError = true;
                   this.errorMsg = this.apiRespBody.Message;
                }
        }
    }
}