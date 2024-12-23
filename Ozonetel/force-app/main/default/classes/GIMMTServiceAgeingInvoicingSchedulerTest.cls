@isTest
private class GIMMTServiceAgeingInvoicingSchedulerTest {
    @isTest static void fullRefundTestMethod(){
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
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        insert orIt;
        
        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2B';
        cs.Business_Unit_ct__c ='REDBUS_IN';
        cs.Booking_Email_ID__c ='test@mail.com';
        cs.Total_Fare_Value__c=50.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.Max_Refund_Amount__c = 100.00;
        insert cs;

        case exceCs = new case();
        exceCs.Transaction_ID__c = orIt.Id;
        exceCs.My_Desk_Id__c ='13123213232132';
        exceCs.isAgening_Refund_Processed__c = true;
        exceCs.Refund_Reason__c ='Refund by service ageing scheduler';
        exceCs.redCare_Status__c ='Instant resolution with refund-Approved';
        exceCs.status = 'Refunded By Ageing Scheduler';
        insert exceCs;
        Test.setCreatedDate(cs.Id, DateTime.newInstance(2024,09,01));

        Test.startTest();
        string json='{"status":"SUCCESS","error_message":null,"error_code":null,"errors":[],"data":{"oldOperatorCancellationStatus":null,"newOperatorCancellationStatus":null,"OrderItemUuid":"618776fce205f005e2483f9f01020100"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string query='';
        GIMMTServiceAgeingInvoicingScheduler  busCan= new GIMMTServiceAgeingInvoicingScheduler ();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        // GIMMTServiceAgeingInvoicingBatch busCan= new GIMMTServiceAgeingInvoicingBatch('');
        // DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
        Test.stopTest();
    }
}