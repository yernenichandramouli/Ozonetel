import { LightningElement,api, track,wire } from 'lwc';
import GetJsString from '@salesforce/apex/GenericJsonToTable.getJson'; 
import GetData from '@salesforce/apex/GenericJsonToTable.jsonToMap';
import GetColumns from '@salesforce/apex/GenericJsonToTable.jsonColumns';
export default class GenericJsonToTable extends LightningElement {
@api recordId;  
@track jsString=' ';
@track columns;
@track data;
@track showTable=false;
@track showError =false;
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