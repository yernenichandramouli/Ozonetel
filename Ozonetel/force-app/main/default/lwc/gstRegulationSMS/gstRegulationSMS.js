import { LightningElement, api, wire, track } from 'lwc';
import GetTransdetailsLc from '@salesforce/apex/GSTregulationSMSController.GetTicketDetails';
export default class GstRegulationSMS extends LightningElement {


    @api recordId;
    @track success;
    @track message;
    @wire(GetTransdetailsLc, {ordItemId:'$recordId' })
    wireMethod({error,data}){
        if(data){
                console.log('data -->' + data);
                if (data == 'Apex Error' || data == 'No Tin Found' || data == 'No API Response') {
                    this.success=false;
                    this.message= 'Invoice cannot be generated. Please get in touch with the BO directly.';
                } else if(data == 'GST SMS has been sent successfully'){
                    this.success=true;
                    this.message='Success, GST Invoice sent successfully.';
                                    }
            } else if (error) {
                this.success=false;
                this.message = 'Something Went Wrong!! Please try again or Contact Admin. Error Code-> JS Failed';
                console.log('data error  details->' + error);
            }
      
        }
}