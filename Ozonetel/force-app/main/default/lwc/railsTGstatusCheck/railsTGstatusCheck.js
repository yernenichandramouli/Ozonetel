// lwcComponent.js
import { LightningElement, api,wire } from 'lwc';
import railsTGstatusCheck from '@salesforce/apex/RailsPNRstatusCheckCntrl.GetRailsTGstatus';

const columns = [
    { label: 'Attribute', fieldName: 'key',initialWidth: 130 },
    { label: 'Value', fieldName: 'value',initialWidth: 950 }
];

export default class railsClassTGstatusCheck extends LightningElement {
        @api recordId;

    tripAttributes = [];
    columns = columns;

    @wire(railsTGstatusCheck, {
        ordItemId: '$recordId'
    })
    wireMethod({
        error,
        data
    }) {
        if (data) {
            // Parse the JSON response
            const parsedResponse = JSON.parse(data);
            this.tripAttributes = [];

            // Convert the response into an array of objects
            for (let key in parsedResponse) {
                if (parsedResponse.hasOwnProperty(key)) {
                let value = parsedResponse[key];
                // Check if the key is 'isChartPrepared' and modify the value accordingly
                value = key === 'isChartPrepared' ? (value ? 'YES' : 'NO') : value;
                this.tripAttributes.push({ key: key, value: value });
               }
            }
        } else if (error) {
            console.error('Error fetching trip status:', error);
        }
    }
}