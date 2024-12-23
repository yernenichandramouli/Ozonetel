@isTest
public class API_UpdateLabelTest{
    
    public static testMethod void updateLabelTest()
    {
        Test.startTest();
        string jsonBody='{"boId":"234","status":"add"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/UpdateLabel';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());             
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));   
        API_UpdateLabel.UpdateLabel();
        Test.stopTest();       
    }  
    
    public static testMethod void removeLabelTest()
    {
        Test.startTest();
        string jsonBody='{"boId":"234","status":"remove"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/UpdateLabel';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());             
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));   
        API_UpdateLabel.UpdateLabel();
        Test.stopTest();       
    }  
}