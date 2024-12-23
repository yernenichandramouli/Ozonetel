import { LightningElement, api, wire, track } from 'lwc';
import getTicketDetailsLM from '@salesforce/apex/TicketDetailsController.GetTicketDetails';
export default class TicketDetails extends LightningElement {

    @api recordId;
    @track apiRespBody;
    @track policyValues = [];
    @track travellerInfo = [];
    @track priceBreakup = [];
    @track ticketFare;
    @track discount;
    @track showUpdMsg;
    @track notifType;
    @track notifMsg;
    activeSections = ['A', 'B', 'C'];
    @track fields = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Age', fieldName: 'Age' },
        { label: 'Gender', fieldName: 'Gender' },
        { label: 'Seat Number', fieldName: 'SeatNumber' }
    ];
    @track cpfields = [
        { label: 'Name', fieldName: 'componentName' },
        { label: 'Amount', fieldName: 'value' },
        { label: 'Refundable Amount', fieldName: 'refundableValue' }
    ];
    @track showSection = false;
    @track fetchLoad = false;

    handleClick(event) {
        console.log('handleClick here');
        this.fetchLoad = true;
        getTicketDetailsLM({ ordItemId: this.recordId, source: 'Transaction' }).then(data => {
            console.log('insdied get');
            if (data) {
                console.log('data ticket details-->' + data);
                if (data == 'Apex Error' || data == 'No Tin Found' || data == 'No API Response') {
                    this.fetchLoad = false;
                    this.showUpdMsg = true;
                    this.notifType = 'error';
                    this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code->' + data;
                } else {
                    this.showSection = true;
                    this.fetchLoad = false;
                    this.apiRespBody = JSON.parse(data);
                    console.log('apiRespBody-->' + this.apiRespBody);
                    console.log('serviceNotes-->' + this.apiRespBody.serviceNotes);
                    if (typeof this.apiRespBody.serviceNotes !== 'undefined' && this.apiRespBody.serviceNotes != null) {
                        console.log('came here why 3');
                        this.policyValues = this.apiRespBody.serviceNotes.policy;
                    }
                    console.log('here??');
                    this.travellerInfo = this.apiRespBody.PassengerDetails;
                    this.priceBreakup = this.apiRespBody.customerPriceBreakUp;
                    this.ticketFare = this.apiRespBody.TicketFare.currencyType + ' ' + this.apiRespBody.TicketFare.amount;
                    this.discount = this.apiRespBody.Discount;
                    console.log('policyValues-->' + JSON.stringify(this.policyValues));
                    //console.log('apiRespBody-->' + JSON.stringify(this.policyValues.PolicyID));
                }
            } else if (error) {
                this.fetchLoad = false;
                showUpdMsg = true;
                this.notifType = 'error';
                this.notifMsg = 'Something Went Wrong!! Please try again or Contact Admin. Error Code-> JS Failed';
                console.log('data error ticket details->' + error);
            }
        }).catch(error => {

        })
    }
    /*   @wire(getTicketDetailsLM, { ordItemId: '$recordId', source: 'Transaction' })
       wiredTicketDetails({ data, error }) {
           console.log('came here ticket details');
   
           if (data) {
               console.log('data ticket details-->' + data);
   
               this.apiRespBody = JSON.parse(data);
               this.policyValues = this.apiRespBody.serviceNotes.policy;
               this.travellerInfo = this.apiRespBody.PassengerDetails;
               console.log('policyValues-->' + JSON.stringify(this.policyValues));
               //console.log('apiRespBody-->' + JSON.stringify(this.policyValues.PolicyID));
   
           } else if (error) {
               console.log('data error ticket details->' + error);
           }
       }*/
}