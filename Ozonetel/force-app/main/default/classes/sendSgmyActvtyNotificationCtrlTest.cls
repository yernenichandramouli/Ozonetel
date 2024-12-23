@isTest
private class sendSgmyActvtyNotificationCtrlTest {
    @isTest static void testMethod1(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Business_Unit__c='REDBUS_MY';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;
        Test.startTest();
        string json =' {"statusMessage":"Email and WhatsApp message sent successfully","isEmailSent":true,"isWhatsAppSent":true,"emailRespId":"010e018b5c1b6ccd-d22216bc-ee0b-4e76-b906-fe2657693310-000000","isSMSSent":false}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sendSgmyActvtyNotificationCtrl.sendNotification(String.valueOf(act.Id),'919591791734','test@mail.com','3');
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        act.Business_Unit__c='REDBUS_MY';
        insert act;
        Test.startTest();
        string json =' {"statusMessage":"Email and WhatsApp message sent successfully","isEmailSent":true,"isWhatsAppSent":true,"emailRespId":"010e018b5c1b6ccd-d22216bc-ee0b-4e76-b906-fe2657693310-000000","isSMSSent":false}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
        sendSgmyActvtyNotificationCtrl.sendNotification(String.valueOf(act.Id),'919591791734','test@mail.com','3');
        Test.stopTest();
    }

    @isTest static void testMethod3(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        act.Business_Unit__c='REDBUS_MY';
        insert act;
        Test.startTest();
        string json ='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
        sendSgmyActvtyNotificationCtrl.sendNotification(String.valueOf(act.Id),'919591791734','test@mail.com','3');
        Test.stopTest();
    }

    @isTest static void testMethod4(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '';
        act.Purchase_Item_Currency__c = 'MYR';
        act.Business_Unit__c='REDBUS_MY';
        insert act;
        Test.startTest();
        string json ='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
        sendSgmyActvtyNotificationCtrl.sendNotification(String.valueOf(act.Id),'919591791734','test@mail.com','3');
        Test.stopTest();
    }

}