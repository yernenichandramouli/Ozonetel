@isTest()
public without sharing class API_redBus_Booking_Test
{
    static testMethod void Success()
    {
        ordersData ord = new ordersData();
        list<ordersData> listOrd = new list<ordersData>();
        ord.id = '99472429';
        ord.additional_details = 'test';
        ord.created_by = 'test';
        ord.creation_time = '2016-09-01 15:23:35';
        ord.transaction_source = 'WEBDIRECT';
        ord.updated_by = 'test';
        ord.updated_time ='2016-09-01 15:23:35';
        ord.version =1;
        ord.item_count =1;
        ord.business_unit='BUS';
        ord.creation_time_long =2016245;
        ord.cust_id = '3407679';
        ord.selected_payment_currency ='INR';
        ord.status_flag = true;
        ord.cust_details = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"9500797093\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord.guid ='test';
        ord.operationType ='UPDATE';
        listOrd.add(ord);
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = '98378137';
        oid.additional_details = 'test';
        oid.created_by = 'test';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = 'test';
        oid.updated_time = '2016-09-01 17:37:27';
        oid.version = 0;
        oid.amount_recieved_currency = 'INR';
        oid.amount_recieved_value = '';
        oid.business_unit = 'BUS';
        oid.business_unit_conversion_currency = 'INR';
        oid.business_unit_conversion_value = 0.0;
        oid.cancellation_time = '';
        oid.child_purchase_item_id = '';
        oid.date_of_service = '2016-09-09 00:00:00';
        oid.discount_currency = 'INR';
        oid.discount_value = '';
        oid.inventory_id = '';
        oid.item_type = 'BUS';
        oid.order_id = 99492420;
        oid.order_item_reference_no = '';
        oid.payment_currency = '';
        oid.parent_purchase_item_id = '';
        oid.primary_passenger_id = 112411946;
        oid.purchase_item_currency = 'INR';
        oid.service_provider_id = '0';
        oid.service_provider_name = 'testesttest';
        oid.status = 'TRANSACTION_CREATE_PO_COMPLETE';
        oid.sub_item_count = 0;
        oid.tentative_key = 'RBMOBILE::7195ab7123d644c89304f0c429a82ed2|8213640|2016-09-09';
        oid.total_fare_currency = 'INR';
        oid.total_fare_value = 795.0;
        oid.total_tax_currency = 'INR';
        oid.total_tax_value = 0;
        oid.service_provider_reference_no = '';
        oid.creation_time_long = 2016245;
        oid.date_of_service_long = 2016253;
        oid.conversionRate = '';
        oid.markupValue = '';
        oid.inventory_type = '';
        oid.conversion_info = '';
        oid.email = 'delvindavid.98@gmail.com';
        oid.mobile = '919538604400';
        oid.receivable_amount_value = 795.0;
        oid.receivable_amount_currency = 'INR';
        oid.view_details = '';
        oid.date_of_purchase = '2016-09-01 17:37:31';
        oid.guid = '';
        oid.tentative_details = '';
        oid.rb_user_Id = '';
        oid.client_ip = '';
        oid.cancellation_policy = '';
        oid.old_order_item_reference_no = '';
        oid.spot_cancel_time_minutes = '';
        oid.is_return = false;
        oid.transaction_charge = '0.0';
        oid.support_action = 'Rebook';
        oid.total_fare_paid_to_operator = 663.75;
        oid.exp_time = '2016-09-01 17:57:31';
        oid.is_partial_cancellation_allowed = false;
        oid.operator_cancellation_charges = '';
        oid.force_cancelled = false;
        oid.live_operator_force_cancel_status = '';
        oid.agent_ip = '';
        oid.operationType = 'UPDATE';
        
        ListOid.add(oid);
        
        orderItemFareComponentsData oicd = new orderItemFareComponentsData();
        list<orderItemFareComponentsData> listOicd = new list<orderItemFareComponentsData>();
        oicd.id = '89635';
        oicd.additional_details = '';
        oicd.created_by = '';
        oicd.creation_time = '2016-08-10T09:19:29';
        oicd.transaction_source = '';
        oicd.updated_by = '';
        oicd.updated_time = '2016-08-10T09:19:29';
        oicd.version = '0';
        oicd.fare_component_subtype = 'BASE_FARE';
        oicd.fare_component_type = 'FARE';
        oicd.fare_component_currency = 'SGD';
        oicd.fare_component_value = 299.00000;
        oicd.item_id = '29556738';
        oicd.order_id = '270923';
        oicd.sub_item_id = '';
        oicd.creation_time_public = '';
        oicd.fare_component_status = 'ACTIVE';
        oicd.guid = '';
        oicd.operationType = 'UPDATE';
        listOicd.add(oicd);
        
        paymentItemsData pid = new paymentItemsData();
        list<paymentItemsData> ListPid = new list<paymentItemsData>();
        
        pid.id = '83593551';
        pid.additional_details = '';
        pid.created_by = '';
        pid.creation_time = '2016-09-01 17:39:35';
        pid.transaction_source = 'RB:MOBILEWEB#droidapp';
        pid.updated_by = 'moinkhan';
        pid.updated_time = '2016-09-01 18:05:14';
        pid.version = '';
        pid.business_unit_currency = 'INR';
        pid.business_unit_value = '';
        pid.amount_payable_currency = 'INR';
        pid.amount_payable_value = '795.0';
        pid.order_id = '99492420';
        pid.payment_status = 'COMPLETED';
        pid.payment_session_id = '18795';
        pid.payment_system = 'MobilePG';
        pid.payment_system_ref_no = '';
        pid.settled_currency = 'INR';
        pid.settled_value = '';
        pid.settlement_time = '';
        pid.creation_time_public = '2016245';
        pid.settlement_time_public = '';
        pid.is_reconceiled = '';
        pid.commission = '';
        pid.payment_type = '14';
        pid.is_complete = 'true';
        pid.guid = '';
        pid.operationType = 'UPDATE';
        ListPid.add(pid);
        
        paymentSessionsData psd = new paymentSessionsData();
        list<paymentSessionsData> ListPsd = new list<paymentSessionsData>();
        psd.id = '18795';
        psd.additional_details = '';
        psd.created_by = '2016-08-10T09:19:29';
        psd.transaction_source = '';
        psd.updated_by = '';
        psd.updated_time = '2016-08-10T09:19:29';
        psd.version = '2';
        psd.amount_payable_currency = '';
        psd.amount_payable_value = '';
        psd.business_unit = 'REDBUS_SG';
        psd.discount_currency = '';
        psd.discount_value = '';
        psd.order_id = '270923';
        psd.payment_currency = '';
        psd.payment_value = '';
        psd.status = '';
        psd.amount_paid_currency = 'SGD';
        psd.amount_paid_value = '0.00000';
        psd.amount_receivable_currency = 'SGD';
        psd.amount_receivable_value = '299.00000';
        psd.order_value_currency = 'SGD';
        psd.creation_time_public = '';
        psd.guid = '';
        psd.operationType = 'UPDATE';
        ListPsd.add(psd);
        
        pgPaymentItemsData pgpid = new pgPaymentItemsData();
        list<pgPaymentItemsData> ListPgpid = new list<pgPaymentItemsData>();
        pgpid.id = '81963151';
        pgpid.amount_currency = 'INR';
        pgpid.amount_value = '795.0';
        pgpid.bank_name = '';
        pgpid.card_no = '';
        pgpid.pg_name = 'PaaS';
        pgpid.pg_reference_no = '83593551';
        pgpid.pg_type = 'MobilePG';
        pgpid.status = '';
        pgpid.guid = '';
        pgpid.operationType = 'UPDATE';
        ListPgpid.add(pgpid);
        
        travellerInfoData tid = new travellerInfoData();
        list<travellerInfoData> ListTid = new list<travellerInfoData>();
        tid.id = '112411946';
        tid.additional_details = '';
        tid.created_by = '';
        tid.creation_time = '';
        tid.transaction_source = '';
        tid.updated_by = '';
        tid.updated_time = '';
        tid.version = '';
        tid.city = '';
        tid.country = '';
        tid.postalCode = '';
        tid.state = '';
        tid.age = '20';
        tid.alternate_mobile_no = '';
        tid.dateOfBirth = '2016-09-09 20:10:00';
        tid.email_id = 'rk9031517059@gmail.com';
        tid.gender = 'male';
        tid.issuing_authority = '';
        tid.mobile_no = '919835517914';
        tid.name_on_proof = 'Jitendra Kumar';
        tid.passenger_name = 'Jitendra Kumar';
        tid.passenger_type = '';
        tid.proof_id = '';
        tid.proof_type = '';
        tid.title = '';
        tid.creation_time_public = '';
        tid.address = '';
        tid.addressLine1 = '';
        tid.addressLine2 = '';
        tid.addressLine3 = '';
        tid.guid = '';
        tid.operationType = '';
        ListTid.add(tid);
        
        busOrderItemDetailsData boidd = new busOrderItemDetailsData();
        list<busOrderItemDetailsData> ListBoidd = new list<busOrderItemDetailsData>();
        boidd.id = '98378137';
        boidd.boarding_point = 'Manipal. Near Petrol Bunk';
        boidd.boarding_point_id = '1106201';
        boidd.boarding_time = '2016-09-09 20:10:00';
        boidd.bus_type = 'A/C Sleeper (2+1)';
        boidd.destination_city = 'Bangalore';
        boidd.destination_id = '122';
        boidd.item_details = '[{\"travellerInfoId\":112411946,\"seatName\":\"29\",\"seatType\":null,\"seatFare\":null,\"additionalTax\":null,\"refunableAmount\":null,\"mealType\":null,\"isMealOpted\":false,\"isMealAvailable\":false}]';
        boidd.primary_boarding_time = '2016-09-09 20:10:00';
        boidd.route_id = '8213640';
        boidd.source_city = 'Manipal';
        boidd.source_id = '155';
        boidd.starting_location = 'hyd';
        boidd.starting_location_id = '144';
        boidd.ticket_details = '{\"dateOfJourney\":[2016,9,9,0,0],\"boardingPointDetails\":{\"address\":{\"addressLine1\":\"Manipal. Near Petrol Bunk\",\"addressLine2\":null,\"city\":null,\"state\":null,\"country\":null,\"pincode\":null},\"landMark\":null,\"time\":\"9/9/2016 8:10:00 PM\",\"contactNos\":[]},\"departurePointDetails\":{\"address\":{\"addressLine1\":\"Manipal. Near Petrol Bunk\",\"addressLine2\":null,\"city\":null,\"state\":null,\"country\":null,\"pincode\":null},\"landMark\":null,\"time\":\"9/9/2016 8:10:00 PM\",\"contactNos\":[]}}';
        boidd.dropping_point = 'bangalore';
        boidd.dropping_point_id = '123';
        boidd.refund_status = '';
        boidd.operationType = 'UPDATE';
        ListBoidd.add(boidd);
        
        cancelledOrderItemsData coid = new cancelledOrderItemsData();
        list<cancelledOrderItemsData> listCoid = new list<cancelledOrderItemsData>();
        coid.operationType = 'INSERT';
        coid.id = '32768';
        coid.additional_details = '';
        coid.created_by = '';
        coid.creation_time = '2016-06-30 12:56:14';
        coid.transaction_source = 'WEBDIRECT';
        coid.updated_by = '';
        coid.updated_time = '2016-06-30 12:57:10';
        coid.version = '1';
        coid.order_item_reference_no = 'SG166U2891143';
        coid.order_item_id = '1935732';
        coid.status = 'CANCELLATION_COMPLETED';
        coid.service_provider_reference_no = '68T1427737#1064135714|SRT052';
        coid.seates_to_be_cancelled = '';
        coid.total_fare_currency = 'SGD';
        coid.total_fare_value = '1.09770';
        coid.total_tax_currency = 'MYR';
        coid.total_tax_value = '0.00000';
        coid.operator_cancellation_status = 'OPERATOR_CANCELLATION_SUCCESS';
        coid.cancellation_reference_no = 'SG166U2891143CNR123';
        coid.business_unit = 'REDBUS_SG';
        coid.cancellation_time = '2016-06-30 12:56:14';
        coid.primary_passenger_id = '310377';
        coid.service_provider_id = '15092';
        coid.service_provider_name = 'Transnasional';
        coid.date_of_purchase = '2016-06-30 12:57:10';
        coid.guid = '';
        coid.creation_time_long = '2016182';
        coid.cancellation_reason = 'This is for Testing';
        coid.order_id = '252361';
        coid.client_ip = '10.11.12';
        ListCoid.add(coid);
        
        refundOrderItemsData roid = new refundOrderItemsData();
        list<refundOrderItemsData> ListRoid = new list<refundOrderItemsData>();
        roid.operationType = 'INSERT';
        roid.id = '1';
        roid.additional_details = '';
        roid.created_by = '';
        roid.creation_time = '2016-06-30 12:57:13';
        roid.transaction_source = 'WEBDIRECT';
        roid.updated_by = '';
        roid.updated_time = '2016-06-30 12:58:36';
        roid.version = '1';
        roid.status = 'REFUNDED';
        roid.refund_reason = 'This is for Testing';
        roid.customer_name = 'Test';
        roid.mobile_no = '919019411236';
        roid.email_id = 'shankarnath.reddy@redbus.in';
        roid.refund_for_tin = 'SG166U2891143';
        roid.refund_type = 'ONLINE';
        roid.order_item_id = '1935732';
        roid.payment_item_id = '1641137';
        roid.pg_name = 'Braintree';
        roid.pg_reference_no = 'm7txk8hg';
        roid.pg_type = 'CreditCard';
        roid.bank_name = '';
        roid.card_no = '';
        roid.creation_time_long = '2016182';
        roid.guid = '';
        
        listRoid.add(roid);
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        bdata.orders = listOrd;
        bdata.orderItems = ListOid;
        bdata.orderItemFareComponents = listOicd;
        bdata.paymentItems = ListPid;
        bdata.paymentSessions = ListPsd;
        bdata.pgPaymentItems = ListPgpid;
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        bdata.cancelledOrderItems = ListCoid;
        bdata.refundOrderItems = listRoid;
        
        String JsonMsg=JSON.serialize(bdata);
        
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
        
    }
    static testMethod void Fail()
    {
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof('test');
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
    }
    static testMethod void Success2()
    {
        Bus_Order_Item_Details__c boi1 = new Bus_Order_Item_Details__c();
        boi1.id__c = '9837813711';
        insert boi1;
        
        Traveller_Info__c ti1 = new Traveller_Info__c();
        ti1.id__c = '112233';
        ti1.Bus_Order_Item_Details_Id__c = '9837813711';
        insert ti1;
        
        Refund_Order_Items__c roi1 = new Refund_Order_Items__c();
        roi1.ID__c = '112233';
        roi1.Order_Item_ID__c = '9837813711';
        insert roi1;
        
        Cancelled_Order_Items__c coi1 = new Cancelled_Order_Items__c();
        coi1.ID__c = '112233';
        coi1.Order_Item_ID__c = '9837813711';
        insert coi1;
        
        Payment_Session__c PS1 = new Payment_Session__c();
        PS1.ID__c = '112233';
        PS1.Order_ID__c = '99472429';
        insert PS1;
        
        Order_Item_Fare_Component__c oicd2 = new Order_Item_Fare_Component__c();
        oicd2.name = '89635';
        oicd2.ID__c = '89635';
        /*oicd.additional_details = '';
        oicd.created_by = '';
        oicd.creation_time = '2016-08-10T09:19:29';
        oicd.transaction_source = '';
        oicd.updated_by = '';
        oicd.updated_time = '2016-08-10T09:19:29';
        oicd.version = '0';
        oicd.fare_component_subtype = 'BASE_FARE';
        oicd.fare_component_type = 'FARE';
        oicd.fare_component_currency = 'SGD';
        oicd.fare_component_value = 299.00000;*/
        oicd2.Item_ID__c = '9837813711';
        oicd2.Order_ID__c = '99472429';
        /*
        oicd.sub_item_id = '';
        oicd.creation_time_public = '';
        oicd.fare_component_status = 'ACTIVE';
        oicd.guid = '';
        oicd.operationType = 'UPDATE';
        listOicd.add(oicd);*/
        insert oicd2;
        
        Payment_Items__c pid2 = new Payment_Items__c();
        pid2.name = '83593551';
        pid2.id__c = '83593551';
        /*pid.additional_details = '';
        pid.created_by = '';
        pid.creation_time = '2016-09-01 17:39:35';
        pid.transaction_source = 'RB:MOBILEWEB#droidapp';
        pid.updated_by = 'moinkhan';
        pid.updated_time = '2016-09-01 18:05:14';
        pid.version = '';
        pid.business_unit_currency = 'INR';
        pid.business_unit_value = '';
        pid.amount_payable_currency = 'INR';
        pid.amount_payable_value = '795.0';*/
        pid2.order_id__c = '99472429';
        pid2.Payment_Status__c = 'COMPLETED';
        pid2.Payment_Session_ID__c = '18795';
       /* pid.payment_system = 'MobilePG';
        pid.payment_system_ref_no = '';
        pid.settled_currency = 'INR';
        pid.settled_value = '';
        pid.settlement_time = '';
        pid.creation_time_public = '2016245';
        pid.settlement_time_public = '';
        pid.is_reconceiled = '';
        pid.commission = '';
        pid.payment_type = '14';
        pid.is_complete = 'true';
        pid.guid = '';
        pid.operationType = 'UPDATE';
        ListPid.add(pid); */
        insert pid2;
        
        Payment_Session__c psd2 = new Payment_Session__c();
        psd2.name = '18795';
        psd2.id__c = '18795';
        psd2.additional_details__c = '';
        psd2.created_by__c = '';
        psd2.transaction_source__c = '';
        psd2.updated_by__c = '';
        psd2.updated_time__c = system.now();
        psd2.version__c = 2.0;
        psd2.amount_payable_currency__c = '';
        //psd2.amount_payable_value__c = '';
        psd2.business_unit__c = 'REDBUS_SG';
        //psd2.discount_currency__c = '';
        //psd2.discount_value__c = '';
        psd2.order_id__c = '99472429';
        /*psd.payment_currency = '';
        psd.payment_value = '';
        psd.status = '';
        psd.amount_paid_currency = 'SGD';
        psd.amount_paid_value = '0.00000';
        psd.amount_receivable_currency = 'SGD';
        psd.amount_receivable_value = '299.00000';
        psd.order_value_currency = 'SGD';
        psd.creation_time_public = '';
        psd.guid = '';
        psd.operationType = 'UPDATE';
        ListPsd.add(psd); */
        insert psd2;
        
        PG_Payment_Items__c pgpid2 = new PG_Payment_Items__c();
        pgpid2.name = '81963151';
        pgpid2.id__c = '81963151';
        /*pgpid.amount_currency = 'INR';
        pgpid.amount_value = '795.0';
        pgpid.bank_name = '';
        pgpid.card_no = '';*/
        pgpid2.pg_name__c = 'PaaS';
        pgpid2.pg_reference_no__c = '83593551';
        pgpid2.pg_type__c = 'MobilePG';
        /*pgpid.status = '';
        pgpid.guid = '';
        pgpid.operationType = 'UPDATE';
        ListPgpid.add(pgpid);*/
        insert pgpid2;
         
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
        
        ordersData ord = new ordersData();
        list<ordersData> listOrd = new list<ordersData>();
        ord.id = '99472429';
        ord.additional_details = 'test';
        ord.created_by = 'test';
        ord.creation_time = '2016-09-01 15:23:35';
        ord.transaction_source = 'WEBDIRECT';
        ord.updated_by = 'test';
        ord.updated_time ='2016-09-01 15:23:35';
        ord.version =1;
        ord.item_count =1;
        ord.business_unit='REDBUS_IN';
        ord.creation_time_long =2016245;
        ord.cust_id = '3407679';
        ord.selected_payment_currency ='INR';
        ord.status_flag = true;
        ord.cust_details = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"9500797093\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord.guid ='test';
        ord.operationType ='UPDATE';
        listOrd.add(ord);
        
     /*   Order_Items__c  oid2 = new Order_Items__c();
        
        oid2.name = '9837813711';
        oid2.ID__c = '9837813711';
        oid2.additional_details = 'test';
        oid2.created_by__c = 'test';
        oid2.creation_time__c = '2016-09-01 17:37:27';
        oid2.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        oid2.updated_by__c = 'test';
        oid2.updated_time__c = '2016-09-01 17:37:27';
        oid2.version__c = 0;
        oid2.amount_recieved_currency__c = 'INR';
        oid2.amount_recieved_value__c = '';
        oid2.business_unit__c = 'REDBUS_IN';
        oid2.business_unit_conversion_currency__c = 'INR';
        oid2.business_unit_conversion_value__c = 0.0;
        oid2.cancellation_time__c = '';
        oid2.child_purchase_item_id__c = '';
        oid2.date_of_service__c = system.now();
        oid2.discount_currency__c = 'INR';
        oid2.discount_value__c = '';
        oid2.inventory_id__c = '';
        oid2.item_type__c = 'BUS'; 
        
        oid2.Order_Id__c = '99472429';
        oid2.order_item_reference_no = '';
        oid2.payment_currency = '';
        oid2.parent_purchase_item_id = '';
        oid2.primary_passenger_id = 112411946;
        oid2.purchase_item_currency = 'INR';
        oid2.service_provider_id = '0';
        oid2.service_provider_name = 'testesttest';
        oid2.status = 'TRANSACTION_CREATE_PO_COMPLETE';
        oid2.sub_item_count = 0;
        oid2.tentative_key = 'RBMOBILE::7195ab7123d644c89304f0c429a82ed2|8213640|2016-09-09';
        oid2.total_fare_currency = 'INR';
        oid2.total_fare_value = 795.0;
        oid2.total_tax_currency = 'INR';
        oid2.total_tax_value = 0;
        oid2.service_provider_reference_no = '';
        oid2.creation_time_long = 2016245;
        oid2.date_of_service_long = 2016253;
        oid2.conversionRate = '';
        oid2.markupValue = '';
        oid2.inventory_type = '';
        oid2.conversion_info = '';
        oid2.email = 'delvindavid.98@gmail.com';
        oid2.mobile = '919538604400';
        oid2.receivable_amount_value = 795.0;
        oid2.receivable_amount_currency = 'INR';
        oid2.view_details = '';
        oid2.date_of_purchase = '2016-09-01 17:37:31';
        oid2.guid = '';
        oid2.tentative_details = '';
        oid2.rb_user_Id = '';
        oid2.client_ip = '';
        oid2.cancellation_policy = '';
        oid2.old_order_item_reference_no = '';
        oid2.spot_cancel_time_minutes = '';
        oid2.is_return = false;
        oid2.transaction_charge = '0.0';
        oid2.support_action = 'Rebook';
        oid2.total_fare_paid_to_operator = 663.75;
        oid2.exp_time = '2016-09-01 17:57:31';
        oid2.is_partial_cancellation_allowed = false;
        oid2.operator_cancellation_charges = '';
        oid2.force_cancelled = false;
        oid2.live_operator_force_cancel_status = '';
        oid2.agent_ip = '';
        oid2.operationType = 'UPDATE';*/
        
        //insert oid2;
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = '9837813711';
        oid.additional_details = 'test';
        oid.created_by = 'test';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = 'test';
        oid.updated_time = '2016-09-01 17:37:27';
        oid.version = 0;
        oid.amount_recieved_currency = 'INR';
        oid.amount_recieved_value = '';
        oid.business_unit = 'REDBUS_IN';
        oid.business_unit_conversion_currency = 'INR';
        oid.business_unit_conversion_value = 0.0;
        oid.cancellation_time = '';
        oid.child_purchase_item_id = '';
        oid.date_of_service = '2016-09-09 00:00:00';
        oid.discount_currency = 'INR';
        oid.discount_value = '';
        oid.inventory_id = '';
        oid.item_type = 'BUS';
        oid.order_id = 99472429;
        oid.order_item_reference_no = '';
        oid.payment_currency = '';
        oid.parent_purchase_item_id = '';
        oid.primary_passenger_id = 112411946;
        oid.purchase_item_currency = 'INR';
        oid.service_provider_id = '0';
        oid.service_provider_name = 'testesttest';
        oid.status = 'TRANSACTION_CREATE_PO_COMPLETE';
        oid.sub_item_count = 0;
        oid.tentative_key = 'RBMOBILE::7195ab7123d644c89304f0c429a82ed2|8213640|2016-09-09';
        oid.total_fare_currency = 'INR';
        oid.total_fare_value = 795.0;
        oid.total_tax_currency = 'INR';
        oid.total_tax_value = 0;
        oid.service_provider_reference_no = '';
        oid.creation_time_long = 2016245;
        oid.date_of_service_long = 2016253;
        oid.conversionRate = '';
        oid.markupValue = '';
        oid.inventory_type = '';
        oid.conversion_info = '';
        oid.email = 'delvindavid.98@gmail.com';
        oid.mobile = '919538604400';
        oid.receivable_amount_value = 795.0;
        oid.receivable_amount_currency = 'INR';
        oid.view_details = '';
        oid.date_of_purchase = '2016-09-01 17:37:31';
        oid.guid = '';
        oid.tentative_details = '';
        oid.rb_user_Id = '';
        oid.client_ip = '';
        oid.cancellation_policy = '';
        oid.old_order_item_reference_no = '';
        oid.spot_cancel_time_minutes = '';
        oid.is_return = false;
        oid.transaction_charge = '0.0';
        oid.support_action = 'Rebook';
        oid.total_fare_paid_to_operator = 663.75;
        oid.exp_time = '2016-09-01 17:57:31';
        oid.is_partial_cancellation_allowed = false;
        oid.operator_cancellation_charges = '';
        oid.force_cancelled = false;
        oid.live_operator_force_cancel_status = '';
        oid.agent_ip = '';
        oid.operationType = 'UPDATE';
        
        ListOid.add(oid);
        
        orderItemFareComponentsData oicd = new orderItemFareComponentsData();
        list<orderItemFareComponentsData> listOicd = new list<orderItemFareComponentsData>();
        oicd.id = '89635';
        oicd.additional_details = '';
        oicd.created_by = '';
        oicd.creation_time = '2016-08-10T09:19:29';
        oicd.transaction_source = '';
        oicd.updated_by = '';
        oicd.updated_time = '2016-08-10T09:19:29';
        oicd.version = '0';
        oicd.fare_component_subtype = 'BASE_FARE';
        oicd.fare_component_type = 'FARE';
        oicd.fare_component_currency = 'SGD';
        oicd.fare_component_value = 299.00000;
        oicd.item_id = '99472429';
        oicd.order_id = '99472429';
        oicd.sub_item_id = '';
        oicd.creation_time_public = '';
        oicd.fare_component_status = 'ACTIVE';
        oicd.guid = '';
        oicd.operationType = 'UPDATE';
        listOicd.add(oicd);
        
        
        
        
        paymentItemsData pid = new paymentItemsData();
        list<paymentItemsData> ListPid = new list<paymentItemsData>();
        
        pid.id = '83593551';
        pid.additional_details = '';
        pid.created_by = '';
        pid.creation_time = '2016-09-01 17:39:35';
        pid.transaction_source = 'RB:MOBILEWEB#droidapp';
        pid.updated_by = 'moinkhan';
        pid.updated_time = '2016-09-01 18:05:14';
        pid.version = '';
        pid.business_unit_currency = 'INR';
        pid.business_unit_value = '';
        pid.amount_payable_currency = 'INR';
        pid.amount_payable_value = '795.0';
        pid.order_id = '99492420';
        pid.payment_status = 'COMPLETED';
        pid.payment_session_id = '18795';
        pid.payment_system = 'MobilePG';
        pid.payment_system_ref_no = '';
        pid.settled_currency = 'INR';
        pid.settled_value = '';
        pid.settlement_time = '';
        pid.creation_time_public = '2016245';
        pid.settlement_time_public = '';
        pid.is_reconceiled = '';
        pid.commission = '';
        pid.payment_type = '14';
        pid.is_complete = 'true';
        pid.guid = '';
        pid.operationType = 'UPDATE';
        ListPid.add(pid);
        
        
        
        paymentSessionsData psd = new paymentSessionsData();
        list<paymentSessionsData> ListPsd = new list<paymentSessionsData>();
        psd.id = '18795';
        psd.additional_details = '';
        psd.created_by = '2016-08-10T09:19:29';
        psd.transaction_source = '';
        psd.updated_by = '';
        psd.updated_time = '2016-08-10T09:19:29';
        psd.version = '2';
        psd.amount_payable_currency = '';
        psd.amount_payable_value = '';
        psd.business_unit = 'REDBUS_SG';
        psd.discount_currency = '';
        psd.discount_value = '';
        psd.order_id = '270923';
        psd.payment_currency = '';
        psd.payment_value = '';
        psd.status = '';
        psd.amount_paid_currency = 'SGD';
        psd.amount_paid_value = '0.00000';
        psd.amount_receivable_currency = 'SGD';
        psd.amount_receivable_value = '299.00000';
        psd.order_value_currency = 'SGD';
        psd.creation_time_public = '';
        psd.guid = '';
        psd.operationType = 'UPDATE';
        ListPsd.add(psd);
        
        pgPaymentItemsData pgpid = new pgPaymentItemsData();
        list<pgPaymentItemsData> ListPgpid = new list<pgPaymentItemsData>();
        pgpid.id = '81963151';
        pgpid.amount_currency = 'INR';
        pgpid.amount_value = '795.0';
        pgpid.bank_name = '';
        pgpid.card_no = '';
        pgpid.pg_name = 'PaaS';
        pgpid.pg_reference_no = '83593551';
        pgpid.pg_type = 'MobilePG';
        pgpid.status = '';
        pgpid.guid = '';
        pgpid.operationType = 'UPDATE';
        ListPgpid.add(pgpid);
        
        travellerInfoData tid = new travellerInfoData();
        list<travellerInfoData> ListTid = new list<travellerInfoData>();
        tid.id = '112411946';
        tid.BusOrderItemDetailsId = '9837813711';
        tid.additional_details = '';
        tid.created_by = '';
        tid.creation_time = '';
        tid.transaction_source = '';
        tid.updated_by = '';
        tid.updated_time = '';
        tid.version = '';
        tid.city = '';
        tid.country = '';
        tid.postalCode = '';
        tid.state = '';
        tid.age = '20';
        tid.alternate_mobile_no = '';
        tid.dateOfBirth = '2016-09-09 20:10:00';
        tid.email_id = 'rk9031517059@gmail.com';
        tid.gender = 'male';
        tid.issuing_authority = '';
        tid.mobile_no = '919835517914';
        tid.name_on_proof = 'Jitendra Kumar';
        tid.passenger_name = 'Jitendra Kumar';
        tid.passenger_type = '';
        tid.proof_id = '';
        tid.proof_type = '';
        tid.title = '';
        tid.creation_time_public = '';
        tid.address = '';
        tid.addressLine1 = '';
        tid.addressLine2 = '';
        tid.addressLine3 = '';
        tid.guid = '';
        tid.operationType = '';
        ListTid.add(tid);
        
        busOrderItemDetailsData boidd = new busOrderItemDetailsData();
        list<busOrderItemDetailsData> ListBoidd = new list<busOrderItemDetailsData>();
        boidd.id = '9837813711';
        boidd.boarding_point = 'Manipal. Near Petrol Bunk';
        boidd.boarding_point_id = '1106201';
        boidd.boarding_time = '2016-09-09 20:10:00';
        boidd.bus_type = 'A/C Sleeper (2+1)';
        boidd.destination_city = 'Bangalore';
        boidd.destination_id = '122';
        boidd.item_details = '[{\"travellerInfoId\":112411946,\"seatName\":\"29\",\"seatType\":null,\"seatFare\":null,\"additionalTax\":null,\"refunableAmount\":null,\"mealType\":null,\"isMealOpted\":false,\"isMealAvailable\":false}]';
        boidd.primary_boarding_time = '2016-09-09 20:10:00';
        boidd.route_id = '8213640';
        boidd.source_city = 'Manipal';
        boidd.source_id = '155';
        boidd.starting_location = 'hyd';
        boidd.starting_location_id = '144';
        boidd.ticket_details = '{\"dateOfJourney\":[2016,9,9,0,0],\"boardingPointDetails\":{\"address\":{\"addressLine1\":\"Manipal. Near Petrol Bunk\",\"addressLine2\":null,\"city\":null,\"state\":null,\"country\":null,\"pincode\":null},\"landMark\":null,\"time\":\"9/9/2016 8:10:00 PM\",\"contactNos\":[]},\"departurePointDetails\":{\"address\":{\"addressLine1\":\"Manipal. Near Petrol Bunk\",\"addressLine2\":null,\"city\":null,\"state\":null,\"country\":null,\"pincode\":null},\"landMark\":null,\"time\":\"9/9/2016 8:10:00 PM\",\"contactNos\":[]}}';
        boidd.dropping_point = 'bangalore';
        boidd.dropping_point_id = '123';
        boidd.refund_status = '';
        boidd.operationType = 'UPDATE';
        ListBoidd.add(boidd);
        
        cancelledOrderItemsData coid = new cancelledOrderItemsData();
        list<cancelledOrderItemsData> listCoid = new list<cancelledOrderItemsData>();
        coid.operationType = 'INSERT';
        coid.id = '32768';
        coid.additional_details = '';
        coid.created_by = '';
        coid.creation_time = '2016-06-30 12:56:14';
        coid.transaction_source = 'WEBDIRECT';
        coid.updated_by = '';
        coid.updated_time = '2016-06-30 12:57:10';
        coid.version = '1';
        coid.order_item_reference_no = 'SG166U2891143';
        coid.order_item_id = '9837813711';
        coid.status = 'CANCELLATION_COMPLETED';
        coid.service_provider_reference_no = '68T1427737#1064135714|SRT052';
        coid.seates_to_be_cancelled = '';
        coid.total_fare_currency = 'SGD';
        coid.total_fare_value = '1.09770';
        coid.total_tax_currency = 'MYR';
        coid.total_tax_value = '0.00000';
        coid.operator_cancellation_status = 'OPERATOR_CANCELLATION_SUCCESS';
        coid.cancellation_reference_no = 'SG166U2891143CNR123';
        coid.business_unit = 'REDBUS_SG';
        coid.cancellation_time = '2016-06-30 12:56:14';
        coid.primary_passenger_id = '310377';
        coid.service_provider_id = '15092';
        coid.service_provider_name = 'Transnasional';
        coid.date_of_purchase = '2016-06-30 12:56:14';
        coid.guid = '';
        coid.creation_time_long = '2016182';
        coid.cancellation_reason = 'This is for Testing';
        coid.order_id = '252361';
        coid.client_ip = '10.11.12';
        ListCoid.add(coid);
        
        refundOrderItemsData roid = new refundOrderItemsData();
        list<refundOrderItemsData> ListRoid = new list<refundOrderItemsData>();
        roid.operationType = 'INSERT';
        roid.id = '1';
        roid.additional_details = '';
        roid.created_by = '';
        roid.creation_time = '2016-06-30 12:57:13';
        roid.transaction_source = 'WEBDIRECT';
        roid.updated_by = '';
        roid.updated_time = '2016-06-30 12:58:36';
        roid.version = '1';
        roid.status = 'REFUNDED';
        roid.refund_reason = 'This is for Testing';
        roid.customer_name = 'Test';
        roid.mobile_no = '919019411236';
        roid.email_id = 'shankarnath.reddy@redbus.in';
        roid.refund_for_tin = 'SG166U2891143';
        roid.refund_type = 'ONLINE';
        roid.order_item_id = '9837813711';
        roid.payment_item_id = '1641137';
        roid.pg_name = 'Braintree';
        roid.pg_reference_no = 'm7txk8hg';
        roid.pg_type = 'CreditCard';
        roid.bank_name = '';
        roid.card_no = '';
        roid.creation_time_long = '2016182';
        roid.guid = '';
        
        listRoid.add(roid);
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        bdata.orders = listOrd;
        bdata.orderItems = ListOid;
        bdata.orderItemFareComponents = listOicd;
        bdata.paymentItems = ListPid;
        bdata.paymentSessions = ListPsd;
        bdata.pgPaymentItems = ListPgpid;
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        bdata.cancelledOrderItems = ListCoid;
        bdata.refundOrderItems = listRoid;
        
        String JsonMsg=JSON.serialize(bdata);
        
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
        
    }
    public class bookingData
    {
        string type;
        string sentAt;
        list<ordersData> orders;
        list<orderItemsData> orderItems;
        list<orderItemFareComponentsData> orderItemFareComponents;
        list<paymentItemsData> paymentItems;
        list<paymentSessionsData> paymentSessions;
        list<pgPaymentItemsData> pgPaymentItems;
        list<travellerInfoData> travellerInfo;
        list<busOrderItemDetailsData> busOrderItemDetails;
        list<cancelledOrderItemsData> cancelledOrderItems;
        list<refundOrderItemsData> refundOrderItems;
        public bookingData()
        {
            
        }
    }
    public class ordersData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        integer version;
        integer item_count;
        string business_unit;
        integer creation_time_long;
        string cust_id;
        string selected_payment_currency;
        string guid;
        boolean status_flag;
        string cust_details;
        public ordersData()
        {
        
        }
    }
    public class orderItemsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        integer version;
        string amount_recieved_currency;
        string amount_recieved_value;
        string business_unit;
        string business_unit_conversion_currency;
        decimal business_unit_conversion_value;
        string cancellation_time;
        string child_purchase_item_id;
        string date_of_service;
        string discount_currency;
        string discount_value;
        string inventory_id;
        string item_type;
        integer order_id;
        string order_item_reference_no;
        string parent_purchase_item_id;
        string payment_currency;
        integer primary_passenger_id;
        string purchase_item_currency;
        string service_provider_id;
        string service_provider_name;
        string status;
        integer sub_item_count;
        string tentative_key;
        string total_fare_currency;
        decimal total_fare_value;
        string total_tax_currency;
        decimal total_tax_value;
        string service_provider_reference_no;
        integer creation_time_long;
        integer date_of_service_long;
        string conversionRate;
        string markupValue;
        string inventory_type;
        string conversion_info;
        string email; 
        string mobile;
        decimal receivable_amount_value;
        string receivable_amount_currency;
        string view_details; 
        string date_of_purchase;
        string guid;
        string tentative_details;
        string rb_user_Id; 
        string client_ip;
        string cancellation_policy;
        string old_order_item_reference_no;
        string spot_cancel_time_minutes; 
        string agent_ip;
        boolean is_return;
        string transaction_charge;
        string support_action;
        decimal total_fare_paid_to_operator;
        string exp_time;
        boolean is_partial_cancellation_allowed;
        string operator_cancellation_charges;
        boolean force_cancelled;
        string live_operator_force_cancel_status;
        public orderItemsData()
        {
        
        }
    }
    public class orderItemFareComponentsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string fare_component_subtype;
        string fare_component_type;
        string fare_component_currency;
        decimal fare_component_value;
        string item_id;
        string order_id;
        string sub_item_id;
        string creation_time_public;
        string creation_time_long;
        string fare_component_status;
        string guid;
        public orderItemFareComponentsData()
        {
            
        }
    }
    public class paymentItemsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string business_unit_currency;
        string business_unit_value;
        string amount_payable_currency;
        string amount_payable_value;
        string order_id;
        string payment_status;
        string payment_session_id;
        string payment_system;
        string payment_system_ref_no;
        string settled_currency;
        string settled_value;
        string settlement_time;
        string creation_time_public;
        string creation_time_long;
        string settlement_time_long;
        string has_discrepancy;
        string is_reconceiled;
        string settlement_time_public;
        string guid;
        string commission;
        string payment_type;
        string is_complete;
        public paymentItemsData()
        {
        
        }
    }
    
    public class paymentSessionsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string amount_payable_currency;
        string amount_payable_value;
        string business_unit;
        string discount_currency;
        string discount_value;
        string order_id;
        string payment_currency;
        string payment_value;
        string status;
        string amount_paid_currency;
        string amount_paid_value;
        string amount_receivable_currency;
        string amount_receivable_value;
        string order_value_currency;
        string order_value;
        string creation_time_long;
        string guid;
        string creation_time_public;
        public paymentSessionsData()
        {
        
        }
    }
    public class pgPaymentItemsData
    {
        string operationType;
        string amount_currency;
        string amount_value;
        string bank_name;
        string card_no;
        string pg_name;
        string pg_reference_no;
        string pg_type;
        string status;
        string id;
        string guid;
        public pgPaymentItemsData()
        {
            
        }
    }
    
    public class travellerInfoData
    {
        string operationType;
        string id;
        string BusOrderItemDetailsId;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string city;
        string country;
        string postalCode;
        string state;
        string age;
        string alternate_mobile_no;
        string dateOfBirth;
        string email_id;
        string gender;
        string issuing_authority;
        string mobile_no;
        string name_on_proof;
        string passenger_name;
        string passenger_type;
        string proof_id;
        string proof_type;
        string title;
        string creation_time_long;
        string address;
        string addressLine1;
        string addressLine2;
        string addressLine3;
        string guid;
        string creation_time_public;
        
        public travellerInfoData()
        {
        
        }
    }
    
    public class busOrderItemDetailsData
    {
        string operationType;
        string boarding_point;
        string boarding_point_id;
        string boarding_time;
        string bus_type;
        string destination_city;
        string destination_id;
        string item_details;
        string primary_boarding_time;
        string route_id;
        string source_city;
        string source_id;
        string starting_location;
        string starting_location_id;
        string id;
        string ticket_details;
        string dropping_point;
        string dropping_point_id;
        string refund_status;
        
        public busOrderItemDetailsData()
        {
        
        }
    }
    public class cancelledOrderItemsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string order_item_reference_no;
        string order_item_id;
        string status;
        string service_provider_reference_no;
        string seates_to_be_cancelled;
        string total_fare_currency;
        string total_fare_value;
        string total_tax_currency;
        string total_tax_value;
        string operator_cancellation_status;
        string cancellation_reference_no;
        string business_unit;
        string cancellation_time;
        string primary_passenger_id;
        string service_provider_id;
        string service_provider_name;
        string date_of_purchase;
        string guid;
        string creation_time_long;
        string cancellation_reason;
        string order_id;
        string client_ip;
        public cancelledOrderItemsData()
        {
            
        }
    }
    public class refundOrderItemsData
    {
        string operationType;
        string id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        string version;
        string status;
        string refund_reason;
        string customer_name;
        string mobile_no;
        string email_id;
        string refund_for_tin;
        string refund_type;
        string order_item_id;
        string payment_item_id;
        string pg_name;
        string pg_reference_no;
        string pg_type;
        string bank_name;
        string card_no;
        string creation_time_long;
        string guid;
        public refundOrderItemsData()
        {
            
        }
    }
}