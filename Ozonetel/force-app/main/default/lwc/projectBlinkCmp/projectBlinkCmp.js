import { LightningElement, track, wire, api } from 'lwc';
import fetchDojFareAndBPDetails from '@salesforce/apex/projectBlinkCtrl.createExceptionalRefundCase';
import getWhatsappStatusInfo from '@salesforce/apex/projectBlinkCtrl.GetWhatsappStatus';
import getTicketCancellationDetails from '@salesforce/apex/projectBlinkCtrl.getTicketCancellationEvents';


export default class ProjectBlinkCmp extends LightningElement {
    @api  recordId;
    @track tabContent = '';
    @track apiResponseData=[];
    @track dojData=[];
    @track fareDetailsData =[];
    @track bpTimingsData=[];
    @track createdDOJ; @track confimedDOJ; @track tentativedDOJ;
    @track createdboardingTime; @track confimedboardingTime; @track tentativedboardingTime;
    @track createdTimeOfEvent; @track confimedTimeOfEvent; @track tentativeTimeOfEvent;
    @track createdDOI; @track confimedDOI; @track tentativeDOI;
    @track createdorderId; @track confimedorderId; @track tentativeorderId;
    @track createdTIN; @track confimedTIN; @track tentativeTIN;
    @track createdUserSelectedData; @track confimedUserSelectedData; @track tentativeUserSelectedData;
    @track createdTicketFare; @track confimedTicketFare; @track tentativeTicketFare;
    @track createdBaseFare; @track confimedBaseFare; @track tentativeBaseFare;
    @track createdServiceTax; @track confimedServiceTax; @track tentativeServiceTax;
    @track createdDiscount; @track confimedDiscount; @track tentativeDiscount;
    @track createdSeatCount; @track confimedSeatCount; @track tentativeSeatCount;
    @track createdBp; @track tentativeBp; @track confimedBp;
    @track createdBpLandmark; @track tentativeBpLandmark; @track confimedBpLandmark;
    @track isError=false;
    @track errorMessage;
    @track whatsApperrorMessage;
    @track isLoading = false;
    @track watsUpData = [];
    @track isWatsUpError =false;
    @track isWatsUpSuccess =false;
    @track  isWatsapBtn = true;
    @track isTcValError = false;
     @track eventTabs = [];
    @track tabColumns = [];

    @track columns = [
        { label: '', fieldName: 'paramValue' },
        { label: 'Created', fieldName: 'CREATED' },
        { label: 'Tentative Successful', fieldName: 'TENTATIVE_SUCCESSFUL' },
        { label: 'Confirmed', fieldName: 'CONFIRMED' }
    ];

     @track watcolumns = [
        { label: 'Requested At', fieldName: 'requestedat' },
        { label: 'Sent At', fieldName: 'sentAt' },
        { label: 'Delivered At', fieldName: 'deliveredAt' },
        { label: 'Read At', fieldName: 'readAt' },
        { label: 'Message Tag', fieldName: 'messageTag' }
       
    ];
 
