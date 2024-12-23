import { LightningElement, api, track,wire } from 'lwc';
import GetDetails from '@salesforce/apex/GetTransactionDetails.yourBusTracking';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class YourBusTracking extends LightningElement {
    @api recordId; 
    @track message='';
    @track isAmenities=false;
    
    connectedCallback(){
        GetDetails({
            ordId: this.recordId 
        }).then(data=>{
            console.log('--data--'+JSON.stringify(data.mmtGiServiceId));
            if(data.orderItem.Business_Unit__c =='REDBUS_IN')
            {
                if(data.orderItem.Amenities__c!=null){
                var str= data.orderItem.Amenities__c;
                if(str.includes("19")){
                    this.isAmenities=true;
                }
                }
                if(this.isAmenities || data.orderItem.Inventory_Type__c=='Amazon' || data.orderItem.Service_Provider_Id__c=='10283' || data.orderItem.Service_Provider_Id__c=='18491'){
                    let today = new Date().toISOString().slice(0,10);
                    if(data.orderItem.Date_of_Boarding_Time__c <= today)
                    {
                        if(data.orderItem.Transaction_Status__c =='Booked' && data.orderItem.Order_Item_Reference_No__c !='' && data.orderItem.Service_Provider_Id__c !='' && data.orderItem.Date_of_Boarding_Time__c !='' && data.orderItem.ServiceID__c !='')
                        { 
                            console.log('--service--'+data.orderItem.Service_Provider_Id__c);
                            if(data.orderItem.Service_Provider_Id__c!='10283' && data.orderItem.Service_Provider_Id__c!='18491'){
                                var doj = new Date(data.orderItem.Date_of_Boarding_Time__c);
                                var lDate=doj.getFullYear()+'-'+(doj.getMonth()+1+'-'+doj.getUTCDate());
                                var ulrId='https://reports.yourbus.in/ci/crmdash?op_id='+data.orderItem.Service_Provider_Id__c+'&doj='+lDate+'&service_id='+data.orderItem.ServiceID__c;
                                const closePopUp = new CustomEvent('close',{
                                    detail: {ulrId} 
                                });
                                this.dispatchEvent(closePopUp);                    
                            }else if(data.orderItem.Service_Provider_Id__c=='10283'){
                                console.log('---elseff---');
                                var ulrId='http://apsrtclivetrack.com/#/trips/'+data.orderItem.ServiceID__c; 
                                console.log('--ulrId---'+ulrId);
                                window.open(ulrId, "_blank");    
                                const closePopUp = new CustomEvent('close',{ 
                                    detail: {ulrId} 
                                });
                                this.dispatchEvent(closePopUp);
                            }else if(data.orderItem.Service_Provider_Id__c=='18491'){
                                var ulrId='https://www.tsrtconline.in/oprs-web/services/driverInfoList.do';
                                window.open(ulrId, "_blank");   
                                const closePopUp = new CustomEvent('close',{
                                    detail: {ulrId} 
                                });
                                this.dispatchEvent(closePopUp);
                            }   
                        }else{
                            this.message ='It is not confirmed ticket or required details are missing.So,we can not track the bus location';
                        }
                    }
                    else {
                        this.message='Date of Journey of the ticket is not today.So,Tracking is not allowed';
                    }
                }else if((data.orderItem.Inventory_Type__c=='MMT' || data.orderItem.Inventory_Type__c=='GOIBIBO') && data.mmtGiServiceId !== null && data.mmtGiServiceId !== undefined && data.isMMTGITransaction){
                    var doj = new Date(data.orderItem.Date_of_Boarding_Time__c);
                    var lDate=doj.getFullYear()+'-'+(doj.getMonth()+1+'-'+doj.getUTCDate());
                    var ulrId='https://reports.yourbus.in/ci/crmdash?op_id='+data.orderItem.Service_Provider_Id__c+'&doj='+lDate+'&service_id='+data.mmtGiServiceId;
                    window.open(ulrId, "_blank");    
                    this.dispatchEvent(new CloseActionScreenEvent());  
                }else{
                    this.message='Tracking not not available for this bus';
                }
            }else{
                this.message='Currently tracking is not enabled for international transactions';
            }
        })
    }
}