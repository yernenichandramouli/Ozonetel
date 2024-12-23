@isTest()
public without sharing class ContentVersionTriggerTest
{
static testMethod void ContentDocumentTriggerTest(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string mockResp='{ "setStatus": true, "setUrl": "http://10.5.10.104:8081/rpwapp/v1/sf/image/15926/321/BO-123/16443160490.jpg", "created_epoch": 16443160490, "file_name": "BO-123" }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();       
        cs.Status ='Open';
        cs.Origin = 'EmailSupport';
        cs.description='Test Description';              
        cs.Status ='Open';
        insert cs;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'SFAgentFromChat',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        }
       }