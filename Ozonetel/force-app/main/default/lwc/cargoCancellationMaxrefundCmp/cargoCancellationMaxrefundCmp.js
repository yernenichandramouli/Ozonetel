import { LightningElement, api, track,wire } from 'lwc';
//import maxrefundDetailsCargo from '@salesforce/apex/CargoservicesCntrl.maxrefundCargoAPI';
import cancellationAPIcall from '@salesforce/apex/CargoservicesCntrl.CancellationCargoAPI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import maxrefundDetails from '@salesforce/apex/CargoservicesCntrl.maxrefundApi';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
const CONTACT_FIELDS = [
    'Activities__c.Transaction_Status__c',
    'Activities__c.Final_Status__c',
    'Activities__c.First_Mile_Status__c',
    'Activities__c.Cargo_Tracking_status__c',
];


export default class CargoCancellationMaxrefundCmp extends LightningElement {

  @api recordId;
  objectData;
  @track showClicktoCanclBtn = false;
  @track isLoading = false;
  @track callingMaxrefundApi = true;
  @track respResult;
  @track selTypeCancel;
  @track data = [];
  @track showCanceloptions = true;
  @track bolParitialCancel = false;
  @track selItemTypeRefundAmnt = [];
  @track selectedItem;
  @track enteredRefundAmnt;
  @track errorMsg;
  @track successMsg;
  @track isCancelCmpltd = false;
  @track tableData = [];
  @track cancelReasonVal;
  @track isMaxRefundRespFail = false;
  

  saveDraftValues = [];
    @track tableColumns = [
        { label: 'Item Type', fieldName: 'key', type: 'text' ,sortable: false,isSelected: false},
        { label: 'Amount', fieldName: 'amount', type: 'number' ,sortable: false,isSelected: false,cellAttributes: { class: 'highlight-column' }},
        //{ label: 'Item UUID', fieldName: 'itemUuid', type: 'text' },
        { label: 'Refund Amount', fieldName: 'selRfndAmnt', type: 'number' ,sortable: false,editable: true},

        // Add your custom column here, e.g., checkbox column
    ];

  @track statusOptions = [
    { label: '--None--', value: 'None' },
    { label: 'Full Cancellation', value: 'fullcancellation' },
    { label: 'Partial Cancellation', value: 'partialCancellation' }
  ];

  @track allSelected = false;

  connectedCallback() {
    this.isLoading = true;
    this.getMaxrefundDtls();
  }

  selectAllRows(event) {
    this.allSelected = event.target.checked;
    this.tableData = this.tableData.map(item => ({ ...item, isSelected: this.allSelected }));
    console.log('--allSelc--' + this.allSelected);
    const firstItem = this.tableData[0];
    console.log('>.iiiiiiii>>'+firstItem);

    if (this.allSelected == true) {
      this.showClicktoCanclBtn = true;
    } else {
      this.showClicktoCanclBtn = false;
    }
  }

  handleRowSelection(event) {
    console.log('--row selection--');
    const index = event.target.dataset.index;
    this.tableData[index].isSelected = event.target.checked;
    this.allSelected =  this.tableData.every(item => item.isSelected);

    const selectedCheckbox = event.currentTarget;
    const selectedRowKey = selectedCheckbox.dataset.key;
    //const selectedRowIndex = selectedCheckbox.dataset.index;
    console.log('---true/false--' + selectedCheckbox.checked);

    const rowIndex = event.currentTarget.dataset.index;
    const selRow =  this.tableData[rowIndex];
    console.log('>>selRow>>>' + JSON.stringify(selRow));
    const selJsondData = JSON.parse(JSON.stringify(selRow));
    const maxRefundAmnt = selJsondData.amount;
    console.log('-..maxRefundAmnt.->>'+maxRefundAmnt);

if(selectedCheckbox.checked && (maxRefundAmnt ==='0' || maxRefundAmnt ===0 || maxRefundAmnt===undefined || maxRefundAmnt ==='')){
    this.showClicktoCanclBtn = false;
    this.isMaxRefundRespFail = true;
    this.successMsg ='Cancellation is not possible for this Cargo because Maxrefund Amount is Zero';
}

if (maxRefundAmnt ===0 && selectedCheckbox.checked) {
        if(selectedRowKey ==='CARGO'){
            //this.selectAllRows(event);
         const nextIndex = (index + 1) % this.tableData.length; // Loop back to the first row if at the end
         this.tableData[nextIndex].isSelected = true;
        }
      this.showClicktoCanclBtn = false;
      console.log('--Selected Row Key:', selectedRowKey);
  } else if(selectedCheckbox.checked){
      this.showClicktoCanclBtn = true;
  }else {
    this.isMaxRefundRespFail = false;
    this.showClicktoCanclBtn = false;

  }

  }


