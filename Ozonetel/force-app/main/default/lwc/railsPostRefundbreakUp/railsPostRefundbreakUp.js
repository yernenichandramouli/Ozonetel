import { LightningElement, api, wire, track } from 'lwc';
import railsiRefundBreakUP from '@salesforce/apex/RailsPostRefundBreakCntrl.GetRailsRefundBreak';
export default class RailsRefundBreakUp extends LightningElement {
   
    @api recordId; 
    @track apiRespBody;
    @track errorCod;
    @track success;
    @track message;
    @track apierrorResponse;
    @track isError = false;
    @track totalAmountPaid;
    @track refundableAmount;
    @track cancellationChargesAmt;
    @track basicFareVal;
    @track basicRefundval;
    @track redRailsPGVal;
    @track redRailsPGRefundVal;
    @track agentServChrgeVal;
    @track agentServChrgeRefundVal;
    @track irctcConvFeeVal;
    @track irctcConvFeeRefundVal;
    @track showSection = false;
    @track fetchLoad =false;
    @track showFullbrkUp = false;
    @track strResp=[];
    @track pssgrLst = [];
    @track data=[];
    @track passengerWiseBreakup = [];
    @track passgnrWsebtnVisibility=false;
    @track bckTorefndBrkUpbtnVisibility=false;
    @track passgrfields = [
        { label: 'Passenger Name', fieldName: 'name',hideDefaultActions: true },
        { label: 'Fare', fieldName: 'fare' ,hideDefaultActions: true},
        { label: 'Refund', fieldName: 'refund' ,hideDefaultActions: true },
        { label: 'Cancellation Charge', fieldName: 'cancellationCharge' ,hideDefaultActions: true },
    ];

    @track refundfields = [
        { label: 'Component Name', fieldName: 'componentName',hideDefaultActions: true },
        { label: 'Amount Paid', fieldName: 'value' , hideDefaultActions: true,type: 'number', typeAttributes: { maximumFractionDigits: '2' } },
        { label: 'Amount Deducted', fieldName: 'deductionAmnt', hideDefaultActions: true , type: 'number', typeAttributes: { maximumFractionDigits: '2' },cellAttributes: {class: 'slds-text-color_error slds-text-title_caps'}},
        { label: 'Amount Refunded', fieldName: 'refundableValue' , hideDefaultActions: true,type: 'number', typeAttributes: { maximumFractionDigits: '2' } },
        
    ];


    @wire(railsiRefundBreakUP, {ordItemId:'$recordId' })
    wireMethod({error,data}){
        console.log('--recordId -->'+this.recordId);
        if(data){
            this.apiRespBody =JSON.parse(data);
            console.log('--resp data -->'+JSON.stringify(this.apiRespBody));
            console.log('=== this.strResp=='+ this.strResp);
            if (data != null && data !='') {
                this.apiRespBody =JSON.parse(data);
                this.errorCod = JSON.stringify(this.apiRespBody.errorcode);
               if(this.errorCod !=null && this.errorCod !=''){
                    this.isError = true;
                    this.showFullbrkUp=false;
                    this.message= JSON.stringify(this.apiRespBody.detailedmsg);
                    this.apierrorResponse =JSON.stringify(this.apiRespBody.errormsg);
                    console.log('----if= -->');
               }else{
                console.log('----else= -->');
                this.message='Response Success';
                var respObj =JSON.parse(data);
                this.showFullbrkUp=true;
                this.passgnrWsebtnVisibility=true;
                this.totalAmountPaid=respObj.totalFare;
                this.refundableAmount=respObj.refundAmount;
                this.cancellationChargesAmt=respObj.cancellationCharges;
                console.log('----paidAMt= -->'+this.totalAmountPaid);
                this.strResp=this.apiRespBody.refundFareBreakup;
               // If the "Discount" component is found in the list
/*const discountItem = this.apiRespBody.refundFareBreakup.find(item => item.componentName === "Discount");

// Check if the discountItem is found
if (discountItem) {
    // Access the refundableValue when componentName is "Discount"
    const refundableValueForDiscount = Math.abs(discountItem.refundableValue);
    console.log("Refundable Value for Discount:", refundableValueForDiscount);
} else {
    console.log("--No item found with componentName 'Discount'");
}*/
                /*this.strResp =  this.apiRespBody.refundFareBreakup.map(
                    record => Object.assign(
                                { "deductionAmnt": record.value - record.refundableValue},
                                record
                            
                        )    );*/
                     
            this.strResp = this.apiRespBody.refundFareBreakup.map(record => {
              return {
                ...record,
                //deductionAmnt: record.componentName === 'Discount' ?  Math.abs(record.refundableValue) : (record.value - record.refundableValue)
 deductionAmnt: record.componentName === 'Discount' ? Math.abs(record.refundableValue) :
                       (record.componentName === 'Ticket Charge' ? 0 :
                       (record.value - record.refundableValue)),

                       refundableValue : record.componentName === 'Ticket Charge' ? record.value :
                     record.refundableValue

              };
            });
              var NewRow = {"componentName":"Cancellation Charges","value":0,"refundableValue":-this.cancellationChargesAmt,"deductionAmnt":this.cancellationChargesAmt};

                this.strResp.push(NewRow);
               var Item = {"componentName":"Total","value":this.totalAmountPaid,"refundableValue":this.refundableAmount,"deductionAmnt":this.totalAmountPaid-this.refundableAmount};

                this.strResp.push(Item);
               }
        }
     }
  } 

  handleClick(event) {
    console.log('handleClick here');
    this.fetchLoad = true;
    this.showFullbrkUp=false;
    railsiRefundBreakUP({ ordItemId: this.recordId}).then(result => {
        if (result) {
            this.apiRespBody =JSON.parse(result);
            this.errorCod = JSON.stringify(this.apiRespBody.errorcode);
            console.log('ccccccstringify -->'+JSON.stringify(this.apiRespBody));
            if (result == 'Apex Error' || result == 'No Tin Found' || result == 'No API Response') {
                this.fetchLoad = false;
                this.showUpdMsg = true;
                this.notifType = 'error';
                this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code 1->';
            } else {

                if(this.errorCod !=null && this.errorCod !=''){
                    this.fetchLoad = false;
                    this.message= JSON.stringify(this.apiRespBody.detailedmsg);
                    this.apierrorResponse =JSON.stringify(this.apiRespBody.errormsg);
                
                 }else{
                    this.fetchLoad = false;
                    this.showSection = true;
                    this.bckTorefndBrkUpbtnVisibility=true;
                    this.passgnrWsebtnVisibility=false;
                   this.pssgrLst=this.apiRespBody.passengerWiseRefundables;
                  
                 }
            }
        }
    }).catch(error => {
        this.showUpdMsg = true;
        this.fetchLoad = false;
        this.notifType = 'error';
        this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code 3->' + error;
        console.log('errrr--->' + error);
    })
  } 
  returnToBreakupClick(event) {
    this.showFullbrkUp=true;
    this.showSection=false;
    this.passgnrWsebtnVisibility=true;
    this.bckTorefndBrkUpbtnVisibility=false;;

  }
}