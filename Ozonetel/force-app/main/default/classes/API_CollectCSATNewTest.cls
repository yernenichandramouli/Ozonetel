@isTest
public class API_CollectCSATNewTest
{
    static testMethod void caseStatus()
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
        Call_Details__c cd=new Call_Details__c();
        cd.Call_Unique_Id__c='d137-5cefc4fc-vce-daf-2802';
        insert cd;
        API_CollectCSATNew.callCapture();
       
        Test.stopTest();
       } 
    static testMethod void caseStatus2()
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
       
        API_CollectCSATNew.callCapture();
       
        Test.stopTest();
       } 
    }