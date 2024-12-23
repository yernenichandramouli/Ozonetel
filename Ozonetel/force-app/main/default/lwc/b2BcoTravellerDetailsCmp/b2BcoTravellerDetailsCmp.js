/**
 * **********************************************************************************************************
 * (c) 2023 RedBus
 * Lightning Web Component   :   b2BcoTravellerDetailsCmp
 * Includes                  :   b2BcoTravellerDetailsCmp.html, b2BcoTravellerDetailsCmp.js, b2BcoTravellerDetailsCmp.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      05 FEB 2023
 * @description  This component "b2BcoTravellerDetailsCmp" is created to fetch the co passenger details to display at transaction level for B2B.
 * @JiraId       CRM-1632
 */
import { LightningElement, api,track } from 'lwc';
import getCoPassengerDetailsLM from '@salesforce/apex/CoPassengerDetailsCtrl.GetB2BCoPassengerDetails';

export default class B2BcoTravellerDetailsCmp extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track isLoading = false;
    @track data =[];
    @track errorMessage;
    @track error = false;
    @track initialDataReceived =[];
    @track showTableData = false;
    @track sortBy;
    @track sortDirection;

    @track coloumns = [
        {
            label: 'Tin',
            fieldName: 'transaction_url',
            type: 'url',
            typeAttributes: {label: { fieldName: 'tin' }, 
            target: '_self'}
        },
        {
            label: 'Boarding point',
            fieldName: 'boardingPoint',
            type: 'text',
            sortable: true
        },
        {
            label: 'Dropping point',
            fieldName: 'dropLocation',
            type: 'text',
            sortable: true
        },
        {
            label: 'Mobile Number',
            fieldName: 'mobile',
            type: 'text'
        },
        {
            label: 'Boarding Time',
            fieldName: 'convertedBoardingPoint',
            type: 'datetime',
            sortable: true
        },
        {
            label: 'Dropping Time',
            fieldName: 'convertedDroppingPoint',
            type: 'datetime',
            sortable: true
        }, 
        {
            label: 'InventoryType',
            fieldName: 'InventoryType',
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
        getCoPassengerDetailsLM({
            ordItemId:this.recordId
        })
        .then(result=>{
            this.isLoading=false;
            if(result){
                this.showTableData = true;
                let tempRecs = [];
                result.forEach( ( record ) => {
                    let tempRec = Object.assign( {}, record );  
                    tempRec.transaction_url = '/' + tempRec.transactionId;
                    tempRecs.push( tempRec );
                    
                });
                this.data = tempRecs;
                console.log(':: this.data1 = '+JSON.stringify(this.data));
                if(this.data.length>0){
                    this.initialDataReceived = tempRecs;
                    if(this.data){
                        this.data.forEach(item => item['transaction_url'] = '/lightning/r/Order_Items__c/' +item['transactionId'] +'/view');
                    }
                    console.log(':: this.data = '+JSON.stringify(this.data));


                }else{
                    this.error = true;
                    this.errorMessage = 'something went wrong please contact to the system administrator';
                }
            }
        }).catch(error => {
            this.isLoading = false;
            this.errorMessage = error;
        });
    }

    //Search the table based on boarding point name.
    searchBoardingPoint(event) {
        const inputValue = event.target.value;
        const regex = new RegExp(`^${inputValue}`, 'i');
        this.data = this.initialDataReceived.filter(row => regex.test(row.boardingPoint));
        if (!event.target.value) {
            this.data = [...this.initialDataReceived];
        }
    }

    //Search the table based on dropping point name.
    searchDroppingPoint(event) {
        const inputValue = event.target.value;
        const regex = new RegExp(`^${inputValue}`, 'i');
        this.data = this.initialDataReceived.filter(row => regex.test(row.dropLocation));
        if (!event.target.value) {
            this.data = [...this.initialDataReceived];
        }
    }
}