    connectedCallback() {
        this.isLoading = true;
        
        fetchDojFareAndBPDetails({
            transactionId:this.recordId
        })
        .then(result=>{
            this.isLoading = false;
            if(result){
                if(result==='Received InValid response from API. Please contact administartor.' || result==='No records found' || result==='Exception occured, Please contact administartor.' || result==='Invalid Transaction Id. Please contact administartor' || result==='Invalid business unit. Please contact administartor'){
                    this.isError=true;
                    this.errorMessage=result;
                }else{
                    this.apiResponseData=JSON.parse(result);
                    console.log('::: apiResponseData = '+this.apiResponseData);
                    let alldata=this.apiResponseData.data;
                    console.log('::: alldata = '+this.apiResponseData);
                    alldata.forEach(item => {
                        if (item.Status === "CREATED") {
                            console.log('::: Item DOJ = '+item.DateOfJourney);
                            this.createdDOJ = (item.DateOfJourney!==undefined && item.DateOfJourney!==null && item.DateOfJourney!=='')?item.DateOfJourney:'No Data';
                            this.createdboardingTime = (item.BoardingTime!==undefined && item.BoardingTime!==null && item.BoardingTime!=='')?item.BoardingTime:'No Data';
                            this.createdTimeOfEvent = (item.TimeOfEvent!==undefined && item.TimeOfEvent!==null && item.TimeOfEvent!=='')?item.TimeOfEvent:'No Data';
                            this.createdorderId = (item.OrderId!==undefined && item.OrderId!==null && item.OrderId!=='')?item.OrderId:'No Data';
                            this.createdDOI = (item.DateOfIssue!==undefined && item.DateOfIssue!==null && item.DateOfIssue!=='')?item.DateOfIssue:'No Data';
                            this.createdTIN = (item.Tin!==undefined && item.Tin!==null && item.Tin!=='')?item.Tin:'No Data';
                            this.createdUserSelectedData = (item.UserSelectedDate!==undefined && item.UserSelectedDate!==null && item.UserSelectedDate!=='')?item.UserSelectedDate:'No Data';
                            this.createdTicketFare = (item.TicketFare!==undefined && item.TicketFare!==null && item.TicketFare!=='')?item.TicketFare:'No Data';
                            this.createdBaseFare = (item.BaseFare!==undefined && item.BaseFare!==null && item.BaseFare!=='')?item.BaseFare:'No Data';
                            this.createdServiceTax = (item.ServiceTax!==undefined && item.ServiceTax!==null && item.ServiceTax!=='')?item.ServiceTax:'No Data';
                            this.createdDiscount = (item.Discount!==undefined && item.Discount!==null && item.Discount!=='')?item.Discount:'No Data';
                            this.createdSeatCount = (item.SeatCount!==undefined && item.SeatCount!==null && item.SeatCount!=='')?item.SeatCount:'No Data';
                            this.createdBp = (item.BoardingPoint!==undefined && item.BoardingPoint!==null && item.BoardingPoint!=='')?item.BoardingPoint:'No Data';
                            this.createdBpLandmark = (item.BoardingPointLandmark!==undefined && item.BoardingPointLandmark!==null && item.BoardingPointLandmark!=='')?item.BoardingPointLandmark:'No Data';
                        } else if (item.Status === "TENTATIVE_SUCCESSFUL") {
                            this.tentativedDOJ = (item.DateOfJourney!==undefined && item.DateOfJourney!==null && item.DateOfJourney!=='')?item.DateOfJourney:'No Data';
                            this.tentativedboardingTime = (item.BoardingTime!==undefined && item.BoardingTime!==null && item.BoardingTime!=='')?item.BoardingTime:'No Data';
                            this.tentativeTimeOfEvent = (item.TimeOfEvent!==undefined && item.TimeOfEvent!==null && item.TimeOfEvent!=='')?item.TimeOfEvent:'No Data';
                            this.tentativeorderId = (item.OrderId!==undefined && item.OrderId!==null && item.OrderId!=='')?item.OrderId:'No Data';
                            this.tentativeDOI = (item.DateOfIssue!==undefined && item.DateOfIssue!==null && item.DateOfIssue!=='')?item.DateOfIssue:'No Data';
                            this.tentativeTIN = (item.Tin!==undefined && item.Tin!==null && item.Tin!=='')?item.Tin:'No Data';
                            this.tentativeUserSelectedData = (item.UserSelectedDate!==undefined && item.UserSelectedDate!==null && item.UserSelectedDate!=='')?item.UserSelectedDate:'No Data';
                            this.tentativeTicketFare = (item.TicketFare!==undefined && item.TicketFare!==null && item.TicketFare!=='')?item.TicketFare:'No Data';
                            this.tentativeBaseFare = (item.BaseFare!==undefined && item.BaseFare!==null && item.BaseFare!=='')?item.BaseFare:'No Data';
                            this.tentativeServiceTax = (item.ServiceTax!==undefined && item.ServiceTax!==null && item.ServiceTax!=='')?item.ServiceTax:'No Data';
                            this.tentativeDiscount = (item.Discount!==undefined && item.Discount!==null && item.Discount!=='')?item.Discount:'No Data';
                            this.tentativeSeatCount = (item.SeatCount!==undefined && item.SeatCount!==null && item.SeatCount!=='')?item.SeatCount:'No Data';
                            this.tentativeBp = (item.BoardingPoint!==undefined && item.BoardingPoint!==null && item.BoardingPoint!=='')?item.BoardingPoint:'No Data';
                            this.tentativeBpLandmark = (item.BoardingPointLandmark!==undefined && item.BoardingPointLandmark!==null && item.BoardingPointLandmark!=='')?item.BoardingPointLandmark:'No Data';
                        }else if(item.Status === "CONFIRMED"){
                            this.confimedDOJ = (item.DateOfJourney!==undefined && item.DateOfJourney!==null && item.DateOfJourney!=='')?item.DateOfJourney:'No Data';
                            this.confimedboardingTime = (item.BoardingTime!==undefined && item.BoardingTime!==null && item.BoardingTime!=='')?item.BoardingTime:'No Data';
                            this.confimedTimeOfEvent = (item.TimeOfEvent!==undefined && item.TimeOfEvent!==null && item.TimeOfEvent!=='')?item.TimeOfEvent:'No Data';
                            this.confimedorderId = (item.OrderId!==undefined && item.OrderId!==null && item.OrderId!=='')?item.OrderId:'No Data';
                            this.confimedDOI = (item.DateOfIssue!==undefined && item.DateOfIssue!==null && item.DateOfIssue!=='')?item.DateOfIssue:'No Data';
                            this.confimedTIN = (item.Tin!==undefined && item.Tin!==null && item.Tin!=='')?item.Tin:'No Data';
                            this.confimedUserSelectedData = (item.UserSelectedDate!==undefined && item.UserSelectedDate!==null && item.UserSelectedDate!=='')?item.UserSelectedDate:'No Data';
                            this.confimedTicketFare = (item.TicketFare!==undefined && item.TicketFare!==null && item.TicketFare!=='')?item.TicketFare:'No Data';
                            this.confimedBaseFare = (item.BaseFare!==undefined && item.BaseFare!==null && item.BaseFare!=='')?item.BaseFare:'No Data';
                            this.confimedServiceTax = (item.ServiceTax!==undefined && item.ServiceTax!==null && item.ServiceTax!=='')?item.ServiceTax:'No Data';
                            this.confimedDiscount = (item.Discount!==undefined && item.Discount!==null && item.Discount!=='')?item.Discount:'No Data';
                            this.confimedSeatCount = (item.SeatCount!==undefined && item.SeatCount!==null && item.SeatCount!=='')?item.SeatCount:'No Data';
                            this.confimedBp = (item.BoardingPoint!==undefined && item.BoardingPoint!==null && item.BoardingPoint!=='')?item.BoardingPoint:'No Data';
                            this.confimedBpLandmark = (item.BoardingPointLandmark!==undefined && item.BoardingPointLandmark!==null && item.BoardingPointLandmark!=='')?item.BoardingPointLandmark:'No Data';
                        }
                    });
                    this.dojData=[
                        {id:1,paramValue:'Date of Journey',CREATED:this.createdDOJ,TENTATIVE_SUCCESSFUL:this.tentativedDOJ,CONFIRMED:this.confimedDOJ},
                        {id:2,paramValue:'Boarding Time',CREATED:this.createdboardingTime,TENTATIVE_SUCCESSFUL:this.tentativedboardingTime,CONFIRMED:this.confimedboardingTime},
                        {id:3,paramValue:'Time of Event',CREATED:this.createdTimeOfEvent,TENTATIVE_SUCCESSFUL:this.tentativeTimeOfEvent,CONFIRMED:this.confimedTimeOfEvent},
                        {id:4,paramValue:'Date of Issue',CREATED:this.createdDOI,TENTATIVE_SUCCESSFUL:this.tentativeDOI,CONFIRMED:this.confimedDOI},
                        {id:5,paramValue:'Order Id',CREATED:this.createdorderId,TENTATIVE_SUCCESSFUL:this.tentativeorderId,CONFIRMED:this.confimedorderId},
                        {id:6,paramValue:'TIN',CREATED:this.createdTIN,TENTATIVE_SUCCESSFUL:this.tentativeTIN,CONFIRMED:this.confimedTIN},
                        {id:7,paramValue:'User Selected Date',CREATED:this.createdUserSelectedData,TENTATIVE_SUCCESSFUL:this.tentativeUserSelectedData,CONFIRMED:this.confimedUserSelectedData}
                    ];
                    this.fareDetailsData=[
                        {id:1,paramValue:'Date of Journey',CREATED:this.createdDOJ,TENTATIVE_SUCCESSFUL:this.tentativedDOJ,CONFIRMED:this.confimedDOJ},
                        {id:2,paramValue:'Time of Event',CREATED:this.createdTimeOfEvent,TENTATIVE_SUCCESSFUL:this.tentativeTimeOfEvent,CONFIRMED:this.confimedTimeOfEvent},
                        {id:3,paramValue:'Date of Issue',CREATED:this.createdDOI,TENTATIVE_SUCCESSFUL:this.tentativeDOI,CONFIRMED:this.confimedDOI},
                        {id:4,paramValue:'Ticket Fare',CREATED:this.createdTicketFare,TENTATIVE_SUCCESSFUL:this.tentativeTicketFare,CONFIRMED:this.confimedTicketFare},
                        {id:5,paramValue:'Base Fare',CREATED:this.createdBaseFare,TENTATIVE_SUCCESSFUL:this.tentativeBaseFare,CONFIRMED:this.confimedBaseFare},
                        {id:6,paramValue:'Service Tax',CREATED:this.createdServiceTax,TENTATIVE_SUCCESSFUL:this.tentativeServiceTax,CONFIRMED:this.confimedServiceTax},
                        {id:7,paramValue:'Discount',CREATED:this.createdDiscount,TENTATIVE_SUCCESSFUL:this.tentativeDiscount,CONFIRMED:this.confimedDiscount},
                        {id:8,paramValue:'Order Id',CREATED:this.createdDiscount,TENTATIVE_SUCCESSFUL:this.tentativeDiscount,CONFIRMED:this.confimedDiscount},
                        {id:9,paramValue:'Seat Count',CREATED:this.createdSeatCount,TENTATIVE_SUCCESSFUL:this.tentativeSeatCount,CONFIRMED:this.confimedSeatCount},
                        {id:10,paramValue:'Tin',CREATED:this.createdTIN,TENTATIVE_SUCCESSFUL:this.tentativeTIN,CONFIRMED:this.confimedTIN}
                    ];
                    this.bpTimingsData=[
                        {id:1,paramValue:'Date of Journey',CREATED:this.createdDOJ,TENTATIVE_SUCCESSFUL:this.tentativedDOJ,CONFIRMED:this.confimedDOJ},
                        {id:2,paramValue:'Time of Event',CREATED:this.createdTimeOfEvent,TENTATIVE_SUCCESSFUL:this.tentativeTimeOfEvent,CONFIRMED:this.confimedTimeOfEvent},
                        {id:3,paramValue:'Date of Issue',CREATED:this.createdDOI,TENTATIVE_SUCCESSFUL:this.tentativeDOI,CONFIRMED:this.confimedDOI},
                        {id:4,paramValue:'Boarding Point',CREATED:this.createdBp,TENTATIVE_SUCCESSFUL:this.tentativeBp,CONFIRMED:this.confimedBp},
                        {id:5,paramValue:'Boarding Time',CREATED:this.createdboardingTime,TENTATIVE_SUCCESSFUL:this.tentativedboardingTime,CONFIRMED:this.confimedboardingTime},
                        {id:6,paramValue:'Boarding Point Landmark',CREATED:this.createdBpLandmark,TENTATIVE_SUCCESSFUL:this.tentativeBpLandmark,CONFIRMED:this.confimedBpLandmark},
                        {id:7,paramValue:'Order Id',CREATED:this.createdorderId,TENTATIVE_SUCCESSFUL:this.tentativeorderId,CONFIRMED:this.confimedorderId},
                        {id:8,paramValue:'TIN',CREATED:this.createdTIN,TENTATIVE_SUCCESSFUL:this.tentativeTIN,CONFIRMED:this.confimedTIN}
                    ];
                }
            }else{
                console.log(':: isError = '+this.result);
            }
        }).catch(error => {
            console.log(':: error1 = '+error);
        });
        //this.fetchWhatsappStatus();
    }

