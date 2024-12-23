@isTest
public class redBus_data_relink_Batch_Test
{
    Public static testMethod void Success()
    {
        DataReLinkInterval__c dr = new DataReLinkInterval__c();
        dr.name = 'Interval';
        dr.Start_Time__c = 0;
        dr.End_Time__c = 1000;
        insert dr;
        
        DataProcessStages__c DPS = new DataProcessStages__c();
        DPS.name = '1';
        DPS.Status_Name__c = 'TRANSACTION_LIS_CONFIRM_START';
        insert DPS;
        
                RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        insert b;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        //o.UTC_time_difference_in_min__c = ;
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'HOTEL';
        o2.Auth_Key__c = 'HOTEL';
        o2.Channel_Name__c = '';
        //o2.UTC_time_difference_in_min__c = -150 ;
        insert o2;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        account ac = new account();
        ac.lastname = 'test';
        ac.user_id__c = '4261556';
        ac.PersonMobilePhone = '1122334455';
        insert ac;
        
        account ac1 = new account();
        ac1.lastname = 'test';
        ac1.user_id__c = '12345';
        ac1.PersonMobilePhone = '112233445566';
        ac1.PersonEmail = 'vinolinga@gmail.com';
        insert ac1;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.Cust_Details__c = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"1122334455\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        order.User_Id__c = '4261556';
        order.Customer_Name__c = ac.id;
        insert order;

        Order_Items__c orItem = new Order_Items__c();
        orItem.id__c = '56789';
        orItem.Order_Id__c = '123456';
        orItem.Mobile__c = '112233445566';
        orItem.status__c = 'TRANSACTION_LIS_CONFIRM_START';
        orItem.Order_Name__c = order.id;
        orItem.Customer_Name__c = ac.id;
        orItem.Primary_Contact_Customer__c = ac1.id;
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.Id__c = '112233';
        PI.Order_ID__c = '123456';
        PI.Order_Name__c = order.id;
        PI.Payment_Session_ID__c = '334455';
        insert PI;
        
        Payment_Session__c PS = new Payment_Session__c();
        PS.Id__c = '112233';
        PS.Order_ID__c = '123456';
        PS.Order_Name__c = order.id;
        insert PS;
        
        PG_Payment_Items__c PGPI = new PG_Payment_Items__c();
        PGPI.Id__c = '112233';
        PGPI.PG_Reference_No__c = '11223344';
        PGPI.Payment_Items__c = PI.id;
        PGPI.PG_Name__c = 'axis';
        insert PGPI;
        
        Test.StartTest();
        redBus_data_relink_Batch CCT= new redBus_data_relink_Batch();
        Database.executeBatch(CCT);
        Test.StopTest();
    }
}