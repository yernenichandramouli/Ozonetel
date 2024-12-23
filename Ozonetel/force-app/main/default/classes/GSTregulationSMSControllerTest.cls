@isTest
public with sharing class GSTregulationSMSControllerTest {

    @isTest static void testMethod1(){
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Business_Unit__c='Open';
        ordItem.isAggregator__c='2';
        ordItem.Order_Item_Reference_No__c='123456';
        insert ordItem;
        Test.startTest();
        string json='{ "Error": null, "Response": { "Data": "The SMS and Whatsapp message have been triggered already" }, "Status": { "StatusCode": 200, "StatusMsg": "OK" } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        GSTregulationSMSController.GetTicketDetails(ordItem.id,'test@redbus.com');
        Test.stopTest();  
    }
}