/**
* (c) 2017 RedBus
*
* Name           : SyncAPICntrlTest
* Created Date   : 18 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Test class for SyncAPICntrl class
*
**/

@isTest
private class SyncAPICntrlTest
{
    @isTest static void testSyncAPI() 
    {
        SyncAPICntrl sync = new SyncAPICntrl();
        sync.addToQueue();       
        sync.ordId ='6525XY55';
        sync.addToQueue();
        
        ApexPages.currentpage().getParameters().put('id','6525XY55');
        SyncPollingCntrl syncPoll = new SyncPollingCntrl();
        syncPoll.searchOrder();
        
        Orders__c ord = new Orders__c();
        ord.Name = '6525XY55';
        insert ord;
        
        Test.startTest();
        syncPoll.searchOrder();
        //recId = ApexPages.currentPage().getParameters().get('id');

        ApexPages.currentPage().getParameters().put('emailId','test@redbus.com');
        ApexPages.currentPage().getParameters().put('phone','9167523229');
        ApexPages.currentPage().getParameters().put('isConole','Yes');
        
          
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        account acc= new account();
        acc.name='test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert acc;
        UserTripsCntrl obj = new UserTripsCntrl(new ApexPages.StandardController(acc));
        ApexPages.currentPage().getParameters().put('id',acc.id);
        UserTripsCntrl ustr = new UserTripsCntrl();
        ustr.userDetReq='test';
        ustr.userResp='resp';
        ustr.fetchUserTrips();
        UserTripsCntrl userTrip = new UserTripsCntrl();
        userTrip.searchUserTrips();
        userTrip.emailId = 'test@redbus.com';
        userTrip.region = 'IND';
        userTrip.searchUserTrips();
        ApexPages.currentpage().getParameters().put('ordId2','6525Y55');
        userTrip.searchOrder();
        userTrip.searchB2BTin();
        ApexPages.currentpage().getParameters().put('ordId2','6525XY55');
        userTrip.searchOrder();
        ApexPages.currentpage().getParameters().put('ordId2','6525XY55');
        ApexPages.currentpage().getParameters().put('hasPayment','Yes');
        userTrip.searchOrder();
        ApexPages.currentpage().getParameters().put('ordId2','6525XY55');
        ApexPages.currentpage().getParameters().put('hasPayment','No');
        userTrip.searchOrder();
        Test.stopTest();
        
    }
    
    static testMethod void missingCodecoverage(){
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        SyncAPICntrl sync= new SyncAPICntrl();
        sync.ordId='123456';
        sync.tin='122344';
        sync.hotelSync();
        UserTripsCntrl ustr = new UserTripsCntrl();
        UserTripsCntrl.UserTripsResponse tripResp =new UserTripsCntrl.UserTripsResponse();
        UserTripsCntrl.bookingsWrapper wrapResp =new UserTripsCntrl.bookingsWrapper();
        tripResp.tin='1234';
        tripResp.transactionNo='1234';
        tripResp.cartId='1234';
        tripResp.status='open';
        tripResp.dateOfJourney='1234';
        tripResp.source='tvt';
        tripResp.destination='peru';
        tripResp.travels='rbk';
        tripResp.pnr='123409876';
        tripResp.seats='34';
        tripResp.userId='rb1234'; 
        tripResp.emailId='test@gmail.com'; 
        tripResp.phone='rb1234'; 
        tripResp.creationDate='rb1234';
        tripResp.trainName='example';
        tripResp.trainNo='123';
        tripResp.hasPayment=True;
           
        wrapResp.source='ongole'; 
        wrapResp.destination='vijayawada'; 
        wrapResp.travels='tvtk'; 
        wrapResp.busType='AC'; 
        wrapResp.fare='123'; 
        wrapResp.doj='TODAY'; 
        wrapResp.arrivalTime='6 PM'; 
        wrapResp.source='ongole'; 
        wrapResp.departureTime='8 PM'; 
        wrapResp.tin='ongole'; 
        wrapResp.status='open'; 
        
        ustr.tin='45673778';
        ustr.region = 'IND';
        ustr.emailId='';
        ustr.PhoneNo='';
        ustr.tripid='';
        ustr.searchUserTrips();        
    }
    static testMethod void rechargeOrder(){
        SyncAPICntrl sync = new SyncAPICntrl();
        sync.rcordId ='1841545';
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        sync.syncOldRecharge();
    }
    