  handleEnteredRfndAmnt(event) {
    const changedInput = event.target;
    const changedRowKeyy = changedInput.dataset.key;
    this.selectedItem = changedInput.dataset.key;
    this.enteredRefundAmnt = changedInput.value;

    if (this.enteredRefundAmnt == undefined || this.enteredRefundAmnt == null || this.enteredRefundAmnt == '') {
      this.enteredRefundAmnt = '0';
    }
    console.log('--selectedItem:', this.selectedItem);
    console.log('--enteredRefundAmnt:', this.enteredRefundAmnt);

    const rowwIndex = event.currentTarget.dataset.index;
    this.tableData[rowwIndex].selRfndAmnt = parseInt(this.enteredRefundAmnt);

    const selectedRow = this.tableData[rowwIndex];
    console.log('>>115 selRow>>>' + JSON.stringify(selectedRow));

    const selJsondData = JSON.parse(JSON.stringify(selectedRow));
    const selectedRfndAmnt = selJsondData.selRfndAmnt;
    const refundAmnt = selJsondData.amount;

    if ((this.selectedItem == 'FIRST_MILE' || this.selectedItem == 'CARGO') && this.enteredRefundAmnt == '') {
      this.errorMsg = 'Refund Amound should not be Empty';
      this.displayToastMessage(this.errorMsg, 'error');
    }

    if ((this.selectedItem == 'FIRST_MILE' || this.selectedItem == 'CARGO') && selectedRfndAmnt != null && selectedRfndAmnt > refundAmnt) {
      this.errorMsg = 'Refund amount should not be greater than Maximum Refund Amount';
      this.displayToastMessage(this.errorMsg, 'error');
    }

  }


getMaxrefundDtls(){
   maxrefundDetails({ ItemId: this.recordId })
    .then((result) => {
         this.isLoading = false;
        console.log('----rsult--' + result);
        const rspResult = JSON.stringify(result);
        this.respResult = JSON.parse(rspResult);
        console.log('>>>this.respResult>>>' + this.respResult);
        const dtTest = this.respResult;
        console.log('---data---'+dtTest);
   if(dtTest==='null' || dtTest===null || dtTest==='' ||  dtTest===undefined ){     
      this.callingMaxrefundApi = false;
      this.isMaxRefundRespFail = true;
      this.successMsg ='OrderId not found or Invalid response from MaxrefundApi';
    }else{
        let processedData = [];
       dtTest.forEach((item, index) => {
            let key = Object.keys(item)[0];
            let values = item[key];
            processedData.push({
                key: key,
                amount: values.amount,
                itemUuid: values.itemUuid,
                selRfndAmnt: 0,
                // Add your custom column data here
            });
        });

        this.tableData = processedData;
    }
      })
      .catch((error) => {
        this.isLoading = false;
        console.error('Error: \n ', error);
      });
      
 }

@wire(getRecord, { recordId: '$recordId', fields: [CONTACT_FIELDS] })
    wiredRecord({ error, data }) {
        console.log('--182--apex--');
        if (data) {
            this.objectData = data;
        } else if (error) {
            console.error('Error loading record data', error);
        }
    }


handleRefresh(){
  this.isSuccessfulTrackingUpd = false;
  console.log('--192--apex--');
  location.reload();
    //return refreshApex(this.objectData);

}

handleCancelReason(event){
  this.cancelReasonVal = event.target.value;

}

  finalCancellationCall() {
    console.log('--calling cancel btn--');
    console.log('>>> final request Apex Class-->>>' + JSON.stringify(this.tableData));
    if (!this.cancelReasonVal) {
          this.successMsg = 'Cancellation Reason Is Empty';
          this.displayToastMessage(this.successMsg, 'error');
    }else if(!this.enteredRefundAmnt || this.enteredRefundAmnt === 0 || this.enteredRefundAmnt === '0'){
          this.successMsg = 'Refund Amount Is Empty';
          this.displayToastMessage(this.successMsg, 'error');
    }else {
      cancellationAPIcall({ ItemId: this.recordId, selReqJson: JSON.stringify(this.tableData),cancelReason: this.cancelReasonVal})
      .then((result) => {
        console.log(':::: result ::::' + result);
        console.log(':::: Apex Resp ::::' + JSON.stringify(result));
        if (result != '' && result != null && result == 'OPERATOR_CANCELLATION_SUCCESS') {
          this.successMsg = 'Successfully Cancelled';
          this.callingMaxrefundApi = false;
          this.displayToastMessage(this.successMsg, 'success');
          this.showClicktoCanclBtn = false
          this.isCancelCmpltd  = true;

        }else {
          this.successMsg =result;
          this.enteredRefundAmnt = '0'
          this.callingMaxrefundApi = false;
          this.displayToastMessage(this.successMsg, 'error');
          this.showClicktoCanclBtn = false
          this.isCancelCmpltd  = true;

        }
      }).catch((error) => {
        this.fetchLoad = false;
        console.error('Error: \n ', error);
      });
    }
  }

  displayToastMessage(msg, type) {
    const toastEvt = new ShowToastEvent({
      title: type,
      // message: 'Failed to send ticket, Please contact your System Administrator.',
      message: msg,
      // variant: 'error',
      variant: type,
      mode: 'dismissable'
    });
    this.dispatchEvent(toastEvt);
  }

}