@isTest
private class metroIGMCancellationCtrlTest {
    @isTest static void createOndcCaseTestMethod(){
        Activities__c act = New Activities__c();
        act.Additional_Details__c = '{"QRStatusList":["UNCLAIMED"],"QRValidity":"2024-07-12T08:41:53","bapId":"rb-metro-preprod.redbus.in","bapUri":"https://rb-metro-preprod.redbus.in","bppId":"metrobox.preprod.triffy.in","bppUri":"https://metrobox.preprod.triffy.in/metro/seller","destinationStation":"Kalamassery","itemType":"SJT","metroCity":"Kochi","metroDescription":"KMRL","ondcCity":"std:0484","ondcOrderStatus":["ACTIVE"],"ondcPaymentId":"af30ef46-d216-4a62-9cc3-f20d5927b1b3","ondcTxnId":"5abcdf8f-e244-419c-8490-b848c9a365ea","singleQRNeeded":"true","sourceStation":"Townhall"}';
        act.Fulfillment_List__c ='(townhall-kalamassery)';
        act.Activity_Title__c= 'sjt-townhall-kalamassery';
        act.Sub_Items_Count__c =1;
        act.Transaction_Status__c = 'CONFIRMED';
        act.OrderUuid__c='2ca464201d07e0068fc8999901011100';
        act.Service_Provider_Id__c='triffy-kmrl-rail-metro';
        act.Booking_User_Email__c='test@gmail.com';
        act.Booking_user_Name__c='Test';
        act.Booking_User_Mobile__c='1234567890';
        insert act;

        case cs = New case();
        cs.Issue_Type__c='Ticket not working - due to To & fro mismatch';
        cs.Issue_Sub_Category__c='Origin & Destination mismatch';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
        cs.Status='Open';
        cs.Activity_Id__c =act.id;
        insert cs;

        Test.startTest();
        string json='{"error":"Teste","sourceStation":"AG-DMS","destinationStation":"Chennai International Airport","ticketQuantity":3,"cancellationStatus":"CANCELLED","cancelPrice":{"totalRefundableAmount":288,"totalOriginalAmount":0,"totalCancellationAmount":0},"cancellationTime":"2024-01-23T12:36:19.754Z","cancelledBy":"CONSUMER"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        metroIGMCancellationCtrl.invokeCancellationApi(cs.Id,'SOFT_CANCEL');
        Test.stopTest();

    }
    
    @isTest static void fetchCancellationStatusTestMethod(){
        Activities__c act = New Activities__c();
        act.Additional_Details__c = '{"QRStatusList":["UNCLAIMED"],"QRValidity":"2024-07-12T08:41:53","bapId":"rb-metro-preprod.redbus.in","bapUri":"https://rb-metro-preprod.redbus.in","bppId":"metrobox.preprod.triffy.in","bppUri":"https://metrobox.preprod.triffy.in/metro/seller","destinationStation":"Kalamassery","itemType":"SJT","metroCity":"Kochi","metroDescription":"KMRL","ondcCity":"std:0484","ondcOrderStatus":["ACTIVE"],"ondcPaymentId":"af30ef46-d216-4a62-9cc3-f20d5927b1b3","ondcTxnId":"5abcdf8f-e244-419c-8490-b848c9a365ea","singleQRNeeded":"true","sourceStation":"Townhall"}';
        act.Fulfillment_List__c ='(townhall-kalamassery)';
        act.Activity_Title__c= 'sjt-townhall-kalamassery';
        act.Sub_Items_Count__c =1;
        act.Transaction_Status__c = 'CONFIRMED';
        act.OrderUuid__c='2ca464201d07e0068fc8999901011100';
        act.Service_Provider_Id__c='triffy-kmrl-rail-metro';
        act.Booking_User_Email__c='test@gmail.com';
        act.Booking_user_Name__c='Test';
        act.Booking_User_Mobile__c='1234567890';
        insert act;

        case cs = New case();
        cs.Issue_Type__c='Ticket not working - due to To & fro mismatch';
        cs.Issue_Sub_Category__c='Origin & Destination mismatch';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
        cs.Status='Open';
        cs.Activity_Id__c =act.id;
        insert cs;

        Test.startTest();
        string json='{"totalFare":9,"refundAmount":9,"totalPaid":0,"currencyType":"INR","sourceLocation":"Edapally Jn.","destinationLocation":"Changampuzha Park","noOfSeatsBooked":1,"tin":"T4B67433","orderItemUuid":"4e5eac03135de0063597d7ad02011100","items":[{"itemType":"GENERIC_ITEM","totalFare":9,"refundAmount":9,"totalPaid":9,"refundBreakUp":[{"displayName":"BASIC_FARE","amount":9,"refundAmount":9,"nonRefundAmount":0}],"cancelPolicy":[]}],"refundDetails":{"refundAmount":9,"expectedTAT":null,"actualTAT":null,"refundMode":null,"refundStatus":"REFUND_SUCCESS","creditedTime":null}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        metroIGMCancellationCtrl.fetchCancellationStatus(cs.Id);
        Test.stopTest();

    }
}