    // Handle Tab Change.
    handleActive(event) {
        this.tabContent = event.target.value;
    }


    handleClickRefresh(){
      location.reload();
     
    
}


  handleClickGetWhatsapStatus(){
      console.log('---148--');
     this.isLoading = true;
     this.whatsApperrorMessage='';
     this.isWatsapBtn = false;
     getWhatsappStatusInfo({
            transactionId:this.recordId
        })
        .then(result=>{
            if(result){
                console.log('---result=--'+JSON.stringify(result));
               if(result==='operation exceeded time limit' || result==='No records found' || result==='Received InValid Data from API. Please contact administrator.' || result=== 'Received InValid response from API. Please contact administartor.' || result==='Invalid Mobile No or DOJ. Please contact administartor.' || result==='operation exceeded time limit. Please contact administrator.'){
                    this.isWatsUpError=true;
                    this.watsUpData = [];
                    this.isLoading = false;
                    this.isWatsUpSuccess=false;
                    if(result==='No records found'){
                        this.whatsApperrorMessage=result; 
                    }else{
                        this.whatsApperrorMessage='Please re-try again once';
                    }
                }else{
                     this.isWatsapBtn = false;
                     this.isWatsUpError=false;
                     this.isWatsUpSuccess=true;
                     this.apiResponseData=JSON.parse(result);
                     let fewData=this.apiResponseData.data;
                     console.log('---fewData=--'+JSON.stringify(fewData));
                     this.watsUpData =  fewData.map(item => ({
                        sentAt: item.sentAt,
                        deliveredAt: item.deliveredAt,
                        readAt: item.readAt,
                        messageTag: item.messageTag,
                        requestedat: item.requestedat
                    }));
                }
            }
            this.isLoading = false;
          }).catch(error => {
            this.isLoading = false;
            this.isWatsUpError=true;
            this.whatsApperrorMessage='Time out error please re-try again';
            console.log(':: error2 = '+error);
        });   
  }

