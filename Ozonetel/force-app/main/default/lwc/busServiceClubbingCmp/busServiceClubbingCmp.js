/**
 * **********************************************************************************************************
 * Lightning Web Component   :   busServiceClubbingCmp
 * Includes                  :   busServiceClubbingCmp.html, busServiceClubbingCmp.js, busServiceClubbingCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2022-DEC-14
 * @description  This component is created to display busshift changes.
 * @JiraId       CRM-1257
 */
import { LightningElement,api,track} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getbusShiftData from '@salesforce/apex/serviceClubbingCtrl.getBusShiftDetails';

export default class BusServiceClubbingCmp extends LightningElement {
    @api recordId;
    @track busHistoryData = [];
    @track updatedDetailsList=[];
    @track prevDetailsList=[];
    @track isError = false;
    @track isLoading = true;
    @track updatedBoardingTime;
    @track updatedBoardingPoint;
    @track updatedBusType;
    @track updatedSpName;
    @track prevBoardingTime;
    @track prevBoardingPoint;
    @track prevBusType;
    @track prevSpName;
    @track columns = [
        { label: 'Name Type', fieldName: 'NameType' },
        { label: 'Updated Value', fieldName: 'UpdatedValue' },
        { label: 'Previous Value', fieldName: 'PreviousValue' }
    ];
    @track data=[];
    @track hideButton=false;

    connectedCallback() {
        console.log('connected===============');
        console.log(this.recordId + ' is null');
    }

    renderedCallback() {
        console.log('rendered------------');
        console.log(this.recordId + ' is provided');
        this.fetchBusShiftDetails();
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    fetchBusShiftDetails(){
        getbusShiftData({
            transactionId:this.recordId
        })
        .then(result=>{
            this.hideButton=true;
            this.isLoading=false;
            if(result.Error){
                this.isError=true;
                console.log('::: No Data Avialable :: ');
            }else{
                this.showResponse=true;
                console.log('result '+result);
                this.busHistoryData = result;
                this.updatedDetailsList = JSON.parse(this.busHistoryData.updatedDetails);
                this.updatedBoardingTime = (this.updatedDetailsList!==null && this.updatedDetailsList.boardingTime!==undefined && this.updatedDetailsList.boardingTime!==null)?this.updatedDetailsList.boardingTime:'No Data';
                this.updatedBoardingPoint = (this.updatedDetailsList!==null && this.updatedDetailsList.boardingPoint!==undefined && this.updatedDetailsList.boardingPoint!==null)?this.updatedDetailsList.boardingPoint:'No Data';
                this.updatedBusType = (this.updatedDetailsList!==null && this.updatedDetailsList.busType!==undefined && this.updatedDetailsList.busType!==null)?this.updatedDetailsList.busType:'No Data';
                this.updatedSpName = (this.updatedDetailsList!==null && this.updatedDetailsList.serviceProviderName!==undefined && this.updatedDetailsList.serviceProviderName!==null)?this.updatedDetailsList.serviceProviderName:'No Data';
                this.prevDetailsList = JSON.parse(this.busHistoryData.prevDetails);
                this.prevBoardingTime = (this.prevDetailsList!==null && this.prevDetailsList.boardingTime!==undefined && this.prevDetailsList.boardingTime!==null)?this.prevDetailsList.boardingTime:'No Data';
                this.prevBoardingPoint = (this.prevDetailsList!==null && this.prevDetailsList.boardingPoint!==undefined && this.prevDetailsList.boardingPoint!==null)?this.prevDetailsList.boardingPoint:'No Data';
                this.prevBusType = (this.prevDetailsList!==null && this.prevDetailsList.busType!==undefined && this.prevDetailsList.busType!==null)?this.prevDetailsList.busType:'No Data';
                this.prevSpName = (this.prevDetailsList!==null && this.prevDetailsList.serviceProviderName!==undefined && this.prevDetailsList.serviceProviderName!==null)?this.prevDetailsList.serviceProviderName:'No Data';
                this.data=[
                    {NameType:'Boarding Time',UpdatedValue:this.updatedBoardingTime,PreviousValue:this.prevBoardingTime},
                    {NameType:'Boarding Point',UpdatedValue:this.updatedBoardingPoint,PreviousValue:this.prevBoardingPoint},
                    {NameType:'Bus Type',UpdatedValue:this.updatedBusType,PreviousValue:this.prevBusType},
                    {NameType:'Service Provider',UpdatedValue:this.updatedSpName,PreviousValue:this.prevSpName}
                ];
            }
            
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }
}