@isTest
public class redBusLiveDataPing_Test
{
    static TestMethod void HotelCreditTest()
    {
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;   
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Order_Id__c = '123456';
        orItem.Total_Fare_Value__c=10;
        orItem.Discount_Value__c=9;
        orItem.Email__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';        
        orItem.Primary_Contact_Customer__c = a.Id;
        insert orItem;
      

        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Issue_Type__c='redHotel';
        //c.CreatedDate=System.now().addHours(-2);
        //Test.setCreatedDate(c.Id, System.now().addHours(-2));
        insert c;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        test.StartTest();
        string mJson='{"useid" : "51482263", "emailId" : "jayswalmehul1@gmail.com", "phone" : "918866470323", "amount" : "15.00"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mjson));
        ApexPages.CurrentPage().getParameters().put('id',orItem.Id);        
        ApexPages.StandardController controller = new ApexPages.StandardController(orItem);
        String mockResponse='{"Status": {'+'"statusCode": "201"'+'}'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResponse));
  
        redBusLiveDataPing instance = new redBusLiveDataPing(controller); 
        instance.creditAmountToWallet();
        instance.walletCreditButtonEnable();
        instance.syncEnable =false;
        instance.iSwalletCreditEnable = false;
        instance.dojDate=system.now();
        instance.finalDoj='test';
        instance.gftRebboking=false;
        instance.rebookingURL='test';
        instance.genrateDisbrslid=true;

        Test.StopTest();
    }
    
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
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.Total_Fare_Value__c =0;
        orItem.Discount_Value__c =12;
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '1234567';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        PI.Payment_Gateway_Type__c  = 'Testing';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
          String mockResponse1='{"Status": {'+'"statusCode": "401"'+'}'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResponse1));
        
        tra.creditAmountToWallet();
        Test.StopTest();
    }
    Static TestMethod void method1()
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '1234567';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        PI.Payment_Gateway_Type__c  = 'Testing';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        //  tra.SessionIdPing();
        Test.StopTest();
    }
    
    Static TestMethod void method2()
    {
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        //tra.SessionIdPing();
        tra.PaymentButtonEnable();
        //tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method3()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'Green Failed Transaction (GFT)';
        r.Transaction_Status__c = 'Green Failed Transaction (GFT)';
        insert r;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c='Green Failed Transaction (GFT)';
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.PaymentUpdatePing();
        
        Test.StopTest();
    }
    Static TestMethod void method4()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'Green Failed Transaction (GFT)';
        r.Transaction_Status__c = 'CONFIRMATION_FAILED';
        insert r;
        
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        //orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CONFIRMATION_FAILED';
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        //o.UTC_time_difference_in_min__c = ;
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.ReBookingURL__c='testt';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        //tra.SessionIdPing();
        //tra.PaymentButtonEnable();
         tra.refundAPIping();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method5()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        //orItem.Customer_Name__c = a.Id;
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        //tra.SessionIdPing();
        //tra.PaymentButtonEnable();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method6()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method7()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        Account a = new Account();
        a.Name = 'N/A';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        //tra.SessionIdPing();
        //tra.PaymentButtonEnable();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method8()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        Account a = new Account();
        a.Name = 'N/A';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        //orItem.Customer_Name__c = a.Id;
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        //tra.SessionIdPing();
        //tra.PaymentButtonEnable();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method9()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        Account a = new Account();
        a.Name = 'Test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        //orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        RefundAPISettings__c setting = new RefundAPISettings__c();
        setting.Name = 'REDBUS_IN';
        setting.Business_Unit__c = 'BUS';
        setting.Channel_Name__c='WEB_DIRECT';
        setting.Currency_Type__c='INR';
        setting.Country_Name__c='IND';
        setting.Auth_Key__c = 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        setting.URL__c='Test';
        insert setting;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        redBusLiveDataPing.refundResponse rfRes = new redBusLiveDataPing.refundResponse();
        rfRes.InitiatedTime= string.valueof(system.now());
        rfRes.IsSuccess= 'true';
        rfRes.CustRefundId= '23456789';
        String sampleJson='{'+'"InitiatedTime": "2022-04-05T12:30:45Z",'+'"CustRefundId": "123456789",'+'"IsSuccess": "true",'+'"ResponseMessage": "Refund initiated successfully"'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', sampleJson));

        tra.PaymentUpdatePing();
        tra.refundAPIping();
        Test.StopTest();
    }
    Static TestMethod void method10()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_BD';
        wb.Create_WFT__c = True;
        wb.Create_GFT__c = True;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        //orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.PaymentUpdatePing();
        Test.StopTest();
    }
    Static TestMethod void method11()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMockFail());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.PaymentUpdatePing();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        tra.syncDataCall();
        Test.StopTest();
    }
    
    Static TestMethod void method12()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='TESTTEST';
        orItem.Total_Fare_Currency__c ='123';
        orItem.Business_Unit__c='REDBUS_IN';
        orItem.Boarding_Time__c = system.now();
        insert orItem;
        
        
        Refund_Order_Items__c  rt = New Refund_Order_Items__c();
        rt.Refunded_Amount__c=123;
        rt.Refund_Type__c = 'ONLINE';
        rt.Status__c = 'REFUND_FAILURE';
        rt.PG_Name__c ='REDBUS_ADJUSTMENT';
        rt.Disbursal_ID__c ='323324434324324443543543';
        rt.Order_Item_Name__c =orItem.Id;
        insert rt;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'ONLINE';
        PI.PG_Reference_ID__c ='12345678';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.ReBookingURL__c='testt';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Business_Unit_ct__c='REDBUS_IN';
        c.issue_type__c='NEFT Refund';
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Disbursal_ID__c ='323324434324324443543543';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        String jsonmm = '{'+'"IsSuccess": true'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonmm));
        
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnable =true;
        tra.refundEnableCheck();
       // tra.sendNEFTlink();
        tra.sendDisbursallink();
        Test.StopTest();
    }
    
    Static TestMethod void method13()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='Test1223445';
        orItem.Guid__c='Test1223445';
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.ReBookingURL__c='testt';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Issue_Type__c ='NEFT Refund';
        c.TIN_No__c='Test1223445';
        c.Transaction_UUID__c='Test1223445';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        
        string jsona=' {"is_success":false,"message":"Refund not created at Neon"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsona));
        
        
        
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnable =true;
        tra.neftRefundAmt='123 34546 656';
        tra.refundEnableCheck();
        tra.GenrateDisbursalid();
        Test.StopTest();
    }
    
    Static TestMethod void method14()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        Account a = new Account();
        a.Name = 'Test';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        //orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        insert orItem;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        RefundAPISettings__c setting = new RefundAPISettings__c();
        setting.Name = 'REDBUS_IN';
        setting.Business_Unit__c = 'BUS';
        setting.Channel_Name__c='WEB_DIRECT';
        setting.Currency_Type__c='INR';
        setting.Country_Name__c='IND';
        setting.Auth_Key__c = 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        setting.URL__c='Test';
        insert setting;
        
        RefundAPISettings__c setting2 = new RefundAPISettings__c();
        setting2.Name = 'URL';
        setting2.Business_Unit__c = 'BUS';
        setting2.Channel_Name__c='WEB_DIRECT';
        setting2.Currency_Type__c='INR';
        setting2.Country_Name__c='IND';
        setting2.Auth_Key__c = 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        setting2.URL__c='Test';
        insert setting2;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        String sampleJson='{'+'"InitiatedTime": "2022-04-05T12:30:45Z",'+'"CustRefundId": "123456789",'+'"IsSuccess": "true",'+'"ResponseMessage": "Refund initiated successfully"'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', sampleJson));

        
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.refundAPIping();
        Test.StopTest();
    }
    
    
    Static TestMethod void sendDisbursallinkForNewcaseTest()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='TESTTEST';
        orItem.Total_Fare_Currency__c ='123';
        orItem.Business_Unit__c='REDBUS_IN';
        insert orItem;
        
        
        Refund_Order_Items__c  rt = New Refund_Order_Items__c();
        rt.Refunded_Amount__c=123;
        rt.Refund_Type__c = 'ONLINE';
        rt.Status__c = 'REFUND_FAILURE';
        rt.PG_Name__c ='REDBUS_ADJUSTMENT';
        rt.Disbursal_ID__c ='323324434324324443543543';
        rt.Order_Item_Name__c =orItem.Id;
        insert rt;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
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
        o1.ReBookingURL__c='testt';
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Business_Unit_ct__c='REDBUS_IN';
        c.issue_type__c='NEFT Refund';
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Disbursal_ID__c ='323324434324324443543543';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='{"IsSuccess":true,"ErrorMsg":"","ReferenceID":"8a33d50683e5f9971b307b87c0f86f5b"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.sendDisbursallinkForNewcase('323324434324324443543543');
        Test.StopTest();
    }
    
    Static TestMethod void method19()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
          String noBUsString = System.label.GFT_Rebooking_Slab;
                List<String> noBUsList = noBUsString.split('_');
                
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_ID';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='TESTTEST';
        orItem.Total_Fare_Currency__c ='123';
        orItem.Business_Unit__c='REDBUS_IN';
        orItem.Total_Fare_Value__c =56;
        orItem.Payment_Details__c='{"id":13473197457266714,"orderId":13473197457266714,"uuid":"a78dbb03fbb9f0054c27f30c02010500","creationTime":"2023-05-15T11:21:22","businessUnit":"REDBUS_ID","orderValue":{"currencyType":"IDR","amount":529},"amountReceivable":{"currencyType":"IDR","amount":0},"amountPaid":{"currencyType":"IDR","amount":529},"refundableSurplus":{"currencyType":"IDR","amount":0},"paymentItemList":[{"id":13473197622403436,"orderId":13473197457266714,"uuid":"a8c8b42dfbb9f0054c27f30c04030500","refunds":null,"businessUnitValue":{"currencyType":"IDR","amount":529},"paymentItemValue":{"currencyType":"IDR","amount":529},"paymentStatus":"COMPLETED","paymentSessionId":13473197457266714,"paymentSystem":"RBOFFER","paymentSystemRefNo":"DBT","updatedBy":"","creationTime":"2023-05-15T11:21:42","pgName":"","pgtype":"","cardNo":"","bankName":"","bankAccountNumber":"","accountHolderName":"","bank_ref_num":"","itemUuids":["a78dc578fbb9f0054c27f30c01020500"],"paymentSubType":"","_meta":{"version":null,"confirm_millisecond":""}},{"id":13473197629411001,"orderId":13473197457266714,"uuid":"a8d611d7fbb9f005d93dc8e301030500","refunds":[{"reason":"gft_refund-multiple item state","updatedBy":"","refundedBy":"","refundType":"ONLINE","refundTime":1684322571083014,"refundStatus":"REFUND_CREATED","refundAmount":{"currencyType":"IDR","amount":504471},"refundCreationTime":"2023-05-17T11:22:51","refundCategory":"GFT","order_item_uuid":"b03f3ff2fbb9f00585344c3004020500","channel":"OMS","refNo":"","orderItemId":0,"index":1}],"businessUnitValue":{"currencyType":"IDR","amount":504471},"paymentItemValue":{"currencyType":"IDR","amount":504471},"paymentStatus":"COMPLETED","paymentSessionId":13473197457266714,"paymentSystem":"ONLINE","paymentSystemRefNo":"21838021","updatedBy":"CAPI","creationTime":"2023-05-15T11:21:49","pgName":"BankTransfer","pgtype":"BankTransfer","cardNo":"","bankName":"BCA","bankAccountNumber":"2063 335 002","accountHolderName":"IBIBO GROUP INDONESIA PT","bank_ref_num":"","itemUuids":null,"paymentSubType":"","_meta":{"version":null,"confirm_millisecond":""}}]}';
        
        insert orItem;
        
        
        
        Refund_Order_Items__c  rt = New Refund_Order_Items__c();
        rt.Refunded_Amount__c=123;
        rt.Refund_Type__c = 'ONLINE';
        rt.Status__c = 'REFUND_FAILURE';
        rt.PG_Name__c ='REDBUS_ADJUSTMENT';
        rt.Disbursal_ID__c ='323324434324324443543543';
        rt.Order_Item_Name__c =orItem.Id;
        insert rt;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        o2.ReBookingURL__c='testt';
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Business_Unit_ct__c='REDBUS_IN';
        c.issue_type__c='NEFT';
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Disbursal_ID__c ='323324434324324443543543';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
       /* string json='{"IsSuccess":true,"ErrorMsg":"","ReferenceID":"8a33d50683e5f9971b307b87c0f86f5b"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));*/
        String jsonmm = '{'+'"IsSuccess": true'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonmm));

        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnable =true;
        tra.refundEnableCheck();
        //tra.sendNEFTlink();
        tra.sendDisbursallink();
        Test.StopTest();
    }
    
    Static TestMethod void testRefund()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='TESTTEST';
        orItem.Total_Fare_Currency__c ='123';
        orItem.Business_Unit__c='REDBUS_IN';
        insert orItem;
        
        
        Refund_Order_Items__c  rt = New Refund_Order_Items__c();
        rt.Refunded_Amount__c=123;
        rt.Refund_Type__c = 'ONLINE';
        rt.Status__c = 'REFUND_FAILURE';
        rt.PG_Name__c ='REDBUS_ADJUSTMENT';
        rt.Disbursal_ID__c ='323324434324324443543543';
        rt.Order_Item_Name__c =orItem.Id;
        insert rt;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.ReBookingURL__c='testt';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Business_Unit_ct__c='REDBUS_IN';
        c.issue_type__c='NEFT';
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Disbursal_ID__c ='323324434324324443543543';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='{"IsSuccess":true,"ErrorMsg":"","ReferenceID":"8a33d50683e5f9971b307b87c0f86f5b"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.UPIRefundPage(); 
        Test.StopTest();
    }
    
    Static TestMethod void method15()
    {
            List<Order_Items__c> listOrdItems = new List<Order_Items__c>();

        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
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
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
       // orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='Test1223445';
        orItem.Guid__c='Test1223445';
        listOrdItems.add(orItem);
        
        Order_Items__c orItem2 = new Order_Items__c();
        orItem2.name = '23456';
        orItem2.id__c = '23456';
        //orItem2.Customer_Name__c = a.Id;
        orItem2.Email_Copy__c = 'test@redbus.com    ';
        orItem2.Mobile__c = '1234567891';
        orItem2.Business_Unit__c = 'REDBUS_IN';
        orItem2.Transaction_Source__c = 'MOBILEAPP';
        orItem2.Item_Type__c = 'BUS';
        orItem2.Primary_Contact_Customer__c = a.Id;
        orItem2.status__c = 'CREATED';
        orItem2.Date_of_Service__c = system.today();
       // orItem.Order_Id__c='Test';
        orItem2.Order_Item_Reference_No__c='Test122349945';
        orItem2.Guid__c='Test771223445';
        listOrdItems.add(orItem2);        
        
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.ReBookingURL__c='testt';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Issue_Type__c ='NEFT Refund';
        c.TIN_No__c='Test1223445';
        c.Transaction_UUID__c='Test1223445';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        
        string jsona=' {"is_success":true,"message":"Refund not created at Neon"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsona));
        
        
        
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
               Test.StopTest();
    }
    
     Static TestMethod void dotComTest()
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
        orItem.Business_Unit__c = 'REDBUS_COM';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.Refund_IsSuccess__c = false;
        orItem.Amount_Recieved_Currency__c = 'INR';
        orItem.Total_Fare_Currency__c='INR';
        orItem.Flag__c  = 0;
        insert orItem;
       
         RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
          Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        RefundAPISettings__c reAPI = new RefundAPISettings__c();
        reAPI.name = 'REDBUS_COM';
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
        
    
        case ca = new case();
        ca.Transaction_ID__c = orItem.id;
        ca.issue_type__c='NEFT Refund' ;
        ca.Disbursal_Id__c='123456789';
        ca.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        ca.status = 'Open';
        insert ca;        
        
        Refund_Order_Items__c roi = new Refund_Order_Items__c();
        roi.id__c = '123456';
        roi.name = '123456';
        roi.Refund_Type__c='ONLINE';
        roi.Order_Item_ID__c = '23456';
        roi.Refunded_Amount__c= 205.0;
        roi.Order_Item_Name__c = orItem.id;
        insert roi;
        
          
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_COM';
        o1.Auth_Key__c = 'INTL';
        o1.ReBookingURL__c='testt';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        Test.setMock(HttpCalloutMock.class, new RefundAPICalloutMock());
        
        string json=' {"is_success":true,"message":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        tra.refundAPIping();
        tra.refundEnableCheck();
        tra.sendDisbursallink();
        tra.GenrateDisbursalid();
        redBusLiveDataPing.sendDisbursallinkForNewcase('123456789');
        Test.StopTest();
    }
     Static TestMethod void tryMethodTest()
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
            orItem.Email_Copy__c = 'test@redbus.com ';
            orItem.Mobile__c = '1234567891';
            orItem.Business_Unit__c = 'REDBUS_COM';
            orItem.Transaction_Source__c = 'MOBILEAPP';
            orItem.Item_Type__c = 'BUS';
            orItem.Email_Copy__c = 'Test@gmail.com';
            orItem.Mobile__c = '124521234';
            orItem.Primary_Contact_Customer__c = a.Id;
            orItem.Refund_IsSuccess__c = false;
            orItem.Amount_Recieved_Currency__c = 'INR';
            orItem.Flag__c  = 0;
            insert orItem;
            
            Refund_Order_Items__c roi = new Refund_Order_Items__c();
            roi.id__c = '123456';
            roi.name = '123456';
            roi.Refund_Type__c='ONLINE';
            roi.Order_Item_ID__c = '23456';
            roi.Order_Item_Name__c = orItem.id;
            insert roi;
            
              
      
            Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
            ApexPages.StandardController con = new ApexPages.StandardController(orItem);
            redBusLiveDataPing tra = new redBusLiveDataPing(con);
                    //tra.GenrateDisbursalid();
            Test.StopTest();

    }
    Static TestMethod void method20()
    {
        RecTypesAndStatus__c r = new RecTypesAndStatus__c();
        r.Name = 'CONFIRMATION_FAILED';
        r.Case_Type__c = 'White Failed Transaction (WFT)';
        r.Transaction_Status__c = 'CREATED';
        insert r;
        
        WFT_GFT_Business_Units__c wb = new WFT_GFT_Business_Units__c();
        wb.Name='REDBUS_IN';
        wb.Create_WFT__c = false;
        wb.Create_GFT__c = True;
        wb.Account_DOJ_Check__c = true;
        insert wb;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
          String noBUsString = System.label.GFT_Rebooking_Slab;
                List<String> noBUsList = noBUsString.split('_');
                
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Customer_Name__c = a.Id;
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_ID';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Primary_Contact_Customer__c = a.Id;
        orItem.status__c = 'CREATED';
        orItem.Date_of_Service__c = system.today();
        orItem.Order_Id__c='Test';
        orItem.Order_Item_Reference_No__c='TESTTEST';
        orItem.Total_Fare_Currency__c ='123';
        orItem.Business_Unit__c='REDBUS_IN';
        orItem.Total_Fare_Value__c =56;
        orItem.Payment_Details__c='{"id":13473197457266714,"orderId":13473197457266714,"uuid":"a78dbb03fbb9f0054c27f30c02010500","creationTime":"2023-05-15T11:21:22","businessUnit":"REDBUS_ID","orderValue":{"currencyType":"IDR","amount":529},"amountReceivable":{"currencyType":"IDR","amount":0.0},"amountPaid":{"currencyType":"IDR","amount":529},"refundableSurplus":{"currencyType":"IDR","amount":0},"paymentItemList":[{"id":13473197622403436,"orderId":13473197457266714,"uuid":"a8c8b42dfbb9f0054c27f30c04030500","refunds":null,"businessUnitValue":{"currencyType":"IDR","amount":529},"paymentItemValue":{"currencyType":"IDR","amount":529},"paymentStatus":"COMPLETED","paymentSessionId":13473197457266714,"paymentSystem":"RBOFFER","paymentSystemRefNo":"DBT","updatedBy":"","creationTime":"2023-05-15T11:21:42","pgName":"","pgtype":"","cardNo":"","bankName":"","bankAccountNumber":"","accountHolderName":"","bank_ref_num":"","itemUuids":["a78dc578fbb9f0054c27f30c01020500"],"paymentSubType":"","_meta":{"version":null,"confirm_millisecond":""}},{"id":13473197629411001,"orderId":13473197457266714,"uuid":"a8d611d7fbb9f005d93dc8e301030500","refunds":[{"reason":"gft_refund-multiple item state","updatedBy":"","refundedBy":"","refundType":"ONLINE","refundTime":1684322571083014,"refundStatus":"REFUND_CREATED","refundAmount":{"currencyType":"IDR","amount":504471},"refundCreationTime":"2023-05-17T11:22:51","refundCategory":"GFT","order_item_uuid":"b03f3ff2fbb9f00585344c3004020500","channel":"OMS","refNo":"","orderItemId":0,"index":1}],"businessUnitValue":{"currencyType":"IDR","amount":504471},"paymentItemValue":{"currencyType":"IDR","amount":504471},"paymentStatus":"COMPLETED","paymentSessionId":13473197457266714,"paymentSystem":"ONLINE","paymentSystemRefNo":"21838021","updatedBy":"CAPI","creationTime":"2023-05-15T11:21:49","pgName":"BankTransfer","pgtype":"BankTransfer","cardNo":"","bankName":"BCA","bankAccountNumber":"2063 335 002","accountHolderName":"IBIBO GROUP INDONESIA PT","bank_ref_num":"","itemUuids":null,"paymentSubType":"","_meta":{"version":null,"confirm_millisecond":""}}]}';
        
        insert orItem;
        
        Refund_Order_Items__c  rt = New Refund_Order_Items__c();
        rt.Refunded_Amount__c=123;
        rt.Refund_Type__c = 'ONLINE';
        rt.Status__c = 'REFUND_FAILURE';
        rt.PG_Name__c ='REDBUS_ADJUSTMENT';
        rt.Disbursal_ID__c ='323324434324324443543543';
        rt.Order_Item_Name__c =orItem.Id;
        insert rt;
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '112233';
        PI.id__c = '1234567';
        PI.Order_ID__c = '123456';
        PI.Order_Item_Name__c = orItem.id;
        PI.Order_Name__c = order.id;
        PI.Payment_System__c = 'MobilePG';
        insert PI;
        
        list<Livedatasyncsettings__c> listliveSyc = new list<Livedatasyncsettings__c>();
        Livedatasyncsettings__c liveSyc = new Livedatasyncsettings__c();
        liveSyc.name = 'REDBUS_IN';
        livesyc.Auth_Key__c = '123456789';
        livesyc.Channel_Name__c = 'WEB_DIRECT';
        livesyc.Country_Name__c = 'IND';
        listliveSyc.add(livesyc);
        
        Livedatasyncsettings__c liveSyc2 = new Livedatasyncsettings__c();
        liveSyc2.name = 'URL';
        livesyc2.URL__c = 'http://test.com';
        listliveSyc.add(livesyc2);
        insert listliveSyc;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.ReBookingURL__c='testt';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'BUS';
        o2.Auth_Key__c = 'BUS';
        o2.Channel_Name__c = '';
        o2.UTC_time_difference_in_min__c = 0;
        o2.ReBookingURL__c='testt';
        insert o2;
        
        Case c = new Case();
        c.Transaction_ID__c = orItem.Id;
        c.AccountId = a.Id;
        c.Customer_Name__c = a.Id;
        c.Business_Unit_ct__c='REDBUS_IN';
        c.issue_type__c='NEFT';
        Id recordTypeId1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        c.RecordTypeId = recordTypeId1;
        c.Disbursal_ID__c ='323324434324324443543543';
        insert c;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
       /* string json='{"IsSuccess":true,"ErrorMsg":"","ReferenceID":"8a33d50683e5f9971b307b87c0f86f5b"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));*/
        String jsonmm = '{'+'"IsSuccess": true'+'}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonmm));

        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        tra.refundEnable =true;
        tra.refundEnableCheck();
        
        Test.StopTest();
    }
    Static TestMethod void method21()
    {
      list<Order_Items__c> lstOrItm = new list<Order_Items__c> ();
       OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        o1.ReBookingURL__c='testt';
        insert o1;
        
        Account a = new Account();
        a.Name = 'Sample';
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
        a.RecordTypeId = recordTypeId;
        insert a;
      
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Business_Unit__c='REDBUS_IN',Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
     
         Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orderList[0].Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orderList[0]);
        redBusLiveDataPing tra = new redBusLiveDataPing(con);
        redBusLiveDataPing.Response rs = new redBusLiveDataPing.Response();
        tra.syncDataCall();
        tra.refundEnableCheck();
        Test.StopTest(); 
        
        
    }
}