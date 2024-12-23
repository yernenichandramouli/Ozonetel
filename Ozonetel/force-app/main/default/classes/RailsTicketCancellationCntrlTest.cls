@isTest
public class RailsTicketCancellationCntrlTest{
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718',Date_Of_Purchase__c=system.now()));
        } 
        insert orderList ;
    }
    
    public static testMethod void RailsTicketCanclTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"srcStation":"ETAWAH JN","destStation":"KAMAKHYA","doj":"2022-07-31T11:40:00","amountPaid":"3575.40","refundableAmount":"3160.00","passengerWiseRefundables":[{"name":"1","fare":"1770.00","refund":"1580.00","cancellationCharge":"190.00"},{"name":"2","fare":"1770.00","refund":"1580.00","cancellationCharge":"190.00"}],"selectedPaymentCurrency":"INR","refundTypeList":"Online","refundModeList":null,"refundDistributions":{"BACK_TO_SOURCE":[{"refundType":"ONLINE","refundAmount":{"currencyType":"INR","amount":3160},"pgName":"PAYUS2S"}]},"lstPassengerInfo":[{"name":"Sheelendra Kumar","age":38,"ticketStatus":"CNF","CoachId":"B1","BerthNo":"25","BerthCode":"LOWER BERTH","serialNo":"1"},{"name":"Arti Devi","age":32,"ticketStatus":"CNF","CoachId":"B1","BerthNo":"26","BerthCode":"MIDDLE BERTH","serialNo":"2"}],"refundFareBreakup":[{"value":3540,"refundableValue":3160,"componentName":"Ticket Charge"},{"value":35.4,"refundableValue":0,"componentName":"IRCTC Convenience Fee (incl. of GST)"}],"cancelPolicyList":[{"cancellationCharge":"Non refundable","duration":"Less than 4h before travel","id":2,"isCurrent":false},{"cancellationCharge":"930.00","duration":"12h - 4h before travel","id":3,"isCurrent":false},{"cancellationCharge":"465.00","duration":"48h - 12h before travel","id":4,"isCurrent":false},{"cancellationCharge":"190.00","duration":"48h before travel","id":5,"isCurrent":true}],"cancellationReferenceMsg":"Your cancellation time falls in the interval [48h before travel]","cancelDiscalimer":"This refund amount is a best estimate as per redRail calculations. The actual refund from IRCTC may vary.","cancelTblMsg":"Above table is valid only for Confirmed Seats. For RAC or Waitlisted Seats, the cancellation charge is Rs. 60 per passenger for Non-AC & Rs. 65 per passenger for AC classes. Please note that tickets can only be cancelled before chart preparation."}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsTicketCancellationCntrl.GetRailsIsCancellable(ol[0].id);   
        Test.stopTest();
    }
    
    public static testMethod void V1TicketCanclTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"srcStation":"ETAWAH JN","destStation":"KAMAKHYA","doj":"2022-07-31T11:40:00","amountPaid":"3575.40","refundableAmount":"3160.00","passengerWiseRefundables":[{"name":"1","fare":"1770.00","refund":"1580.00","cancellationCharge":"190.00"},{"name":"2","fare":"1770.00","refund":"1580.00","cancellationCharge":"190.00"}],"selectedPaymentCurrency":"INR","refundTypeList":"Online","refundModeList":null,"refundDistributions":{"BACK_TO_SOURCE":[{"refundType":"ONLINE","refundAmount":{"currencyType":"INR","amount":3160},"pgName":"PAYUS2S"}]},"lstPassengerInfo":[{"name":"Sheelendra Kumar","age":38,"ticketStatus":"CNF","CoachId":"B1","BerthNo":"25","BerthCode":"LOWER BERTH","serialNo":"1"},{"name":"Arti Devi","age":32,"ticketStatus":"CNF","CoachId":"B1","BerthNo":"26","BerthCode":"MIDDLE BERTH","serialNo":"2"}],"refundFareBreakup":[{"value":3540,"refundableValue":3160,"componentName":"Ticket Charge"},{"value":35.4,"refundableValue":0,"componentName":"IRCTC Convenience Fee (incl. of GST)"}],"cancelPolicyList":[{"cancellationCharge":"Non refundable","duration":"Less than 4h before travel","id":2,"isCurrent":false},{"cancellationCharge":"930.00","duration":"12h - 4h before travel","id":3,"isCurrent":false},{"cancellationCharge":"465.00","duration":"48h - 12h before travel","id":4,"isCurrent":false},{"cancellationCharge":"190.00","duration":"48h before travel","id":5,"isCurrent":true}],"cancellationReferenceMsg":"Your cancellation time falls in the interval [48h before travel]","cancelDiscalimer":"This refund amount is a best estimate as per redRail calculations. The actual refund from IRCTC may vary.","cancelTblMsg":"Above table is valid only for Confirmed Seats. For RAC or Waitlisted Seats, the cancellation charge is Rs. 60 per passenger for Non-AC & Rs. 65 per passenger for AC classes. Please note that tickets can only be cancelled before chart preparation."}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        list<string> lstseats = new  list<string>();
        lstseats.add('');
        RailsTicketCancellationCntrl.railsV1Cancel(ol[0].id,lstseats);   
        Test.stopTest();
    }
    
     public static testMethod void FailV1TicketCanclTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        list<string> lstseats = new  list<string>();
        lstseats.add('');
        RailsTicketCancellationCntrl.railsV1Cancel(ol[0].id,lstseats);   
        Test.stopTest();
    }
    
    
 }