@isTest
public class RailsPNRstatusCheckCntrlTest{
    @testsetup
    static void testCreateOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718',Date_Of_Purchase__c=system.now()));
        } 
        insert orderList ;
    }
    
    public static testMethod void RailsPnrTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"pnrNo":"6216073426","doj":"2023-03-05T00:00:00","pnrLastUpdated":"Updated few min ago","chartStatus":"Chart Not Prepared","trainName":"FALAKNUMA EXP","trainNumber":"12703","journeyClass":"SL","quota":"(General)","departureTime":"2023-03-05T22:35:00","arrivalTime":"2023-03-06T04:55:00","duration":380,"srcName":"VISAKHAPATNAM","dstName":"GUNTUR JN","srcCode":"VSKP","dstCode":"GNT","passengers":[{"name":"Kasapu  raju","currentStatus":"Waitlist","currentCoachId":"N/A","currentBerthNo":"8","currentBerthCode":"N/A"}],"bookReturn":{"header":"Book Return Tickets","srcName":"VISAKHAPATNAM","dstName":"GUNTUR JN","srcCode":"VSKP","dstCode":"GNT","dates":[{"actualDate":"20230306"},{"actualDate":"20230307"},{"actualDate":"20230308"}]},"decode":{"heading":"Decode your PNR","data":[{"imageSrc":"https://st.redbus.in/Images/redrail/Fact1.png","imageText":"First digit of a PNR no represents the Railway","imageReadTime":"2 mins read","imageLink":"https://www.redbus.in/information/pnr-status"},{"imageSrc":"https://st.redbus.in/Images/redrail/Fact2.png","imageText":"Confusing short forms in PNR Status","imageReadTime":"2 mins read","imageLink":"https://www.redbus.in/information/pnr-status"},{"imageSrc":"https://st.redbus.in/Images/redrail/Fact3.png","imageText":"Flushed PNR","imageReadTime":"1 min read","imageLink":"https://www.redbus.in/information/pnr-status"}]},"disclaimerMsg":"This feature has no affiliation with IRCTC. Neither redBus nor IRCTC will be responsible for any liability occuring due to this information.","trainCancelledMsg":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPNRstatusCheckCntrl.GetRailsPNRstatus(ol[0].id);   
        Test.stopTest();
    }
    
     public static testMethod void RailsFailPnrTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"errorcode":"700.15","errormsg":"Invalid Response","detailedmsg":"unable to get ticket details"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPNRstatusCheckCntrl.GetRailsPNRstatus('');   
        Test.stopTest();
    }

     public static testMethod void RailsTGtest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"isChartPrepared":false,"passengerStatus":"1/1 passengers confirmed","tgStatus":"Enjoy your trip to PANVEL, Seat details will be updated after chart preparation."}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPNRstatusCheckCntrl.GetRailsTGstatus(ol[0].id);   
        Test.stopTest();
    }
    
       public static testMethod void RailsFailTGTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"errorcode":"700.15","errormsg":"Invalid Response","detailedmsg":"unable to get ticket details"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPNRstatusCheckCntrl.GetRailsTGstatus('');   
        Test.stopTest();
    }
    
 }