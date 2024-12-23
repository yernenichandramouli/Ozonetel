global class deleteWFTGFTPmtmask_Batch implements DataBase.Batchable<sObject>
{
    Integer val = Integer.Valueof(Label.Masking_Objects_Delete_Duration);
    Date dt = System.Today().addDays(-val);
    Public String query = 'SELECT Id,Name FROM WFT_GFT_Payment__c WHERE CreatedDate <=: dt';
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        return DataBase.getQueryLocator(query);
    }
    global void execute(DataBase.BatchableContext bc,List<WFT_GFT_Payment__c> deleterec)
    {
        Delete deleterec;
    }
    global void finish(DataBase.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add(Label.Delete_Logs_Mail);
       mail.setToAddresses(toAddresses);
       mail.setSubject('Delete Mask Object WFT_GFT_Payment__c: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}