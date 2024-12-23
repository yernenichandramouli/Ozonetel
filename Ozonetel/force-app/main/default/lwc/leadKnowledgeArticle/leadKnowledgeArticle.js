import { LightningElement ,wire, track, api} from 'lwc';
import GetKnowledgeArticles from '@salesforce/apex/LeadKnowledgeArticle.getArticles';
import { NavigationMixin } from 'lightning/navigation';

export default class LeadKnowledgeArticle extends NavigationMixin(LightningElement){

@api article;
@track searchText=''; 
@track mapdata=[]; 
@track mapArticles=[];
@wire(GetKnowledgeArticles)
wireMethod({error,data}){
if(data){
    var cmdt = data;
    for(var key in cmdt){
        this.mapArticles.push({value:cmdt[key],key:key});
        this.mapdata.push({value:cmdt[key],key:key});
    }
}
}

handleKeyUp(event){
this.searchText = event.target.value;
this.mapdata=[];
for(var key in this.mapArticles){
var article = this.mapArticles[key].value.Article__c;
var pos = article.indexOf(this.searchText);
if(pos != -1)
    this.mapdata.push({value:this.mapArticles[key].value,key:this.mapArticles[key].value.DeveloperName});
}
}
handleClickUrl(event){
    this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
            componentName: "c__OpenKnowledgeArticle"
        },
        state: {
            c__article:event.target.label
        }
    });

}
}