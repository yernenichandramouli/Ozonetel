import { LightningElement,api, track,wire } from 'lwc';
import GetJsString from '@salesforce/apex/TravelProtectInsuranceCls.getJson'; 
import GetData from '@salesforce/apex/TravelProtectInsuranceCls.jsonToMap';
import GetColumns from '@salesforce/apex/TravelProtectInsuranceCls.jsonColumns';
export default class TravelProtectInsuranceCls extends LightningElement {
@api recordId;  
@track jsString=' ';
@track columns;
@track data;
@track showTable=false;
@track showError =false;
@track comments=[];
@wire(GetJsString,{ordId:'$recordId'})
wireMethod({error,data}){

if(data){

var str = data;

if (data == 'error'){
this.showError = true;
}
else{
str = str.replace(/\\/g, "");

this.jsString = str;

GetColumns({jsdata:this.jsString})
.then(data=>{
    this.columns = JSON.parse(data);
   this.comments=this.columns;
}) 
.catch(error =>{
this.error = error;
});
GetData({jsdata:this.jsString})
.then(data=>{
    this.data = data;
    this.showTable = true;
}) 
.catch(error =>{
this.error = error;
});
} 
}
else{
    console.log('error-->'+error);
    }    
}

}