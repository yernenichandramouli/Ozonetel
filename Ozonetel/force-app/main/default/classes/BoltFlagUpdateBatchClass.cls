/**
* (c) 2019 RedBus
*
* Name           : BoltFlagUpdateBatchClass
* Created Date   : 14 sep 2023
* Created By     : Mahendra K
* Purpose        : If any case missing bolt flag will be updated  
*
**/

global class BoltFlagUpdateBatchClass implements Database.Batchable<sObject>,Schedulable
{      
    
    global final String Query;
    
    public BoltFlagUpdateBatchClass(){}
    
    public BoltFlagUpdateBatchClass(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Missing_BoltFlag_Batch_Query'].QueryDetails__c;
        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Missing_BoltFlag_Batch_Query'].Duration__c;
        System.schedule('Missing_BoltFlag_Batch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new BoltFlagUpdateBatchClass(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('--query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<case> caseList)
    {     
        System.debug('caseList## ..'+caseList.size()+' records'+'..'+caseList);
        if(!caseList.isEmpty())
        {
            
                DateTime currTime = System.Now();
                set<Id> setMetaIssueIds = new set<Id>();
                Set<String> setBoltSubIssueTypes = new Set<String>();
                
                list<casecomment> listCommToInsert = new List<casecomment>();
                List<case>  caseListUpdate= new List<case>();

                list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
                Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));

                //Instant Bolt
                for(Meta_Issue_Type__mdt mdt : [select id,toLabel(Issue_Type__c) from Meta_Issue_Type__mdt where Issue_Type__c!=null])
                {
                 setMetaIssueIds.add(mdt.id);
                }

                for(Meta_Issue_Sub_Category__mdt subMdt :[select toLabel(Issue_Sub_Category__c),Bolt_Applicable__c,Meta_Issue_Type__c from Meta_Issue_Sub_Category__mdt where Meta_Issue_Type__c in :setMetaIssueIds])
                {
                if(subMdt.Bolt_Applicable__c){
                  setBoltSubIssueTypes.add(subMdt.Issue_Sub_Category__c);
                 }
                }
        
            
            for(case cs: caseList)
            {
                try{
                    
                    string serviceProvId =  String.isNotBlank(cs.Service_Provider_Id__c)?cs.Service_Provider_Id__c:String.isNotBlank(cs.Service_Providerr_Id__c)?cs.Service_Providerr_Id__c:'';
                    if(string.isNotBlank(serviceProvId))
                    {
                        //bolt opertid + bolt subIssuetype 
                        if(instantRefundBoIds.contains(serviceProvId) && setBoltSubIssueTypes.contains(cs.Issue_Sub_Category__c))
                        { 
                          cs.Case_Category__c='Instant resolution-BOLT';
                          caseListUpdate.add(cs);  
                        }                        
                    }
                    
                }
                Catch(Exception e)
                {
                    
                }
            }
            
            system.debug('>>>caseListUpdate>>>'+caseListUpdate);
            if(!caseListUpdate.isEmpty()){
                DataBase.update(caseListUpdate,false);
            }
            
        }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {                 
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('mahendrareddy.k@redbus.com');
        //toAddresses.addall(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('Bolt flag update batch Has Finished '+a.Status);
        mail.setPlainTextBody
            ('Bolt flag batch update is processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}