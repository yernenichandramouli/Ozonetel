import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import railsiRefundBreakUP from '@salesforce/apex/RailsPostRefundBreakCntrl.GetRailsRefundBreak';
import railsiRefundList from '@salesforce/apex/RailsPostRefundBreakCntrl.GetRailsRefundList';
import fetchRefundDetailsApex from '@salesforce/apex/RailsPostRefundBreakCntrl.GetRailsRefundDetailsBreakUP';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class RailsPostRefundDetails extends LightningElement {

    @api recordId;
    @track apiRespBody;
    @track isLoading = true; // Initialize isLoading to true
    @track responseRefundListData = [];
    @track isRefundList = true;
    @track responseRefundBrkViewList = [];
    @track isRefundBrkupView = false;
    @track totalDeductionsAdded = false; // Flag to track if Total Deductions is already added
    @track errorCod;
    @track errordtlMessage;
    @track errorMsg;
    @track totalRefundAmnt;
    @track isError = false;

    @wire(railsiRefundList, {
        ordItemId: '$recordId'
    })
    wireMethod({
        error,
        data
    }) {
        console.log('--recordId -->' + this.recordId);
        this.isRefundBrkupView = false;
        if (data != null && data != '') {
            console.log('>>data>>>' + data);
            this.apiRespBody = JSON.parse(data);
            this.errorCod = JSON.stringify(this.apiRespBody.errorcode);
            this.totalRefundAmnt = JSON.stringify(this.apiRespBody.totalRefund);
            this.responseRefundListData = this.apiRespBody.data;
                if (this.errorCod != null && this.errorCod != '') {
                    this.isError = true;
                    this.isRefundList = false;
                    this.errordtlMessage = JSON.stringify(this.apiRespBody.detailedmsg);
                    this.errorMsg = JSON.stringify(this.apiRespBody.errormsg);
                    console.log('----if= -->');
               } else if(this.responseRefundListData.length === 0){
                    this.isError = true;
                    this.isRefundList = false;  
                    this.errorMsg = 'Refund Amount is  '+this.totalRefundAmnt;
                    this.errordtlMessage = 'There are NO refunds for this Ticket';
               }
                else { 
                    this.responseRefundListData = this.apiRespBody.data;
                    console.log('>> this.responseData>>>' + this.responseRefundListData);
                }
        } else if (error) {
            this.isLoading = false;
            this.isRefundBrkupView = false;
            console.error('Error retrieving data:', error);
        }
    }

    handleViewRefundBrkButtonClick(event) {
        const itemUuid = event.target.dataset.itemUuid;
        // Use itemUuid as needed
        console.log('>>Item UUID:', itemUuid);
        this.callingRefundDetailsView(itemUuid);
    }

    callingRefundDetailsView(itemUuid) {
        // Call the Apex method with the parameter
        this.isRefundBrkupView = true;
        this.isRefundList = false;

        fetchRefundDetailsApex({
                orderItemUuid: itemUuid
            })
            .then(result => {
                // Handle the result if needed
                console.log('Apex method result:', result);
                // Parse the result and extract the breakDownTable
                this.apiRespBody = JSON.parse(result);
                let totalDeductionsProcessed = false;
                           
                 if (this.apiRespBody && this.apiRespBody.tgOfferData) {
                    const tgOfData = this.apiRespBody.tgOfferData;
                    const sgHeading = tgOfData ? tgOfData.heading : undefined;
                    const sgOffrText = tgOfData ? tgOfData.offerText : undefined;
                    this.sgHeading = sgHeading;
                    this.sgOffrText = sgOffrText;

                 }
                 
                this.apiRespBody.breakDownTable.forEach(breakDown => {
                    if (breakDown.componentName === 'Total Deductions' && !totalDeductionsProcessed) {
                        breakDown.amount = '-'+' '+breakDown.amount;
                        this.responseRefundBrkViewList.push(breakDown);
                        totalDeductionsProcessed = true;

                        if (breakDown.detailedBreakDown && breakDown.detailedBreakDown.length > 0) {
                            breakDown.detailedBreakDown.forEach(detailedBreakDownItem => {
                                detailedBreakDownItem.amount = '-'+' '+detailedBreakDownItem.amount;
                                //this.responseRefundBrkViewList.push(detailedBreakDownItem);
                            });
                        }
                    } else if (breakDown.componentName === 'Total Refund') {
                        // Skip this entry, don't add it to responseData
                        // If you want to remove detailedBreakDown list for Total Refund, set it to an empty array
                        breakDown.detailedBreakDown = [];
                        this.responseRefundBrkViewList.push(breakDown);
                    } else if (breakDown.componentName !== 'Total Deductions') {
                        this.responseRefundBrkViewList.push(breakDown);

                    }

                });
            })
            .catch(error => {
                // Handle any errors
                console.error('Error calling Apex method:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error calling Apex method',
                        variant: 'error',
                    })
                );
            });
    }

    handleBacktToRfndLstClick(event) {
        this.isRefundBrkupView = false;
        this.isRefundList = true;
        this.responseRefundBrkViewList = [];
    }
}