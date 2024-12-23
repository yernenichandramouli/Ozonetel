// emailInputComponent.js
import { LightningElement, track, wire } from 'lwc';
import processEmail from '@salesforce/apex/projectBlinkCtrl.GetUserMobileno';

const columns = [
    { label: 'Mobile', fieldName: 'mobile', type: 'text' },
    { label: 'Country', fieldName: 'country', type: 'text' }
];


export default class EmailInputComponent extends LightningElement {
    @track emailValue;
    @track response;


    @track columns = columns;

    handleEmailChange(event) {
        this.emailValue = event.target.value;
    }

    handleSubmit() {
        // Call the Apex method with the email value
        processEmail({ emailAddress: this.emailValue })
            .then(result => {
                // Update the response property with the result
                console.log('>>>result>>'+result);
                this.response = result;
            })
            .catch(error => {
                // Handle errors here
                console.error('Error:', error);
            });
    }
}