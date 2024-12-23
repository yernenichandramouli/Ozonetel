public with sharing class CZentrixRecords_cls
{
    public Integer numberofCalls{get;set;}
    public String lastCaseFeedStatus{get;set;}
    public String lastCSATAnswer{get;set;}
    public Account acc{get;set;}
    public Integer numberOfOpenCases{get;set;}
    public CZentrixRecords_cls(ApexPages.StandardController controller)
    {
        lastCaseFeedStatus='';
        numberofCalls=0;
        lastCSATAnswer='';
        Id accId=ApexPages.CurrentPage().getParameters().get('Id');
        List<AggregateResult> agr = [Select Count(Id)ct From CZentrix_Info__c Where Account_Name__c=:accId AND LastModifiedDate= LAST_N_DAYS:7];
        numberofCalls=(Integer)agr[0].get('ct');
        
        List<Case> caseList=[select id from Case where status!='Closed' AND (Accountid=:accId OR customer_name__c=:accId)];
        
        numberOfOpenCases=caseList.size();
        for(CZentrix_CSAT__c c :[Select answer__c,Answer_Formula__c From CZentrix_CSAT__c Where CZentrix_Info__r.Account_Name__c=:accId ORDER BY CreatedDate DESC LIMIT 1])
        {
            lastCSATAnswer=c.Answer_Formula__c;
        } 
        for(Case cs :[Select Id,(Select Id,Rating__c,Case_Name__c From Case_Feedback__r ORDER BY CreatedDate DESC limit 1) From Case Where AccountId =:accId ORDER BY CreatedDate DESC limit 1])
        {
            if(cs.Case_Feedback__r.size()>0)
            {
                lastCaseFeedStatus=cs.Case_Feedback__r[0].Rating__c;
            }
        }
    }
   
}