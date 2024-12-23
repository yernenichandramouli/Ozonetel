@isTest
private class projectBlinkCtrlTest {
    @istest(SeeAllData=true)
    static void createExceptionalRefundCaseTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        insert orIt;

        Test.startTest();
        string json = '{"data": [ { "Status": "CREATED", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:54", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "TENTATIVE_SUCCESSFUL", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:55", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "CONFIRMED", "ItemType": "BUS", "Tin": "TSBM79163087", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:09:10", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "2023-10-24 14:09:10", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] } ]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.createExceptionalRefundCase(String.valueOf(orIt.Id));
        Test.stopTest();
    }

    @istest(SeeAllData=true)
    static void createExceptionalRefundCaseExceptionTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        insert orIt;

        Test.startTest();
        projectBlinkCtrl.createExceptionalRefundCase(String.valueOf(orIt.Id));
        Test.stopTest();
    }
    @istest
    static void createExceptionalRefundCaseElseTest() {
        Test.startTest();
        projectBlinkCtrl.createExceptionalRefundCase('');
        Test.stopTest();
    }

    @istest(SeeAllData=true)
    static void createExceptionalRefundCaseBadRequestTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        insert orIt;

        Test.startTest();
        string json = '{"data": [ { "Status": "CREATED", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:54", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "TENTATIVE_SUCCESSFUL", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:55", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "CONFIRMED", "ItemType": "BUS", "Tin": "TSBM79163087", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:09:10", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "2023-10-24 14:09:10", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] } ]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        projectBlinkCtrl.createExceptionalRefundCase(String.valueOf(orIt.Id));
        Test.stopTest();
    }

    @istest
    static void GetWhatsappStatusTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Mobile__c = '9591791734';
        orIt.Creation_Time__c = system.now();
        insert orIt;

        Test.startTest();
        string json = '{"isSuccess":true,"data":[{"sentAt":"09/11/2023 4:58:04 PM","deliveredAt":"09/11/2023 4:58:04 PM","readAt":"","messageTag":"MTicket_WHATSAPP","requestedat":"09/11/2023 4:57:59 PM"}],"error":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.GetWhatsappStatus(String.valueOf(orIt.Id));
        Test.stopTest();
    }
    @istest
    static void GetWhatsappStatusErrorTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Mobile__c = '9591791734';
        orIt.Creation_Time__c = system.now();
        insert orIt;

        Test.startTest();
        string json = '{"isSuccess":true,"data":[{"sentAt":"09/11/2023 4:58:04 PM","deliveredAt":"09/11/2023 4:58:04 PM","readAt":"","messageTag":"MTicket_WHATSAPP","requestedat":"09/11/2023 4:57:59 PM"}],"error":"Bad Request"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.GetWhatsappStatus(String.valueOf(orIt.Id));
        Test.stopTest();
    }

    @istest
    static void GetWhatsappStatusBadRequestTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Mobile__c = '9591791734';
        orIt.Creation_Time__c = system.now();
        insert orIt;

        Test.startTest();
        string json = '{"isSuccess":true,"data":[{"sentAt":"09/11/2023 4:58:04 PM","deliveredAt":"09/11/2023 4:58:04 PM","readAt":"","messageTag":"MTicket_WHATSAPP","requestedat":"09/11/2023 4:57:59 PM"}],"error":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'Bad Request', json));
        projectBlinkCtrl.GetWhatsappStatus(String.valueOf(orIt.Id));
        Test.stopTest();
    }

    @istest
    static void GetWhatsappStatuselseTest() {
        Test.startTest();
        projectBlinkCtrl.GetWhatsappStatus('');
        Test.stopTest();
    }

    @istest
    static void GetUserMobilenoTest() {
        Test.startTest();
        string json = '{"mobile":"1234567890","country":"India"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.GetUserMobileno('test@mail.com');
        Test.stopTest();
    }

    @istest
    static void GetUserMobilenoBadRequestTest() {
        Test.startTest();
        string json = '{"mobile":"1234567890","country":"India"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'Bad Request', json));
        projectBlinkCtrl.GetUserMobileno('test@mail.com');
        Test.stopTest();
    }

    @istest
    static void GetUserMobilenoElseTest() {
        Test.startTest();
        string json = '{"mobile":"1234567890","country":"India"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.GetUserMobileno('');
        Test.stopTest();
    }

 @istest
    static void GetTicketCancellationTest() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.Creation_Time__c = system.now();
        orIt.Business_Unit__c = 'REDBUS_IN';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Mobile__c = '9591791734';
        orIt.Creation_Time__c = system.now();
        insert orIt;

         BusinessUnitMapping__c setting = new BusinessUnitMapping__c(
            Name = 'REDBUS_IN',
            Country__c = 'IND'
            );
        insert setting;
        
        Test.startTest();
        string json ='{"data":[{"EventType":"Ticket-checkCancel","Time":"2024-03-08 20:23:43","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","MRISessionId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:24:40","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","MRISessionId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-checkCancel","Time":"2024-03-08 20:26:43","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","MRISessionId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-checkCancel","Time":"2024-03-08 20:27:53","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","MRISessionId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:29:04","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:29:04","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:29:07","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:29:08","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:00","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:00","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:03","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:03","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:06","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-08 20:30:06","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-checkCancel","Time":"2024-03-08 20:41:07","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","MRISessionId":"AM21747de5-b3f1-3e5a-89cf-07bb318edf39","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-checkCancel","Time":"2024-03-09 13:18:52","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM03a7b1e6-0082-3a2b-8f7d-efe669bf8e8f","MRISessionId":"AM37235a92-899d-333d-9b59-8bd57edfbdba","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV1","Time":"2024-03-09 13:19:39","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM03a7b1e6-0082-3a2b-8f7d-efe669bf8e8f","MRISessionId":"AM37235a92-899d-333d-9b59-8bd57edfbdba","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":true},{"EventType":"Ticket-checkCancel","Time":"2024-03-09 13:24:38","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM03a7b1e6-0082-3a2b-8f7d-efe669bf8e8f","MRISessionId":"AM37235a92-899d-333d-9b59-8bd57edfbdba","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","IsRescheduled":false},{"EventType":"Ticket-isCancellableV2","Time":"2024-03-09 13:26:05","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM03a7b1e6-0082-3a2b-8f7d-efe669bf8e8f","MRISessionId":"AM37235a92-899d-333d-9b59-8bd57edfbdba","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","SeatsToBeCancelled":"L9","TotalFare":1861.45,"RefundAmount":1502.91,"TotalPaid":1686.55,"CurrencyType":"INR","IsTicketCancellable":true},{"EventType":"Ticket-cancelTicket","Time":"2024-03-09 13:27:38","TIN":"TT4889303473","RBUserId":"49922813","MRIClientId":"AM03a7b1e6-0082-3a2b-8f7d-efe669bf8e8f","MRISessionId":"AM37235a92-899d-333d-9b59-8bd57edfbdba","Country":"IND","Channel":"MOBILE_APP","OS":"Android","Status":200,"StatusStr":"true","StatusCode":"OPERATOR_CANCELLATION_SUCCESS","ErrMsg":"","ErrCode":"","ErrDetMsg":"","CancellationType":"1","SelectedSeat":"L9","SelectedRefundType":"BACK_TO_SOURCE","RefundAmount":1502.9099999999999,"CancellationCharges":174.9,"IsRefundSuccess":true,"NeftRefundSupported":false,"CancelledAddOns":["49fdcd3c1327f0064df6863b04020100"]},{"EventType":"Ticket-refundStatus","Time":"2024-03-09 13:28:01","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","Revamp":true,"TotalPaid":1686.55,"TotalFare":1861.45,"RefundAmount":1502.91,"RefundText":""},{"EventType":"Ticket-refundStatus","Time":"2024-03-11 21:44:22","TIN":"TT4889303473","RBUserId":"","MRIClientId":"","MRISessionId":"","Country":"IND","Channel":"WEB_DIRECT","OS":"","Status":200,"StatusStr":"true","ErrMsg":"","ErrCode":"","ErrDetMsg":"","Revamp":true,"TotalPaid":1686.55,"TotalFare":1861.45,"RefundAmount":1502.91,"RefundText":""}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.getTicketCancellationEvents(String.valueOf(orIt.Id));
        Test.stopTest();
    }
    
    @istest
    static void offerTest() {
    
      Test.startTest();
        string json ='{"data":[{"Time":"2024-10-15 21:02:33","RBUserId":"33353158","MRIClientId":"AMeb775624-5397-3f4c-9624-c0db95af22ed","MRISessionId":"AM82d7c24e-cf07-30cf-a3ef-6b00fa78df61","Country":"IND","Channel":"MOBILE_APP","OS":"Android","UserType":"RETURNING","Phone":"919015606141","Email":"rohitmaurya805@gmail.com","OfferCode":"BUS300","OfferType":"DISCOUNT_CASHBACK_OFFER","OfferResp":"FAILURE","OfferMsg":"Sorry! You have already availed redbus offer code "}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        projectBlinkCtrl.getOfferEvents('IND','8884876775','TEST@gmail.com');
        Test.stopTest();
    
    }
    @isTest static void wrapperTest(){
        projectBlinkCtrl.responseReult wrap = New projectBlinkCtrl.responseReult();
        wrap.Status='Test';
        wrap.ItemType='Test';
        wrap.Tin='Test';
        wrap.OrderId='Test';
        wrap.OrderUUID='Test';
        wrap.OrderItemId='Test';
        wrap.ItemUUID='Test';
        wrap.TimeOfEvent='Test';
        wrap.DateOfIssue='Test';
        wrap.DateOfJourney='Test';
        wrap.DepartureTime='Test';
        wrap.ArrivalTime='Test';
        wrap.PrimaryBoardingTime='Test';
        wrap.PrimaryDroppingPointTime='Test';
        wrap.BoardingTime='Test';
        wrap.DroppingTime='Test';
        wrap.ConfirmationTime='Test';
        wrap.Name='Test';
        wrap.Mobile='Test';
        wrap.EmailId='Test';
        wrap.UserSelectedDate='Test';
        wrap.ServiceProviderName='Test';
        wrap.BusType='Test';
        wrap.SourceLocation='Test';
        wrap.SrcLocationName='Test';
        wrap.DestinationLocation='Test';
        wrap.DstLocationName='Test';
        wrap.DepartureLandmark='Test';
        wrap.StartingLocation='Test';
        wrap.BoardingPoint='Test';
        wrap.BoardingGridPoint='Test';
        wrap.BoardingPointLandmark='Test';
        wrap.DroppingPoint='Test';
        wrap.TotalOrderItems=2;
        wrap.ReschedulingFor='Test';
        wrap.OldItemReferenceNo='Test';
        wrap.JourneyType='Test';
        wrap.BusinessUnit='Test';
        wrap.SalesChannel='Test';
        wrap.PurchaseItemCurrency='Test';
        wrap.SubItemsCount=2;
        wrap.TicketFare=2;
        wrap.BaseFare=2;
        wrap.ServiceTax=2;
        wrap.TransactionCharge=2;
        wrap.RescheduleCharge=2;
        wrap.SeatCount=2;
    }

}