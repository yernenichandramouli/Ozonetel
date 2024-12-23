import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'

export default class FileUploader_S3 extends LightningElement {
    selectedFileToUpload = [];
    handleSelectedFile(event) {
        console.log('calling');
        //  console.log('f-->' + event.detail.files);
        //this.selectedFileToUpload = Array.from(event.target.files);
    }

    @api
    myRecordId;
    @track fileLink;
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        console.log('call fin');
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }

    @api recordId;
    fileData
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var tstm = Math.round((new Date()).getTime() / 1000);
            var base64 = reader.result.split(',')[1];
            var fNameAct= file.name.replaceAll(' ','');
            fNameAct = fNameAct.replaceAll('[^a-zA-Z0-9 -]', '');
            fNameAct = fNameAct.replaceAll('-','');
            fNameAct = fNameAct.replaceAll('_','');
            fNameAct = fNameAct.toLowerCase();
            this.fileData = {
                'filename': 'SFAgentFromChat'+tstm+fNameAct,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }

    handleClick() {

        const { base64, filename, recordId } = this.fileData
        uploadFile({ base64, filename, recordId }).then(result => {
            this.fileData = null
            this.fileLink = filename;
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }
}