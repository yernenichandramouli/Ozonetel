import { LightningElement, track, api} from 'lwc';
import fetchMaxRefundAmount from '@salesforce/apex/exceptionalRefundHotelsCtrl.getMaxRefundAmount';
import submitForApproval from '@salesforce/apex/exceptionalRefundHotelsCtrl.submitForApproval';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ExceptionalRefundHotels extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track showExceptionalButton = true;
    @track showExceptionalRefundPage = false;
    @track errorMessageToShow;
    @track isError=false;
    @track issuccess=false;
    @track successMessageToShow;
    @track refundReasonValues = [      
        {label : 'Collectible From BO', value :'Collectible From BO'}, 
        {label : 'Customer Delight', value :'Customer Delight'},
        {label : 'Technical Error', value :'Technical Error'},
        {label : 'Instant refund - customer delight', value :'Instant refund - customer delight'},
        {label : 'Instant refund - Collectible from BO', value :'Instant refund - Collectible from BO'}
    ];
    @track maxRefundAmountToShow;
    @track maxRefundAmount;

    handleExceRefundClick(){
        this.isLoading = true;
        console.log(':: Inside handleExceRefundClick :: '+this.recordId);
        fetchMaxRefundAmount({
            transactionId:this.recordId
        })
        .then(result=>{
            this.isLoading = false;
            this.showExceptionalButton = false;
            console.log(':: Inside result ' +JSON.stringify(result));
            if(result.hasErrorOccured){
                this.errorMessageToShow = result.errorMessage;
                this.isError = true
            }else{
                const currency = result.data.currencyType; // 'INR'
                const amount = result.data.amount; // 950
                this.showExceptionalRefundPage = true;
                this.maxRefundAmount = result.data.amount;
                this.maxRefundAmountToShow = `${currency} ${amount}`;
                console.log('maxRefundAmountToShow '+this.maxRefundAmountToShow);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.showExceptionalRefundPage = false;
            console.log('Error '+JSON.stringify(error.message));
        });
    }


    //Function To Fetch Arrival Patterns
    handleSubmitForApprovalClick(){
        this.isLoading = true;
        var refundAmountEntered = this.template.querySelector('[data-field-name="refundAmount"]').value ;
        const parentCaseNumber = this.template.querySelector('[data-field-name="parentCase"]').value ;
        const selectedRefundResn = this.template.querySelector('[data-field-name="refundReason"]').value ;
        const selectedRefundDesc = this.template.querySelector('[data-field-name="refundDescription"]').value ;
        refundAmountEntered = parseInt(refundAmountEntered);
        submitForApproval({
            orItemId:this.recordId,
            maxRefundAmount:parseInt(this.maxRefundAmount),
            amountToRefund:refundAmountEntered,
            parentCase:parentCaseNumber,
            refundReason:selectedRefundResn,
            refundDescp:selectedRefundDesc
        })
        .then(result=>{
            this.isLoading = false;
            if(result){
                this.issuccess = true;
                this.successMessageToShow ='Case has been submitted for approval.';
                this.showExceptionalRefundPage = false;
                console.log(':: result :: ', +result);
            }
        })
        .catch(error => {
            this.isLoading = false;
            console.log('Error '+JSON.stringify(error.body.message));
            this.showToast('Something went wrong', error.body.message, 'error');
            return;
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}