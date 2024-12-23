/**
 * **********************************************************************************************************
 * Lightning Web Component   :   YbDashboardLink
 * Includes                  :   YbDashboardLink.html, YbDashboardLink.js, YbDashboardLink.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2022-Oct-13
 * @description  This component "YbDashboardLink" is created to revamp the existing YB Dashboard.
 * @JiraId       CRM-1185
 */


import { LightningElement,api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BOARDING_POINT from '@salesforce/schema/Order_Items__c.Boarding_Point__c';
import DROPPING_POINT from '@salesforce/schema/Order_Items__c.Dropping_Point__c';
import BUSINESS_UNIT from '@salesforce/schema/Order_Items__c.Business_Unit__c';
import getAllBps from '@salesforce/apex/YBDashBoardLinkController.GetAllBps';
import getArrivalPatterns from '@salesforce/apex/YBDashBoardLinkController.Getarrivalpatterns';
import gettrackingDetails from '@salesforce/apex/YBDashBoardLinkController.GetTrackingDetails';
const fields = [BOARDING_POINT, DROPPING_POINT, BUSINESS_UNIT];

export default class YbDashboardLink extends LightningElement {
    @api recordId;
    @track allBps;
    @track isLoading = true;
    @track areDetailsVisible= false;
    @track selectedBpValue;
    @track arrivalData;
    @track trackingDetailsData;
    @track bpNameList = [];
    @track getScheduledTime;
    @track customerYBLink;
    @track customerRBLink;
    @track driverName1;
    @track driverMobile1;
    @track driverName2;
    @track driverMobile2;
    @track arrivalPatternsList = [];
    @track trackingDetailsList = [];
    @track bpListData = [];
    @track onChangeSelectedValue;
    @track selectedBpId;
    @track isArrivalError=false;
    @track isTrackingDetailsError=false;
    @track isGetAllBPsError=false;
    @track allBPErrorMessage;
    @track arrivalErrorMessage;
    @track vehicleNo;
    @track disbaleGetDetialsBtn =true;
    @track conductorName;
    @track conductorMobile;
    @track hideDetails=true;
    @track trackingDetailsErrorMessage;
    @track busiUnit;

    @wire(getRecord, { recordId: '$recordId', fields })
    transaction;
    get boardingPoint() {
        return getFieldValue(this.transaction.data, BOARDING_POINT);
    }
    get droppingPoint() {
        return getFieldValue(this.transaction.data, DROPPING_POINT);
    }

    // get businessUnit(){
    //     this.busiUnit = getFieldValue(this.transaction.data, BUSINESS_UNIT);
    //     console.log(':: busiUnit :: ', +this.busiUnit);
    //     if(this.busiUnit==='REDBUS_IN'){
    //         return true;
    //     }
    //     return false;
    // }
    
    search(selectedBpName, myArray){
        var i;
        for (i=0; i < myArray.length; i++) {
            if (myArray[i].bpName === selectedBpName) {
                return myArray[i].rbBpId;
            }
        }
    }
    handleTypeChange(event){
        this.onChangeSelectedValue = this.template.querySelector("[data-id='Available Values']").value;
        this.disbaleGetDetialsBtn = this.onChangeSelectedValue!==null?false:true;
        this.selectedBpId = this.search(this.onChangeSelectedValue, this.bpListData);
        console.log(':: selectedBpId :: ', +this.selectedBpId);
        this.areDetailsVisible = false;
    }
    handleClick(event){
        this.selectedBpValue = this.template.querySelector("[data-id='Available Values']").value;
        console.log(':: Selected BP Name :: ', +this.selectedValue);
        this.isLoading=true;
        this.fetchTrackingDetails();
        this.fetchArrivalPatterns();
    }

    handlehideDetails(event){
        var i;
        this.hideDetails=false;
        if(this.hideDetails === false){
            getAllBps({
                transactionId:this.recordId
            })
            .then(result=>{
                this.isLoading=false;
                console.log('::: getAllBps ::: '+result);
                this.allBps=JSON.parse(result);
                this.allBps=JSON.parse(this.allBps);
                this.bpListData=this.allBps.data;
                if(this.bpListData===null){
                    this.isGetAllBPsError = true;
                    this.allBPErrorMessage = 'Boarding points not found';
                }else{
                    for (i = 0; i < this.allBps.data.length; i++ ) {
                    this.bpNameList = [...this.bpNameList, { label: this.allBps.data[i].bpName, value: this.allBps.data[i].bpName }];
                }
                }
                //console.log(':: bpListData :: '+this.bpListData);
                
            })
            .catch(error => {
                console.log('Error '+JSON.stringify(error.message));
            });
        }
    }
     //Function To Fetch Arrival Patterns
    fetchArrivalPatterns(){
        var newArrayList = [];
        getArrivalPatterns({
            transactionId:this.recordId,
            boardingPointId:this.selectedBpId
        })
        .then(result=>{
            this.isLoading=false;
            this.areDetailsVisible = true;
            this.arrivalData=JSON.parse(result);
            // this.arrivalData=JSON.parse(this.arrivalData);
            if(this.arrivalData.statusCode ==='NOT_ENOUGH_DATA' || this.arrivalData.data===null){
                this.isArrivalError = true;
                this.arrivalErrorMessage = this.arrivalData.msg;
            }else{
                this.isArrivalError = false;
                this.arrivalPatternsList = this.arrivalData.data.arrivalTrends;
                this.getScheduledTime = this.arrivalData.data.scheduleTime;
                let alldata=this.arrivalData.data.arrivalTrends;
                alldata.forEach(function (record) {
                    Object.keys(record).forEach(function (key) {
                        if(key ==='delay'){
                            if(JSON.stringify(record[key]).includes('-')){
                                record[key] = JSON.stringify(record[key]).replace('-', 'Early By ');
                            }else{
                                record[key] = JSON.stringify(record[key]).replace('', 'Late By ');
                            }
                        }
                        
                    });
                    newArrayList.push(record);
                });
            }
        })
        .catch(error => {
            this.isLoading=false;
            this.areDetailsVisible = true;
            console.log('Error '+JSON.stringify(error.message));
        });
    }
      //Function To Fetch Tracking Details
    fetchTrackingDetails(){
        gettrackingDetails({
            transactionId:this.recordId
        })
        .then(result=>{
            console.log(':: Result ::: '+JSON.parse(result));
            this.isLoading=false;
            this.areDetailsVisible = true;
            this.trackingDetailsData=JSON.parse(result);
            console.log('::: trackingDetailsData :: '+this.trackingDetailsData.data);
            if(this.trackingDetailsData==='JourneyExpired'){
                this.isTrackingDetailsError=true;
                this.trackingDetailsErrorMessage='No Data available for Past journeys';
            }else if(this.trackingDetailsData.statusCode ==='TIN_NOT_FOUND' || this.trackingDetailsData.data==null){
                this.isTrackingDetailsError=true;
                this.trackingDetailsErrorMessage=this.trackingDetailsData.msg;
            }
            else{
            this.isTrackingDetailsError=false;
            this.trackingDetailsList = this.trackingDetailsData.data.eta;
            console.log('::: trackingDetailsList :: '+this.trackingDetailsList);
            this.customerYBLink = this.trackingDetailsData.data.ybTrackingLink;
            this.customerRBLink = this.trackingDetailsData.data.rbTrackingLink!==undefined?this.trackingDetailsData.data.rbTrackingLink:'No Data';
            this.driverMobile1 = (this.trackingDetailsData.data.driver_mobile_1!==undefined && this.trackingDetailsData.data.driver_mobile_1!==null)?this.trackingDetailsData.data.driver_mobile_1:'No Data';
            this.driverName1 = (this.trackingDetailsData.data.driver_name_1!==undefined && this.trackingDetailsData.data.driver_name_1!==null)?this.trackingDetailsData.data.driver_name_1:'No Data';
            this.driverMobile2 = (this.trackingDetailsData.data.driver_mobile_2!==undefined && this.trackingDetailsData.data.driver_mobile_2!==null)?this.trackingDetailsData.data.driver_mobile_2:'No Data';
            this.driverName2 = (this.trackingDetailsData.data.driver_name_2!==undefined && this.trackingDetailsData.data.driver_name_2!==null)?this.trackingDetailsData.data.driver_name_2:'No Data';
            this.vehicleNo = (this.trackingDetailsData.data.vehRegnNo!==undefined && this.trackingDetailsData.data.vehRegnNo!==null)?this.trackingDetailsData.data.vehRegnNo:'No Data';
            this.conductorName = (this.trackingDetailsData.data.helper_name!==undefined && this.trackingDetailsData.data.helper_name!==null)?this.trackingDetailsData.data.helper_name:'No Data';
            this.conductorMobile = (this.trackingDetailsData.data.helper_mobile!==undefined && this.trackingDetailsData.data.helper_mobile!==null)?this.trackingDetailsData.data.helper_mobile:'No Data';
            }
        })
        .catch(error => {
            this.isLoading=false;
            this.areDetailsVisible = true;
            console.log('Error '+error.message);
        });
    }
}