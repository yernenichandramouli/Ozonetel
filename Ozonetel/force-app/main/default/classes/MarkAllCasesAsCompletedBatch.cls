/**
 * (c) 2017 RedBus
 *
 * Name           : MarkAllCasesAsCompletedBatch
 * Created Date   : 28 Mar 2018
 * Created By     : Sreenivas M
 * Purpose        : Generic Class to Mark All Cases As Completed Based on given Query
 * TestClass      : MergeAndDeleteAccountsTest
 **/
 
global class MarkAllCasesAsCompletedBatch implements Database.Batchable<sObject>
{   
    global final String Query;
        
    global MarkAllCasesAsCompletedBatch(String q)
    {
        Query = q;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //query to return all expired Case Share records         
        return Database.getQueryLocator(Query);
    } 
   
    global void execute(Database.BatchableContext BC, list<Case> scope)
    {     
      System.debug('## deleting '+scope.size()+' records');   
 
      //  delete list of expired Case Share records
          try
         { 
            List<CaseComment> listcsComm = new List<CaseComment>();
            List<Case> listcs= new List<Case>();

            for(Case c:scope)
            {
                c.status='Closed';
                listcs.add(c);

                CaseComment csComm = new CaseComment();
                csComm.parentId =c.id;
                csComm.commentbody ='System Update-Transaction Has Already Processed.So,Closing this Case Marking as Duplicate';
                listcsComm.add(csComm);
            }
            Database.SaveResult[] DR_Ins = Database.insert(listcsComm,false);
            Database.SaveResult[] DR_Upd = Database.update(listcs,false);   
           
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
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Marking All Cases As Closed is '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
}