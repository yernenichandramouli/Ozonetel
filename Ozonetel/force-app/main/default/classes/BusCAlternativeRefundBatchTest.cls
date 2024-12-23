@istest
class BusCAlternativeRefundBatchTest
{
    static testmethod void test() 
    {
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        insert orIt;

        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Initiated';
        cs.type='B2B';
        cs.transaction_id__c = orIt.Id;
        cs.TIN_No__c ='D4UZ22Ymk5';
        cs.isAgening_Refund_Processed__c=false;
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Notes__c='Alternative Arrangement by redBus';
        cs.Business_Unit_ct__c='REDBUS_IN';
        cs.Type='Test';
        Datetime yesterday = Datetime.now().addDays(-10);
        cs.SS_DOJ__c = Datetime.now().addDays(-10);
        insert cs;
        cs.Status ='Closed';
        //Test.setLastModifiedDate(cs.Id, DateTime.newInstance(2001,01,01));
        update cs;

        Test.startTest();
        
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string query='';
        BusCAlternativeRefundBatch rodR = new BusCAlternativeRefundBatch(query);
        String cronExp ='0 00 1 3 * ?';
        System.schedule('b2bbucCancl', cronExp,rodR);
        Test.stopTest();
    }
}