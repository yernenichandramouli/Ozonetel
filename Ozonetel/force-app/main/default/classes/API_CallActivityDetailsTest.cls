@isTest
public class API_CallActivityDetailsTest
{
    public static testMethod void TestActivitySuccess()
    {
         string jsonBody='{"mobile":"9591522393","phoneCode":"91","rating":"Average","call_Id":"d137-5cefc4fc-vce-daf-2802"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/collectCSAT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallActivityDetails.callCapture();
       
        Test.stopTest();
     }   
}