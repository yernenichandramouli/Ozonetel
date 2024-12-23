@isTest
private class LATAMNeftRefundReportSchedulerTest {
    @isTest
    static void testMthod1() {

        case c = new case();
        c.Issue_Type__c = 'Exceptional Refund';
        c.Bank_Name__c = 'Test Bank';
        c.Status = 'Open';
        insert c;
        Test.StartTest();
        LATAMNeftRefundReportScheduler rep = new LATAMNeftRefundReportScheduler();
        String sche = '0 0 0 ? * * *';
        System.schedule('LATAM_NEFT_Refund_Report', sche, rep);
        Test.StopTest();
        
    }
}