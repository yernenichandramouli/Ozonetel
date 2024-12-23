@isTest
private class ApproveExceptionalRefundTest {
    @isTest static void successMethodTest(){

        OrderItemTransactionResource__c ord=new OrderItemTransactionResource__c();
        ord.Auth_Key__c='IDN';
        ord.Default_Currency__c='IDR';
        ord.Name='REDBUS_ID';
        insert ord;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.Email_Copy__c ='test@mail.com';
        orIt.Guid__c='12232576';
        orIt.Service_Provider_Id__c ='15926';
        orIt.Order_Item_Reference_No__c='VR11087544';
        insert orIt;

        Case parentCase=new Case();
        parentCase.Issue_Type__c='I need help to board my bus';
        parentCase.Issue_Sub_Category__c='Instant refund - Collectible from BO';
        insert parentCase;

        Case c=new Case();
        c.Service_Providerr_Id__c='15926';       
        c.Category__c='Ac to Non AC';    
        c.Refund_Type__c='Instant resolution with refund';  
        c.Exceptional_Refund_Count__c=0;
        c.status='Open';
        c.TIN_No__c='VR11087544';
        c.Booking_Email_ID__c='test@mail.com';
        c.Booking_Mobile_No__c	='9591791754';
        c.Issue_Sub_Category__c='Instant refund - customer delight';
        c.Refund_Amount__c=23456;
        c.Price_Paid_Currency_ctp__c='TestClass';
        c.Exceptional_Refund_Initiated__c = false;
        c.Refund_status__c='Success';
        c.Business_Unit_ct__c = 'REDBUS_ID';
        c.ParentId=parentCase.id;
        c.Price_Paid_Currency_ctp__c = 'IDR';
        insert c;  
        set<Id> caseIdSet = New set<Id>();
        caseIdSet.add(c.Id);

        Test.startTest();
        string json='[data={OrderItemUuid=51347748f3b2f0055722993401020100, newOperatorCancellationStatus=null, oldOperatorCancellationStatus=null}, errors=(), status=SUCCESS] Body : {"status":"SUCCESS","error_message":null,"error_code":null,"errors":[],"data":{"oldOperatorCancellationStatus":null,"newOperatorCancellationStatus":null,"OrderItemUuid":"51347748f3b2f0055722993401020100"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ApproveExceptionalRefund.InitiateRefund(caseIdSet);
        Test.stopTest();
    }

    @isTest static void failureTestMethod(){

        OrderItemTransactionResource__c ord=new OrderItemTransactionResource__c();
        ord.Auth_Key__c='IDN';
        ord.Default_Currency__c='IDR';
        ord.Name='REDBUS_ID';
        insert ord;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.Email_Copy__c ='test@mail.com';
        orIt.Guid__c='12232576';
        orIt.Service_Provider_Id__c ='15926';
        orIt.Order_Item_Reference_No__c='VR11087544';
        insert orIt;

        Case parentCase=new Case();
        parentCase.Issue_Type__c='I need help to board my bus';
        parentCase.Issue_Sub_Category__c='Instant refund - Collectible from BO';
        insert parentCase;

        Case c=new Case();
        c.Service_Providerr_Id__c='15926';       
        c.Category__c='Ac to Non AC';    
        c.Refund_Type__c='Instant resolution with refund';  
        c.Exceptional_Refund_Count__c=0;
        c.status='Open';
        c.TIN_No__c='VR11087544';
        c.Booking_Email_ID__c='test@mail.com';
        c.Booking_Mobile_No__c	='9591791754';
        c.Issue_Sub_Category__c='Instant refund - customer delight';
        c.Refund_Amount__c=23456;
        c.Price_Paid_Currency_ctp__c='TestClass';
        c.Exceptional_Refund_Initiated__c = false;
        c.Refund_status__c='Success';
        c.Business_Unit_ct__c = 'REDBUS_ID';
        c.ParentId=parentCase.id;
        c.Price_Paid_Currency_ctp__c = 'IDR';
        insert c;  
        set<Id> caseIdSet = New set<Id>();
        caseIdSet.add(c.Id);

        Test.startTest();
        string json='{"Code":"11.24","Message":"Refund is alreday processed for the provided order id.","DetailedMessage":"Refund is alreday processed for the provided order id.","HttpStatusCode":200}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(500, 'OK', json));
        ApproveExceptionalRefund.InitiateRefund(caseIdSet);
        Test.stopTest();
    }
}