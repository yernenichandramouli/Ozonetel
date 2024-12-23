@isTest
public class TrainDetailsTest{
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
    }
    
    public static testMethod void GetTrainDetailsTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{ "pnrNo": "2810955620", "dateOfJourney": "2021-11-16T14:45:00", "trainNumber": "01118", "trainName": "PCOI ET EXP SPL", "sourceStation": "PCOI", "destinationStation": "JBP", "reservationUpto": "JBP", "boardingPoint": "PCOI", "journeyClass": "SL", "numberOfpassenger": 3, "chartStatus": "NOT_PREPARED", "passengerList": [ { "passengerSerialNumber": 1, "passengerAge": 17, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 37, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 37, "passengerName": "Nitin rai", "seniorCitizenApplicable": false }, { "passengerSerialNumber": 2, "passengerAge": 52, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 34, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 34, "passengerName": "virendra rai", "seniorCitizenApplicable": false }, { "passengerSerialNumber": 3, "passengerAge": 47, "bookingStatus": "CNF", "bookingCoachId": "S3", "bookingBerthNo": 35, "currentStatus": "CNF", "currentCoachId": "S3", "currentBerthNo": 35, "passengerName": "sheela rai", "seniorCitizenApplicable": false } ], "bookingFare": 230, "quota": "GN" }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        TrainDetails.GetTrainDetails(ol[0].id,'Transaction');   
        Test.stopTest();
    }
}