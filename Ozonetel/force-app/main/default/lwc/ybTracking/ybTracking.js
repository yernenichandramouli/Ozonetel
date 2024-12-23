import { api, track, LightningElement } from 'lwc';
import getBpDpValues from '@salesforce/apex/ybTrackingCtrl.fetchBpDpDetails';
import getArrivalPatterns from '@salesforce/apex/ybTrackingCtrl.Getarrivalpatterns';
import fetchYourBusTrackingLink from '@salesforce/apex/ybTrackingCtrl.getYourBusTrackingLink';

export default class YbTracking extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track showBpDpDetails = false;
    @track showArrivalPatterns =true;
    @track isArrivalPatternsLoading = false;
    @track arrivalsDataLoading = false;
    @track error = false;
    @track errorMessage;
    @track onChangeSelectedValue;
    @track arrivalData;
    @track isArrivalError=false;
    @track arrivalErrorMessage;
    @track arrivalPatternsList = [];
    @track getScheduledTime;
    @track isInvalidRbURL=false;

    @track vehicleNumber; @track travelsName; @track doj;
    @track route; @track driver1Details; @track trackingType;
    @track rbTrackingLink; @track ybTrackingLink;@track isVanPickUp = false;

    @track bpName; @track bpStaEta; @track bpPhoneNumber;
    @track bp360Link; @track bpAddressLink; @track bpAddress;

    @track dpName; @track dpStaEta; @track dpPhoneNumber;
    @track dp360Link; @track dpAddrLink; @track dpAddress;

    @track bpList =[];
    @track allBpNames =[];

    //
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';
    // @track url='https://b.redbus.com/w5oiI27ee';
    @track url;
    //


    @track ybtrackingLink;
    @track showYbTrackingLink = false;
    @track ybTrackingErrorMessage;


    connectedCallback() {
        this.isLoading = true;
        this.isArrivalPatternsLoading = true;
        this.fetchYbTrackingLink();
        getBpDpValues({
            transactionID:this.recordId
        })
        .then(result=>{
            this.isLoading = false;
            this.isArrivalPatternsLoading = false;
            this.showBpDpDetails = true;
            console.log(':: resultMsg = '+JSON.stringify(result));

            if(result.hideArrivalPatterns && result.arrivalPatternsError){
                this.showArrivalPatterns = false;
                this.errorMessage = result.errorMessage;
            }else if(result.msg!==null && result.isError && result.data!=null){
                console.log('::: Inside EsleOf');
                this.errorMessage = result.msg;
                this.showArrivalPatterns = false;

            }

            if(result.bpIdAndNames!==undefined){
                this.bpList = result.bpIdAndNames;
                console.log(':: bpList = '+JSON.stringify(this.bpList));
                this.allBpNames = Object.entries(this.bpList).map(([value, label]) => ({ value, label }));
                console.log(':: allBpNames = '+JSON.stringify(this.allBpNames));
            }

            if(!result.isError && result.data!=null){
                this.vehicleNumber = result.data.vehicle_no!==''?result.data.vehicle_no:'No data found';
                this.travelsName = result.data.traveler_name!==''?result.data.traveler_name:'No data found';
                this.doj = result.data.doj!==''?result.data.doj:'No data found';
                this.route = result.data.route!==''?result.data.route:'No data found';
                this.driver1Details = result.data.driver_details!==''?result.data.driver_details:'No data found';
                this.trackingType = result.data.tracking_type!==''?result.data.tracking_type:'No data found';
                this.rbTrackingLink = result.data.redbus_tarcking_link!==''?result.data.redbus_tarcking_link:'No data found';
                this.ybTrackingLink = result.data.yourbus_tracking_link!==''?result.data.yourbus_tracking_link:'No data found';

                if(this.rbTrackingLink==='No data found' && this.ybTrackingLink==='No data found'){
                    this.isInvalidRbURL = true;
                }

                if(result.busType =='B2C' && this.rbTrackingLink=='No data found'){
                    this.isInvalidRbURL = true;
                }

                if(result.busType =='B2C' && this.rbTrackingLink!='No data found'){
                    this.url = this.rbTrackingLink;
                }else if(result.busType=='B2B'){
                    this.url = this.ybTrackingLink;
                }


                if(result.data.is_pick_up_bp == 1){
                    this.isVanPickUp = true;
                }

                // Bp Details
                this.bpName = result.data.bp_name!==''?result.data.bp_name:'No data found';
                this.bpStaEta = result.data.bp_sta!==''?result.data.bp_sta:result.data.bp_ata;
                this.bpPhoneNumber = result.data.bp_contact!==''?result.data.bp_contact:'No data found';
                this.bp360Link = result.data.bp_street_view_link!==''?result.data.bp_street_view_link:'No data found';
                this.bpAddressLink = result.data.bp_address_link!==''?result.data.bp_address_link:'No data found';
                this.bpAddress = result.data.bp_address!==''?result.data.bp_address:'No data found';

                // DP Details
                this.dpName = result.data.dp_name!==''?result.data.dp_name:'No data found';
                this.dpStaEta = result.data.dp_sta!==''?result.data.dp_sta:result.data.dp_ata;
                this.dpPhoneNumber = result.data.dp_conatct!==''?result.data.dp_conatct:'No data found';
                this.dp360Link = result.data.dp_street_view_link!==''?result.data.dp_street_view_link:'';
                this.dpAddrLink = result.data.dp_address_link!==''?result.data.dp_address_link:'No data found';
                this.dpAddress = result.data.dp_address!==''?result.data.dp_address:'No data found';
            }
            console.log(':: showArrivalPatterns = '+this.showArrivalPatterns);
        }).catch(error => {
            this.isLoading = false;
            this.isArrivalPatternsLoading = false;
            this.error = true;
            this.errorMessage = error;
            // this.showArrivalPatterns = false;
            // console.log(':: showArrivalPatterns = '+this.showArrivalPatterns);
            console.log(':: errorMessage = '+JSON.stringify(this.errorMessage));
        });
    }


    isBpListEmpty() {
        return Object.keys(this.bpList).length !== 0;
    }
    openUrlInNewTab(event) {
        console.log('::: target value '+event.target.value);
        const url = event.target.value;
        if (url) {
            window.open(url, '_blank');
        }
    }

    handleBpChange(){
        this.onChangeSelectedValue = this.template.querySelector("[data-id='Available Values']").value;
        console.log(':: selectedBpId :: ', +this.onChangeSelectedValue);
        this.fetchArrivalPatterns();
    }

    //Function To Fetch Arrival Patterns
    fetchArrivalPatterns(){
        var newArrayList = [];
        // this.arrivalsDataLoading = true;
        console.log(':: Inside Arrival pattern :: ');
        getArrivalPatterns({
            transactionId:this.recordId,
            boardingPointId:this.onChangeSelectedValue
        })
        .then(result=>{
            // this.arrivalsDataLoading = false;
            this.arrivalData=JSON.parse(result);
            console.log(':: arrivalData :: ', +result);
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
            this.areDetailsVisible = true;
            console.log('Error '+JSON.stringify(error.message));
        });
    }


    //Function To Fetch Yourbus Tracking Link
    fetchYbTrackingLink(){
        console.log(':: Inside fetchYbTrackingLink :: ');
        fetchYourBusTrackingLink({
            transactionId:this.recordId
        })
        .then(result=>{
            if(result.isError){
                this.ybTrackingErrorMessage = result.errorMessage;
            }else{
                this.showYbTrackingLink = true;
                this.ybtrackingLink = result.urlToShow;
            }
        })
        .catch(error => {
            console.log('Error '+JSON.stringify(error.message));
        });
    }
}