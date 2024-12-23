import { LightningElement, api, track } from 'lwc';
import GetParentCase from '@salesforce/apex/RelatedCases.getParentCase';
import GetRelatedCases from '@salesforce/apex/RelatedCases.getrelatedCases';
import GetChildCases from '@salesforce/apex/RelatedCases.getChilidCases';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'url',
    typeAttributes: {
        label: { fieldName: 'CaseNumber' },
        target: '_blank'
    }},
    { label: 'Status', fieldName: 'Status'  }
];
export default class RelatedCases extends NavigationMixin(LightningElement) {
@api recordId;
@track parentCase;
@track showparent=false;
@track showCases=false;
@track showChildCases=false;
@track caseList;
@track childCases;
columnsList = columns;

    connectedCallback() {
        GetRelatedCases({
            caseId:this.recordId
        })
        .then(data=>{
            if(data != null && data !=''){
                this.caseList=data;
                this.showCases=true;
            }
            GetParentCase({
                caseId:this.recordId
            })
            .then(data=>{
                if(data!=null && data!= ''){
                    this.parentCase=data;
                    this.showparent=true;
                }
            })         
            GetChildCases({
                caseId:this.recordId
            })
            .then(data=>{
                if(data!=null && data !=''){
                  this.showChildCases=true;
                  this.childCases=data;
              }  
            })    

        })
    }
    handleparentCase(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentCase.Id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        }, false);
    }
    handlepChildCase(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Case',
                actionName: 'view'
            }
        }, false);

    }

}