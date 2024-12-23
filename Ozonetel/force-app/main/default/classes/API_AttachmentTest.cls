@isTest()
public without sharing class API_AttachmentTest
{
    static testMethod void AttachmentInsert()
    {
        Test.startTest();
        string jsonBody='{ "attachments": [{ "Body": "d29ybGQ=", "ContentType": "csv", "Name": "DBTBulkConfirmFile" }] }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_Attachment.doPost();
        Test.stopTest();
        
    }
    
    static testMethod void AttachmentInsert2()
    {
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();       
        cs.Status ='Open';
        cs.Origin = 'EmailSupport';
        cs.description='Test Description';              
        cs.Status ='Open';
        //cs.Service_Provider_Id__c='32';
        insert cs;
        Test.startTest();
        case cObj=[select id,casenumber from case where id=:cs.id];
        string jsonBody='{ "attachments": [{ "Body": "d29ybGQ=","ContentType":"png","Name":"Screenshot 2021-02-26 at 2.51.29 PM.png","csNum":"'+cObj.casenumber+'"}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('channel', 'RB+');
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_Attachment.doPost();
        Test.stopTest();
        
    }
    
   /* static testMethod void ContentDocumentTriggerTest(){
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
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cs.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.stopTest();
        
    }*/
}