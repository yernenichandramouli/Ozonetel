@isTest
public class CaseCreationonTra_Batch_Test
{
   Public static testMethod void method1()
    {
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
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
        insert o2;
        
        Account ac = new Account();
        ac.Name='SAMPLE';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Primary_Contact_Customer__c = ac.Id;
        ori.Customer_Name__c=ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
       // w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        c.Transaction_ID__c=ori.Id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
     Public static testMethod void method2()
    {
         UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
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
        insert o2;
        
        Account ac = new Account();
        ac.Name='SAMPLE';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Primary_Contact_Customer__c = ac.Id;
        ori.Customer_Name__c=ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
    
    Public static testMethod void method3()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Primary_Contact_Customer__c = ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
    Public static testMethod void method4()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        //ori.Primary_Contact_Customer__c = ac.Id;
        ori.Customer_Name__c=ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        //c.Transaction_ID__c = ori.id;
        //c.Primary_Contact_Customer__c = ac.id;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }
    Public static testMethod void method5()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Customer_Name__c = ac.Id;
        //ori.Primary_Contact_Customer__c = ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        //ori.Transaction_Latest_Status__c = 'FAIL';
        ori.Business_Unit__c = 'REDBUS_BD';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
        Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        //c.Transaction_ID__c = ori.id;
        //c.Primary_Contact_Customer__c = ac.id;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }
    Public static testMethod void method6()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Customer_Name__c = ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        //ori.Transaction_Latest_Status__c = 'FAIL';
        ori.Business_Unit__c = 'REDBUS_BD';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
        Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'SUCCESS';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
    Public static testMethod void method7()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'Green Failed Transaction (GFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Customer_Name__c = ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        //ori.Transaction_Latest_Status__c = 'FAIL';
        ori.Business_Unit__c = 'REDBUS_BD';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
        Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'SUCCESS';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    } 
     Public static testMethod void method8()
    {
       
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'Green Failed Transaction (GFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = FALSE;
        insert b;
        
                
        Account ac = new Account();
        ac.Name='N/A';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        //ori.Primary_Contact_Customer__c = ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'FAIL';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
      Public static testMethod void method9()
    {
         UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CREATED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c b = new WFT_GFT_Business_Units__c();
        b.Name = 'REDBUS_IN';
        b.Create_WFT__c = True;
        b.Create_GFT__c = True;
        b.Account_DOJ_Check__c = True;
        insert b;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
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
        insert o2;
        
        Account ac = new Account();
        ac.Name='SAMPLE';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Boarding_Time__c=System.Today();
        ori.Order_Item_Reference_No__c='';
        ori.Transaction_Status__c='Booked';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Primary_Contact_Customer__c = ac.Id;
        ori.Customer_Name__c=ac.Id;
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        ori.Already_Processed__c = False;
        ori.Transaction_Status_WFT_GFT__c = 'WFT';
       // ori.status__c='CREATED';
       Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        w.Already_Processed__c=False;
        w.Transaction_Latest_Status__c = 'SUCCESS';
        insert w;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'ONLINE';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        Case_Creation_Interval__c cx = new Case_Creation_Interval__c();
        cx.Name = 'Interval';
        cx.Start_Time__c = 0;
        cx.End_Time__c = 10;
        insert cx;
        
        String recordTypeId1  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        Case c = new Case();
        c.RecordTypeId = recordTypeId1;
        c.Accountid = ac.id;
        insert c;
                
        Test.StartTest();

        CaseCreationonTraStatus_Batch CCT= new CaseCreationonTraStatus_Batch();
        Id bid = Database.executeBatch(CCT,1);
        Test.StopTest();
    }  
    
   }