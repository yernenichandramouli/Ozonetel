@isTest
public class ZQPExceptionalRefundBatchTest {
    @isTest static void fullRefundTestMethod(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.Guid__c = 'test123test';
        orIt.Order_Id__c ='test123';
        orIt.OrderUuid__c = 'test123';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Dropping_Time__c = Datetime.now().addminutes(-60);
        orIt.Transaction_Status__c = 'Booked';
        orIt.Mobile__c = '432133445566';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email__c ='test@mail.com';
        insert orIt;
        
        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Refund_Amount__c =123;
        cs.Order_UUId__c='test123';
        cs.Booking_Email_ID__c = 'test@mail.com';
        cs.Booking_Mobile_No__c = '432133445566';
        cs.Issue_Type__c ='Exceptional Refund';
        cs.Issue_Sub_Category__c ='Zero Question Policy';
        cs.Subject='ZQP Automation';
        cs.Total_Fare_Value__c=250;
        cs.Price_Paid_Currency_ctp__c='INR';
        insert cs;
        
        Test.startTest();
        string json='20';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string query='';
        ZQPExceptionalRefundBatchSchedular zqp= new ZQPExceptionalRefundBatchSchedular();
        String sch = '0 0 8 13 2 ?';
        system.schedule('zqpAutomation', sch,zqp);
        Test.stopTest();
    }
}