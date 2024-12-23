/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
/* eslint-disable no-else-return */
import { LightningElement,api, track } from 'lwc';

export default class GenericToastMessages extends LightningElement {
    @api notificationtype; //='success';
    @api notificationmessage;//='All working!';
   
    get showAnyMsg()
   {
        console.log('show any msg' + this.notificationtype + '..' + this.notificationmessage);
        if (this.notificationtype !== undefined && this.notificationmessage !== undefined)
            return true;
       else return false;
    
   }

    

    get notifcationThemeClass() {
        console.log('show any theme');
        return (
            "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_" +
            this.notificationtype
        );
    }

    get notifcationContainerClass() {
        console.log('show any con');
        return (
            "slds-icon_container slds-icon-utility-" +
            this.notificationtype +
            " slds-m-right_x-small"
        );
    }

    get iconClass() {
        console.log('show any icon');
        return (
            "/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#" + this.notificationtype
        );
    }
}