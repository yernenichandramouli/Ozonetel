@isTest
public class ExperiencesCancellationTest
{

 public static testMethod void expCanclMethod()
    {
    
        Activities__c act = new Activities__c ();
        act.Activity_uuid__c='122334445';
        insert act;
        ApexPages.StandardController con = new ApexPages.StandardController(act);
        ExperiencesCancellation controller = new ExperiencesCancellation(con);
        string jsonBody='{"backToSource":true,"reason":"Testing","cancelledBy":"NilikaSFTester","emailID":"srinu.it1234@gmail.com"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = 'https://capi.redbus.com/xp/v1/orders/';  //Request URL
        req.httpMethod = 'post';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;   
        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ExperiencesCancellation.cancelActivity(act.id);
        ExperiencesCancellation.isCancellable(act.id); 
        Test.stopTest();
    }
}