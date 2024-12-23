@isTest
private class CallDetailsTriggerTest{

 static testMethod void AccountCreateTest()
    {
       call_details__c c=new call_details__c ();
       c.OrderUuid__c ='123333';
       insert c;
    }

}