@isTest
private class giMmtPnrSyncBatchSchedulerTest {
    @isTest
    static void testMethod1() {
        case c=new case();
        c.tin_no__c='1234';
        c.My_Desk_Id__c='1212';
        c.Channel_ct__c ='MMT';
        c.PNR__c='';
        insert c;
        Test.startTest();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        System.schedule('giMmtPnrSyncBatchScheduler',  '0 30 * * * ?', new giMmtPnrSyncBatchScheduler());
        Test.stopTest();
    }
}