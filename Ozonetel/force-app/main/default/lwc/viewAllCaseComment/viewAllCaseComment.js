import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetDetails from '@salesforce/apex/HighLightPanelDataGet.getCaseComment';
import updateCC from '@salesforce/apex/HighLightPanelDataGet.ViewAllUpdateCaseComments';
import updateCaseComment from '@salesforce/apex/HighLightPanelDataGet.UpdateCaseComment';

export default class ViewAllCaseComment extends LightningElement {
@api recordId ;
@track ccData=[];
@track showNew=false;
@track showEdit = false;
@track showDelete = false;
@track editMode = false;
@track selCmnt='';
@track ccId='';
@track caseId='';
@track editMode = false;
@track columns = [
{
label: 'Created Date',
fieldName: 'CreatedDate',
type: 'date',
typeAttributes: {  
    day: 'numeric',     
    month: 'short',  
    year: 'numeric',  
    hour: '2-digit',  
    minute: '2-digit',  
    second: '2-digit',  
    hour12: true},
sortable: true
},   
{
label: 'Created By',
fieldName: 'CreatedBy',
type: 'link',
sortable: true
}, 
{
label: 'Comment',
fieldName: 'CommentBody',
type: 'text',
sortable: true,
editable: true,
},
/*{type: "button-icon", typeAttributes: {  
iconName: "utility:delete",
name: 'delete_record', 
title: 'Delete',
variant: 'border-filled',
alternativeText: 'edit',
disabled: false,
}},*/ 
];

connectedCallback() {
console.log('View ALl Lwc : '+this.recordId);
GetDetails({
    csId:this.recordId
    })
    .then(data=>{
        console.log( 'view All data List'+JSON.stringify(data));
        this.ccData = data;
        for(var i=0; i<this.ccData.length;i++){
            var row = this.ccData[i];
            row.CreatedBy=row.CreatedBy.Name;
        }
    })
}
/*    handleSave(event) {
    this.draftCCData= event.detail.draftValues;
    updateCC({
        ccData : this.draftCCData
    })
    .then(data=>{
        this.ccData=[];
        GetDetails({
            csId:this.recordId
            })
            .then(data=>{
                this.draftValues = [];
                this.ccData = data;
                for(var i=0; i<this.ccData.length;i++){
                    var row = this.ccData[i];
                    row.CreatedBy=row.CreatedBy.Name;
                }
        })
    })        

} */
handleBody(event){
    this.selCmnt=event.target.value;
    }
    
handleSave(event){
    this.editMode=false;
    updateCaseComment({
            Id:this.ccId,
            comment:this.selCmnt
        })
        .then(data=>{
            this.ccData=[];
            GetDetails({
                csId:this.recordId
                })
                .then(data=>{
                    console.log( 'view All data List'+JSON.stringify(data));
                    this.ccData = data;
                    for(var i=0; i<this.ccData.length;i++){
                        var row = this.ccData[i];
                        row.CreatedBy=row.CreatedBy.Name;
                    }
                })
        
        })
        .catch(error =>{
        }); 
    
    }        
handleCancel(event){
this.editMode = false;
this.caseId='';
this.ccId='';
this.selCmnt='';}
    handleClickEdit(event){
    this.editMode = true;
for(var i=0;i<this.ccData.length; i++){
    if(this.ccData[i].Id==event.target.value){
        this.selCmnt= this.ccData[i].CommentBody;
        this.ccId = this.ccData[i].Id;
        this.caseId= this.ccData[i].ParentId;
    }
}
}

hanldeProgressValueChange(event){
    if(event.detail == true){
        this.showNew = false;
        this.ccData = [];
        GetDetails({
            csId:this.recordId
            })
            .then(data=>{
                this.ccData = data;
                for(var i=0; i<this.ccData.length;i++){
                    var row = this.ccData[i];
                    row.CreatedBy=row.CreatedBy.Name;
                }
        })
    }
    
}
handleNewClick(event){
    this.showNew = true;
}
callRowAction( event ) {  
this.ccId=event.detail.row.Id;
this.showDelete = true;
}
handleDeleteCancel(){
    this.ccId='';
    this.showDelete=false;
}
handleDelete(){
    this.showDelete=false;
    deleteCC({
        Id:this.ccId
    })
    .then(() => {
        this.ccId ='';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record Is Deleted',
                variant: 'success',
            }),
        );
        this.ccData = [];
        GetDetails({
            csId:this.recordId
            })
            .then(data=>{
                this.ccData = data;
                for(var i=0; i<this.ccData.length;i++){
                    var row = this.ccData[i];
                    row.CreatedBy=row.CreatedBy.Name;
                }
        })

    })
    .catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error While Deleting record',
                message: error.message,
                variant: 'error',
            }),
        );
    });
}

}