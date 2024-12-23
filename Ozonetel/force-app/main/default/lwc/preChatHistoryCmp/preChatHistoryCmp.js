/**
 * **********************************************************************************************************
 * Lightning Web Component   :   preChatHistoryCmp
 * Includes                  :   preChatHistoryCmp.html, preChatHistoryCmp.js, preChatHistoryCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2023-JUN-14
 * @description  This component "preChatHistoryCmp" is created to fetch the selfhelp bot comments before connecting chat to agent.
 * @JiraId       CRM-1431
 */

import { LightningElement,api, track } from 'lwc';
import invokeChatHistoryApi from '@salesforce/apex/chatHistoryCtrl.invokeSelfHelpAPI';

export default class PreChatHistoryCmp extends LightningElement {
    @api recordId;
    @track prevChatHistory;
    @track success = false;
    @track error = false;
    @track isLoading = false;
    @track showChatHistory = false;
    @track errorMessage;

    connectedCallback() {
        this.isLoading = true;
        invokeChatHistoryApi({
            recordId:this.recordId
        })
        .then(result=>{
            if(result ==='Unable to process the request'){
                this.error = true;
                this.isLoading = false;
                this.errorMessage = result;
            }else{
                this.success=true;
                this.isLoading = false;
                this.prevChatHistory = result;
                this.showChatHistory = true;
                console.log(':: result = '+this.prevChatHistory);
            }
        }).catch(error => {
            this.isLoading = false;
            this.error = true;
            this.errorMessage = error;
        });
    }

}