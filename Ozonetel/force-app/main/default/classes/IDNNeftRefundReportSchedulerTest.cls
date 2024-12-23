@isTest
private class IDNNeftRefundReportSchedulerTest {
    static testMethod void IDNNeftRefundReportSchedulerTest()
    {
        case c=new case();
        c.Issue_Type__c='Exceptional Refund';
        c.Bank_Name__c='Test Bank';
        c.Status='Open';
        insert c;
        Test.StartTest();   
        IDNNeftRefundReportScheduler nef = new IDNNeftRefundReportScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Indonesia_NEFT_Refund_Report', sche, nef);
        Test.StopTest();
    }
    
}