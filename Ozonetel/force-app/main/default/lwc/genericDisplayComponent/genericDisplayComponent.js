import { LightningElement, api,track } from 'lwc';

export default class GenericDisplayComponent extends LightningElement {
   @api objectData;

 get objectProperties() {
         if (!this.objectData) {
            return [];
        }
        console.log('>>this.objectData>>'+this.objectData);
        // Convert object properties into an array of { name, label, value } objects

        //const jsonObject = JSON.parse(this.objectData);
        const obj = JSON.parse(this.objectData);
        return Object.keys(obj).map(key => ({ name: key, value: obj[key] }));
  }

  get columns() {
        return [
            { label: 'Name', fieldName: 'name', type: 'text'},
            { label: 'Value', fieldName: 'value', type: 'text'},
        ];
    }
 }