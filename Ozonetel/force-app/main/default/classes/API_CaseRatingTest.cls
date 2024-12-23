/**
* Name           : API_CaseRatingTest
* Created Date   : 19 July 2018
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for API_CaseRating
**/

@isTest
public class API_CaseRatingTest
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
        string jsonBody='{"caseId":"'+cObj.casenumber+'","rating":"Good"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseRating.CaseRating();
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
       c.status='Closed';
        update c;
           
        string jsonBody='{"caseId":"1234","rating":"Good"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseRating.CaseRating();
        
        Test.stopTest();
    }
    public static testMethod void RatingAvailableTest()
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
        Case_Feedback__c cf=new Case_Feedback__c();
        cf.Case_Name__c=c.id;
        cf.Rating__c='Good';
        insert cf;
        case cObj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cObj.casenumber+'","rating":"Good"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseRating.CaseRating();
        
        Test.stopTest();
    }
    public static testMethod void RatingEmptyTest()
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
      
        Case_Feedback__c cf=new Case_Feedback__c();
        cf.Case_Name__c=c.id;
        cf.Rating__c='Good';
        insert cf;
        case cObj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cObj.casenumber+'","rating":" "}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseRating.CaseRating();
        
        Test.stopTest();
    }
    
    public static testMethod void OpenCaseRatingTest()
    {
        Test.startTest();
        Case c=new Case();
        c.SS_Route_Id__c='8404193';       
        c.Issue_Type__c='Bus Operator Service';    
        c.Phone_No_ct__c='9491322718';  
        c.Status='Open';
        insert c;  
        casecomment cc=new casecomment();
        cc.CommentBody='STC--> Test';
        cc.ParentId=c.id;
        insert cc;
       Case_Feedback__c cf=new Case_Feedback__c();
        cf.Case_Name__c=c.id;
        cf.Rating__c='Good';
        insert cf;
        case cObj=[select id,casenumber from case where id=:c.id];
        string jsonBody='{"caseId":"'+cObj.casenumber+'","rating":"Good"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CaseComments/9491322718';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CaseRating.CaseRating();
        Test.stopTest();
    }
}