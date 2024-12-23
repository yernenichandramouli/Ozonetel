@isTest
public class API_TripCaseDetails_Test
{
    static testMethod void casedtlsTrip()
    {
       string jsonBody='{"tripid":"12406553650301410","tin":"PEN3R20331054","issuetype":"test12","subissuetype":"test123"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/TripCaseDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
         list<case> listcs = new list<case>();
         case cs = new case();
         //cs.casenumber=1234;
         cs.TIN_No__c='PEN3R20331054';
         cs.Trip_Id_ct__c='12406553650301410';
         cs.Issue_Type__c='test12';
         cs.Issue_Sub_Category__c='test123';
         cs.status='open';
         listcs.add(cs);
         insert listcs;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_TripCaseDetails.casedetails();
       
        Test.stopTest();
       }
    static testMethod void errorcasedtlsTrip()
    {
       string jsonBody='{"tripid":"","tin":"","issuetype":"","subissuetype":""}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/TripCaseDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_TripCaseDetails.casedetails();
       
        Test.stopTest();
       } 
    static testMethod void IVRCaseDetails() {
        string jsonBody='{"tripid":"12406553650301410","tin":"PEN3R20331054","issuetype":"test12","subissuetype":"test123", "mobile":"9539518396"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Channel', 'IVR-Ameyo');
        req.requestURI = '/services/apexrest/redBus/TripCaseDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
         list<case> listcs = new list<case>();
         case cs = new case();
         //cs.casenumber=1234;
         cs.TIN_No__c='PEN3R20331054';
         cs.Trip_Id_ct__c='12406553650301410';
         cs.Issue_Type__c='test12';
         cs.Issue_Sub_Category__c='test123';
         cs.status='open';
         listcs.add(cs);
         insert listcs;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_TripCaseDetails.casedetails();
       
        Test.stopTest();
    }
    static testMethod void IVRCaseDetailsError() {
        string jsonBody='{"tripid":"12406553650301410","tin":"PEN3R20331054","issuetype":"test12","subissuetype":"test123"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('Channel', 'IVR-Ameyo');
        req.requestURI = '/services/apexrest/redBus/TripCaseDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
         list<case> listcs = new list<case>();
         case cs = new case();
         //cs.casenumber=1234;
         cs.TIN_No__c='PEN3R20331054';
         cs.Trip_Id_ct__c='12406553650301410';
         cs.Issue_Type__c='test12';
         cs.Issue_Sub_Category__c='test123';
         cs.status='open';
         listcs.add(cs);
         insert listcs;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_TripCaseDetails.casedetails();
       
        Test.stopTest();
    }
    }