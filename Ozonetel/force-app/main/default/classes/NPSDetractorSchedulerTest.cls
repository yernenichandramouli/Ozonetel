@isTest
public class NPSDetractorSchedulerTest{
    public static testMethod void  testNPSSchedulerforCreate() 
    {
        Test.StartTest();
        string json='[ { "RequestId": 713, "CheckInDate": "2017-02-03 00:00:00.0", "TIN": "T171U6625739", "MobileNumber": "9538956479", "EmailId": "raghavendra.g1729@gmail.com", "NPS": 8, "HotelName": "Palm Era Resorts", "Location": "Coorg", "NoOfRooms": 1, "Feedback": "", "Status": "Follow-Up Pending" }, { "RequestId": 706, "CheckInDate": "2017-02-03 00:00:00.0", "TIN": "T17233146273", "MobileNumber": "8157057972", "EmailId": "muneebkkv@gmail.com", "NPS": 8, "HotelName": "Rainbow Cottage", "Location": "Ooty", "NoOfRooms": 1, "Feedback": "", "Status": "Follow-Up Pending" } ]';
            Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        NPSDetractorScheduler npSch= new NPSDetractorScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, npSch);
        Test.stopTest();
        
      }
  }