/**
 * (c) 2018 RedBus
 *
 * Name           : BusCancellationAgeingRefundSchedularTest
 * Created Date   : 12 Apr 2018
 * Created By     : Sreenivas M
 * Purpose        : Test class for BusCancellationAgeingRefundSchedular/BusCancellationAgeingRefundBatch
 *
 **/

@istest
class BusCancellationAgeingRefundSchedularTest
{
   static testmethod void test() 
   {
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        //orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.date_of_service__c = DateTime.newInstance(2022,10,10);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        insert orIt;
        
        list<case> caselist=new list<Case>();
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Initiated';
        cs.Origin = 'Inbound Call';
        cs.Notes__c='Test';
        cs.isAgening_Refund_Processed__c=false;
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Issue_Sub_Category__c ='Alternate bus not arranged';
        Datetime yesterday = Datetime.now().addDays(-1);
        insert cs;
        caselist.add(cs);
        Test.setCreatedDate(cs.Id, DateTime.newInstance(2022,10,10));
        
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        BusCancellationAgeingRefundSchedular  busCan= new BusCancellationAgeingRefundSchedular();

        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
       
       Test.stopTest();
   
   }
 }