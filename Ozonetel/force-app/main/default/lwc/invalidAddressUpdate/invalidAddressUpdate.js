import { LightningElement, api, wire, track } from 'lwc';
import GetDetails from '@salesforce/apex/InvalidAddressUpdate.GetDetails';
import CaseCreate from '@salesforce/apex/InvalidAddressUpdate.InvalidAddressCaseCreate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InvalidAddressUpdate extends LightningElement {
@api recordId;
@track boardingAddress;
@track customerBP='';
@track options;
@track status='';
@track comment;
@track show=false;
@track showSpinner=false;
@track StatusOptions=[
    {label:'None', value:''},
    {label:'Wrong Address', value:'Wrong Address'},
    {label:'Address Changed', value:'Address Changed'}
];

@wire(GetDetails, {ordId:'$recordId' })
wireMethod({error,data}){
    if(data){
        if((data.Business_Unit__c =='REDBUS_MY' || data.Business_Unit__c =='REDBUS_SG' ||  data.Business_Unit__c =='REDBUS_ID') & data.Transaction_Status__c =='Booked'){
            this.show=true;
            this.boardingAddress=data.Boarding_Point__c;
        }
    }
}
handleSubmit(event){
    if(this.status == ''){
        const evt = new ShowToastEvent({
        message: 'Please select status',
        variant: 'error',
        mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    else if(this.customerBP==''){
        const evt = new ShowToastEvent({
            message: 'Please enter customer provided boarding point',
            variant: 'error',
            mode: 'dismissable'
            });
            this.dispatchEvent(evt); 
    }
    else{
        this.showSpinner=true;
        CaseCreate({
            ordId:this.recordId,
            comment:this.comment,
            status:this.status,
            customerBP:this.customerBP
        })
        .then(data=>{
            this.customerBP='';
            this.status='';
            this.comment='';        
            this.showSpinner=false;
            if(data=='already exist'){
                const evt = new ShowToastEvent({
                    message: 'Case is exist with the given details',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);                 
            }
            else if(data=='error'){
                const evt = new ShowToastEvent({
                    message: 'Somthing went wrong please retry',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);                 
            }
            else{
                const evt = new ShowToastEvent({
                    message: data,
                    variant: 'success',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(evt); 
    
            }    
            console.log('<<data'+JSON.stringify(data));
        })    
    }
}
handleCancel(event){
    this.customerBP='';
    this.status='';
    this.comment='';        
}
handleStatusChange(event){
    this.status=event.target.value;
}
handlecbpChange(event){
    this.customerBP=event.target.value;
}

}