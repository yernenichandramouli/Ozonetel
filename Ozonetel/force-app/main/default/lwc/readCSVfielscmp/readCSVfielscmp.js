import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/CSVfileController.readCSVFile';


export default class readCSVfielscmp extends LightningElement {
    @api recordId;
    @track error;
   // @track columns = columns;
    @track data;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }
    
    handleUploadFinished(event) {
        console.log('====method==');
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('====muploadfile===');
        console.log('===id=='+uploadedFiles[0].documentId);
        // calling apex class
        readCSV({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {

            window.console.log('result ===> '+result);
            console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'BP Records created based CSV file!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }
}