/**
 * **********************************************************************************************************
 * Lightning Web Component   :   retriveAmenities
 * Includes                  :   retriveAmenities.html, retriveAmenities.js, retriveAmenities.js-meta.xml, retriveAmenities.css files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2022-May-30
 * @description  This component "retriveAmenities" is created to show aminites values.
 * @JiraId       CRM-1420
 */
import { LightningElement, track, api} from 'lwc';  
import retriveAmenities from '@salesforce/apex/ShowAmenitiesCtrl.fetchAmenities'; 
const columns = [  
    { label: 'Amenities Id', fieldName: 'Id' }, 
    { label: 'Amenities Name', fieldName: 'Name' }
]; 

export default class ShowAmenitiesCmp extends LightningElement {
    @api recordId;
    @track metaDataResponse;
    @track errorMessage;
    @track columns = columns;
    @track showTable = false;
    @track data ;
    @track isError = false;

    connectedCallback() {
        this.isLoading = true;
        retriveAmenities({
            transactionId:this.recordId
        })
        .then(data=>{
            if(data){
                this.showTable=true;
                this.data = Object.keys(data).map(item=>({"Id":item,"Name": data[item]}));
                console.log(':: Data = '+this.data);
                this.isLoading = false;
            }else{
                this.isError=true;
                this.isLoading = false;
                console.log(':: isError = '+this.data);
                this.errorMessage = 'No Aminites available for this transaction';
            }
        }).catch(error => {
            this.isError=true;
            this.isLoading = false;
            console.log(':: error = '+JSON.stringify(error));
            this.errorMessage = error;
        });
    }
}