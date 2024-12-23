/**
 * **********************************************************************************************************
 * Lightning Web Component   :   transactionCallDetails
 * Includes                  :   transactionCallDetails.html, transactionCallDetails.js, transactionCallDetails.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      21 MAY 2024
 * @description  This component "transactionCallDetails" is created to show the related call details at the transaction layout.
 * @JiraId       CRM-1756
 */

import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchRelatedCallDetails from "@salesforce/apex/fetchCallDetailsCtrl.getRelatedCallDetails";

export default class TransactionCallDetails extends NavigationMixin(LightningElement) {

    @track callDetailsData = [];
    @api recordId;
    @track isLoading;
    @track showTableData;
    @track initialDataReceived =[];
    @track error;
    @track errorMessage;
    @track sortBy;
    @track sortDirection;
    @track data =[];

    @track coloumns = [
        {
            label: 'Call Id',
            fieldName: 'callDetail_url',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_self'}
        },
        {
            label: 'Created Date',
            fieldName: 'CallcreatedDate',
            type: 'text',
            sortable: true
        }
    ];

    doSorting(event) {
        console.log('Inside Sort');
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }    

    connectedCallback() {
        this.isLoading = true;
        fetchRelatedCallDetails({
            transactionId:this.recordId
        })
        .then(result=>{
            this.isLoading=false;
            if(result){
                let tempRecs = [];
                const options = {
                    year: 'numeric', month: 'numeric', day: 'numeric',
                    hour: 'numeric', minute: 'numeric', second: 'numeric',
                    hour12: false
                };
                result.forEach( ( record ) => {
                    console.log(':: this.record = '+JSON.stringify(record));
                    let tempRec = Object.assign( {}, record );  
                    tempRec.callDetail_url = '/' + tempRec.Id;
                    let dt = new Date( tempRec.CreatedDate );
                    console.log(':: dt = '+dt);
                    tempRec.CallcreatedDate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
                    console.log(':: tempRec = '+JSON.stringify(tempRec));
                    tempRecs.push( tempRec );
                    
                });
                this.data = tempRecs;
                console.log(':: this.data1 = '+JSON.stringify(this.data));
                if(this.data.length>0){
                    this.showTableData = true;
                    this.initialDataReceived = tempRecs;
                    if(this.data){
                        this.data.forEach(item => item['callDetail_url'] = '/lightning/r/Call_Details__c/' +item['Id'] +'/view');
                    }
                    console.log(':: this.data = '+JSON.stringify(this.data));


                }else{
                    this.showTableData = false;
                    this.error = true;
                    this.errorMessage = 'something went wrong please contact to the system administrator';
                }
            }
        }).catch(error => {
            this.isLoading = false;
            this.errorMessage = error;
        });
    }
}