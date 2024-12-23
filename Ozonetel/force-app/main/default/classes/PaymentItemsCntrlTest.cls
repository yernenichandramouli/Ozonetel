@isTest
public class PaymentItemsCntrlTest{
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(Total_Fare_Value__c=123.45,Transaction_Source__c='MOBWEB',name = 'testLName'+i , Order_Id__c='2123213',Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_IN'));
        } 
        insert orderList ;
        Country_Codes__c ccObj=new Country_Codes__c();
        ccObj.name='REDBUS_ID';
        ccObj.Country_Code__c='62';
        ccObj.Business_Unit__c='Indonesia';
        ccObj.Country_Header__c='IDR';
        insert ccObj;
        OrderItemTransactionResource__c o=new OrderItemTransactionResource__c();
        o.name='REDBUS_IN';
        o.Auth_Key__c='123123';
        o.Channel_Name__c='MOBWEB';
        o.Default_Currency__c='INR';
        insert o;
        OrderItemTransactionResource__c o2=new OrderItemTransactionResource__c();
        o2.name='MOBWEB';
        o2.Auth_Key__c='123123';
        o2.Channel_Name__c='MOBWEB';
        insert o2;
    }
    public static testMethod void TestPaymentDetails()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c,Order_Id__c from Order_Items__c]; 
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('ordId', ol[0].Order_Id__c);
        PaymentItemsCntrl pic=new PaymentItemsCntrl ();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ol[0]);
        PaymentItemsCntrl pctr = new PaymentItemsCntrl(sc);
        pctr.recId=ol[0].id;
        //pic.getPaymentDetails();
        
        Continuation conti = (Continuation)pctr.getPaymentDetails();
        HttpResponse response = new HttpResponse();
        string  responseBody='[{"id":12235850840940002,"additional_details":null,"created_by":null,"creation_time":"2018-06-20T13:25:55","transaction_source":null,"updated_by":null,"updated_time":null,"version":null,"business_unit_currency":"INR","business_unit_value":4.0,"amount_payable_currency":"INR","amount_payable_value":4.0,"order_id":12235850543482282,"payment_status":"COMPLETED","payment_session_id":null,"payment_system":"RBOFFER","payment_system_ref_no":"TESTQA5","settled_currency":"INR","settled_value":null,"settlement_time":null,"creation_time_public":null,"settlement_time_public":null,"has_discrepancy":null,"is_reconceiled":null,"commission":0.0,"payment_type":0,"is_complete":true,"guid":"20dcc3bc6f0ef0055722993402030100","pgName":null,"pgtype":null,"bankAccountNumber":null,"accountHolderName":null,"latestPgStatus":null,"PgRefNo":0,"IsOffline":false,"bankName":null,"operationType":"UPDATE"},{"id":12235850842251681,"additional_details":null,"created_by":null,"creation_time":"2018-06-20T13:25:55","transaction_source":null,"updated_by":null,"updated_time":null,"version":null,"business_unit_currency":"INR","business_unit_value":76.0,"amount_payable_currency":"INR","amount_payable_value":76.0,"order_id":12235850543482282,"payment_status":"COMPLETED","payment_session_id":null,"payment_system":"ONLINE","payment_system_ref_no":null,"settled_currency":"INR","settled_value":null,"settlement_time":null,"creation_time_public":null,"settlement_time_public":null,"has_discrepancy":null,"is_reconceiled":null,"commission":0.0,"payment_type":1,"is_complete":true,"guid":"20df44346f0ef005e2483f9f01030100","pgName":null,"pgtype":null,"bankAccountNumber":null,"accountHolderName":null,"latestPgStatus":null,"PgRefNo":0,"IsOffline":false,"bankName":null,"operationType":"UPDATE"}]';
        response.setBody(responseBody);
        Test.setContinuationResponse(pctr.requestLabel, response);
        Object result = Test.invokeContinuationMethod(pctr, conti);  
        Test.stopTest();
    }  
    
    static testMethod void UPITest(){
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.startTest();
        
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Guid__c='34512345';
        ordtm.Payment_Details__c='{ "uuid": "1ea568b56f0ef005e2483f9f02010100", "id": "12235850543482282", "paymentItemList": [{ "uuid": "20dcc3bc6f0ef0055722993402030100", "id": "12235850840940002" },{ "uuid": "20df44346f0ef005e2483f9f01030100", "id": "12235850842251681" } ] }';
        insert ordtm;
         ApexPages.StandardController sc = new ApexPages.StandardController(ordtm);
        PaymentItemsCntrl upincntr = new PaymentItemsCntrl(sc);
        ApexPages.currentPage().getParameters().put('id', ordtm.id);
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c,Order_Id__c from Order_Items__c]; 
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('ordId', ol[0].Order_Id__c);
        //PaymentItemsCntrl upincntr =new PaymentItemsCntrl ();
        
        upincntr.tId='test';
        upincntr.refStResp='success';
        upincntr.pgOrderId='20dcc3bc6f0ef0055722993402030100';
        upincntr.trexOrderItmId='34512345';
        upincntr.enableRefund=false;
        upincntr.disInputs=true;
        upincntr.vpa='test@t.com';
        upincntr.refAmount=12;
        upincntr.pgTransactionId='1234';
        
        Continuation conti = (Continuation)upincntr.RefundInitiate();
        HttpResponse response = new HttpResponse();
        string  responseBody='{"publishStatus":"SUCCESS","errors":""}';
        response.setBody(responseBody);
        Test.setContinuationResponse(upincntr.refStReq, response);
        Object result = Test.invokeContinuationMethod(upincntr, conti);   
        
        Continuation conti2 = (Continuation)upincntr.RefundStatusCheck();
        HttpResponse response2 = new HttpResponse();
        string  responseBody2='{"status":true,"message":"Balance Amount is 5000.0"}';
        response2.setBody(responseBody2);
        Test.setContinuationResponse(upincntr.refStReq, response2);
        Object result2 = Test.invokeContinuationMethod(upincntr, conti2);   
        
        upincntr.processUPI();
        upincntr.RefundAteempts();
        upincntr.RefundAmount();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        String jsonBody='{"status":true,"message":"Balance Amount is 5000"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        Test.stopTest();
    }
}