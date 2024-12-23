@isTest
public class RailsPostRefundBreakCntrlTest{
    @testsetup
    static void testCreateOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718',Date_Of_Purchase__c=system.now()));
        } 
        insert orderList ;
    }
    
    public static testMethod void RailsrefundBrkTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"status":"CANCELLATION_SUCCESSFUL","trainNo":"16217","trainName":"MYS SNSI EXP","cancellationTime":"2022-11-08T20:22:45","selectedPaymentCurrency":"INR","refundAmount":1657.2,"totalFare":2350.56,"refundMode":"ONLINE","pnr":"4758989699","orderItemUuid":"386b8761ec8de005bcc008bf01020b00","ticketNo":"RDX34356851","cancellationCharges":480,"passengerWiseRefundables":[{"name":"Passenger 1","fare":"565.00","refund":"565.00","cancellationCharge":"0.00"},{"name":"Passenger 2","fare":"565.00","refund":"565.00","cancellationCharge":"0.00"},{"name":"Passenger 3","fare":"565.00","refund":"565.00","cancellationCharge":"0.00"},{"name":"Passenger 4","fare":"565.00","refund":"85.00","cancellationCharge":"480.00"}],"refundFareBreakup":[{"value":2260,"refundableValue":1780,"componentName":"Ticket Charge"},{"value":52.85,"refundableValue":0,"componentName":"RedRails PG Charges"},{"value":20,"refundableValue":0,"componentName":"Agent Service Charge & GST"},{"value":17.7,"refundableValue":0,"componentName":"IRCTC Convenience Fee (incl. of GST)"},{"value":-122.8,"refundableValue":-122.8,"componentName":"Wallet (Offer Cash)"}],"cancelPolicyList":[{"cancellationCharge":"Non refundable","duration":"Less than 4h before travel","id":2,"isCurrent":false},{"cancellationCharge":"285.00","duration":"12h - 4h before travel","id":3,"isCurrent":false},{"cancellationCharge":"145.00","duration":"48h - 12h before travel","id":4,"isCurrent":false},{"cancellationCharge":"120.00","duration":"48h before travel","id":5,"isCurrent":false}],"refundStatus":{"resultCode":243,"refundStatus":"INITIATED","refundMode":"ONLINE","messageToClient":"The refund has been initiated by redRail.","refundTime":"2022-11-08T20:23:13"},"cancellationReferenceMsg":"","newItemUuid":null,"customerCare":{"heading":"Reach out to us","txt":"redRail Customer Care","phone":["9902977777"]},"cancelTblMsg":"Above table is valid only for Confirmed Seats. For RAC or Waitlisted Seats, the cancellation charge is Rs. 60 per passenger for Non-AC & Rs. 65 per passenger for AC classes. Please note that tickets can only be cancelled before chart preparation.","refundDistributions":{"BACK_TO_SOURCE":[{"refundType":"ONLINE","refundAmount":{"currencyType":"INR","amount":1657.2},"itemUuids":[]}]},"rfndStcMsg":["UPI payments will be refunded within 24 hours.","Other payment modes can take up to 5-7 working days for the refund to reflect in your account."],"allRefunds":[{"resultCode":243,"refundStatus":"INITIATED","refundMode":"ONLINE","messageToClient":"The refund has been initiated by redRail.","refundTime":"2022-11-08T20:23:13"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPostRefundBreakCntrl.GetRailsRefundBreak(ol[0].id);   
        Test.stopTest();
    }
    
     public static testMethod void RailsFailrefundBrkTest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"errorcode":"700.15","errormsg":"Invalid Response","detailedmsg":"unable to get ticket details"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPostRefundBreakCntrl.GetRailsRefundBreak('');   
        Test.stopTest();
    }
    
     public static testMethod void RailsFRfndLstest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"totalRefund":117,"data":[{"itemUuid":"5aa35d98112be00607d69c2e02020a00","ticketNo":"","refundAmount":32,"passengersList":["Likhitha si","hagsg"],"cancellationTime":"2024-02-12T14:34:43","refundTime":"2024-02-12T14:34:43","itemType":"SG Refund Details","isTgObj":true},{"itemUuid":"5a93f196112be00607d69c2e01020a00","ticketNo":"T4E57451577","refundAmount":85,"passengersList":["Likhitha si"],"cancellationTime":"2024-02-12T15:56:00","refundTime":"2024-02-12T15:56:00","itemType":"Refund Details"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPostRefundBreakCntrl.GetRailsRefundList(ol[0].id);   
        Test.stopTest();
    }
    
     public static testMethod void RailsRfndDtlsest()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"isFCOpted":false,"isTGRefund":true,"subHeading":"Seat Guarantee Premium","cancellationType":"","breakDownTable":[{"componentName":"Total Premium Amount: x2 pax","amount":32,"detailedBreakDown":null},{"componentName":"Total Deductions","amount":0,"detailedBreakDown":null},{"componentName":"Total Refund","amount":32,"detailedBreakDown":null}],"summaryTable":null,"refundDetails":{"componentName":"","amount":32,"detailedBreakDown":null},"refundStatus":{"displayBoth":false,"paymentMethod":[{"ComponentName":"Refund Initiated","time":"2:34 PM, 12 Feb 2024","stepCompleted":true},{"ComponentName":"Refund Credited","time":"2:34 PM, 12 Feb 2024","stepCompleted":true}],"walletMethod":null},"rrnMesg":"","extraInfo":null,"fcCardText":"","cancellationMsg":"","fcExpiryMsg":"","refundDiffText":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        RailsPostRefundBreakCntrl.GetRailsRefundDetailsBreakUP('1234567890');   
        Test.stopTest();
    }

    
 }