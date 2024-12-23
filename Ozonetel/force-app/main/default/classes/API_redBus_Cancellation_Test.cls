@isTest()
public class API_redBus_Cancellation_Test {
     static testMethod void Success()
    {
        
        string json='[{"routeId":"9161721","tin":["Y5BTPU6"],"doj":"2017-03-10 00:00:00","status":"Initiated"}]';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/redBus/busCancellation/';  
        req.httpMethod = 'POST';     
        req.addHeader('source', 'RB+');       
        req.requestBody = Blob.valueof(json);
        System.debug('check-->'+req.requestBody.toString());
        OrderItemTransactionResource__c ord=new OrderItemTransactionResource__c();
        ord.Auth_Key__c='IDN';
        ord.Default_Currency__c='IDR';
        ord.Name='REDBUS_ID';
        insert ord;
      
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;
        Case c = new Case();
        //get 'Bus Cancellation' record type id
        Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        c.Status = 'Approved For Bus Cancellation';
        c.RecordTypeId=recTypeId;      
        c.TIN_No__c='Y5BTPU6';
        c.Country__c ='India';
        c.Business_Unit_ct__c = 'REDBUS_ID';
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        
        API_redBus_Cancellation.doPost();
    }
    static testMethod void FailedTest()
    {
        
        string json='[{"routeId":"9161721","tin":["Y5BTPU6"],"doj":"2017-03-10 00:00:00","status":"Initiated"}';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/redBus/busCancellation/';  
        req.httpMethod = 'POST';     
        req.addHeader('source', 'RB+');       
        req.requestBody = Blob.valueof(json);
        System.debug('check-->'+req.requestBody.toString());
        
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        
        API_redBus_Cancellation.doPost();
    }


}