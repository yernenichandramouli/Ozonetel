/**
 * **********************************************************************************************************
 * Lightning Web Component   :   getB2bBusAssignmentDetails
 * Includes                  :   getB2bBusAssignmentDetails.html, getB2bBusAssignmentDetails.js, getB2bBusAssignmentDetails.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      06 DEC 2023
 * @description  This component "getB2bBusAssignmentDetails" is created to fetch bus details for B2b Transactions.
 * @JiraId       CRM-1589
 */
import { api, LightningElement, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBusAssignmentDetails from '@salesforce/apex/B2bBusAssignmentDetailsCtrl.getBusAssignmentDetails';

export default class GetB2bBusAssignmentDetails extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track isError = false;
    @track busDetailData=[];
    @track fetchedBusDetailsData=[];
    @track operatorName; @track vehicleNumber; @track driverNumber; @track driverName; @track conductorNumber;
    @track conductorName; @track source; @track destination; @track passengerCount;

    connectedCallback() {
        this.isLoading=true;
        console.log("====connectedCallback:recordId=====", this.recordId);
        this.sleep(1000).then(() => {
            console.log("====connectedCallback:recordId2=====", this.recordId);
            this.b2bBusDetailsFetch();
        });
    }

    sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToastMessage(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }


    b2bBusDetailsFetch(){
        console.log(this.recordId + ' is provided');
        getBusAssignmentDetails({
            transactionId:this.recordId
        })
        .then(result=>{
            this.isLoading=false;
            if(result.Error){
                this.showToastMessage('Exception occured. Please contact system administartor.', JSON.stringify(result.message), 'error');
                this.closeAction();
                
            }else{                
                    this.busDetailData = result;
                    console.log('::: busDetailData= '+JSON.stringify(this.busDetailData.data));
                    this.operatorName = (this.busDetailData.data[0].operatorName!==null && this.busDetailData.data[0].operatorName!==undefined && this.busDetailData.data[0].operatorName!==null)?this.busDetailData.data[0].operatorName:'No Data';
                    this.vehicleNumber = (this.busDetailData.data[0].vehicleNumber!==null && this.busDetailData.data[0].vehicleNumber!==undefined && this.busDetailData.data[0].vehicleNumber!==null)?this.busDetailData.data[0].vehicleNumber:'No Data';
                    this.driverNumber = (this.busDetailData.data[0].driverNumber!==null && this.busDetailData.data[0].driverNumber!==undefined && this.busDetailData.data[0].driverNumber!==null)?this.busDetailData.data[0].driverNumber:'No Data';
                    this.driverName = (this.busDetailData.data[0].driverName!==null && this.busDetailData.data[0].driverName!==undefined && this.busDetailData.data[0].driverName!==null)?this.busDetailData.data[0].driverName:'No Data';
                    this.conductorNumber = (this.busDetailData.data[0].conductorNumber!==null && this.busDetailData.data[0].conductorNumber!==undefined && this.busDetailData.data[0].conductorNumber!==null)?this.busDetailData.data[0].conductorNumber:'No Data';
                    this.conductorName = (this.busDetailData.data[0].conductorName!==null && this.busDetailData.data[0].conductorName!==undefined && this.busDetailData.data[0].conductorName!==null)?this.busDetailData.data[0].conductorName:'No Data';
                    this.source = (this.busDetailData.data[0].source!==null && this.busDetailData.data[0].source!==undefined && this.busDetailData.data[0].source!==null)?this.busDetailData.data[0].source:'No Data';
                    this.destination = (this.busDetailData.data[0].destination!==null && this.busDetailData.data[0].destination!==undefined && this.busDetailData.data[0].destination!==null)?this.busDetailData.data[0].destination:'No Data';
                    this.passengerCount = (this.busDetailData.data[0].passengerCount!==null && this.busDetailData.data[0].passengerCount!==undefined && this.busDetailData.data[0].passengerCount!==null)?this.busDetailData.data[0].passengerCount:'No Data';
                    console.log('data----- '+this.data);
            }
        })
        .catch(error => {
            this.isLoading=false;
            this.showToastMessage('Operator Id Doesnot exist in YB.', 'Please Contact system Administrator', 'error');
            this.closeAction();
            console.log('Error '+JSON.stringify(error.message));
        });
    }
}