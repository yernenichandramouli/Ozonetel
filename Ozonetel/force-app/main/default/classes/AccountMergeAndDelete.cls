/**
 * (c) 2017 RedBus
 *
 * Name           : AccountMergeAndDelete
 * Created Date   : 18 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Class to Merge And Delete duplicate Accounts
 *
 **/
 
global class AccountMergeAndDelete implements DataBase.Batchable<sObject>
{
    global final String Query;
        
    global AccountMergeAndDelete(String q)
    {
        Query = q;
        
    }
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        return DataBase.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext bc,List<Account> accs)
    {
       System.debug('accs.'+accs+'Size..'+accs.size());
       Set<String> setMobileNums = new Set<String>();
       Set<Id> setAccIds = new Set<Id>();
       
       for(Account ac : accs)
       {
           if(ac.Phone_10_Digits__c.length()>=10)
           {
              setMobileNums.add('%'+ac.Phone_10_Digits__c.right(10)); 
           }
           setAccIds.add(ac.Id);
       }
      
      System.debug('setMobileNums..'+setMobileNums+'..size..'+setMobileNums.size());
      List<Id> listAccountIds = new List<Id>();
      
      for(Account act : [Select id,User_Id__c,WalletId__c from Account where PersonMobilePhone Like:setMobileNums])
       {
           if(!setAccIds.contains(act.id) && String.isBlank(act.User_Id__c))
              listAccountIds.add(act.id); 
       }
    
       if(!listAccountIds.isEmpty())
       { 
         try
         { 
          System.debug('total duplicate records..'+listAccountIds.size());
          Database.DeleteResult[] DR_Dels = Database.Delete(listAccountIds,false);
         
            for(Database.DeleteResult dr : DR_Dels) {
                if (dr.isSuccess()) {
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                }
            }
         }
         Catch(Exception e)
         {
          System.debug('excp..'+e);
         }
                
      }         
    }
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Account Merge and Deletion Logic '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}