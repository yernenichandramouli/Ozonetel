/**
 * (c) 2017 RedBus
 *
 * Name           : MergeAndDeleteAccounts
 * Created Date   : 18 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Class to Merge And Delete duplicate Accounts
 *
 **/
 
global class MergeAndDeleteAccounts implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        return DataBase.getQueryLocator(System.Label.AccountsMergeQuery);
    }
    
    global void execute(DataBase.BatchableContext bc,List<Account> accs)
    {
       System.debug('accs.'+accs);
       Set<String> setMobileNums = new Set<String>();
       Set<Id> setAccIds = new Set<Id>();
       
       for(Account ac : accs)
       {
           if(String.isNotBlank(ac.Phone_10_Digits__c) && (ac.Phone_10_Digits__c).length()>=10)
           {
              setMobileNums.add('%'+ac.Phone_10_Digits__c.right(10)); 
           }
           setAccIds.add(ac.Id);
       }
       List<String> listMobileNums = new List<String>();
       listMobileNums.addAll(setMobileNums);
       List<Account> listAccounts = new List<Account>();
      System.debug('listMobileNums..'+listMobileNums);
      
      for(Account act : [Select id,User_Id__c,WalletId__c from Account where PersonMobilePhone Like:listMobileNums And LastModifiedDate=LAST_YEAR])
       {
           if(!setAccIds.contains(act.id) && String.isBlank(act.User_Id__c) && String.isBlank(act.WalletId__c))
              listAccounts.add(act); 
       }
       if(!listAccounts.isEmpty())
       { 
         try
         { 
          Database.DeleteResult[] DR_Dels = Database.Delete(listAccounts,false);
          // Iterate through each returned result
            for(Database.DeleteResult dr : DR_Dels) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
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