@isTest
public class API_CallBacks_Test
{
    static testMethod void callBacks()
    {
     string jsonBody='{"mobile":"9491322718","phoneCode":"91","actionType":"Insert","callBackTime":"2019-06-15 16:22:00","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('actionType', 'Insert');
        RestContext.request = req;
        RestContext.response= res;
       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
       static testMethod void callFailure()
    {
    
     string jsonBody='{"mobile":"9491322718","phoneCode":"91","actionType":"Insert","callBackTime":"","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('actionType', 'Update');
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
     static testMethod void callSuccess2()
    {
    
     string jsonBody='{"mobile":"9491322718","phoneCode":"91","actionType":"Update","callBackTime":"2019-06-15 16:22:00","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('actionType', 'Update');
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        Call_Back_Records__c c=new Call_Back_Records__c();
        
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
     static testMethod void callFailure2()
    {
    
     string jsonBody='{"mobile":"9491322718","actionType":"","phoneCode":"91","callBackTime":"2019-06-15 16:22:00","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
       // req.addHeader('actionType', 'Update');
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
    static testMethod void callFailure3()
    {
    
     string jsonBody='{"mobile":"","actionType":"","phoneCode":"91","callBackTime":"2019-06-15 16:22:00","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
       // req.addHeader('actionType', 'Update');
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
     static testMethod void callSuccess3()
    {
    
     string jsonBody='{"mobile":"9491322718","actionType":"","phoneCode":"91","callBackTime":"2019-06-15 16:22:00","agentId":"aarav.choudhary@redbus.com.ameyointl"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/API_CallBacks';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
       // req.addHeader('actionType', 'Update');
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        Call_Back_Records__c cb=new Call_Back_Records__c();
        cb.name='9491322718';
        cb.Call_Back_Time__c=System.now();
        insert cb;
        API_CallBacks.CaptureCallBacks();
       
        Test.stopTest();
       } 
    }