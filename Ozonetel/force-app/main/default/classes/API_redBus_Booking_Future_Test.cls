@isTest()
public without sharing class API_redBus_Booking_Future_Test
{
    static testMethod void Success()
    {
        set<string> customerIds = new set<string>(); 
        set<string> custPhoneNumbers = new set<string>(); 
        list<string> custList = new list<string>();
        set<string> primaryEmails = new set<string>();
        set<string> primaryPhoneNumbers = new set<string>(); 
        set<string> orItemprimaryEmails = new set<string>(); 
        list<string> orItemcustList = new list<string>(); 
        set<string> allOrdersids = new set<string>();
        set<string> allOrderItemids = new set<string>(); 
        list<string> OrderItemFareComponentids = new list<string>(); 
        list<string> PaymentSessionIds = new list<string>(); 
        list<string> PaymentItemsIds = new list<string>(); 
        list<string> PGPaymentItemsids = new list<string>(); 
        list<string> BusOrderItemDetailsids = new list<string>(); 
        list<string> TravellerInfoIds = new list<string>(); 
        list<string> PaymentItemSessionIds = new list<string>(); 
        list<string> pgReferencePayItems = new list<string>(); 
        list<string> cancelOrderItemIds = new list<string>();
        list<string> refundIds = new list<string>();
        set<string> filterOrderIds = new set<string>();
        string DBLoagID;
        list<string> orderItemFailedPro = new list<string>();
        list<string> PaymentItemsFailedPro = new list<string>();
        list<string> OrderFailedPro = new list<string>();
        list<string> OrderItemFareComponentFailedPro = new list<string>();
        list<string> PaymentSessionFailedPro = new list<string>();
        list<string> PGPaymentItemsFailedPro = new list<string>();
        list<string> BusOrderItemDetailsFailedPro = new list<string>();
        list<string> TravellerInfoFailedPro = new list<string>();
        list<string> cancelOrderItemFailedPro = new list<string>();
        list<string> refundFailedPro = new list<string>();
        
        DBLog_Summary__c DBS = new DBLog_Summary__c();
        DBS.SentAt__c = system.now().addminutes(5);
        insert DBS;
        
        DBLoagID = string.valueof(DBS.id);
        
        DB_Log__c DB1 = new DB_Log__c();
        DB1.DBLog_Summary__c = DBS.id;
        DB1.Error_Description__c = 'test';
        DB1.ID__c = '99472429';
        DB1.Locked_record__c = true;
        DB1.Lock_type__c = 'redBus Data process';
        DB1.Object_Name__c = 'Orders';
        insert DB1;
        
        DB_Log__c DB2 = new DB_Log__c();
        DB2.DBLog_Summary__c = DBS.id;
        DB2.Error_Description__c = 'test';
        DB2.ID__c = '9837813711';
        DB2.Locked_record__c = true;
        DB2.Lock_type__c = 'redBus Data process';
        DB2.Object_Name__c = 'OrderItems';
        insert DB2;
        
        DB_Log__c DB3 = new DB_Log__c();
        DB3.DBLog_Summary__c = DBS.id;
        DB3.Error_Description__c = 'test';
        DB3.ID__c = '89635';
        DB3.Locked_record__c = true;
        DB3.Lock_type__c = 'redBus Data process';
        DB3.Object_Name__c = 'OrderItemFareComponent';
        insert DB3;
        
        DB_Log__c DB4 = new DB_Log__c();
        DB4.DBLog_Summary__c = DBS.id;
        DB4.Error_Description__c = 'test';
        DB4.ID__c = '112233';
        DB4.Locked_record__c = true;
        DB4.Lock_type__c = 'redBus Data process';
        DB4.Object_Name__c = 'PaymentSession';
        insert DB4;
        
        DB_Log__c DB5 = new DB_Log__c();
        DB5.DBLog_Summary__c = DBS.id;
        DB5.Error_Description__c = 'test';
        DB5.ID__c = '99472429';
        DB5.Locked_record__c = true;
        DB5.Lock_type__c = 'redBus Data process';
        DB5.Object_Name__c = 'PaymentItems';
        insert DB5;
        
        DB_Log__c DB6 = new DB_Log__c();
        DB6.DBLog_Summary__c = DBS.id;
        DB6.Error_Description__c = 'test';
        DB6.ID__c = '99472429';
        DB6.Locked_record__c = true;
        DB6.Lock_type__c = 'redBus Data process';
        DB6.Object_Name__c = 'PGPaymentItems';
        insert DB6;
        
        DB_Log__c DB7 = new DB_Log__c();
        DB7.DBLog_Summary__c = DBS.id;
        DB7.Error_Description__c = 'test';
        DB7.ID__c = '99472429';
        DB7.Locked_record__c = true;
        DB7.Lock_type__c = 'redBus Data process';
        DB7.Object_Name__c = 'BusOrderItemDetails';
        insert DB7;
        
        DB_Log__c DB8 = new DB_Log__c();
        DB8.DBLog_Summary__c = DBS.id;
        DB8.Error_Description__c = 'test';
        DB8.ID__c = '99472429';
        DB8.Locked_record__c = true;
        DB8.Lock_type__c = 'redBus Data process';
        DB8.Object_Name__c = 'TravellerInfo';
        insert DB8;
        
        DB_Log__c DB9 = new DB_Log__c();
        DB9.DBLog_Summary__c = DBS.id;
        DB9.Error_Description__c = 'test';
        DB9.ID__c = '99472429';
        DB9.Locked_record__c = true;
        DB9.Lock_type__c = 'redBus Data process';
        DB9.Object_Name__c = 'CancelOrderItems';
        insert DB9;
        
        DB_Log__c DB10 = new DB_Log__c();
        DB10.DBLog_Summary__c = DBS.id;
        DB10.Error_Description__c = 'test';
        DB10.ID__c = '99472429';
        DB10.Locked_record__c = true;
        DB10.Lock_type__c = 'redBus Data process';
        DB10.Object_Name__c = 'RefundOrderItems';
        insert DB10;
        
        
        OrderFailedPro = new list<string>();
        Orders__c ord2 = new Orders__c();
        ord2.name = '99472429';
        ord2.ID__c = '99472429';
        ord2.Additional_Details__c = 'test';
        ord2.Created_By__c = 'test';
        ord2.Creation_Time__c = system.now();
        ord2.Transaction_Source__c = 'WEBDIRECT';
        ord2.Updated_By__c = 'test';
        ord2.Updated_Time__c = system.now();
        ord2.Version__c =1;
        ord2.Item_Count__c =1;
        ord2.Business_Unit__c ='BUS';
        ord2.Creation_Time_Long__c = '2016245';
        ord2.Cust_Id__c = '3407679';
        ord2.Selected_Payment_Currency__c ='INR';
        ord2.status_flag__c = true;
        ord2.Cust_Details__c = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"9500797093\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord2.Guid__c ='test';
        insert ord2;
        OrderFailedPro.add(JSON.Serialize(ord2));
        
        Order_Items__c  oid2 = new Order_Items__c();
        
        oid2.name = '9837813711';
        oid2.ID__c = '9837813711';
        oid2.additional_details__c = 'test';
        oid2.created_by__c = 'test';
        oid2.creation_time__c = system.now();
        oid2.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        oid2.updated_by__c = 'test';
        oid2.updated_time__c = system.now();
        oid2.version__c = 0;
        oid2.amount_recieved_currency__c = 'INR';
        oid2.amount_recieved_value__c = 0.0;
        oid2.business_unit__c = 'REDBUS_IN';
        oid2.business_unit_conversion_currency__c = 'INR';
        oid2.business_unit_conversion_value__c = 0.0;
        oid2.cancellation_time__c = system.now();
        oid2.child_purchase_item_id__c = '';
        oid2.date_of_service__c = system.now();
        oid2.discount_currency__c = 'INR';
        oid2.discount_value__c = 0.0;
        oid2.inventory_id__c = '';
        oid2.item_type__c = 'BUS';
        oid2.order_id__c = '99472429';
        insert oid2;
        orderItemFailedPro.add(JSON.Serialize(oid2));
        
        Order_Item_Fare_Component__c oicd2 = new Order_Item_Fare_Component__c();
        oicd2.name = '89635';
        oicd2.ID__c = '99472429';
        oicd2.Item_ID__c = '9837813711';
        oicd2.Order_ID__c = '99472429';
        insert oicd2;
        OrderItemFareComponentFailedPro.add(JSON.Serialize(oicd2));
        
        Bus_Order_Item_Details__c boi1 = new Bus_Order_Item_Details__c();
        boi1.id__c = '99472429';
        insert boi1;
        BusOrderItemDetailsFailedPro.add(JSON.Serialize(boi1));
        
        Traveller_Info__c ti1 = new Traveller_Info__c();
        ti1.id__c = '99472429';
        ti1.Bus_Order_Item_Details_Id__c = '9837813711';
        insert ti1;
        TravellerInfoFailedPro.add(JSON.Serialize(ti1));
        
        Refund_Order_Items__c roi1 = new Refund_Order_Items__c();
        roi1.ID__c = '99472429';
        roi1.Order_Item_ID__c = '9837813711';
        insert roi1;
        refundFailedPro.add(JSON.Serialize(roi1));
        
        Cancelled_Order_Items__c coi1 = new Cancelled_Order_Items__c();
        coi1.ID__c = '99472429';
        coi1.Order_Item_ID__c = '9837813711';
        insert coi1;
        cancelOrderItemFailedPro.add(JSON.Serialize(coi1));
        
        Payment_Session__c PS1 = new Payment_Session__c();
        PS1.ID__c = '99472429';
        PS1.Order_ID__c = '99472429';
        insert PS1;
        PaymentSessionFailedPro.add(JSON.Serialize(PS1));
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '99472429';
        PI.ID__C = '99472429';
        insert PI;
        PaymentItemsFailedPro.add(JSON.Serialize(PI));
        
        PG_Payment_Items__c PGPI = new PG_Payment_Items__c();
        PGPI.name ='99472429';
        PGPI.id__c ='99472429';
        insert PGPI;
        PGPaymentItemsFailedPro.add(JSON.Serialize(PGPI));

        API_redBus_Booking_Future.ProcessBookingINfo(customerIds, custPhoneNumbers, custList, primaryEmails, primaryPhoneNumbers, orItemprimaryEmails, orItemcustList, allOrdersids, allOrderItemids, OrderItemFareComponentids, PaymentSessionIds, PaymentItemsIds, PGPaymentItemsids, BusOrderItemDetailsids,  TravellerInfoIds, PaymentItemSessionIds, pgReferencePayItems,cancelOrderItemIds,refundIds, filterOrderIds,DBLoagID,orderItemFailedPro,PaymentItemsFailedPro,OrderFailedPro,OrderItemFareComponentFailedPro,PaymentSessionFailedPro,PGPaymentItemsFailedPro,BusOrderItemDetailsFailedPro,TravellerInfoFailedPro,cancelOrderItemFailedPro,refundFailedPro);
    }
    static testMethod void Success2()
    {
        set<string> customerIds = new set<string>(); 
        set<string> custPhoneNumbers = new set<string>(); 
        list<string> custList = new list<string>();
        set<string> primaryEmails = new set<string>();
        set<string> primaryPhoneNumbers = new set<string>(); 
        set<string> orItemprimaryEmails = new set<string>(); 
        list<string> orItemcustList = new list<string>(); 
        set<string> allOrdersids = new set<string>();
        set<string> allOrderItemids = new set<string>(); 
        list<string> OrderItemFareComponentids = new list<string>(); 
        list<string> PaymentSessionIds = new list<string>(); 
        list<string> PaymentItemsIds = new list<string>(); 
        list<string> PGPaymentItemsids = new list<string>(); 
        list<string> BusOrderItemDetailsids = new list<string>(); 
        list<string> TravellerInfoIds = new list<string>(); 
        list<string> PaymentItemSessionIds = new list<string>(); 
        list<string> pgReferencePayItems = new list<string>(); 
        list<string> cancelOrderItemIds = new list<string>();
        list<string> refundIds = new list<string>();
        set<string> filterOrderIds = new set<string>();
        string DBLoagID;
        list<string> orderItemFailedPro = new list<string>();
        list<string> PaymentItemsFailedPro = new list<string>();
        list<string> OrderFailedPro = new list<string>();
        list<string> OrderItemFareComponentFailedPro = new list<string>();
        list<string> PaymentSessionFailedPro = new list<string>();
        list<string> PGPaymentItemsFailedPro = new list<string>();
        list<string> BusOrderItemDetailsFailedPro = new list<string>();
        list<string> TravellerInfoFailedPro = new list<string>();
        list<string> cancelOrderItemFailedPro = new list<string>();
        list<string> refundFailedPro = new list<string>();
        
        DBLog_Summary__c DBS = new DBLog_Summary__c();
        DBS.SentAt__c = system.now().addminutes(-5);
        insert DBS;
        
        DBLoagID = string.valueof(DBS.id);
        
        DB_Log__c DB1 = new DB_Log__c();
        DB1.DBLog_Summary__c = DBS.id;
        DB1.Error_Description__c = 'test';
        DB1.ID__c = '99472429';
        DB1.Locked_record__c = true;
        DB1.Lock_type__c = 'redBus Data process';
        DB1.Object_Name__c = 'Orders';
        insert DB1;
        
        DB_Log__c DB2 = new DB_Log__c();
        DB2.DBLog_Summary__c = DBS.id;
        DB2.Error_Description__c = 'test';
        DB2.ID__c = '9837813711';
        DB2.Locked_record__c = true;
        DB2.Lock_type__c = 'redBus Data process';
        DB2.Object_Name__c = 'OrderItems';
        insert DB2;
        
        DB_Log__c DB3 = new DB_Log__c();
        DB3.DBLog_Summary__c = DBS.id;
        DB3.Error_Description__c = 'test';
        DB3.ID__c = '89635';
        DB3.Locked_record__c = true;
        DB3.Lock_type__c = 'redBus Data process';
        DB3.Object_Name__c = 'OrderItemFareComponent';
        insert DB3;
        
        DB_Log__c DB4 = new DB_Log__c();
        DB4.DBLog_Summary__c = DBS.id;
        DB4.Error_Description__c = 'test';
        DB4.ID__c = '112233';
        DB4.Locked_record__c = true;
        DB4.Lock_type__c = 'redBus Data process';
        DB4.Object_Name__c = 'PaymentSession';
        insert DB4;
        
        DB_Log__c DB5 = new DB_Log__c();
        DB5.DBLog_Summary__c = DBS.id;
        DB5.Error_Description__c = 'test';
        DB5.ID__c = '99472429';
        DB5.Locked_record__c = true;
        DB5.Lock_type__c = 'redBus Data process';
        DB5.Object_Name__c = 'PaymentItems';
        insert DB5;
        
        DB_Log__c DB6 = new DB_Log__c();
        DB6.DBLog_Summary__c = DBS.id;
        DB6.Error_Description__c = 'test';
        DB6.ID__c = '99472429';
        DB6.Locked_record__c = true;
        DB6.Lock_type__c = 'redBus Data process';
        DB6.Object_Name__c = 'PGPaymentItems';
        insert DB6;
        
        DB_Log__c DB7 = new DB_Log__c();
        DB7.DBLog_Summary__c = DBS.id;
        DB7.Error_Description__c = 'test';
        DB7.ID__c = '99472429';
        DB7.Locked_record__c = true;
        DB7.Lock_type__c = 'redBus Data process';
        DB7.Object_Name__c = 'BusOrderItemDetails';
        insert DB7;
        
        DB_Log__c DB8 = new DB_Log__c();
        DB8.DBLog_Summary__c = DBS.id;
        DB8.Error_Description__c = 'test';
        DB8.ID__c = '99472429';
        DB8.Locked_record__c = true;
        DB8.Lock_type__c = 'redBus Data process';
        DB8.Object_Name__c = 'TravellerInfo';
        insert DB8;
        
        DB_Log__c DB9 = new DB_Log__c();
        DB9.DBLog_Summary__c = DBS.id;
        DB9.Error_Description__c = 'test';
        DB9.ID__c = '99472429';
        DB9.Locked_record__c = true;
        DB9.Lock_type__c = 'redBus Data process';
        DB9.Object_Name__c = 'CancelOrderItems';
        insert DB9;
        
        DB_Log__c DB10 = new DB_Log__c();
        DB10.DBLog_Summary__c = DBS.id;
        DB10.Error_Description__c = 'test';
        DB10.ID__c = '99472429';
        DB10.Locked_record__c = true;
        DB10.Lock_type__c = 'redBus Data process';
        DB10.Object_Name__c = 'RefundOrderItems';
        insert DB10;
        
        
        OrderFailedPro = new list<string>();
        Orders__c ord2 = new Orders__c();
        ord2.name = '99472429';
        ord2.ID__c = '99472429';
        ord2.Additional_Details__c = 'test';
        ord2.Created_By__c = 'test';
        ord2.Creation_Time__c = system.now();
        ord2.Transaction_Source__c = 'WEBDIRECT';
        ord2.Updated_By__c = 'test';
        ord2.Updated_Time__c = system.now();
        ord2.Version__c =1;
        ord2.Item_Count__c =1;
        ord2.Business_Unit__c ='BUS';
        ord2.Creation_Time_Long__c = '2016245';
        ord2.Cust_Id__c = '3407679';
        ord2.Selected_Payment_Currency__c ='INR';
        ord2.status_flag__c = true;
        ord2.Cust_Details__c = '{\"UserId\":43212345622,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"432133445566\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord2.Guid__c ='test';
        insert ord2;
        OrderFailedPro.add(JSON.Serialize(ord2));
        filterOrderIds.add(ord2.ID__c);
        
        Order_Items__c  oid2 = new Order_Items__c();
        
        oid2.name = '9837813711';
        oid2.ID__c = '9837813711';
        oid2.additional_details__c = 'test';
        oid2.created_by__c = 'test';
        oid2.creation_time__c = system.now();
        oid2.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        oid2.updated_by__c = 'test';
        oid2.updated_time__c = system.now();
        oid2.version__c = 0;
        oid2.amount_recieved_currency__c = 'INR';
        oid2.amount_recieved_value__c = 0.0;
        oid2.business_unit__c = 'REDBUS_IN';
        oid2.business_unit_conversion_currency__c = 'INR';
        oid2.business_unit_conversion_value__c = 0.0;
        oid2.cancellation_time__c = system.now();
        oid2.child_purchase_item_id__c = '';
        oid2.date_of_service__c = system.now();
        oid2.discount_currency__c = 'INR';
        oid2.discount_value__c = 0.0;
        oid2.inventory_id__c = '';
        oid2.item_type__c = 'BUS';
        oid2.order_id__c = '99472429';
        oid2.Mobile__c = '432133445566';
        insert oid2;
        orderItemFailedPro.add(JSON.Serialize(oid2));
        allOrderItemids.add(oid2.ID__c);
        
        Order_Item_Fare_Component__c oicd2 = new Order_Item_Fare_Component__c();
        oicd2.name = '89635';
        oicd2.ID__c = '99472429';
        oicd2.Item_ID__c = '9837813711';
        oicd2.Order_ID__c = '99472429';
        insert oicd2;
        OrderItemFareComponentFailedPro.add(JSON.Serialize(oicd2));
        OrderItemFareComponentids.add(oicd2.ID__c);
        
        Bus_Order_Item_Details__c boi1 = new Bus_Order_Item_Details__c();
        boi1.id__c = '9837813711';
        insert boi1;
        BusOrderItemDetailsFailedPro.add(JSON.Serialize(boi1));
        BusOrderItemDetailsids.add(boi1.ID__c);
        
        Traveller_Info__c ti1 = new Traveller_Info__c();
        ti1.id__c = '99472429';
        ti1.Bus_Order_Item_Details_Id__c = '9837813711';
        insert ti1;
        TravellerInfoIds.add(ti1.ID__c);
        
        TravellerInfoFailedPro.add(JSON.Serialize(ti1));
        
        Refund_Order_Items__c roi1 = new Refund_Order_Items__c();
        roi1.ID__c = '99472429';
        roi1.Order_Item_ID__c = '9837813711';
        insert roi1;
        refundFailedPro.add(JSON.Serialize(roi1));
        refundIds.add(roi1.ID__c);
        
        Cancelled_Order_Items__c coi1 = new Cancelled_Order_Items__c();
        coi1.ID__c = '99472429';
        coi1.Order_Item_ID__c = '9837813711';
        insert coi1;
        cancelOrderItemFailedPro.add(JSON.Serialize(coi1));
        cancelOrderItemIds.add(coi1.ID__c);
        
        Payment_Session__c PS1 = new Payment_Session__c();
        PS1.ID__c = '99472429';
        PS1.Order_ID__c = '99472429';
        insert PS1;
        PaymentSessionFailedPro.add(JSON.Serialize(PS1));
        PaymentSessionIds.add(PS1.ID__c);
        
        Payment_Items__c PI = new Payment_Items__c();
        PI.name = '99472429';
        PI.ID__C = '99472429';
        PI.Order_ID__c = '99472429';
        insert PI;
        PaymentItemsFailedPro.add(JSON.Serialize(PI));
        PaymentItemsIds.add(PI.ID__c);
        
        PG_Payment_Items__c PGPI = new PG_Payment_Items__c();
        PGPI.name ='99472429';
        PGPI.id__c ='99472429';
        PGPI.PG_Reference_No__c = '99472429';
        insert PGPI;
        PGPaymentItemsFailedPro.add(JSON.Serialize(PGPI));
        PGPaymentItemsids.add(PGPI.ID__c);
        
        account cust = new account();
        cust.Email_Copy__c = 'test@test.com';
        cust.PersonEmail = 'test@test.com';
        primaryEmails.add(cust.PersonEmail);
        cust.lastName = 'N/A';
        cust.User_Id__c = '123';
        customerIds.add(cust.User_Id__c);
        cust.PersonMobilePhone = '112233445566';
        custPhoneNumbers.add(cust.PersonMobilePhone);
        custList.add(JSON.Serialize(cust));
        
        account cust1 = new account();
        cust1.Email_Copy__c = 'test@test.com';
        cust1.PersonEmail = 'test@test.com';
        cust1.lastName = 'N/A';
        cust1.User_Id__c = '123';
        cust1.PersonMobilePhone = '11445566';
        insert cust1;
        
        account cust2 = new account();
        cust2.Email_Copy__c = 'test@test1.com';
        cust2.PersonEmail = 'test@test1.com';
        primaryEmails.add(cust2.PersonEmail);
        cust2.lastName = 'N/A';
        cust2.User_Id__c = '123456';
        customerIds.add(cust2.User_Id__c);
        cust2.PersonMobilePhone = '133445566';
        custPhoneNumbers.add(cust2.PersonMobilePhone);
        custList.add(JSON.Serialize(cust2));
        
        account cust3 = new account();
        cust3.Email_Copy__c = 'test@test.com';
        cust3.PersonEmail = 'test@test.com';
        cust3.lastName = 'N/A';
        cust3.PersonMobilePhone = '133445566';
        insert cust3;
        
        account cust11 = new account();
        cust11.Email_Copy__c = 'test2@test.com';
        cust11.PersonEmail = 'test2@test.com';
        orItemprimaryEmails.add(cust11.PersonEmail);
        cust11.lastName = 'N/A';
        //cust.User_Id__c = '123';
        //customerIds.add(cust.User_Id__c);
        cust11.PersonMobilePhone = '211445566';
        primaryPhoneNumbers.add(cust11.PersonMobilePhone);
        orItemcustList.add(JSON.Serialize(cust11));
        
        account cust12 = new account();
        cust12.Email_Copy__c = 'test2@test.com';
        cust12.PersonEmail = 'test2@test.com';
        cust12.lastName = 'N/A';
        cust12.User_Id__c = '123123';
        cust12.PersonMobilePhone = '211445566';
        insert cust12;
        
        account cust22 = new account();
        cust22.Email_Copy__c = 'test2@test1.com';
        cust22.PersonEmail = 'test2@test1.com';
        orItemprimaryEmails.add(cust22.PersonEmail);
        cust22.lastName = 'N/A';
        cust22.User_Id__c = '212345622';
        customerIds.add(cust22.User_Id__c);
        cust22.PersonMobilePhone = '2133445566';
        primaryPhoneNumbers.add(cust22.PersonMobilePhone);
        orItemcustList.add(JSON.Serialize(cust22));
        
        account cust32 = new account();
        cust32.Email_Copy__c = 'test2@test.com';
        cust32.PersonEmail = 'test2@test.com';
        cust32.lastName = 'N/A';
        cust32.PersonMobilePhone = '2133445566';
        insert cust32;
        
        account cust23 = new account();
        cust23.Email_Copy__c = 'test2@test1.com';
        cust23.PersonEmail = 'test2@test1.com';
        orItemprimaryEmails.add(cust23.PersonEmail);
        cust23.lastName = 'N/A';
        cust23.User_Id__c = '3212345622';
        customerIds.add(cust23.User_Id__c);
        cust23.PersonMobilePhone = '+9132133445566';
        primaryPhoneNumbers.add(cust23.PersonMobilePhone);
        orItemcustList.add(JSON.Serialize(cust23));
        
        account cust33 = new account();
        //cust33.Email_Copy__c = 'test2@test.com';
        //cust33.PersonEmail = 'test2@test.com';
        cust33.lastName = 'N/A';
        cust33.PersonMobilePhone = '+9132133445566';
        insert cust33;
        
        account cust24 = new account();
        cust24.Email_Copy__c = 'test23@test1.com';
        cust24.PersonEmail = 'test23@test1.com';
        orItemprimaryEmails.add(cust24.PersonEmail);
        cust24.lastName = 'N/A';
        //cust24.User_Id__c = '3212345622';
        customerIds.add(cust24.User_Id__c);
        cust24.PersonMobilePhone = '+91432133445566';
        primaryPhoneNumbers.add(cust24.PersonMobilePhone);
        orItemcustList.add(JSON.Serialize(cust24));
        
        account cust34 = new account();
        cust34.Email_Copy__c = 'test24@test.com';
        cust34.PersonEmail = 'test24@test.com';
        cust24.User_Id__c = '43212345622';
        cust34.lastName = 'N/A';
        cust34.PersonMobilePhone = '+91432133445566';
        insert cust34;
        
        API_redBus_Booking_Future.ProcessBookingINfo(customerIds, custPhoneNumbers, custList, primaryEmails, primaryPhoneNumbers, orItemprimaryEmails, orItemcustList, allOrdersids, allOrderItemids, OrderItemFareComponentids, PaymentSessionIds, PaymentItemsIds, PGPaymentItemsids, BusOrderItemDetailsids,  TravellerInfoIds, PaymentItemSessionIds, pgReferencePayItems,cancelOrderItemIds,refundIds, filterOrderIds,DBLoagID,orderItemFailedPro,PaymentItemsFailedPro,OrderFailedPro,OrderItemFareComponentFailedPro,PaymentSessionFailedPro,PGPaymentItemsFailedPro,BusOrderItemDetailsFailedPro,TravellerInfoFailedPro,cancelOrderItemFailedPro,refundFailedPro);
    }
}