 handleTCtabs(event) {
        this.tabContent = event.target.value;
        const activeTabLabel = event.target.label;
        const selectedTabData = this.eventTabs.find(tab => tab.label === activeTabLabel);
        if (selectedTabData) {
            this.tabColumns = this.getColumns(selectedTabData.label);
        }
    }

  getColumns(tabLabel) {
    let columns = [];
    console.log('>>>tabLabel>>>'+tabLabel);
    // Define column mappings for each tab label
    switch (tabLabel) {
        case 'Check Cancellation':
            columns = [
                { label: 'Time', fieldName: 'Time' },
                { label: 'Channel', fieldName: 'Channel' },
                { label: 'OS', fieldName: 'OS' },
                { label: 'ErrDetMsg', fieldName: 'ErrDetMsg' }
                // Add more columns as needed
            ];
            break;
        case 'Reschedule':
            columns = [
                { label: 'Time', fieldName: 'Time' },
                { label: 'Channel', fieldName: 'Channel' },
                { label: 'OS', fieldName: 'OS' },
                { label: 'ErrDetMsg', fieldName: 'ErrDetMsg' }
                // Add more columns as needed
            ];
            break;
            case 'IsCancellable':
            columns = [
                { label: 'Time', fieldName: 'Time' },
                { label: 'Channel', fieldName: 'Channel' },
                { label: 'OS', fieldName: 'OS' },
                { label: 'SeatsToBeCancelled', fieldName: 'SeatsToBeCancelled' },
                { label: 'ErrDetMsg', fieldName: 'ErrDetMsg' }
                // Add more columns as needed
               ];
             break;
            case 'Final Cancellation':
                columns = [
                    { label: 'Time', fieldName: 'Time' },
                    { label: 'Channel', fieldName: 'Channel' },
                    { label: 'OS', fieldName: 'OS' },
                    { label: 'SelectedSeat', fieldName: 'SelectedSeat' },
                    { label: 'RefundAmount', fieldName: 'RefundAmount' },
                    { label: 'CancellationCharges', fieldName: 'CancellationCharges' },
                    { label: 'IsRefundSuccess', fieldName: 'IsRefundSuccess' },
                    { label: 'ErrDetMsg', fieldName: 'ErrDetMsg' }
                    // Add more columns as needed
                ];
         break;
            case 'Ticket Refund':
                columns = [
                    { label: 'Time', fieldName: 'Time' },
                    { label: 'TotalPaid', fieldName: 'TotalPaid' },
                    { label: 'TotalFare', fieldName: 'TotalFare' },
                    { label: 'RefundAmount', fieldName: 'RefundAmount' },
                    { label: 'ErrDetMsg', fieldName: 'ErrDetMsg' }
                    // Add more columns as needed
                ];
            break;
            
        default:
            // Default columns in case no matching tab label is found
            columns = [
                { label: 'Default Column 1', fieldName: 'Field1' },
                { label: 'Default Column 2', fieldName: 'Field2' },
                // Add more default columns as needed
            ];
    }

    return columns;
}

