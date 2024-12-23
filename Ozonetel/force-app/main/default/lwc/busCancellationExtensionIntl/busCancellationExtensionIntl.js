import { LightningElement, track, wire, api } from 'lwc';
import GetboListm from '@salesforce/apex/BusCancellationExtnIntl.getboListValues'
import getmapServiceIdtoCase from '@salesforce/apex/BusCancellationExtnIntl.getmapServiceIdtoCase';
import performUpdate from '@salesforce/apex/BusCancellationExtnIntl.performUpdate';
import { NavigationMixin } from 'lightning/navigation';

export default class BUSCANCELLATIONEXTENSIONINTL extends NavigationMixin(LightningElement){
@track mapOfValues = []; selBO =''; activeSection; tin; doj; doi; selStatus='All'; callStatus='';
CaseStatus=' '; boList=[]; showSearchResult=false; gridData=''; error; testtext='RB'; routeIdList='';
showCallModal=false; showAllUpdate=false; showCaseUpdate=false; selAllCheck=false; showBoDetails=false;
BoAgentName=''; BoAgentNum=''; cases=[]; updateCases=''; updateError='Please select the action';
caseComment=''; showUpdate=false; showBoError=false; showCaseError=false;caseErrormsg='';
boErrormsg='';caserec;tmpCaseStatus=' ';selRouteId;NoRecordsMsg=false;success=false;CaseStatus='';count;
SelectAll=false;currentval;selectedNone=false;
@track updateAllCases='';
@track loaded = true;
@track finalReUrl = "javascript:srcUp('/5000p000002bSBEAA2');" ;
@track finalUrl='';

@wire(GetboListm)
wireMethod({error,data}){
if(data){
this.boList=[...this.boList,{value: '', label: 'All'}]    
for( var i=0; i<data.length; i++){   
this.boList = [...this.boList ,{value: data[i].Bus_Operator_Name__c , label: data[i].Bus_Operator_Name__c} ];
}         
}
else{
console.log('error-->'+error);
}
}

handleStatus(event){
this.selStatus = event.target.value;  
this.CaseStatus='';  
}
handleselBo(event){
this.selBO = event.target.value;    
}
handleTin(event){
this.tin = event.target.value;
}
handledoj(event){
this.doj = event.target.value;
}
handledoi(event){
this.doi=event.target.value;
}


handleSectionToggle(event) {
this.SelectAll = false;
if ( event.detail.openSections != this.selRouteId &&this.selRouteId !='' )
{
for(var i=0;i<this.mapOfValues.length;i++){
    if(this.mapOfValues[i].key == this.selRouteId){
        this.cases= this.mapOfValues[i].value;
        for(var j=0;j<this.cases.length;j++){
            this.cases[j].isSelect = false;
        }
    }
}        
}
this.selRouteId = event.detail.openSections;
};
get boOptions(){
return this.boList;
}
/*
get callStatusOpts() {
return [
{ label: '--None--', value: '' },
{ label: 'BOs Called-Already', value: 'BOs Called-Already' },
{ label: 'To-be-Called', value: 'To-be-Called' },
];
}; */

get statusOptions() {
return[
{label:'All', value:'All'},
{label:'Initiate Bus Cancellation', value:'Initiated'},
{label:'Approved for Bus Cancellation', value:'Approved For Bus Cancellation'},
{label:'Rejected for Bus Cancellation', value:'Rejected For Bus Cancellation'},
/*
{label:'Alternative Arrangement by BO', value:'Alternative Arrangement by BO'},
{label:'Alternative Arrangement by redBus', value:'Alternative Arrangement by redBus'},
{label:'Refunded by redbus',value:'Refund by redBus'},
{label:'Refunded by BO', value:'Refund by BO'}  */ 
];
};

get CaseStatusOpts(){
if(this.selStatus == 'Initiated'){
return[
    {label:'--None--', value:''},   
    {label:'Approved for Bus Cancellation', value:'Approved For Bus Cancellation'},
    {label:'Rejected for Bus Cancellation', value:'Rejected For Bus Cancellation'},
    ]
}
else if(this.selStatus == 'Approved For Bus Cancellation'){
    return[
    {label:'--None--', value:''},
    {label:'Refunded by BO',value:'Refunded by BO'},
    {label:'Refunded by RedBus',value:'Refunded by redBus'},
    {label:'Alternative Arrangement by RedBus',value:'Alternative Arrangement by redBus'},
    {label:'Alternative Arrangement by BO',value:'Alternative Arrangement by BO'}
]    
}
else if(this.selStatus =='Rejected For Bus Cancellation'){
return[
    {label:'--None--', value:''},
    {label:'Re-Approved for Bus Cancellation', value:'Re-Approved For Bus Cancellation'},
]
}
}

handleCaseStatus(event){
this.CaseStatus = event.target.value;
}
handelCall(event){
this.showCallModal = true; 
}
callBo(event){

}
cancelCall(event){
this.showCallModal = false; 
}
doUpdate(event){
if(this.SelectAll == true){
this.showAllUpdate = true;
if(this.CaseStatus != ''){
this.updateAllCases = 'You have selected all records for ' + this.CaseStatus +'. Are you sure?';
this.showCancel = true;
}
else{
this.updateAllCases = this.updateError;
this.showCancel=false;
} 
}   
else {
console.log('<<<'+this.CaseStatus);
for(var i=0;i<this.mapOfValues.length;i++){
    if(this.mapOfValues[i].key == this.selRouteId){
    this.selectedNone=true;
    this.cases= this.mapOfValues[i].value;
        for(var j=0;j<this.cases.length;j++){
            if(this.cases[j].isSelect == true)
                this.selectedNone = false; 
        }       
    }
}
if(this.selectedNone == false){
    if(this.CaseStatus=='Approved For Bus Cancellation' || this.CaseStatus == 'Rejected For Bus Cancellation' ){
        this.showBoDetails=true;
    }
    else{
        this.showCaseUpdate = true;
        if(this.CaseStatus != '')
        this.showComment = true;
        else
        this.showComment = false;    
    }    

}
}

}
updateAll(event){
this.showAllUpdate = false;
if(this.CaseStatus == 'Approved For Bus Cancellation' || this.CaseStatus == 'Rejected For Bus Cancellation'){
this.showBoDetails=true;
}
else{
this.showComment = true;
this.showCaseUpdate=true;
}
}
cancelUpdateAll(event){
this.showAllUpdate = false;
}
doSearch(event){
this.showSearchResult = false; 
this.mapOfValues=[];
this.showUpdate = false;
this.loaded = false;
this.success = false;              
getmapServiceIdtoCase({
    selBo:this.selBO,
    tin:this.tin,
    doj:this.doj,
    doi:this.doi,
    selStatus:this.selStatus,
//        callStatus:this.callStatus,
})
.then(data=>{
    console.log('<<data'+JSON.stringify(data));
for(let key in data) {           
    
    if (data.hasOwnProperty(key)) { // Filtering the data in the loop
    this.mapOfValues.push({value:data[key], key:key});
        }
}
if(this.mapOfValues.length>0){
    this.showSearchResult = true; 
    this.NoRecordsMsg = false;
    if( this.selStatus == 'All'){
        this.showUpdate = false;
    }
    else{
        this.showUpdate = true;
    }    
}
else{
    this.showUpdate = false;
    this.NoRecordsMsg = true;
}

this.loaded =true;

})
.catch(error =>{

this.error = error;
});
}

updateCase(event){  

if(this.CaseStatus !=''){
if(this.CaseStatus == 'Approved For Bus Cancellation')
this.tmpCaseStatus = 'Approved';
else if(this.CaseStatus == 'Rejected For Bus Cancellation')
this.tmpCaseStatus = 'Rejected';
else if(this.CaseStatus == 'Refunded by BO')
this.tmpCaseStatus = 'Refunded by BO';
else if(this.CaseStatus == 'Refunded by redBus')
this.tmpCaseStatus = 'Refunded by redBus';
else if(this.CaseStatus == 'Alternative Arrangement by redBus')
this.tmpCaseStatus = 'Alternative Arrangement by redBus';
else if(this.CaseStatus == 'Alternative Arrangement by BO') 
    this.tmpCaseStatus = 'Alternative Arrangement by BO';
else if(this.CaseStatus == 'Re-Approved For Bus Cancellation')
    this.tmpCaseStatus = 'Re-Approved';

this.success = false;
this.loaded = false;

if(this.showBoDetails==true){
    if((this.BoAgentName=='' || this.BoAgentNum.length!=10 ) && (this.CaseStatus == 'Approved For Bus Cancellation' || this.CaseStatus == 'Rejected For Bus Cancellation')){
        this.showBoDetails = true; 
        this.showBoError=true;
        this.loaded=true;
        if(this.BoAgentName=='')
            this.boErrormsg='You must enter value for BOAgentNamebySPOC';
        else
            this.boErrormsg='You must enter correct value for BOAgentContactBySPOC';    
    }
    else{
        this.showBoDetails=false;
        this.showBoError=false;
        for(var i=0; i<this.mapOfValues.length;i++){
            this.cases = this.mapOfValues[i].value;
            for(var j=0; j<this.cases.length; j++){                       
                if(this.cases[j].isSelect == true){
                    this.updateCases= this.updateCases + this.cases[j].cs.CaseNumber +';'
                }                        
            }
        }
        performUpdate({
            updateAction:this.tmpCaseStatus,
            BOAgentContactBySPOC:this.BoAgentNum,
            BOAgentNameBySPOC:this.BoAgentName,
            casecomment:'',
            updateCases:this.updateCases
        })
        .then(data=>{
            this.updateCases='';
            this.success = true;              
            this.mapOfValues=[];
            this.caseComment='';
            this.BoAgentName='';
            this.BoAgentNum='';
            getmapServiceIdtoCase({
                selBo:this.selBO,
                tin:this.tin,
                doj:this.doj,
                doi:this.doi,
                selStatus:this.selStatus,
//                    callStatus:this.callStatus,
                })
                .then(data=>{
                for(let key in data) {           
                    if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.mapOfValues.push({value:data[key], key:key});
                        console.log('data'+JSON.stringify(this.mapOfValues));
                    }
                } 
                this.loaded = true;  
                })
                .catch(error =>{
                this.error = error;
                });                })
        .catch(error =>{
            this.error = error;
        }); 
        
    }
}
if(this.showCaseUpdate == true){
    if(this.caseComment=='' || this.casecomment==' '){
        this.caseErrormsg ='Please Enter Description';            
        this.showCaseUpdate = true; 
        this.showCaseError =true;
        this.showComment=true;
        this.loaded=true;

    }
    else{
            this.showCaseUpdate = false; 
            this.showCaseError=false;
            console.log('<<<entered here');
            for(var i=0; i<this.mapOfValues.length;i++){
                this.cases = this.mapOfValues[i].value;
                for(var j=0; j<this.cases.length; j++){                       
                    if(this.cases[j].isSelect == true){
                        this.updateCases= this.updateCases + this.cases[j].cs.CaseNumber +';'
                    }                        
                }
            }

            performUpdate({
                updateAction:this.tmpCaseStatus,
                BOAgentContactBySPOC:'',
                BOAgentNameBySPOC:'',
                casecomment:this.caseComment,
                updateCases:this.updateCases
            })
            .then(data=>{
                this.updateCases='';
                this.success = true;              
                this.mapOfValues=[];
                this.caseComment='';
                this.BoAgentName='';
                this.BoAgentNum='';
                    getmapServiceIdtoCase({
                    selBo:this.selBO,
                    tin:this.tin,
                    doj:this.doj,
                    doi:this.doi,
                    selStatus:this.selStatus,
//                        callStatus:this.callStatus,
                    })
                    .then(data=>{
                    for(let key in data) {           
                        if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                            this.mapOfValues.push({value:data[key], key:key});
                            console.log('data'+JSON.stringify(this.mapOfValues));
                        }
                    }
                    this.loaded = true;   
                    })
                    .catch(error =>{
                    this.error = error;
                    });
                                })
            .catch(error =>{
                this.error = error;
            });                    
    }
}
}
else{
this.showCaseUpdate = false;
this.showComment=false;
}
}
cancelUpdateCase(event){
this.showCaseUpdate = false; 
this.showBoDetails=false;
this.caseErrormsg='';
this.showCaseError=false;
this.boErrormsg='';
this.showBoError=false;
this.loaded=true;
this.BoAgentName='';
this.BoAgentNum='';
}
selectDeselectAll(event){
this.SelectAll = !this.SelectAll;
if(event.target.checked)
    this.selectedNone = false;
for(var i=0 ; i<this.mapOfValues.length; i++)
{
if(event.target.value == this.mapOfValues[i].key){
    this.cases = this.mapOfValues[i].value;
    for(var j=0; j<this.cases.length; j++){
        if(this.mapOfValues[i].key == this.cases[j].routeId)   
        {
            if(event.target.checked)
                this.cases[j].isSelect = true;
            else
                this.cases[j].isSelect = false;
        }
    }   

}    
}
}
handleBoName(event){
this.BoAgentName = event.target.value ;   
}
handleBoNumber(event){
this.BoAgentNum = event.target.value;    
}
handleCaseComment(event){
this.caseComment = event.target.value;
}
rowSelChangeEvent(event){
    if(event.target.checked)
        this.selectedNone =false;
for(var i=0; i<this.mapOfValues.length;i++){
this.cases=this.mapOfValues[i].value;
for(var j=0; j<this.cases.length; j++){
    if(this.cases[j].cs.CaseNumber == event.target.value){
        if(event.target.checked)
        this.cases[j].isSelect = true;
        else{
            this.cases[j].isSelect = false;    
            this.SelectAll=false;
        }
    }
}
}
}
handleClick(event){
{

    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: event.target.value,
            objectApiName: 'Case',
            actionName: 'view'
        }
    }, false);
}

//    var caseId=event.target.value;
//    window.open(NavigateToCase+caseId+"/view");
}
handleClickTransaction(event){
{

    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: event.target.value,
            objectApiName: 'Order_Items__c',
            actionName: 'view'
        }
    }, false);
}

//    var transId = event.target.value;
//    window.open(NavigateToOrderItem+transId+"/view");
}
}