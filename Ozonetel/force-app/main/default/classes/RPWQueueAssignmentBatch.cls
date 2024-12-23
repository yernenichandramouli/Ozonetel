/**
 * (c) 2018 RedBus
 *
 * Name           : RPWQueueAssignmentBatch
 * Created Date   : 11 Jan 2022
 * Created By     : Mahendra k
 * Purpose        : Batch class to update Owner to RPW Queue
 **/
 
global class RPWQueueAssignmentBatch implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public RPWQueueAssignmentBatch(){}
  
    public RPWQueueAssignmentBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RPWQueueAssignment'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RPWQueueAssignment'].Duration__c;
        System.schedule('RPWQueueAssignment - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RPWQueueAssignmentBatch(Query));
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
     global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
      System.debug('## ..'+listCase.size()+' records'+'..'+listCase);
      if(!listCase.isEmpty())
      {
 
        List<case> listCasesToUpdate = new List<Case>();
        Group rpwQ=[select id from Group where type='Queue' AND developername='RPW_Queue']; 

        
        for(Case cs : listCase)
        {
            cs.ownerid=rpwQ.id;   
            listCasesToUpdate.add(cs);
        }
        
         
        if(!listCasesToUpdate.isEmpty())
            update listCasesToUpdate;
      }
    }
    
    global void finish(Database.BatchableContext BC) 
    {                 
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('Mahendrareddy.k@redbus.com.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Case Assignment Has Finished '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
  }