  handleClickGetTicketCancellation() {
     console.log('---208--');
     this.isLoading=true;

     getTicketCancellationDetails({
         transactionId:this.recordId

     }) .then(result=> {
         this.isLoading=false;
         console.log('--162->>' +result);

         if(result) {
             this.apiResponseData=JSON.parse(result);
            if(this.apiResponseData.hasOwnProperty('error'))
              {
                this.isTcValError=true;
                this.errorMessage = this.apiResponseData.error
              }else if(result==='Received InValid response from API. Please contact administartor.' || result==='Exception occured, Please contact administartor.' || result==='Invalid Transaction Id. Please contact administartor' || result==='Invalid business unit or Tin. Please contact administartor') {
                 this.isTcValError=true;
                 this.errorMessage=result;
             }
             else {
                 this.apiResponseData=JSON.parse(result);
                 console.log('::: apiResponseData = ' +this.apiResponseData);
                 // Group the data based on EventType
                 let eventMap= {} ;
                 this.apiResponseData.data.forEach(event=> {
                         if ( !eventMap[event.EventType]) {
                             eventMap[event.EventType]=[];
                         }

                         eventMap[event.EventType].push(event);
                     });

                 // Define labels for event types
                 const eventTypeLabels= {
                     'Ticket-checkCancel': 'Check Cancellation',
                     'Ticket-isCancellableV1': 'Reschedule',
                     'Ticket-isCancellableV2': 'IsCancellable',
                     'Ticket-cancelTicket': 'Final Cancellation',
                     'Ticket-refundStatus': 'Ticket Refund',
                 };

                 // Prepare data for lightning-tabset
                 this.eventTabs=Object.keys(eventMap).map(eventType=> {
                         return {
                             label:eventTypeLabels[eventType] || eventType,
                             data: eventMap[eventType]
                         }

                         ;
                     });
             }
         }

         this.isLoading=false;

     }).catch(error=> {
         this.isLoading=false;
         this.isTcValError=true;
         this.errorMessage='Error,Please contact administartor.';
         console.log(':: error2 = ' +error);
     });
 }

}