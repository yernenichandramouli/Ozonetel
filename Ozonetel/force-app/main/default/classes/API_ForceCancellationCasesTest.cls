/**
* Name           : API_ForceCancellationCasesTest
* Created Date   : 23 feb 2021
* Created By     : Mahendra k
* Purpose        : Testing API functionality for API_ForceCancellationCases
**/

@isTest
public class API_ForceCancellationCasesTest
{
   
    public static testMethod void SuccessTest()
    {
        Test.startTest();
        
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='5663'; 
        insert o;
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';
        c.Transaction_ID__c=o.id;
        c.Issue_Type__c='Force Cancellation'; 
        c.country__c='Indonesia';        
        insert c;  
        
        string jsonBody='{"operatorid":"","fromDate":"05/03/2017","toDate":"05/03/2099","country":"Indonesia"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/getForceCancellationCases';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        User u =[Select id from user where LocaleSidKey='en_US' AND isActive = true limit 1];
        System.runAs(u)
        {
            API_ForceCancellationCases.getCases();
        }
        Test.stopTest();
    }
    /*
Name:FailTest
Description: Used to test API functionality with Failed response(doesn't returns records)
*/
    public static testMethod void FailTest()
    {
        Test.startTest();
        
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='5669'; 
        insert o;
        
        Case c=new Case();
        c.SS_Route_Id__c='840419';
        c.Transaction_ID__c=o.id;
        c.Issue_Type__c='Force Cancellation';  
        c.country__c='Indonesia';       
        insert c;  
        
        string jsonBody='{"operatorid":"5669","fromDate":"05/03/2017","toDate":"05/03/2099","country":"Indonesia"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/getForceCancellationCases';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        User u =[Select id from user where LocaleSidKey='en_US' AND isActive = true limit 1];
        System.runAs(u)
        {
            API_ForceCancellationCases.getCases();
        }        
        Test.stopTest();
    }
    
}