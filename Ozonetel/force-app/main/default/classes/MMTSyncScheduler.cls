global class MMTSyncScheduler implements Schedulable {
    global void execute(SchedulableContext sc){        
        DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
        ddObj=[SELECT Id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName='MMTCaseSyncQuery'];
        list<case> caseList=new list<case>();
        caseList= DataBase.query(ddObj.QueryDetails__c);    
        if(!caseList.isEmpty())
        {
            set<string> bookingIds=new set<string>();
            for(case c:caseList){
                bookingIds.add(c.tin_no__c);
            }
            MMTTransactionSync.postDetails(bookingIds);
        }
    }
}