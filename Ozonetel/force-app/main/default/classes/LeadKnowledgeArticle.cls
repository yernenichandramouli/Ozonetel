public class LeadKnowledgeArticle {
    @AuraEnabled(cacheable=true)
    public static map<string ,Lead_Knowledge_Article__mdt> getArticles() {
		system.debug('<<<<'+Lead_Knowledge_Article__mdt.getAll());
		List<knowledgeArticle> kaList = new List<knowledgeArticle>();
        map<string ,Lead_Knowledge_Article__mdt> mapka = Lead_Knowledge_Article__mdt.getAll();
        	if(mapka.size()>0)
            return mapka;
        	else
                return null;
    }
    @AuraEnabled(cacheable=true)
    public static knowledgeArticle openKnowledgeArticle(string devName){
       system.debug('<<<devName'+devName);
        list<Lead_Knowledge_Article__mdt> artdetails = [SELECT MasterLabel,Article__c,ArticleNumber__c,Publication_Status__c FROM Lead_Knowledge_Article__mdt where DeveloperName=:devName];
        system.debug('<<<artdetails'+artdetails);
        if(artdetails.size()>0){
          knowledgeArticle ka = new knowledgeArticle();
            ka.article = artdetails[0].Article__c;
            ka.articlenum = artdetails[0].ArticleNumber__c;
            ka.status = artdetails[0].Publication_Status__c;
            ka.label = artdetails[0].MasterLabel;
			system.debug('<<<ka'+ka);
            return ka;
        }

        return null;
    }
    
    public class knowledgeArticle{
        @Auraenabled
        public string article{get; set;}
        @Auraenabled 
        public decimal articlenum{get; set;}
        @Auraenabled 
        public string status{get; set;}
        @Auraenabled
        public string label{get; set;}
        
    }
    
}