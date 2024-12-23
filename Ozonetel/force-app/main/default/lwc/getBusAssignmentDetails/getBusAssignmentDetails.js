import { LightningElement,api, wire,track } from 'lwc';
import GetbusDetails from '@salesforce/apex/GetTransactionDetails.getBusAssignmentDetails';
export default class GetBusAssignmentDetails extends LightningElement {
@api recId;
@track operatorName='';vehicle='';driverMobile='';driverName='';driverMobile2='';driverName2='';source='';destination='';
@track showDetails = false;showError=false;

connectedCallback() {
    GetbusDetails({
        ordId:this.recId
        })
        .then(data=>{
            console.log('response'+JSON.stringify(data));
            this.showError = data.showError;
            if(data.data!=null && data.data!=[]){
                this.showDetails = true; 
                this.vehicle = data.data[0].vehicleNumber;               
                this.driverMobile = data.data[0].driverNumber;
                this.driverMobile2 = data.data[0].conductorNumber;
                this.operatorName = data.operator;
                this.driverName = data.data[0].driverName;
                this.driverName2 = data.data[0].conductorName;
                this.source = data.data[0].source;
                this.destination = data.data[0].destination;
            }
            else{
                this.showError = true;
                console.log('<<error'+this.showError);
                this.showDetails = false;
        
            }    
        })
    }
    
/*@wire(GetbusDetails, {ordId:'$recId' })
wireMethod({error,data}){
    if(data){ 
        console.log('1'+this.showError);
        this.showError = data.showError;
        if(data.data!=null && data.data!=[]){
            this.showDetails = true; 
            this.vehicle = data.data.vehicle;
            this.driverMobile = data.data.driverMobile;
            this.driverMobile2 = data.data.driverMobile2;
            this.operatorName = data.data.operatorName;
            this.driverName = data.data.driverName;
            this.driverName2 = data.data.driverName2;
            this.helperMobile = data.data.helperMobile;
            this.helperName = data.data.helperName;
        }
        else{
            this.showError = true;
            console.log('2'+this.showError);
            this.showDetails = false;
    
        } 
    }
    else{
        this.showError = true;
        console.log('3'+this.showError);
        this.showDetails = false;

    } 
}*/
}