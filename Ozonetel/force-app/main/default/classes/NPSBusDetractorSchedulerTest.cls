@isTest
public class NPSBusDetractorSchedulerTest{
    public static testMethod void  testchedulerforCreate() 
    {
        Test.StartTest();
        string json='[{"RequestId":538964,"DateOfJourney":"2018-07-15 00:00:00.0","TIN":"TM8A82297627","MobileNumber":"919884916846","EmailId":"ssbkrish@lntecc.com","NPS":"7","Travels":"SRM Transports","OperatorId":"","Routes":"Tiruchendur-Bangalore","NoofSeats":0,"Feedback":"","Status":"Follow-Up Pending"}]';
            Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        NPSBusDetractorScheduler npSch= new NPSBusDetractorScheduler ();
        String sche ='0 0 0 ? * * *';
        system.schedule('Test', sche, npSch);
        Test.stopTest();
        
      }
  }