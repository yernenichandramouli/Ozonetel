@isTest
public class API_ChatPostDetailsTest
{
    static testMethod void chatTest()
    {
        string jsonBody='{"chatSessionId":"503a5034-8f73-42b1-8c66-4a6b080c2390","chatEndedBy":"Customer"}';
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
        API_ChatPostDetails.chatCapture();
        
        Test.stopTest();
    } 
    
    static testMethod void chatSuccessTest()
    {
        string jsonBody='{"chatSessionId":"123456","chatEndedBy":"Customer"}';
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
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        LiveChatTranscript lct=new LiveChatTranscript();
        lct.ChatKey='123456';
        lct.LiveChatVisitorId=lv.id;
        insert lct;
        API_ChatPostDetails.chatCapture();
        
        Test.stopTest();
    } 
    
    static testMethod void chatFailTest()
    {
        string jsonBody='{"chatSessionId":"123456","chatEndedBy":"CustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomerCustomer"}';
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
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        LiveChatTranscript lct=new LiveChatTranscript();
        lct.ChatKey='123456';
        lct.LiveChatVisitorId=lv.id;
        insert lct;
        API_ChatPostDetails.chatCapture();
        
        Test.stopTest();
    } 
    
}