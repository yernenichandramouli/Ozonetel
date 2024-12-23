global class deleteWFTCases_Batch implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        String wftqueue = String.Valueof(Label.WFT_Queue_Name);
        String gftqueue = String.Valueof(Label.GFT_Queue_ID);
        Set<String> WFTBU = new Set<String>();
        Set<String> GFTBU = new Set<String>();
        for(WFT_GFT_Business_Units__c w: WFT_GFT_Business_Units__c.getALL().Values())
        {
            if(w.Delete_WFT__c)
            {
               WFTBU.add(w.Name); 
            }
            if(w.Delete_GFT__c)
            {
               GFTBU.add(w.Name);
            }
        }
        return DataBase.getQueryLocator([SELECT Id,Ownerid,Transaction_ID__r.Business_Unit__c FROM Case WHERE CreatedDate = YESTERDAY AND Status!=: 'Closed' AND((RecordType.Name='White Failed Transaction (WFT)' AND Transaction_ID__r.Business_Unit__c IN :WFTBU AND Ownerid =:wftqueue) OR (RecordType.Name='Green Failed Transaction (GFT)' AND Transaction_ID__r.Business_Unit__c IN :GFTBU AND Ownerid =:gftqueue) )]);
    }
    global void execute(DataBase.BatchableContext bc,List<Case> deleterec)
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
       mail.setSubject('Delete WFT Cases: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}