@isTest
public class B2BCancellationTest
{ 
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderItmList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderItmList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID'));
        } 
        insert orderItmList ;

        OrderItemTransactionResource__c ord=new OrderItemTransactionResource__c();
        ord.Auth_Key__c='IDN';
        ord.Default_Currency__c='IDR';
        ord.Name='REDBUS_ID';
        ord.Case_Business_Type__c='Indonesia-Bus';
        ord.Case_Country__c='Indonesia';
        insert ord;

    }  
    public static testMethod void TestExceptonalRefund()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        
        List<Case> listCase = new List<Case>();
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.transaction_id__c = ol[0].Id;
        cs.Status ='Approved For Bus Cancellation';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='Bus Operative Service';
        cs.Issue_Sub_Category__c ='Alternate bus not arranged'; 
        cs.Type='B2B';
        cs.Max_Refund_Amount__c=16;
        cs.My_Desk_Id__c='23eweww';
        insert cs;
        case c=[select id,casenumber from case where id=:cs.id];
        B2BCancellation  bObj = new B2BCancellation (new ApexPages.StandardController(ol[0]));
        bObj.cancellationType='Technical Error';
        bObj.description='Test';
        bObj.parentCase=c.casenumber;
        bObj.ExceptionalRefund();
        bObj.getSuggestedRefundAmount();
        Test.stopTest();
    }
    
    public static testMethod void TestIsCancellationMultipleSeats()
    {


        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        B2BCancellation  bObj = new B2BCancellation (new ApexPages.StandardController(ol[0]));
        bObj.cancellationType='Technical Error';
        bObj.description='Test';
        Continuation conti = (Continuation)bObj.IsTicketCancellable();
        HttpResponse response = new HttpResponse();
        string responseBody='{"cancellable":"true","cancellationCharges":{"entry":[{"key":"26U","value":"10.00"},{"key":"25U","value":"10.00"},{"key":"23U","value":"10.00"},{"key":"22U","value":"10.00"},{"key":"29U","value":"10.00"},{"key":"28U","value":"10.00"}]},"fares":{"entry":[{"key":"26U","value":"105.00"},{"key":"25U","value":"105.00"},{"key":"23U","value":"105.00"},{"key":"22U","value":"105.00"},{"key":"29U","value":"105.00"},{"key":"28U","value":"105.00"}]},"freeCancellationTime":"10.00","partiallyCancellable":"true","serviceCharge":"0"}';
        response.setBody(responseBody);
        Test.setContinuationResponse(bObj.isCancellableReq, response);
        Object result = Test.invokeContinuationMethod(bObj, conti);
        System.debug('result-->'+result);
        bObj.CancellationBreakup();
        bObj.cancellationType='FC';
        Continuation conti2 = (Continuation)bObj.CancelTicket();
        HttpResponse response2 = new HttpResponse();
        string cancelTktResp='{"cancellationCharge":0,"tin":"84AQ8XUQ","refundAmount":500}';
        response2.setBody(cancelTktResp);
        Test.setContinuationResponse(bObj.cancellationReq, response2);
        Object result2 = Test.invokeContinuationMethod(bObj, conti2);
        Test.stopTest();
    }
    
    public static testMethod void TestIsCancellationSingleSeat()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        B2BCancellation  bObj = new B2BCancellation (new ApexPages.StandardController(ol[0]));
        bObj.cancellationType='Technical Error';
        bObj.description='Test';
        Continuation conti = (Continuation)bObj.IsTicketCancellable();
        HttpResponse response = new HttpResponse();
        string responseBody='{"cancellable":"true","cancellationCharges":{"entry":{"key":"7","value":"10.00"}},"fares":{"entry":{"key":"7","value":"105.00"}},"freeCancellationTime":"0","partiallyCancellable":"true","serviceCharge":"0","tatkalTime":"0"}';
        response.setBody(responseBody);
        Test.setContinuationResponse(bObj.isCancellableReq, response);
        Object result = Test.invokeContinuationMethod(bObj, conti);
        System.debug('result-->'+result);
        bObj.CancellationBreakup();
        bObj.ExceptionalRefundBlock();
        bObj.cancellationType='PC';
        Test.stopTest();
    }
    
}