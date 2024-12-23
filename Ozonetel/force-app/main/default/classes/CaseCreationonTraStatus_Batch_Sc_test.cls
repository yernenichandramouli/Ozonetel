@isTest
Public Class CaseCreationonTraStatus_Batch_Sc_test
{
    public static  String CRON_EXP = string.valueOf(DateTime.now().addMinutes(2).format('s m H d M ? y'));
    
   // CRON_EXP = '0 0 0 15 3 ? 2022';
    Static TestMethod Void CaseCreationonTraStatus_Batch()
    {
    
     Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
    Test.startTest();
    
    
    String jobId = System.schedule('ScheduleApexClassTest',
                CRON_EXP, 
                new CaseCreationonTraStatus_Batch_Schedular());
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
    NextFireTime
    FROM CronTrigger WHERE id = :jobId];
      
    
    Test.stopTest();
    }
}