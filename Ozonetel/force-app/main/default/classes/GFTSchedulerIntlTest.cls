/**
 * (c) 2017 RedBus
 *
 * Name           : GFTSchedulerTest
 * Created Date   : 27 Jun 2019
 * Created By     : Mahendra k 
 * Purpose        : Test class for GFTScheduler class
 *
 **/
 
@isTest
private class GFTSchedulerIntlTest{
   @isTest static void testGFTScheduler() 
    {
             
        Orders__c ord = new Orders__c();
        ord.Guid__c = '5E786D6F5405F0055BE4CE5801010100';
        insert ord;
        
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TJCN77774445';
        orIt.name = '9837321722';
        orIt.Order_Id__c = '232233232';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        orIt.Business_Unit__c='REDBUS_MY';
        orIt.Order_Name__c = ord.id;
        insert orIt;
        
        Payment_Items__c pi = new Payment_Items__c();
        pi.Guid__c ='5e8efc6e5405f0055be4ce5802030100';
        pi.Payment_System__c ='ONLINE';
        pi.Order_Item_Name__c = orIt.id;
        insert pi;
              
        Case cs = new Case();
        cs.Status = 'Open';
        cs.Origin='Failed Transaction';
        //cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        cs.FT_Verified__c=false;
        insert cs;
        
        System.debug('Case..'+[Select id,Owner.name from case where id=:cs.id]);
        
        Test.StartTest();
           Test.setMock(HttpCalloutMock.class, new MockResponseCallout());  
           GFTSchedulerIntl gfSch= new GFTSchedulerIntl();
           String sche ='0 0 22 * * ? *';
           system.schedule('Test', sche, gfSch);
        Test.StopTest();
    }
}