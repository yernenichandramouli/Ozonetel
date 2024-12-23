@isTest
public class LeadKnowledgeArticleTest {
    @isTest
   public static void testLeadKnowledgeArticle(){
        LeadKnowledgeArticle.getArticles();
        list<Lead_Knowledge_Article__mdt> artdetails = [SELECT MasterLabel,Article__c,ArticleNumber__c,Publication_Status__c,DeveloperName FROM Lead_Knowledge_Article__mdt where DeveloperName='To_send_the_quotation_link'];
        LeadKnowledgeArticle.openKnowledgeArticle(artdetails[0].DeveloperName);
    }
}