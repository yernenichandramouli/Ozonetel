/**
* Name           : API_Get_Cases_Test
* Created Date   : 17 May 2017
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for API_Get_Cases
**/

@isTest
public class API_Get_Cases_Test
{
    /*
Name:SuccessTest
Description: Used to test API functionality with Success response(returns records)
*/
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
        c.Issue_Type__c='Bus Operator Service';         
        insert c;  
        
        string jsonBody='{"serviceProviderId":"5663","fromDate":"05/03/2017","toDate":"05/03/2099","routeIds":[8404193]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/getCases';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        User u =[Select id from user where LocaleSidKey='en_US' AND isActive = true limit 1];
        System.runAs(u)
        {
            API_Get_Cases.getCases();
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
        c.Issue_Type__c='Bus Operator Service';        
        insert c;  
        
        string jsonBody='{"serviceProviderId":"5663","fromDate":"05/04/2002","toDate":"05/05/1991","routeIds":[8404193]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/getCases';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        User u =[Select id from user where LocaleSidKey='en_US' AND isActive = true limit 1];
        System.runAs(u)
        {
            API_Get_Cases.getCases();
        }        
        Test.stopTest();
    }
    
}