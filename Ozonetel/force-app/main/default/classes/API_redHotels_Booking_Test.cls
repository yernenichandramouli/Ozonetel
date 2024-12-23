@isTest()
public without sharing class API_redHotels_Booking_Test
{
    static testMethod void SuccessTest()
    {
     Test.startTest();
        
        string jsonBody='{"type":"BOOKING","sentAt":"2018-01-03T08:04:00.9291325Z","hotels":[{"email":"nikethvj@gmail.com","phone":"9986684330","hotel_name":"The Ritz-Carlton, Bangalore","orderId":2789720,"orderItemId":6681024,"checkInDate":"2017-12-29T00:00:00","checkOutDate":"2017-12-30T00:00:00","checkInTime":"12:30","checkOutTime":"1200","pax":{"Item1":1,"Item2":"2","Item3":null},"destination":"Bangalore","paidAmount":17084.00000,"discountAmount":2500.0,"offerCodeUsed":"HOTELFIRST","status":"CONFIRMED","dateOfBooking":"2017-12-27T00:00:00","operationType":"UPDATE"},{"email":"drk_mech@yahoo.co.in","phone":"9177205205","hotel_name":"Hotel Picnic","orderId":2814456,"orderItemId":6760098,"checkInDate":"2018-01-07T00:00:00","checkOutDate":"2018-01-08T00:00:00","checkInTime":"10:23 Hours","checkOutTime":"10:45 Hours","pax":{"Item1":1,"Item2":"2","Item3":"1"},"destination":"Velankanni","paidAmount":1325.00000,"discountAmount":520.0,"offerCodeUsed":"RBHOTELS70","status":"CANCELLATION_COMPLETED","dateOfBooking":"2017-12-29T00:00:00","operationType":"UPDATE"}]}';        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/redHotel_Booking';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        API_redHotels_Booking.doPost();
     Test.stopTest();
     }
     
     static testMethod void FailTest()
    {
     Test.startTest();
        
        string jsonBody='{"type":"BOOKING","sentAt":"2018-01-03T08:04:00.9291325Z","hotels":[{"email":"nikethvj@gmail.com","phone":"9986684330","hotel_name":"The Ritz-Carlton, Bangalore","orderId":2789720,"orderItemId":6681024,"checkInDate":"2017-12-29T00:00:00","checkOutDate":"2017-12-30T00:00:00","checkInTime":"12","checkOutTime":"1200","pax":{"Item1":1,"Item2":"2","Item3":null},"destination":"Bangalore","paidAmount":17084.00000,"discountAmount":2500.0,"offerCodeUsed":"HOTELFIRST","status":"CONFIRMED","dateOfBooking":"2017-12-27T00:00:00","operationType":"UPDATE"},{"email":"drk_mech@yahoo.co.in","phone":"9177205205","hotel_name":"Hotel Picnic","orderId":2814456,"orderItemId":6760098,"checkInDate":"2018-01-07T00:00:00","checkOutDate":"2018-01-08T00:00:00","checkInTime":"10:23 Hours","checkOutTime":"10:45 Hours","pax":{"Item1":1,"Item2":"2","Item3":"1"},"destination":"Velankanni","paidAmount":1325.00000,"discountAmount":520.0,"offerCodeUsed":"RBHOTELS70","status":"CANCELLATION_COMPLETED","dateOfBooking":"2017-12-29T00:00:00","operationType":"UPDATE"}]}';        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/redHotel_Booking';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        API_redHotels_Booking.doPost();
     Test.stopTest();
     }
 }