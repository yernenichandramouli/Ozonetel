/**
 * (c) 2017 RedBus
 *
 * Name           : MetricsUpdateBatch
 * Created Date   : 25 June 2021
 * Created By     : Sreenivas M
 * Purpose        : Handler class for the Daily Bot Metrics
 * Test Class     : 
 *
 **/
 
public class MetricsUpdateBatch implements Database.Batchable<sObject>,Schedulable  {

   
   public void execute(SchedulableContext scon)
    {
        Database.executeBatch(new MetricsUpdateBatch());
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT Name FROM Metric__c LIMIT 1]);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope)
   {
     Metric__c m= new Metric__c();
     m.Metric_Date__c = System.today().addDays(-1);
     m.Country__c = 'IDN';
     m.Messaging_Type__c = 'WhatsApp';
     
     m.Unique_Users__c = Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Unique_Users').QueryDetails__c).isEmpty()?0:Integer.valueOf(Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Unique_Users').QueryDetails__c)[0].get('expr0'));
     
     m.Total_Sessions__c =Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Tot_Sessions').QueryDetails__c).isEmpty()?0:Integer.valueOf(Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Tot_Sessions').QueryDetails__c)[0].get('expr0'));
     
     
     m.Handled_By_Bot__c = Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Bot_Ended').QueryDetails__c).isEmpty()?0:Integer.valueOf(Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_Bot_Ended').QueryDetails__c)[0].get('expr0'));
     
     m.Handled_By_Agent__c = Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_DirectlyToAgent').QueryDetails__c).isEmpty()?0:Integer.valueOf(Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_DirectlyToAgent').QueryDetails__c)[0].get('expr0'));
     
     m.Transfer_To_Agent__c = Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_TransferToAgent').QueryDetails__c).isEmpty()?0:Integer.valueOf(Database.query(DataDeletionSetup__mdt.getInstance('Bot_Metric_TransferToAgent').QueryDetails__c)[0].get('expr0'));
          
     insert m;
   }
     
   public void finish(Database.BatchableContext BC)
   {
     Database.executeBatch(new ReportAsAttachmentBatch('Bot_Metric_Last_N_Days'));
   }
}