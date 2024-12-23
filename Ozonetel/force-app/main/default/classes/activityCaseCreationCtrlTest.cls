@isTest
private class activityCaseCreationCtrlTest {
    @isTest static void testMethod1(){

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

        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',act.Id);
        ApexPages.StandardController cls = new ApexPages.StandardController(act);
        activityCaseCreationCtrl cscls = new activityCaseCreationCtrl(cls);
        cscls.saveMethod();
        cscls.showPopup();
        Test.StopTest();
    }
    
    @isTest static void testMethod2(){
       OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Peru-Bus';
        oritran.Case_Country__c='Peru';
        oritran.Name = 'REDBUS_PE';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;

        Activities__c act=new Activities__c();
        act.Activity_Name__c='TEST Activity';
        act.Amount__c = 12;
        act.Order_Id__c = 'dfsd32432dsfdsfref';
        act.Activity_uuid__c = 'xcds32432432';
        act.Booking_UserUserid__c = 'TESTUSER';
        act.Business_Unit__c ='REDBUS_PE';
        act.Booking_User_Email__c='test@mail.com';
        act.Booking_User_Mobile__c='9591791743';
        act.Booking_user_Name__c='TESTUSER';
        act.Customer_Email_id__c = 'test@mail.com';
        act.Customer_Mobile_No__c='9019411236';
        act.Customer_Name__c='Rakshith';
        act.Date_Of_Purchase__c=System.now();
        act.Service_Provider_Id__c='12345';
        act.RecordTypeId = Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('Cargo').getRecordTypeId();
        act.Service_Provider_Name__c='Test DomesticActivity';
        act.Rb_User_ID__c='-1';
        act.Transaction_Status__c='CONFIRMED'; 
        act.isPartial_Cancellation_Allowed__c=false;
        act.Voucher_Id__c='RBXPSAK86221';
        act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
        act.Purchase_Item_Currency__c = 'MYR';
        insert act;

        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',act.Id);
        ApexPages.StandardController cls = new ApexPages.StandardController(act);
        activityCaseCreationCtrl cscls = new activityCaseCreationCtrl(cls);
        cscls.saveMethod();
        cscls.showPopup();
        Test.StopTest();
    }
    
    @isTest static void testMethod3(){
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
         oritran.Case_Business_Type__c='Peru-Bus';
         oritran.Case_Country__c='Peru';
         oritran.Name = 'REDBUS_PE';
         oritran.Auth_Key__c = 'IND';
         oritran.Channel_Name__c = 'MOBILE_APP';
         oritran.Case_Business_Type__c='REDBUS_IN';
         insert oritran;
 
         Activities__c act=new Activities__c();
         act.Activity_Name__c='TEST Activity';
         act.Amount__c = 12;
         act.Order_Id__c = 'dfsd32432dsfdsfref';
         act.Activity_uuid__c = 'xcds32432432';
         act.Booking_UserUserid__c = 'TESTUSER';
         act.Business_Unit__c ='REDBUS_PE';
         act.Booking_User_Email__c='test@mail.com';
         act.Booking_User_Mobile__c='9591791743';
         act.Booking_user_Name__c='TESTUSER';
         act.Customer_Email_id__c = 'test@mail.com';
         act.Customer_Mobile_No__c='9019411236';
         act.Customer_Name__c='Rakshith';
         act.Date_Of_Purchase__c=System.now();
         act.Service_Provider_Id__c='12345';
         act.RecordTypeId = Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
         act.Service_Provider_Name__c='Test DomesticActivity';
         act.Rb_User_ID__c='-1';
         act.Transaction_Status__c='CONFIRMED'; 
         act.isPartial_Cancellation_Allowed__c=false;
         act.Voucher_Id__c='RBXPSAK86221';
         act.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
         act.Purchase_Item_Currency__c = 'MYR';
         insert act;
 
         Test.StartTest();
         ApexPages.CurrentPage().getParameters().put('tId',act.Id);
         ApexPages.StandardController cls = new ApexPages.StandardController(act);
         activityCaseCreationCtrl cscls = new activityCaseCreationCtrl(cls);
         cscls.saveMethod();
         cscls.showPopup();
         Test.StopTest();
     }
}