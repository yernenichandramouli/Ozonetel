@isTest
private class AutoRemainderMailBusHireSchedulerTest{
    public static testMethod void  testSendRemainder() 
    {
        Test.StartTest();
        case c=new case();
        c.status='Waiting for Customer';
        c.Business_Type__c='BusHire';
        c.TAT_Notifier_Email__c='test@t.com';
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        c.country__c='India';
        insert c;
        System.debug('cs1->'+c.Customer_Revert_Delay__c);
        c.Waiting_for_Customer_Time__c =System.now().addHours(-20);
        update c;
                System.debug('cs2->'+c.Customer_Revert_Delay__c);

         AutoRemainderMailBusHireScheduler ar= new AutoRemainderMailBusHireScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
          Test.StopTest();
     
     }
      public static testMethod void  testSendRemainder2() 
    {
        Test.StartTest();
        case c=new case();
        c.status='Waiting for Customer';
        c.Business_Type__c='BusHire';
        c.TAT_Notifier_Email__c='test@t.com';
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        c.country__c='India';
        insert c;
        System.debug('cs1->'+c.Customer_Revert_Delay__c);
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        update c;
                System.debug('cs2->'+c.Customer_Revert_Delay__c);

         AutoRemainderMailBusHireScheduler ar= new AutoRemainderMailBusHireScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
          Test.StopTest();
     
     }
     
}