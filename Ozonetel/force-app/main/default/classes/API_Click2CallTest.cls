@isTest
public class API_Click2CallTest{


static testMethod void clickToCallTest(){
        Test.startTest();
        string jsonBody='{ "BOCallStatus": "", "UserCallStatus": "FAILURE", "boNumber": "916202120070", "businessUnit": "BUS", "callDateTime": "2020-10-20T11:16:04", "callDuration": "60000", "callStatus": "FAILURE", "callType": "click.to.call.dial", "campaignName": "Redbus_ClickToCallTest", "channel": "IVR", "disconnectedBy": "AGENT", "disposition": "FAILED", "finalCallStatus": "FAILURE", "phoneNo": "918884580492", "recordId": "595999487", "talkTime": "0" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CallDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_Click2Call.callCapture();     
        Test.stopTest();
}

}