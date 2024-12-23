global class DeletingDBLogs implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        Date PriviousDays = System.Today().addDays(-Integer.Valueof(Label.Last_Previous_DB_Logs));
        return DataBase.getQueryLocator([Select Id,Name,DBLog_Summary__c,Error_Description__c,Failure_Process__c,ID__c,Locked_record__c,Lock_released__c,Lock_Released_Time__c,Lock_type__c,Object_Name__c From DB_Log__c Where CreatedDate<=:PriviousDays]);
    }
    global void execute(DataBase.BatchableContext bc,List<DB_Log__c> dbLogList)
    {
            Delete dbLogList;
    }
    global void finish(DataBase.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.Delete_DB_Log_Alert_Email.Split(','));
       mail.setToAddresses(toAddresses);
       mail.setSubject('DB Log Delete Status: ' +a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 
    }
}