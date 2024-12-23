/**
 * (c) 2017 RedBus
 *
 * Name           : NewUserGFTTest
 * Created Date   : 30 Mar 2017
 * Created By     : Praveen
 * Purpose        : Test class for NewUserGFT class
 *
 **/
 
@isTest
private class NewUserGFTTest 
{
     @isTest static void testNewUserGFT() 
     {
       Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MockResponseCallout());  
            Case c= new Case();
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
            c.Issue_Sub_Category__c = 'Payment debited but ticket not issued - Need ticket';
            c.Customer_Phone_Number__c = '917411796876';
            c.Customer_Email_ID__c = 'sadsa@asdasd.com';
            insert c;            
            update [select id from case where id=:c.id];
            
        Test.stopTest();
   
     }
}