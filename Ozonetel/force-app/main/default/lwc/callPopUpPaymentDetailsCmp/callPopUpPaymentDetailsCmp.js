/**
 * **********************************************************************************************************
 * Lightning Web Component   :   callPopUpPaymentDetailsCmp
 * Includes                  :   callPopUpPaymentDetailsCmp.html, callPopUpPaymentDetailsCmp.js, callPopUpPaymentDetailsCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2023-DEC-13
 * @description  This component "callPopUpPaymentDetailsCmp" is created to show the refund details of predicted transaction on call details page.
 * @JiraId       CRM-1576
 */

import { LightningElement, track, api } from 'lwc';
import getPaymentDetails from '@salesforce/apex/callPopUpPaymentDetailsCtrl.fetchPaymentDetails';

export default class CallPopUpPaymentDetailsCmp extends LightningElement {
    @api  recordId;
    @track paymentDetails =[];
    @track refundOrdersList =[];
    @track isErrorOccured = false;
    @track errorMessage;
    @track isLoading = false;
    @track isGFTTransaction = false;
    @track transactionStatus;


    connectedCallback() {
        this.isLoading = true;
        getPaymentDetails({
            callDetailsId:this.recordId
        })
        .then(result=>{
            this.isLoading = false;
            console.log(':: result = '+JSON.stringify(result));
            if(result[0].isError){
                this.isErrorOccured = true;
                this.errorMessage = result[0].errorMessage;
            }else if(result[0].noRefunds){
                this.isErrorOccured = true;
                this.errorMessage = result[0].errorMessage;
            }else{
                if(result[0].isGFT){
                    this.isGFTTransaction = 'Booking Failed';
                }else{
                    this.isGFTTransaction = 'Booking confirmed';
                }
                this.transactionStatus = result[0].transactionStatus;
                this.paymentDetails = result[0].refundOrdersData;
                this.refundOrdersList = result[0].refundOrdersData;
                // console.log('::: paymentDetails = '+JSON.stringify(this.paymentDetails));
            }
        }).catch(error => {
            this.isLoading = false;
            this.isErrorOccured = true;
            this.errorMessage = 'An error occured. contact your system administrator.';
            console.log(':: errorMessage = '+JSON.stringify(error));
        });
    }
    
}