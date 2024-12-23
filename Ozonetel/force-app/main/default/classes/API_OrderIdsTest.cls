/**
* Name           : API_OrderIdsTest
* Created Date   : 15 Sep 2017
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for API_OrderIds
**/

@isTest
public class API_OrderIdsTest
{
    /*
Name:SuccessTest
Description: Used to test test insert recharge items with New customer
*/
    public static testMethod void SuccessWithNewCustomer()
    {
        Test.startTest();
        string jsonBody='[{"id":"428","type":"RBRecharge","userid":"4278817","email":"mani.renus@gmail.com","mobile":"9538910940","status":"success","createdDate":"2017-12-12 17:17:26.784317"},{"id":"429","type":"RBRecharge","userid":"4278817","email":"abc@xyz.com","mobile":"9491322718","status":"success","createdDate":"2017-12-12 17:17:26.784317"}]';
         Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
       // acc.PersonEmail='mani.renus@gmail.com';
        acc.PersonMobilePhone='9491322718';
        insert acc;
        PostGres_Data__c p=new PostGres_Data__c ();
        p.Mobile__c='9491322718';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/Orders';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_OrderIds.doPost();     
        Test.stopTest();
    }
    
      /*
Name:SuccessTest
Description: Used to test test insert recharge items with Existing customer
*/
    public static testMethod void SuccessWithExistingCustomer()
    {
        Test.startTest();
        string jsonBody='[{"id":"428","type":"RBRecharge","userid":"4278817","email":"mani.renus@gmail.com","mobile":"9538910940","status":"success","createdDate":"2017-12-12 17:17:26.784317"},{"id":"429","type":"RBRecharge","userid":"4278817","email":"abc@xyz.com","mobile":"9491322718","status":"success","createdDate":"2017-12-12 17:17:26.784317"}]';
         Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.Email__c='mani.renus@gmail.com';
        acc.Phone_10_Digits__c='9491322718';
        insert acc;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/Orders';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_OrderIds.doPost();     
        Test.stopTest();
    }
}