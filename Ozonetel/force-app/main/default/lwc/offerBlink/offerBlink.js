import { LightningElement, track, wire, api } from 'lwc';
import fetchOfferDetails from '@salesforce/apex/projectBlinkCtrl.getOfferEvents';

export default class offerBlink  extends LightningElement {
    @api  recordId;
    @track selectedCountry;
    @track phone;
    @track email;
    @track responseData = []; 
    @track isLoading = false; 
    @track phoneError = ''; 
    @track emailError = '';
    get countryOptions() {
        return [
            { label: 'India', value: 'IND' },
            { label: 'Peru', value: 'PER' },
            { label: 'Colombia', value: 'COL' },
            { label: 'Indonesia', value: 'IDN' },
            { label: 'Singapore', value: 'SGP' },
            { label: 'Malaysia', value: 'MYS' },
        ];
    }
handleCountryChange(event) {
    this.selectedCountry = event.target.value;
}

handlePhoneChange(event) {
    const inputPhone = event.target.value;
    
    // Remove non-numeric characters and limit to 10 digits
    this.phone = inputPhone.replace(/\D/g, '').slice(0, 10);
        
    if (this.phone.length !== 10) {
        this.phoneError = 'Phone number must be exactly 10 digits.';
    } else {
        this.phoneError = ''; // Clear error if valid
    }
}

handlePhoneKeydown(event) {
    const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Tab', 'Delete'];
    const isNumericKey = event.key >= '0' && event.key <= '9';
    const isAllowed = allowedKeys.includes(event.key);

    // Prevent non-numeric keys and limit to 10 digits
    if (!isNumericKey && !isAllowed) {
        event.preventDefault();
    }

    // Prevent input if length exceeds 10 digits
    if (this.phone && this.phone.length >= 10 && !isAllowed) {
        event.preventDefault();
    }
}

handleEmailChange(event) {
    const inputEmail = event.target.value;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    this.email = inputEmail;

    if (!emailRegex.test(inputEmail)) {
        this.emailError = 'Invalid email format.';
    } else {
        this.emailError = '';  // Clear error if valid
    }
}

get isSubmitDisabled() {
    // Button should be enabled if either phone or email is valid, and country is provided
    return (
        (!this.phone || this.phoneError !== '') && 
        (!this.email || this.emailError !== '') || 
        !this.selectedCountry
    );
}

handleSubmit() {
    // Check if both phone and email are null
    if (!this.phone && !this.email) {
        this.phoneError = 'Please enter either a Phone number or Email.';
        return; 
    }

    // Ensure country is mandatory
    if (!this.selectedCountry) {
        this.countryError = 'Country is mandatory.';
        return;
    }

    // Check if phone number is valid
    if (this.phone && this.phone.length !== 10) {
        this.phoneError = 'Please enter a valid 10-digit phone number.';
        return; 
    }

    console.log('>>>' + this.selectedCountry + '>>' + this.phone + '>>' + this.email);
    this.isLoading = true; 
    
    fetchOfferDetails({ 
        country: this.selectedCountry, 
        phoneNo: this.phone || '', 
        emailId: this.email  || ''
    })
    .then(result => {
       // this.responseData = JSON.parse(result).data; 
        if (result.startsWith('{') || result.startsWith('[')) {
            this.responseData = JSON.parse(result).data; 
            this.errorMessage='';
        }else{

            this.errorMessage =result;
            if( this.errorMessage=='Internal Server Error'){
                this.errorMessage ='No offer details found for given details';
            }else{
              this.errorMessage =result;
            }
            this.responseData =[];
        }
        this.isLoading = false;
        
        this.resetInputs();
        console.log('>>responseData:',  this.responseData);
        console.log('Success:', result);
    })
    .catch(error => {
        this.errorMessage='An error occurred while fetching offers. Please try again.';
        console.error('Error:', error);
    });
}

resetInputs() {
    this.selectedCountry = '';
    this.phone = '';
    this.email = '';
    this.phoneError = ''; 
    this.emailError = ''; // Clear email error as well
   // this.errorMessage='';
}

}