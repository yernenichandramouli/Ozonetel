@isTest
private class NonCallableBoAutoEmailRemSchedulerTest{
    public static testMethod void  testSendRemainder() 
    {
        case c=new case();
        Group noncallableQueueId=[Select Id from Group where name='Non Callable Queue' limit 1];
        c.status='Awaiting BO/BD Response';
        c.Business_Type__c='BusHire';
        c.BO_Type__c ='Non Callable' ;
        c.BO_Email__c='test@gmail.com';
        c.BD_Email__c='test@gmail.com';
        c.BD_Location__c='Banglore';
        c.TAT_Notifier_Email__c='test@t.com';
        c.ownerid=noncallableQueueId.id;
        c.All_Previous_Status_Dates__c=c.status+','+String.valueOf(System.now())+';'+c.All_Previous_Status_Dates__c;
        c.Waiting_for_Customer_Time__c =System.now().addHours(-98);
        c.country__c='India';
        insert c;
        System.debug('cs1->'+c.Customer_Revert_Delay__c);
        c.Waiting_for_Customer_Time__c =System.now().addHours(-20);
        update c;
                Test.setCreatedDate(c.Id, DateTime.newInstance(2023,11,25));

                System.debug('cs2->'+c.Customer_Revert_Delay__c);
        Test.StartTest();
         NonCallableBoAutoEmailRemainderScheduler ar= new NonCallableBoAutoEmailRemainderScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
          Test.StopTest();
     
     }
      public static testMethod void  testSendRemainder2() 
    {
        case c=new case();
        Group noncallableQueueId=[Select Id from Group where name='Non Callable Queue' limit 1];
        c.status='Awaiting BO/BD Response';
        c.Business_Type__c='BusHire';
        c.BO_Email__c='test@gmail.com';
        c.BD_Email__c='test@gmail.com';
        c.BO_Type__c ='Non Callable' ;
        c.BD_Location__c='Banglore';
        c.ownerid=noncallableQueueId.id;
        c.All_Previous_Status_Dates__c=c.status+','+String.valueOf(System.now())+';'+c.All_Previous_Status_Dates__c;
        c.TAT_Notifier_Email__c='test@t.com';
        c.country__c='India';
        insert c;
        update c;
          Test.setCreatedDate(c.Id, DateTime.now().addHours(-26));
        Test.StartTest();

         NonCallableBoAutoEmailRemainderScheduler ar= new NonCallableBoAutoEmailRemainderScheduler();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, ar);
          Test.StopTest();
     
     }
     
}