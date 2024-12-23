@isTest
private class sgmyActivitesExceptionalRefundCtrlTest {
    @isTest static void checkValidateParentCasesTest(){
        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_ACTIVITIES_MY';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        Case c = New Case();
        c.Activity_Id__c = act.Id;
        insert c;

        case cObj=[select id,casenumber,Activity_Id__c from case where id=:c.id];

        sgmyActivitesExceptionalRefundCtrl.checkValidateParentCases(String.valueOf(cObj.Activity_Id__c), String.valueOf(cObj.casenumber));
    }

    @isTest static void getRefundAmountVoucherRealisationErrorTest(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Voucher_Realization_Date__c=Datetime.now().addDays(10);
        insert act;

        Test.startTest();
        sgmyActivitesExceptionalRefundCtrl.getRefundAmount(String.valueOf(act.id));
        Test.stopTest();
    }

    @isTest static void getRefundAmountExceptionalRefundTest(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Voucher_Realization_Date__c=Datetime.now().addDays(-10);
        insert act;
        
        case cs = New case();
        cs.Activity_Id__c = act.Id;
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        insert cs;

        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"ACTIVITY":[{"itemUuid":"dfa9de7116baf006db08f69b01020200","amount":116.0}]},"currencyType":"MYR"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sgmyActivitesExceptionalRefundCtrl.getRefundAmount(String.valueOf(act.id));
        Test.stopTest();
    }

    @isTest static void getRefundAmountErrorResponseTest(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Voucher_Realization_Date__c=Datetime.now().addDays(-10);
        insert act;

        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"ACTIVITY":[{"itemUuid":"dfa9de7116baf006db08f69b01020200","amount":116.0}]},"currencyType":"MYR"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
        sgmyActivitesExceptionalRefundCtrl.getRefundAmount(String.valueOf(act.id));
        Test.stopTest();
    }

    @isTest static void getRefundAmountNullDataTest(){
        Activities__c act=new Activities__c();
        act.Voucher_Realization_Date__c=Datetime.now().addDays(-10);
        insert act;

        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"ACTIVITY":[{"itemUuid":"dfa9de7116baf006db08f69b01020200","amount":116.0}]},"currencyType":"MYR"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
        sgmyActivitesExceptionalRefundCtrl.getRefundAmount(String.valueOf(act.id));
        Test.stopTest();
    }

    @isTest static void getRefundAmountexceptionTest(){
        Activities__c act=new Activities__c();
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Voucher_Realization_Date__c=Datetime.now().addDays(-10);
        insert act;

        Test.startTest();
        sgmyActivitesExceptionalRefundCtrl.getRefundAmount(String.valueOf(act.id));
        Test.stopTest();
    }

    @isTest static void createExceptionalRefundCaseTest(){

        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_ACTIVITIES_MY';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        case cs = New case();
        cs.Activity_Id__c = act.Id;
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        insert cs;
        case cObj=[select id,casenumber from case where id=:cs.id];

        Test.startTest();
        sgmyActivitesExceptionalRefundCtrl.createExceptionalRefundCase(String.valueOf(cObj.casenumber), String.valueOf(act.Id), 'TestTEst', '12', 'TESTTESTTESTTEST');
        Test.stopTest();
    }

    @isTest static void createExceptionalRefundCaseElseTest(){
        case cs = New case();
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        insert cs;
        case cObj=[select id,casenumber from case where id=:cs.id];

        Test.startTest();
        sgmyActivitesExceptionalRefundCtrl.createExceptionalRefundCase(String.valueOf(cObj.casenumber), '', 'TestTEst', '12', 'TESTTESTTESTTEST');
        Test.stopTest();
    }

    @isTest static void approveExceptionalRefundTest(){
        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_ACTIVITIES_MY';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        case cs = New case();
        cs.Activity_Id__c = act.Id;
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        cs.Refund_Amount__c = 12;
        insert cs;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
        insert u1;

        
        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"ACTIVITY":[{"itemUuid":"dfa9de7116baf006db08f69b01020200","amount":116.0}]},"currencyType":"MYR"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sgmyActivitesExceptionalRefundCtrl.approveExceptionalRefund(cs.Id, 'Test', 'SFA');
        Test.stopTest();
    }

    @isTest static void approveExceptionalRefundElseBlockTest(){

        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_ACTIVITIES_MY';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        case cs = New case();
        cs.Activity_Id__c = act.Id;
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        insert cs;

        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"ACTIVITY":[{"itemUuid":"dfa9de7116baf006db08f69b01020200","amount":116.0}]},"currencyType":"MYR"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sgmyActivitesExceptionalRefundCtrl.approveExceptionalRefund(cs.Id, 'Test', 'SFA');
        Test.stopTest();
    }

    @isTest static void approveExceptionalRefundExceptionTest(){

        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_ACTIVITIES_MY';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        case cs = New case();
        cs.Activity_Id__c = act.Id;
        cs.Business_Type__c ='Activities';
        cs.Business_Unit_ct__c ='SGMY Activites';
        cs.Issue_Type__c='Exceptional Refund';
        insert cs;

        Test.startTest();
        sgmyActivitesExceptionalRefundCtrl.approveExceptionalRefund(cs.Id, 'Test', 'SFA');
        Test.stopTest();
    }
}