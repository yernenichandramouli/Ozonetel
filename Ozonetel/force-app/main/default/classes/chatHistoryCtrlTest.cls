@isTest
private class chatHistoryCtrlTest {
    @isTest
    static void chatHistoryTestMethod() {

        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;

        LiveChatTranscript lct=new LiveChatTranscript();
        lct.ChatKey='123456';
        lct.LiveChatVisitorId=lv.id;
        lct.Mobile_No__c = '1234567890';
        lct.Order_Uuid__c='21regfhvc6uy';
        lct.OrderItem_Uuid__c='21regfhvc6uy';
        insert lct;

        Test.startTest();
        string json = '{"data":"SH: Sorry. Your bus doesn"}';
        Test.setMock(HttpCalloutMock.class,new RestClientHTTPMocks(200, 'OK', json));
        chatHistoryCtrl.invokeSelfHelpAPI(String.valueOf(lct.Id));
        Test.stopTest();
    }
}