    public static testMethod void B2BUserTripsTest(){
     Test.startTest();
        UserTripsCntrl ustr = new UserTripsCntrl();
        ustr.region = 'Amazon';
        ustr.PhoneNo='9898787898';
        //ustr.tin='test123';
        Continuation conti = (Continuation)ustr.SearchB2BTrips();
        HttpResponse response = new HttpResponse();
        string responseBody='{ "bookings": [{ "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 5.30, "doj": 1564515720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84YQC3P2", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TNSTC (1430BANCHE)", "busType": null, "fare": 495.00, "doj": 1564563600000, "arrivalTime": 1350, "departureTime": 900, "tin": "84Z47NVF", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 8.46, "doj": 1565811000000, "arrivalTime": 780, "departureTime": 60, "tin": "84HJYHTJ", "status": "BOOKED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "SPG Travels (7)", "busType": null, "fare": 400.00, "doj": 1565107800000, "arrivalTime": 1710, "departureTime": 1370, "tin": "844YZXGT", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "Bharathi Travels (491)", "busType": null, "fare": 577.50, "doj": 1565109000000, "arrivalTime": 1650, "departureTime": 1325, "tin": "84GSR53T", "status": "CANCELLED" }, { "source": "Jammu", "destination": "Katra ", "travels": "JKSRTC (6)", "busType": null, "fare": 93.00, "doj": 1565089200000, "arrivalTime": 1110, "departureTime": 990, "tin": "84B79EF6", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "Bharathi Travels (363)", "busType": null, "fare": 550.00, "doj": 1565740800000, "arrivalTime": 675, "departureTime": 370, "tin": "84XJ8FCV", "status": "BOOKED" }, { "source": "Chennai", "destination": "Aluva", "travels": "TESTING ACCOUNT", "busType": null, "fare": 15.00, "doj": 1565159400000, "arrivalTime": 2220, "departureTime": 720, "tin": "84J9Z2FX", "status": "BOOKED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.24, "doj": 1565811720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84MDNKVM", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "845TCA9Y", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "84TRMXJB", "status": "CANCELLED" }, { "source": "Jamnagar", "destination": "Rajkot", "travels": "Samay travels (45057)", "busType": null, "fare": 500.00, "doj": 1565456400000, "arrivalTime": 1454, "departureTime": 1393, "tin": "845764R4", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.24, "doj": 1566330120000, "arrivalTime": 1680, "departureTime": 72, "tin": "84DCNTTB", "status": "CANCELLED" }, { "source": "Lucknow", "destination": "Delhi", "travels": "Uttar Pradesh State Road Transport Corporation(UPSRTC) (85371)", "busType": null, "fare": 564.00, "doj": 1565634600000, "arrivalTime": null, "departureTime": 0, "tin": "84JE6NV6", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "84NXC638", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Hyderabad", "travels": "VRL Travels (812623)", "busType": null, "fare": 1260.00, "doj": 1565712000000, "arrivalTime": 1765, "departureTime": 1215, "tin": "84H9FHGA", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.23, "doj": 1566156600000, "arrivalTime": 780, "departureTime": 60, "tin": "8496AE8M", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 6.36, "doj": 1564947720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84RH5CMJ", "status": "BOOKED" }, { "source": "Chennai", "destination": "Bangalore", "travels": "TESTING ACCOUNT", "busType": null, "fare": 9.45, "doj": 1566635400000, "arrivalTime": 1500, "departureTime": 840, "tin": "94P53FTR", "status": "BOOKED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 6.36, "doj": 1565096100000, "arrivalTime": 1101, "departureTime": 1105, "tin": "94ZEJ7F9", "status": "CANCELLED" } ] }';
        response.setBody(responseBody);
        Test.setContinuationResponse(ustr.utripsReq, response);
        Object result = Test.invokeContinuationMethod(ustr, conti);
        UserTripsCntrl usr = new UserTripsCntrl();
        usr.tin='test123';
        usr.EnableB2B();
        usr.SearchB2BTrips();
        usr.processUserTripsResponse();
        Test.stopTest();
        
    }
    
    public static testMethod void B2BExistUserTripsTest(){
     Test.startTest();
        UserTripsCntrl ustr = new UserTripsCntrl();
        ustr.tin='test123';
         Test.stopTest();
         ustr.EnableB2B();
         ustr.SearchB2BTrips();
         ustr.processUserTripsResponse();
        }
}