/**
 * (c) 2018 RedBus
 *
 * Name           : RPWescalatedtoBDBatch
 * Created Date   : 21 JUNE 202021
 * Created By     : Mahendra k
 * Purpose        : Batch class to update status to Escalated to BD for RPW cases
 **/
 
global class RPWescalatedtoBDBatch implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public RPWescalatedtoBDBatch(){}
  
    public RPWescalatedtoBDBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RPWcasesEscalted2BD'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinHF'].Duration__c;
        System.schedule('RPWescalatedtoBDBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RPWescalatedtoBDBatch(Query));
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
        Group BDQ=[select id from Group where type='Queue' AND developername='BD_Queue']; 

        
        for(Case cs : listCase)
        {
           datetime twentyFourHoursBD=cs.createddate.addhours(72);
           
           if(currTime > twentyFourHoursBD){
            casecomment cc=new casecomment();
            cc.commentbody='No Response From the BO, 48 hrs completed';
            cc.parentid=cs.id;
            cs.status='Escalated to BD';
            cs.ownerid=BDQ.id;   
            cs.Assigned_to_BD__c=System.now();
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