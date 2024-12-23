/**
 * **********************************************************************************************************
 * Lightning Web Component   :   sgmyActivitesExceptionalRefundComponent
 * Includes                  :   sgmyActivitesExceptionalRefundComponent.html, sgmyActivitesExceptionalRefundComponent.js, sgmyActivitesExceptionalRefundComponent.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2023-Oct-11
 * @description  This component "sgmyActivitesExceptionalRefundComponent" is created to process exceptional refund flow for SGMY Activites.
 * @JiraId       CRM-1502
 */

import { LightningElement, track, api } from 'lwc';
import getMaxRefundAmount from '@salesforce/apex/sgmyActivitesExceptionalRefundCtrl.getRefundAmount';
import validateCaseNumber from '@salesforce/apex/sgmyActivitesExceptionalRefundCtrl.checkValidateParentCases';
import createExceptionalCase from '@salesforce/apex/sgmyActivitesExceptionalRefundCtrl.createExceptionalRefundCase';

export default class SgmyActivitesExceptionalRefundComponent extends LightningElement {
    @api recordId;
    @track refundReasonOptions=[{label:'--None--',value:'None'},{label:'Collectible From BO',value:'Collectible From BO'},{label:'Customer Delight',value:'Customer Delight'}, {label:'Zero Question Policy-Incorrect Booking',value:'ZQP Incorrect Booking'},{label:'Zero Question Policy-Incorrect Source/destination',value:'ZQP Incorrect source-destination'},{label:'Zero Question Policy-Incorrect Gender/Name Change',value:'ZQP Incorrect gender-nameChange'}, {label:'Technical Error',value:'Technical Error'},{label:'Instant refund - customer delight',value:'Instant refund - customer delight'},{label:'Instant refund - Collectible from BO',value:'Instant refund - Collectible from BO'}, {label:'OTG Refund',value:'OTG Refund'}];
    @track maxRefundAmount;
    @track isLoading=false;
    @track showInitiateCancellation=false;
    @track maxAmountToRefund;
    @track amountToBeRefund;
    @track parentCaseNumber;
    @track refundDescription;
    @track selectedRefundReason;
    @track errorMessage;
    @track successMessage;
    @track isError = false;
    @track isSuccess = false;
    @track invalidParentCaseId = false;



    nextStep(){
        this.isLoading=true;
        this.successMessage='';
        this.fetchMaxRefundAmount();
    }


    fetchMaxRefundAmount(){
            getMaxRefundAmount({
                activityId:this.recordId
            })
            .then(result=>{
                this.isLoading=false;
                if(result.isInvalidId){
                    this.isError = true;
                    this.errorMessage = 'Please enter related order number';
                }else if(result.isError){
                    this.isError = true;
                    this.errorMessage = result.customErrorMessage;
                }else{
                    this.showInitiateCancellation=true;
                    console.log('::: maxRefundAmount = '+result.data.maxRefundable.ACTIVITY[0].amount);
                    this.maxRefundAmount = result.data.currencyType+' '+result.data.maxRefundable.ACTIVITY[0].amount;
                }
            })
            .catch(error => {
                this.isLoading=false;
                console.log('Error '+JSON.stringify(error.message));
            });
    }

    handleRefundReasonChange(event){
        if(event.target.dataset.fieldName!==undefined && event.target.dataset.fieldName==='Refund_Reason'){
            this.selectedRefundReason= event.target.value;
        }
    }

    handleSubmitChange(){
        var inp;
        this.isLoading = true;
        this.submitApprovalErrorMsg = '';
        inp=this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element){
            if(element.name==="Amount to Refunded"){
                this.amountToBeRefund=element.value;
            }
            if(element.name==="Parent Case"){
                this.parentCaseNumber=element.value;
            }
            if(element.name==="Refund Description"){
                this.refundDescription=element.value;
            }
        },this);

        if(this.submitApproavlaPageValidations()){
            this.createExceptionalRefundCase();
        }
    }

    submitApproavlaPageValidations(){
        var maxRefundAmountSplit = this.maxRefundAmount.split(' '); 
        var maxAmount;
        this.errorMessage ='';
        this.isError = false;

        if(maxRefundAmountSplit.length>=2){
            maxAmount = maxRefundAmountSplit[1];
        }else{
            maxAmount = '0';
        }

        if(this.amountToBeRefund===undefined || this.amountToBeRefund===null || this.amountToBeRefund===''){
            this.errorMessage = 'Please enter the amount to be refunded.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.selectedRefundReason===undefined || this.selectedRefundReason===null || this.selectedRefundReason==='None'){
            this.errorMessage = 'Please select the refund reason.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.parentCaseNumber===undefined || this.parentCaseNumber===null || this.parentCaseNumber===''){
            this.errorMessage = 'Please enter parent case number.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.refundDescription===undefined || this.refundDescription===null || this.refundDescription===''){
            this.errorMessage = 'Please enter refund description.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }
        if(this.amountToBeRefund > maxAmount){
            this.errorMessage = 'Refund Amount should Greater than 0 and less than or equal to Max Refundable Amount.';
            this.isError = true;
            this.isLoading = false;
            return false;
        }

        if(this.parentCaseNumber!==undefined && this.parentCaseNumber!==null && this.validateForCaseCheck()){
            if(this.invalidParentCaseId){
                this.errorMessage = 'Please provide the valid Case Number.';
                this.isError = true;
                this.isLoading = false;
                return false;
            }
        }
        return true;
    }

    validateForCaseCheck(){
        validateCaseNumber({
            activityId:this.recordId,
            parentCase:this.parentCaseNumber
        })
        .then(result=>{
            let isInvalidCase = result;
            if(!isInvalidCase){
                this.invalidParentCaseId = true;
            }
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }

    createExceptionalRefundCase(){
        createExceptionalCase({
            parentCaseNumber:this.parentCaseNumber,
            activityId:this.recordId,
            refundReason:this.selectedRefundReason,
            refundAmount: this.amountToBeRefund,
            refundDescription:this.refundDescription
        })
        .then(result=>{
            if(result.isSuccess){
                this.isSuccess=true;
                this.isLoading = false;
                this.successMessage = result.status;
                this.showInitiateCancellation=false;
            }else{
                this.isError = true;
                this.isLoading = false;
                this.errorMessage = result.customErrorMessage;
            }
            console.log('::: CreateExceptionalCase'+result);
        })
        .catch(error => {
            this.isLoading = false;
            console.log('Error '+JSON.stringify(error.message));
        });
    }
}