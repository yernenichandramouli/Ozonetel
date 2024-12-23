import { LightningElement,track } from 'lwc';
import serachActivites from '@salesforce/apex/CargoservicesCntrl.getActivites';

const columns = [
    {
        label: 'Voucher Id',
        fieldName: 'accurl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Voucher_Id__c' }, target: '_top'} ,
    }, {
        label: 'Status',
        fieldName: 'Transaction_Status__c'
    },
    {
        label: 'Order Id',
        fieldName: 'accurl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Order_Id__c' }, target: '_top'} ,
    },
    {
        label: 'Phone',
        fieldName: 'Booking_User_Mobile__c',
    },
    {
        label: 'Email',
        fieldName: 'Booking_User_Email__c',
    },
];

export default class CargoServicesCmp extends LightningElement {

    @track searchData;
    @track activityLst;
    @track columns = columns;
    @track errorMsg = '';
    @track strTrackingNo = '';
    @track strEmailId;
    @track strPhoneNo;
 
    

    handleTrckingNo(event) {
        this.errorMsg = '';
        console.log('---this.strTrackingNo--'+this.strTrackingNo);
        this.strTrackingNo = event.currentTarget.value;
    }

    handleEmailId(event) {
        this.errorMsg = '';
        this.strEmailId = event.currentTarget.value;
    }

    handlePhoneNo(event) {
        this.errorMsg = '';
        this.strPhoneNo = event.currentTarget.value;
    }

    
    handleSearch() {
        if(!this.strTrackingNo && !this.strEmailId && !this.strPhoneNo) {
            this.errorMsg = 'Please ensure that at least one value is required for search.';
            this.searchData = undefined;
            return;
        }

      serachActivites({strTrackingNum : this.strTrackingNo,streMailid : this.strEmailId, strMobileNo : this.strPhoneNo})
        .then(result => {
            this.searchData = result;
            this.searchData= JSON.parse(JSON.stringify(result));
             console.log('---result--'+JSON.stringify(result));
             this.activityLst= this.searchData.map(record => Object.assign(
                { "accurl": '/' + record.Id },
                record));

        })
        .catch(error => {
            this.searchData = undefined;
            if(error) {
                if (Array.isArray(error.body)) {
                    this.errorMsg = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMsg = error.body.message;
                }
            }
        }) 
    }
}