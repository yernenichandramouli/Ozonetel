@isTest
public class CaseButtonsTest{
    
    public static testMethod void sendNotificationTest(){ 
        case cs=new case();
        cs.status='Open';
        cs.Lead_TCode__c='12345';
        insert cs;
        Test.startTest();
        string json='{ "Error": null, "Response": { "Data": "The SMS and Whatsapp message have been triggered already" }, "Status": { "StatusCode": 200, "StatusMsg": "OK" } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseButtons.SendCSATNotification(cs.id,'case');
        Test.stopTest();  
    }  
}