/**
* Name           : API_GetBoIdCasesTest
* Created Date   :
* Created By     :  
* Purpose        : Testing API functionality for API_GetBoIdCases
**/

@isTest
public class API_GetBoIdCasesTest
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
        c.Service_Providerr_Id__c='8404193';
        c.Issue_Type__c ='Bus Operator Service';
        c.Bus_Operator_Namee__c='Test Operator';
        c.status='Open';         
        insert c;  
        
        
        string jsonBody='{"caseRecords":"Yes","caseDetails":[{"vendorName":"Imaginary Travels","status":"Open","createdDateTime":"2022-08-22 16:08:48","caseNumber":"18363550","boId":"15926"}]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/GetBoIdCases';  //Request URL
        req.httpMethod = 'Get';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        req.addHeader('channel', 'RB+');
        req.addParameter('lstBoIds', c.Service_Providerr_Id__c);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_GetBoIdCases.getCases();
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
        o.Service_Provider_Id__c='5663'; 
        insert o;
        
        Case c=new Case();
        //c.Service_Provider_Id__c='8404193';
        c.Bus_Operator_Namee__c='Test Operator';
        c.status='Open';         
        insert c;  
        
        string jsonBody='{"caseRecords":"Yes","caseDetails":[{"vendorName":"Imaginary Travels","status":"Open","createdDateTime":"2022-08-22 16:08:48","caseNumber":"18363550","boId":"15926"}]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/GetBoIdCases';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_GetBoIdCases.getCases();
        
        Test.stopTest();
    }
    
}