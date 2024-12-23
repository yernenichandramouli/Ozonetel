@isTest
Private class YourBusNoReplyReportSchedulerTest {
    static testMethod void YourBusNoReplyReportSchedulerTest()
    {
        case c=new case();
        c.Issue_Type__c='Exceptional Refund';
        c.Bank_Name__c='Test Bank';
        c.Status='Open';
        insert c;
        Test.StartTest();   
        YourBusNoReplyReportScheduler nef = new YourBusNoReplyReportScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Amazon_Customer_Delight', sche, nef);
        Test.StopTest();
    }
    
}