@isTest
private class sendWhatAppCapiCtrlTest {
    @isTest static void sendWhatsAppMessageTestMethod(){
        Case cs = new Case();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2C';
        cs.Booking_Mobile_No__c='1234567890';
        cs.Price_Paid_Currency_ctp__c='INR';
        insert cs;

        Map<Id,String> caseMap = new Map<Id,String>();
        caseMap.put(cs.Id,'gamechanger_open');
        Test.startTest();
        string json='{"statusCode":200,"statusMessage":"Successfully Accepted","error":"","code":200,"messageID":"410183641023115025381782"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sendWhatAppCapiFutureCtrl.asyncSendWhatsAppMessage(caseMap);
        Test.stopTest();
    }
}