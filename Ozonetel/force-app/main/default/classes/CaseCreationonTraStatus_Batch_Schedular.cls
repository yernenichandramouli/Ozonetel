global class CaseCreationonTraStatus_Batch_Schedular implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        String qr = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseCreationonTraStatus'].QueryDetails__c;
        
        for(AsyncApexJob ap: DataBase.query(qr))
        {
          
          System.abortJob(ap.ParentJobId);

        }
        CaseCreationonTraStatus_Batch cls = new CaseCreationonTraStatus_Batch();
        DataBase.executeBatch(cls,Integer.valueOf(System.Label.Case_Creation_Size));
    }
}