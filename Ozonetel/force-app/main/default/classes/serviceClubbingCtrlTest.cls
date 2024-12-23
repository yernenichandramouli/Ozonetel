@isTest
private class serviceClubbingCtrlTest {
    @isTest static void testMethod1(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        orit.isShifted__c = true;
        orIt.Historic_Details__c = '{"busShiftHistory":[{"updatedDetails":{"updatedDateOfJourney":"2022-09-28T10:53:00","ticketDetails":{"departurePointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestDPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"boardingPointDetails":{"time":"2022-10-20T09:50:00","location":{"lon":789,"lat":212},"landMark":"TestBPLand","country":"India","contactNos":["8310742798","7676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}}},"serviceProviderName":"Service123","seatDetails":[{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"seatType1","seatName":"3","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":5.0,"trueValue":5.0,"refundableValue":5.0,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]},{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"seatType2","seatName":"4","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":5.0,"trueValue":5.0,"refundableValue":5.0,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]}],"routeId":"3333","cancellationReferenceTime":"2022-09-28T10:53:00","busType":"SEATER","boardingTime":"2022-09-28T10:53:00","boardingPoint":"Marathalli"},"updateTime":"2022-09-28T05:17:23","prevDetails":{"ticketDetails":{"departurePointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestDPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"boardingPointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestBPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}}},"serviceProviderName":"Test Domestic Travel","seatDetails":[{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"SLEEPER","seatName":"1","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":5.0,"trueValue":5.0,"refundableValue":5.0,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]},{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"SLEEPER","seatName":"2","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":5.0,"trueValue":5.0,"refundableValue":5.0,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]}],"routeId":"9999","cancellationReferenceTime":"2022-10-20T09:50:00","busType":"testBusType","boardingTime":"2022-10-20T09:50:00","boardingPoint":"HAL"}}]}';
        // orIt.Historic_Details__c = '{"busShiftHistory":[{"updatedDetails":{"updatedDateOfJourney":"2022-09-28T10:53:00","ticketDetails":{"departurePointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestDPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"boardingPointDetails":{"time":"2022-10-20T09:50:00","location":{"lon":789,"lat":212},"landMark":"TestBPLand","country":"India","contactNos":["8310742798","7676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}}},"serviceProviderName":"Service123","seatDetails":[{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"seatType1","seatName":"3","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":2,"trueValue":2,"refundableValue":2,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]},{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"seatType2","seatName":"4","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":2,"trueValue":2,"refundableValue":2,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]}],"routeId":"3333","cancellationReferenceTime":"2022-09-28T10:53:00","busType":"SEATER","boardingTime":"2022-09-28T10:53:00","boardingPoint":"Marathalli"},"updateTime":"2022-09-28T05:17:23","prevDetails":{"ticketDetails":{"departurePointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestDPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"boardingPointDetails":{"time":"2022-10-20T09:50:00","landMark":"TestBPLand","contactNos":["+918310742798","+917676128874"],"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}}},"serviceProviderName":"Test Domestic Travel","seatDetails":[{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"SLEEPER","seatName":"1","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":2,"trueValue":2,"refundableValue":2,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]},{"travellerDetailsVO":{"title":"Miss.","proofId":"ABCD1234","name":"Ashwini","mobileNo":"+918310742798","issuingAuthority":"ElectionCommission","idProofType":"PAN","gender":"FEMALE","email":"as@redbus.com","dateOfBirth":"1997-05-07","alternateNumber":"+917676128874","age":25,"address":{"state":"Karnataka","pincode":"560008","country":"India","city":"Bangalore","addressLine2":"CaddressLine2","addressLine1":"CaddressLine1"}},"seatType":"SLEEPER","seatName":"2","isPartiallyCancellable":true,"customerPriceBreakUp":[{"value":100,"refundableValue":100,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"},{"value":2,"trueValue":2,"refundableValue":2,"isCancellationPolicyApplicable":false,"componentName":"SERVICE_TAX"}]}],"routeId":"9999","cancellationReferenceTime":"2022-10-20T09:50:00","busType":"testBusType","boardingTime":"2022-10-20T09:50:00","boardingPoint":"HAL"}}]}';
        insert orIt;
        serviceClubbingCtrl.getBusShiftDetails(orIt.Id);
    }

