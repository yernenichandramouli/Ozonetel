@isTest
Private class CreateExceptionalRefundCaseFutureTest {
    @isTest
    static void testMethod1(){

        OrderItemTransactionResource__c ot=new OrderItemTransactionResource__c();
        ot.Name='REDBUS_IN';
        ot.Auth_Key__c='1253Ratr';
        ot.Case_Country__c='India';
        ot.Default_Currency__c='INR';
        insert ot;

        Order_Items__c orIt = new Order_Items__c();
        orIt.name = '918570716975';
        orIt.ID__c = '918570716975';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c = 'TS5Y88976428';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c = '4353';
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c = '2551211';
        orIt.Order_Id__c = '15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c = 'test@mail.com';
        insert orIt;

        Case cs = new Case();
        cs.Business_Type__c='';
        cs.Issue_Type__c='';
        cs.transaction_id__c = orIt.Id;
        cs.Issue_Sub_Category__c='';
        cs.Email_Id_ct__c='test@mail.com';
        cs.Phone_No_ct__c='918570716975';
        cs.Trip_Id_ct__c='13464096756079497';
        cs.TIN_No__c='TS5Y88976428';
        cs.Origin='Complaint Tracker';
        cs.Refund_Type__c='Instant resolution with refund';
        cs.Booking_Email_ID__c='test@mail.com';
        cs.Refund_Amount__c=20;
        cs.Business_Unit_ct__c='REDBUS_IN';
        cs.SH_Dropping_Time__c = Datetime.now().addDays(-10);
        insert cs;

        Test.startTest();
        case cObj = [SELECT id, casenumber, Trip_Id_ct__c FROM case WHERE id = :cs.id];
        CreateExceptionalRefundCaseFuture.createSHExceptionCase(string.valueOf(cObj.CaseNumber),String.valueOf(cObj.Trip_Id_ct__c));
        Test.stopTest();
    }
}