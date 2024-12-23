import { LightningElement, track } from 'lwc';
//import createCase from '@salesforce/apex/IssueCaseController.createCase';

export default class IssueCaseForm extends LightningElement {
    @track issueType = 'My bus broke down or delayed'; // Example default value
    @track subIssueType = 'My boarding or dropping point was changed by the bus operator'; // Example default value
    @track channel = '';
    @track summary = '';

    // Options for Channel picklist
    get channelOptions() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Phone', value: 'Phone' },
            { label: 'Web', value: 'Web' }
        ];
    }

    // Handle Channel selection
    handleChannelChange(event) {
        this.channel = event.detail.value;
    }

    // Handle Summary input
    handleSummaryChange(event) {
        this.summary = event.target.value;
    }

    // Handle Create Case
    handleCreateCase() {
        if (!this.channel || !this.summary) {
            // Display error if required fields are missing
            this.showToast('Error', 'Channel and Summary are required', 'error');
            return;
        }

        // Call Apex to create a case
        createCase({
            issueType: this.issueType,
            subIssueType: this.subIssueType,
            channel: this.channel,
            summary: this.summary
        })
            .then(() => {
                this.showToast('Success', 'Case created successfully', 'success');
                this.resetForm();
            })
            .catch(error => {
                this.showToast('Error', 'Failed to create case: ' + error.body.message, 'error');
            });
    }

    // Show Toast
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    // Reset Form
    resetForm() {
        this.channel = '';
        this.summary = '';
    }
}