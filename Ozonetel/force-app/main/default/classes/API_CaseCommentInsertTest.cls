/**
* Name           : API_CaseCommentInsertTest
* Created Date   : 17 July 2018
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for API_CaseCommentInsert
**/

@isTest
public class API_CaseCommentInsertTest
{
    /*
Name:SuccessTest
Description: Used to test API functionality with Success response(returns records)
*/
   public static testMethod void SuccessTest()
    {
        Test.startTest();
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';   
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        c.status='Closed';
        update c;
        case cObj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cObj.casenumber+'","comment":"Test Comment","attachmentURLs" : "https://s3-ap-southeast-1.amazonaws.com/cxselfhelp/1696322076316Screenshot_20230922-124415_Chrome.jpg"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseCommentInsert.CaseCommentsInsert();
        
        Test.stopTest();
    }
    
    public static testMethod void NoCasesTest()
    {
        Test.startTest();
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';     
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        string jsonBody='{"caseId":"1234","comment":"Test Comment"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseCommentInsert.CaseCommentsInsert();
        Test.stopTest();
    }
    public static testMethod void NoCommentTest()
    {
        Test.startTest();
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';     
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        string jsonBody='{"caseId":"1234","comment":""}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseCommentInsert.CaseCommentsInsert();
        Test.stopTest();
    }
    public static testMethod void AttachmentOnlyTest() {
        Test.startTest();
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718'; 
        c.SH_Attachment_URLs__c = 'https://s3-ap-southeast-1.amazonaws.com/cxselfhelp/1696322076316Screenshot_20230922-124415_Chrome.jpg';
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        case cObj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cObj.casenumber+'","attachmentURLs" : "https://s3-ap-southeast-1.amazonaws.com/cxselfhelp/1696322076316Screenshot_20230922-124415_Chrome.jpg"}';        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseCommentInsert.CaseCommentsInsert();
        Test.stopTest();
    }
     public static testMethod void RedProwWinTest()
    {
        Test.startTest();
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';  
        c.Assigned_By__c = 'Inte';
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
        case cobj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cobj.casenumber+'","comment":"Test Comment","excepRefAmount":20,"processExcepRef":true}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseCommentInsert';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('channel', 'RB+');
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseCommentInsert.CaseCommentsInsert();
        Test.stopTest();
    }
}