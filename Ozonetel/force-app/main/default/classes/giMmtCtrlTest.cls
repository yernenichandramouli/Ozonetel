@isTest
private class giMmtCtrlTest {
    @isTest static void initiateSSBusCancellationTest(){
        case cs = new case();
        cs.PNR__c='B93P8JFC';
        cs.Channel_ct__c='MMT';
        cs.My_Desk_Id__c='123456789012';
        insert cs;
        Test.startTest();
        string json='{"tin":"B93P8JFC","status":"Initiated","message":"Cancel Ticket","processedBySfa":false}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        giMmtCtrl.initiateSSBusCancellation(string.valueOf(cs.Id));
        Test.stopTest();
    }

    @isTest static void pushToRedisB2bTest(){
        Test.startTest();
        string json='true';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        giMmtCtrl.pushToRedisB2b('B93P8JFC');
        Test.stopTest();
    }
}