    @isTest static void wrapperTestMethod(){
        serviceClubbingCtrl.Address addWrapperTest = new serviceClubbingCtrl.Address();
        addWrapperTest.state='Test State';
        addWrapperTest.pincode='Test Pincode';
        addWrapperTest.country='Test Country';
        addWrapperTest.city='Test City';
        addWrapperTest.addressLine1='Test AddressLine1';
        addWrapperTest.addressLine2='Test AddressLine2';

        serviceClubbingCtrl.Location locationWrapperTest = new serviceClubbingCtrl.Location();
        locationWrapperTest.lon = 1;
        locationWrapperTest.lat = 23;

        serviceClubbingCtrl.BoardingPointDetails bpWrapperTest = new serviceClubbingCtrl.BoardingPointDetails();
        bpWrapperTest.boardingtime = System.now();
        bpWrapperTest.location = locationWrapperTest;
        bpWrapperTest.landMark = 'Test landMark';
        bpWrapperTest.country = 'Test country';
        bpWrapperTest.address = addWrapperTest;

        serviceClubbingCtrl.CustomerPriceBreakUp custPriceWrapperTest = new serviceClubbingCtrl.CustomerPriceBreakUp();
        custPriceWrapperTest.value = 1.23;
        custPriceWrapperTest.refundableValue = 1.23;
        custPriceWrapperTest.isCancellationPolicyApplicable = true;
        custPriceWrapperTest.componentName='Test City';
        custPriceWrapperTest.trueValue = 1.23;

        serviceClubbingCtrl.DeparturePointDetails departureWrapperTest = new serviceClubbingCtrl.DeparturePointDetails();
        departureWrapperTest.departuretime = System.now();
        departureWrapperTest.address = addWrapperTest;

        serviceClubbingCtrl.PrevDetails prevWrapperTest = new serviceClubbingCtrl.PrevDetails();
        prevWrapperTest.serviceProviderName='Test City';
        prevWrapperTest.routeId='Test City';
        prevWrapperTest.cancellationReferenceTime = System.now();
        prevWrapperTest.busType = 'Test City';
        prevWrapperTest.boardingTime = System.now();
        prevWrapperTest.boardingPoint = 'Test City';

        serviceClubbingCtrl.TravellerDetailsVO travelWrapperTest = new serviceClubbingCtrl.TravellerDetailsVO();
        travelWrapperTest.title = 'Test City';
        travelWrapperTest.proofId = 'Test City';
        travelWrapperTest.name = 'Test City';
        travelWrapperTest.mobileNo = 'Test City';
        travelWrapperTest.issuingAuthority = 'Test City';
        travelWrapperTest.idProofType = 'Test City';
        travelWrapperTest.gender = 'Test City';
        travelWrapperTest.email = 'Test City';
        travelWrapperTest.dateOfBirth = 'Test City';
        travelWrapperTest.alternateNumber = 'Test City';
        travelWrapperTest.age = 2;
        travelWrapperTest.address = addWrapperTest;

        serviceClubbingCtrl.SeatDetail SeatDetailWrapperTest = new serviceClubbingCtrl.SeatDetail();
        SeatDetailWrapperTest.travellerDetailsVO=travelWrapperTest;
        SeatDetailWrapperTest.seatType='Test City';
        SeatDetailWrapperTest.seatName='Test City';
        SeatDetailWrapperTest.isPartiallyCancellable = true;

        serviceClubbingCtrl.TicketDetails TicketDetailsWrapperTest = new serviceClubbingCtrl.TicketDetails();
        TicketDetailsWrapperTest.departurePointDetails=departureWrapperTest;
        TicketDetailsWrapperTest.boardingPointDetails=bpWrapperTest;

        serviceClubbingCtrl.UpdatedDetails UpdatedDetailsWrapperTest = new serviceClubbingCtrl.UpdatedDetails();
        UpdatedDetailsWrapperTest.updatedDateOfJourney = System.now();
        UpdatedDetailsWrapperTest.ticketDetails = TicketDetailsWrapperTest;
        UpdatedDetailsWrapperTest.serviceProviderName='Test City';
        UpdatedDetailsWrapperTest.routeId='Test City';
        UpdatedDetailsWrapperTest.cancellationReferenceTime = System.now();
        UpdatedDetailsWrapperTest.busType='Test City';
        UpdatedDetailsWrapperTest.boardingTime = System.now();
        UpdatedDetailsWrapperTest.boardingPoint='Test City';
    }
}