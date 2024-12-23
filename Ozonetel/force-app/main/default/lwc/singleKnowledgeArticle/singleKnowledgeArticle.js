import { LightningElement, api,track, wire } from 'lwc';
import GetKnowledgeArticle from '@salesforce/apex/LeadKnowledgeArticle.openKnowledgeArticle';

export default class SingleKnowledgeArticle extends LightningElement {

    @api article;
    @track details;
    @track articledetails ='';
    @track artNum='';
    @track status='';
    @track label='';

    @wire(GetKnowledgeArticle, {devName:'$article'})
    wireMethod({error,data}){
    if(data){
         this.articledetails=data.article;
         this.artNum=data.articlenum;
         this.status=data.status;
         this.label=data.label;

         }
    }
    
    
}