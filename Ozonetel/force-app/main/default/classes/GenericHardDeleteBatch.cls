/**
 * (c) 2017 RedBus
 *
 * Name           : GenericHardDeleteBatch
 * Created Date   : 24 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Generic Class to Hard Delete Based on given Query
 *
 **/
 
global class GenericHardDeleteBatch implements Database.Batchable<sObject>
{   
    global final String Query;
        
    global GenericHardDeleteBatch(String q)
    {
        Query = q;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //query to return all expired Case Share records         
        return Database.getQueryLocator(Query);
    } 
   
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {     
      System.debug('## deleting '+scope.size()+' records');   
 
      //  delete list of expired Case Share records
          try
         { 
            Database.DeleteResult[] DR_Dels = Database.delete(scope,false);   
            DataBase.emptyRecycleBin(scope); 
         }
          Catch(Exception e)
         {
          System.debug('excp..'+e);
         }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {                 
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
    if(a.NumberOfErrors>0)
    {
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('HardDelete Has Finished'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
   }
}