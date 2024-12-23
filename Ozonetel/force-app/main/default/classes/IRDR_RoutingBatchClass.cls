/**
* (c) 2019 RedBus
*
* Name           : IRDR_RoutingBatchClass
* Created Date   : 08 May 2023
* Created By     : Mahendra K
* Purpose        : Scheduler/Batch to mark lead as dead 
*
**/

global class IRDR_RoutingBatchClass implements Database.Batchable<sObject>,Schedulable
{      
    
    global final String Query;
    
    public IRDR_RoutingBatchClass(){}
    
    public IRDR_RoutingBatchClass(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='IRDR_Routing_Batch_Query'].QueryDetails__c;
        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='IRDR_Routing_Batch_Query'].Duration__c;
        System.schedule('L2 Support_RoutingBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new IRDR_RoutingBatchClass(Query));
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
            list<casecomment> listCommToInsert = new List<casecomment>();
            List<case>  caseListUpdate= new List<case>();
            
            Map<String,Issue_Based_TAT__mdt> mapIssueIrDr = new Map<string,Issue_Based_TAT__mdt>();
            
            list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
            Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
            
            for(Issue_Based_TAT__mdt issueTAT : [SELECT id,toLabel(Issue_Type__c),QueueId__c,Queue__c,Business_Type__c,Country__c,Bolt_Enable__c,Priority__c,toLabel(Issue_Sub_Category__c),Applicable_Date_From__c,Amount__c,redCare__c,Version__c,redCare_Applicable_from__c,TAT_Value__c,Enable_IRDR__c,Amber_Zone__c,Green_Zone__c,Red_Zone__c from Issue_Based_TAT__mdt where Version__c='V3' and Enable_IRDR__c=True and Queue__c!=null])
            {
                mapIssueIrDr.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
            }
            
            system.debug('====mapIssueIrDr==='+mapIssueIrDr);
            system.debug('====size==='+mapIssueIrDr.size());
            
            for(case cs: caseList)
            {
                system.debug('>>>>>>>>cs>>>>>>>>>>>'+cs+'>>>size>>>>'+caseList.size());
                try{
                    String strIssueSubIssue = cs.Issue_Type__c+cs.Issue_Sub_Category__c;
                    
                        if(mapIssueIrDr.containsKey(strIssueSubIssue))
                        {
                            system.debug('>>> If bolt>>>>>>');
                             cs.ownerId=System.Label.L2_Support_Queue_Id;
                                cS.Flow_Type__c='L2 Support Queue';
                                cs.Priority = mapIssueIrDr.get(strIssueSubIssue).Priority__c;
                                cs.TAT_Value__c = mapIssueIrDr.get(strIssueSubIssue).TAT_Value__c;
                                cs.Green_Zone__c = mapIssueIrDr.get(strIssueSubIssue).Green_Zone__c;
                                cs.Amber_Zone__c = mapIssueIrDr.get(strIssueSubIssue).Amber_Zone__c;
                                cs.is_IRDR_Batch__c=True;
                                caseListUpdate.add(cs);
                            
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
        mail.setSubject('IR Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The IRDR batch ClassAssignment jobb processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}