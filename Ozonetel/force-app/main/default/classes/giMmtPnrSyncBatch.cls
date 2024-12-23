/**
 * (c) 2023 RedBus
 *
 * Name           : giMmtPnrSyncBatch
 * Created Date   : 25 JUN 2024
 * Created By     : VR Sudarshan
 * Purpose        : batch class to sync PNR for GI and MMT Transactions
 * Test class     : giMmtPnrSyncBatchSchedulerTest
 *
 **/

global class giMmtPnrSyncBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;

    public giMmtPnrSyncBatch(String strQuery) {
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }else{
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MMTCaseSyncQuery'].QueryDetails__c;
        }
    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        set<string> bookingIds=new set<string>();
        if(!lstcases.isEmpty()){
            for(Case csObj : lstcases){
                bookingIds.add(csObj.tin_no__c);
            }
        }

        if(!bookingIds.isEmpty()){
            MMTTransactionSync.postDetails(bookingIds);
        }
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('Gi MMT PNR sync is '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}