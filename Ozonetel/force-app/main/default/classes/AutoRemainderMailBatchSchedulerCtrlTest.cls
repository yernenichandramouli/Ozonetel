@isTest
private class AutoRemainderMailBatchSchedulerCtrlTest {
    @isTest
    static void testSendRemainder() {
        Test.StartTest();
        case c=new case();
        c.status='Waiting for Customer';
        c.TAT_Notifier_Email__c='test@t.com';
        c.country__c='India';
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        insert c;
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        update c;
        AutoRemainderMailBatchSchedulerCtrl ar = New AutoRemainderMailBatchSchedulerCtrl();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
        Test.StopTest();
    }

    static void testSendRemainder2() {
        Test.StartTest();
        case c=new case();
        c.status='Waiting for Customer';
        c.TAT_Notifier_Email__c='test@t.com';
        c.country__c='India';
        insert c;
        c.Waiting_for_Customer_Time__c =System.now().addHours(-10);
        update c;
        AutoRemainderMailBatchSchedulerCtrl ar = New AutoRemainderMailBatchSchedulerCtrl();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
        Test.StopTest();
    }
}