@istest
class AutoCloseFTCasesSchedulerTest
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
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        insert orIt;
        
        list<Case> Cslist = new list<Case>(); 
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Open';
        cs.Origin = 'Failed Transaction';
        //cs.Issue_Type__c ='Bus Cancellation';
       // cs.Issue_Sub_Category__c ='Alternate bus not arranged';
        insert cs;
        Cslist.add(cs);
        
        Refund_Order_Items__c refundOrder = new Refund_Order_Items__c();
        refundOrder.Name='Test';
        refundOrder.Order_Item_Name__c = orIt.Id;
        insert refundOrder;

        // Test.startTest();
        // AutoCloseFTCasesScheduler rodR = new AutoCloseFTCasesScheduler ('');
        // Database.QueryLocator ql = rodR.start(null);
        // rodR.execute(null,Cslist);
        // Test.stopTest();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        string query = '';
        AutoCloseFTCasesScheduler  busCan= new AutoCloseFTCasesScheduler(query);

        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
       
       Test.stopTest();
    }
}