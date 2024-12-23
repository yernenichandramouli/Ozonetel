@isTest
public class redBusLiveDataPing_RefundAPI_Test
{
    Static TestMethod void method()
    {
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
       
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Boarding_Time__c= datetime.newInstance(2019, 9, 15, 12, 30, 0);
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        insert orItem;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnableCheck();
        Test.StopTest();
    }
    
    Static TestMethod void method2()
    {
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
       
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.Refund_IsSuccess__c = false;
        orItem.Order_Item_Reference_No__c = '';
        orItem.Boarding_Time__c= datetime.newInstance(2019, 9, 15, 12, 30, 0);
        orItem.Flag__c  = 0;
        insert orItem;
        
        Refund_Order_Items__c roi = new Refund_Order_Items__c();
        roi.id__c = '123456';
        roi.name = '123456';
        roi.Order_Item_ID__c = '23456';
        roi.Order_Item_Name__c = orItem.id;
        insert roi;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnableCheck();
        Test.StopTest();
    }
    
    Static TestMethod void method3()
    {
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
        
        RefundAPISettings__c reAPI = new RefundAPISettings__c();
        reAPI.name = 'REDBUS_IN';
        reAPI.Auth_Key__c = '123456';
        reAPI.Business_Unit__c = 'BUS';
        reAPI.Channel_Name__c = 'WEB_DIRECT';
        reAPI.Country_Name__c = 'IND';
        reAPI.Currency_Type__c = 'INR';
        reAPI.URL__c = '';
        insert reAPI;
        
        RefundAPISettings__c reAPI2 = new RefundAPISettings__c();
        reAPI2.name = 'URL';
        reAPI2.URL__c = 'http://cmapi-pp.redbus.com';
        insert reAPI2;
        
        
        
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.Refund_IsSuccess__c = false;
        orItem.Order_Item_Reference_No__c = '';
        orItem.Flag__c  = 0;
        insert orItem;
        
         
        
        case ca = new case();
        ca.Transaction_ID__c = orItem.id;
        ca.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        ca.status = 'Open';
        insert ca;        
        
        Refund_Order_Items__c roi = new Refund_Order_Items__c();
        roi.id__c = '123456';
        roi.name = '123456';
        roi.Order_Item_ID__c = '23456';
        roi.Order_Item_Name__c = orItem.id;
        insert roi;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        //tra.refundEnableCheck();
        Test.setMock(HttpCalloutMock.class, new RefundAPICalloutMock());
        tra.refundAPIping();
        
        Test.StopTest();
    }
    
     Static TestMethod void method4()
    {
       
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        

        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Refund_IsSuccess__c = false;
        orItem.Order_Item_Reference_No__c = '3434';
        orItem.Flag__c  = 0;
        insert orItem;
        
        string orItemId = orItem.Id;
        
        case ca = new case();
        ca.Transaction_ID__c = orItem.id;
        ca.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        ca.status = 'Open';
        ca.Transaction_ID__c=orItem.Id;
        insert ca; 
        
         ApexPages.StandardController con = new ApexPages.StandardController(orItem);
      
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
         tra.refundEnableCheck();
    }
}