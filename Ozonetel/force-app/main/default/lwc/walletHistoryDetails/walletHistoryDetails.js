import { LightningElement,api,wire,track} from 'lwc';

import walletHistoryDtls from '@salesforce/apex/WalletHistoryTransDetailsCntrl.GetWalletHistoryDetails';

export default class WalletHistoryDetails extends LightningElement {

 @api recordId;
 @track apiRespBody;
 @track errorMsg;
 @track isError=false;
 @track isSuccessResponse=false;
@track isLoading =false;
  @track walletColumns = [{
        label: 'TransactionDate',
        fieldName: 'TransactionDate',
        hideDefaultActions: true,
        initialWidth:150
    },
    {
        label: 'TransactionMode',
        fieldName: 'TransactionMode',
        hideDefaultActions: true,
        initialWidth:130
    },
    {
        label: 'TransactionType',
        fieldName: 'TransactionType',
        hideDefaultActions: true,
        initialWidth:120
    },
    {
        label: 'Amount',
        fieldName: 'Amount',
        hideDefaultActions: true,
        initialWidth:70
    },
      {
        label: 'ExprationDate',
        fieldName: 'ExprationDate',
        hideDefaultActions: true,
        initialWidth:150
    },
      {
        label: 'OfferName',
        fieldName: 'OfferName',
        hideDefaultActions: true,
        initialWidth:70
    },
      {
        label: 'AmountUsed',
        fieldName: 'AmountUsed',
        hideDefaultActions: true,
        initialWidth:70
    },
      {
        label: 'OpeningBalance',
        fieldName: 'OpeningBalance',
        hideDefaultActions: true,
        initialWidth:70
    },
    {
        label: 'ClosingBalance',
        fieldName: 'ClosingBalance',
        hideDefaultActions: true,
        initialWidth:70
    },

     {
        label: 'SalesChannel',
        fieldName: 'SalesChannel',
        hideDefaultActions: true,
        initialWidth:100
    },
     {
        label: 'ReferenceNo',
        fieldName: 'ReferenceNo',
        hideDefaultActions: true,
        initialWidth:140
    },

    ];
 @wire(walletHistoryDtls, {
    ordItemId: '$recordId'
})
wireMethod({
    error,
    data
}) {
    console.log('--recordId -->' + this.recordId);
    if (data) {
                     this.isLoading=true;

        if (data != null && data != '' && data!=undefined) {
              console.log('--if--'+data)
                this.apiRespBody = JSON.parse(data);
              if(data =='No signed user found' || data =='No Tin Found or not confirmed booking' || data.includes('Wallet not found') || data.includes('Bad Request') || data.includes('[]')){
                 console.log('--error--'+data);
                this.errorMsg =data;
                this.isError=true;
                this.isSuccessResponse=false;
                this.isLoading =false;
              }else{
                console.log('--else--');
                this.isSuccessResponse=true;
                this.isError=false;
                this.isLoading =false;
                
              }
            } else {
                console.log('--api fail--');
                this.errorMsg ='Api Failed Please contact system admin';
                this.isSuccessResponse=false;
                this.isError=true;
               this.isLoading =false;
            }
        }
    }
   
}