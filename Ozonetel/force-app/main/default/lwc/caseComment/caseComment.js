import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetDetails from '@salesforce/apex/HighLightPanelDataGet.getCaseComment';
import updateCaseComment from '@salesforce/apex/HighLightPanelDataGet.UpdateCaseComment';
import { NavigationMixin } from 'lightning/navigation';

export default class CaseComment extends NavigationMixin(LightningElement) {
@api recordId;
@track CaseComment=[];
@track createMode = false;
@track editMode = false;
@track selCmnt='';
@track ccId='';
@track caseId='';
@track url='';
@track caseCount=0;
@track comments=[];
@track showViewAll = false;
connectedCallback() {
    GetDetails({
        csId:this.recordId
        })
        .then(data=>{
            this.CaseComment = data;
            this.caseCount = this.CaseComment.length;
            this.comments=[];
            if(this.caseCount > 0){
                this.showViewAll = true;
                if(this.caseCount >= 3){
                    this.comments.push(this.CaseComment[0]);
                    this.comments.push(this.CaseComment[1]);
                    this.comments.push(this.CaseComment[2]);        
                }
                else{
                    for(var i=0;i<this.caseCount;i++){
                        this.comments.push(this.CaseComment[i]);
                    }
                }
            }
            else{
                this.showViewAll = false;
            }
    })
}
handleClickNew(event) {
this.createMode = true;
this.caseId=event.target.value;
}
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
        this.CaseComment=[];
        GetDetails({
            csId:this.caseId
            })
            .then(data=>{
                this.CaseComment = data;
                this.caseCount = this.CaseComment.length;
                if(this.caseCount > 0){
                    this.showViewAll = true;
                }
                else{
                    this.showViewAll = false;
                }
                this.comments=[];
                if(this.caseCount > 0){
                    this.showViewAll = true;
                    if(this.caseCount >= 3){
                        this.comments.push(this.CaseComment[0]);
                        this.comments.push(this.CaseComment[1]);
                        this.comments.push(this.CaseComment[2]);        
                    }
                    else{
                        for(var i=0;i<this.caseCount;i++){
                            this.comments.push(this.CaseComment[i]);
                        }
                    }
                }
            
                this.caseId='';
                this.ccId='';
                this.selCmnt='';
                const evt = new ShowToastEvent({
                    message: 'Case Comment was saved',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            .catch(error =>{
            });  
    })
    .catch(error =>{
    }); 

}
showSuccessToast(){
    const evt = new ShowToastEvent({
        message: this.message,
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}            
handleCancel(event){
this.editMode = false;
this.caseId='';
this.ccId='';
this.selCmnt='';}
handleClickEdit(event){
    this.editMode = true;
for(var i=0;i<this.CaseComment.length; i++){
    if(this.CaseComment[i].Id==event.target.value){
        this.selCmnt= this.CaseComment[i].CommentBody;
        this.ccId = this.CaseComment[i].Id;
        this.caseId= this.CaseComment[i].ParentId;
    }
}
}
hanldeProgressValueChange(event){
    if(event.detail == true){
    this.createMode =false;
    this.CaseComment=[];
    GetDetails({
        csId:this.caseId
        })
        .then(data=>{
            this.CaseComment = data;
            this.caseCount = this.CaseComment.length;
            if(this.caseCount > 0){
                this.showViewAll = true;
            }
            else{
                this.showViewAll = false;
            }

            this.comments=[];
            if(this.caseCount > 0){
                this.showViewAll = true;
                if(this.caseCount >= 3){
                    this.comments.push(this.CaseComment[0]);
                    this.comments.push(this.CaseComment[1]);
                    this.comments.push(this.CaseComment[2]);        
                }
                else{
                    for(var i=0;i<this.caseCount;i++){
                        this.comments.push(this.CaseComment[i]);
                    }
                }
            }
            this.caseId='';
            this.ccId='';
            this.selCmnt='';
            const evt = new ShowToastEvent({
                message: 'Case Comment was created',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch(error =>{
        });  
    }
}
handleViewAll(event){
    var evnt = 'viewAll';
    console.log('handeViewALl');
    const viewAll = new CustomEvent('click',{
        detail: {evnt} 
    });
    this.dispatchEvent(viewAll);                    

}
}