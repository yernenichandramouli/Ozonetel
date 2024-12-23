@istest
class BusCancellationInvoicingSchedularTest
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
        orIt.Guid__c ='Test';
        insert orIt;

        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Refunded By Ageing Scheduler';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I have a problem with bus service';
        cs.Issue_Sub_Category__c ='The bus was of poor quality';
        cs.isAgening_Refund_Processed__c=false;
        cs.Type='B2C';
        insert cs;


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        string json='[{"tin":"TM4N54341643","status":"Success"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string query='';
        BusCancellationInvoicingBatchSchedular busCan= new BusCancellationInvoicingBatchSchedular();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}