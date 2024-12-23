@isTest
private class sgmyDailyCasesReportSchedulerTest {
    static testMethod void testMethod1()
    {
        Case cs = new Case();
        cs.Status = 'Open';
        cs.origin='Email - hq_sgmy@redbus.my';
        cs.Issue_Type__c = 'I felt unsafe during the journey';
        cs.Issue_Sub_Category__c = 'My bus met with an accident';
        insert cs;
        Test.StartTest();   
        sgmyDailyCasesReportScheduler nef = new sgmyDailyCasesReportScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('SGMY_Daily_Case_Report', sche, nef);
        Test.StopTest();
    }
}