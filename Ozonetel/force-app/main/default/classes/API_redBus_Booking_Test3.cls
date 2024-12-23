@isTest()
public without sharing class API_redBus_Booking_Test3
{
    static testMethod void Success1()
    {
        account ac =new account();
        ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '1122334455';
        ac.LastName = 'test';
        insert ac;
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = 98378137;
        oid.additional_details = '';
        oid.created_by = '';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = '';
        oid.updated_time = '';
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
        oid.mobile = '1122334455';
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
        tid.mobile_no = '1122334455';
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
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        
        bdata.orderItems = ListOid;
        
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        
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

    static testMethod void Success2()
    {
        account ac =new account();
        //ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '1122334455';
        ac.LastName = 'test';
        insert ac;
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = 98378137;
        oid.additional_details = '';
        oid.created_by = '';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = '';
        oid.updated_time = '';
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
        oid.mobile = '1122334455';
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
        tid.mobile_no = '1122334455';
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
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        
        bdata.orderItems = ListOid;
        
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        
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
    static testMethod void Success3()
    {
        account ac =new account();
        //ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '1122334455';
        ac.LastName = 'test';
        ac.User_Id__c = '4261556';
        insert ac;
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = 98378137;
        oid.additional_details = '';
        oid.created_by = '';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = '';
        oid.updated_time = '';
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
        oid.mobile = '1122334455';
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
        tid.mobile_no = '1122334455';
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
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        
        bdata.orderItems = ListOid;
        
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        
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
    static testMethod void Success4()
    {
        account ac =new account();
        ac.PersonEmail = 'test@test2.com';
        ac.PersonMobilePhone = '112233445566';
        ac.LastName = 'test';
        ac.User_Id__c = '4261556';
        insert ac;
        
        account ac1 =new account();
        ac1.PersonEmail = 'test@test.com';
        ac1.PersonMobilePhone = '1122334455';
        ac1.LastName = 'test';
        ac1.Parent_Account__c = ac.id;
        //ac.User_Id__c = '4261556';
        insert ac1;
        
        contact cc = new contact();
        cc.lastname ='test';
        cc.email = 'rk9031517059@gmail.com';
        cc.Account_name__c = ac.id;
        insert cc;
        
        orderItemsData  oid = new orderItemsData();
        list<orderItemsData> ListOid = new list<orderItemsData>();
        
        oid.id = 98378137;
        oid.additional_details = '';
        oid.created_by = '';
        oid.creation_time = '2016-09-01 17:37:27';
        oid.transaction_source = 'RB:MOBILEWEB#droidapp';
        oid.updated_by = '';
        oid.updated_time = '';
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
        oid.mobile = '1122334455';
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
        tid.mobile_no = '1122334455';
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
        
        bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        
        bdata.orderItems = ListOid;
        
        bdata.travellerInfo = ListTid;
        bdata.busOrderItemDetails = ListBoidd;
        
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
    public class bookingData
    {
        string type;
        string sentAt;
        list<orderItemsData> orderItems;
        list<travellerInfoData> travellerInfo;
        list<busOrderItemDetailsData> busOrderItemDetails;
        public bookingData()
        {
            
        }
    }
    public class travellerInfoData
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
    
    public class orderItemsData
    {
        string operationType;
        integer id;
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
}