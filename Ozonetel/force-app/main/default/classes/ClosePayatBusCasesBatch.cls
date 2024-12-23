/**
 * (c) 2018 RedBus
 *
 * Name           : ClosePayatBusCasesBatch
 * Created Date   : 14 March 2022
 * Created By     : Mahendra k
 * Purpose        : Batch class to close pay at bus post doj cases
 **/
 
global class ClosePayatBusCasesBatch implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public ClosePayatBusCasesBatch(){}
  
    public ClosePayatBusCasesBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='PayatBusCasesClose'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='PayatBusCasesClose'].Duration__c;
        System.schedule('ClosePayatBusCasesBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new ClosePayatBusCasesBatch(Query));
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
        DateTime currTime = System.Now();
 
        List<case> listCasesToUpdate = new List<Case>();
        list<casecomment> listCommToInsert = new List<casecomment>();
        
        for(Case cs : listCase)
        {
           datetime doj=cs.SS_DOJ__c;
           
           if(currTime > doj){
            casecomment cc=new casecomment();
            cc.commentbody='This case is closed by the system as doj croseed';
            cc.parentid=cs.id;
            cs.status='Closed';
            listCommToInsert.add(cc);
            listCasesToUpdate.add(cs);
          }
        }
        
         if(!listCommToInsert.isEmpty()){
          insert listCommToInsert;
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