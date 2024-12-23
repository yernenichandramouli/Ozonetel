import { LightningElement, api } from 'lwc';

export default class CustomAlertSupervisorCallback extends LightningElement {
    @api showModal = false;

    handleYes() {
        this.dispatchEvent(new CustomEvent('confirm', { detail: true }));
        this.showModal = false;
    }

    handleNo() {
        this.dispatchEvent(new CustomEvent('confirm', { detail: false }));
        this.showModal = false;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('confirm', { detail: false }));
        this.showModal = false;
    }
}