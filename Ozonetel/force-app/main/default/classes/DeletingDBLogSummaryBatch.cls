/**
 * (c) 2017 RedBus
 *
 * Name           : DeletingDBLogSummaryBatch
 * Created Date   : 19 Apr 2017
 * Created By     : Sreenivas M
 * Purpose        : Bacth class to delete DB Log Summary Details
 * Test class     : DeletingDBLogSummaryTest
 *
 **/
 
global class DeletingDBLogSummaryBatch implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        Date PriviousDays = System.Today().addDays(-Integer.Valueof(Label.DB_Log_Delete_Duration));
        System.debug('Previous Days..'+PriviousDays);
        return DataBase.getQueryLocator([Select Id From DBLog_Summary__c Where Createddate<:PriviousDays]);
    }
    
    global void execute(DataBase.BatchableContext bc,List<DBLog_Summary__c> dblogs)
    {
       System.debug('dblogs.'+dblogs);
        Delete dblogs;       
               
    }
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.Delete_Transaction_Alert_Email.Split(','));
       mail.setToAddresses(toAddresses);
       mail.setSubject('DB Log Summary Delete Status: '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}