/*
* Name           : PendingRefundsTest
* Created Date   : 9 jul 2017
* Created By     : Mahendra
* Purpose        : Used to cove code for the  apex class PendingRefundsCntrl
*/
@isTest

public class PendingRefundsTest{
 
    public static testmethod void pendedfunds() {
        PendingRefundsCntrl pfnds = new PendingRefundsCntrl();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)pfnds.Search();
        // Verify that the continuation has the proper requests
         Map<string, System.HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
        system.assert(requests.get(pfnds.requestLabel) != null);
        // (skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"data":[{"requestId":"4698890","creationTime":"7/6/2018 6:36:13 PM","transactionId":"1013223259","orderId":"1c04f61a7057f0055722993402030100","amount":"215","currencyCode":"INR","gatewayName":"AmazonPay","pgTransactionId":"0","dateOfCreationInLong":"2018187","refundStatus":"PENDING","refundType":"ONLINE","processedTime":"1/1/0001 12:00:00 AM","trexOrderUuid":"1835847c7057f0055722993401010100","mobile":"917760280299","emailId":"eswerp@gmail.com"},{"requestId":"4698928","creationTime":"7/6/2018 6:59:13 PM","transactionId":"1013235223","orderId":"2f9f6fd77059f0055722993401030100","amount":"552.5","currencyCode":"INR","gatewayName":"UPI","pgTransactionId":"0","dateOfCreationInLong":"2018187","refundStatus":"PENDING","refundType":"ONLINE","processedTime":"1/1/0001 12:00:00 AM","trexOrderUuid":"28cda7267059f0055722993402010100","mobile":"919665627410","emailId":"rajendranr7@gmail.com"}],"error":"","message":"Data fetched successfully"}');   
        // Set the fake response for the continuation     
        Test.setContinuationResponse(pfnds.requestLabel, response);
        // Invoke callback method
        Object result = Test.invokeContinuationMethod(pfnds, conti);
        // result is the return value of the callback
        System.assertEquals(null, result);
        //System.assertEquals('Mock response body', controller.result);
        
        pfnds.selRecId='4698890';
        pfnds.refStatus='process';
        pfnds.pgRefNum='345324567';
        pfnds.refundedDate=date.parse('7/6/2018');
        pfnds.status='process';
       pfnds.updateInPaas();
       PendingRefundsCntrl.Datum pendfd = new PendingRefundsCntrl.Datum ();
       pendfd.creationTime='7/6/2018 6:36:13 PM';
       pendfd.refundStatus='pending';
       pendfd.currencyCode='INR';
       pendfd.pgTransactionId='232567';
       pendfd.gatewayName='AmazonPay';
       pendfd.refundType='ONLINE';
       pendfd.processedTime='TEST';
       pendfd.mobile='9513267829';
       pendfd.emailId='eswerp@gmail.com';
      //pendfd.dateOfCreationInLong='text;
      PendingRefundsCntrl.PendingRefundsWrapper pend1 = new  PendingRefundsCntrl.PendingRefundsWrapper();
       pend1.error='';
       pend1.message='text';
    }
    public static testmethod void pendedfunds1() {
        PendingRefundsCntrl pfnddds = new PendingRefundsCntrl();
        Continuation conti = (Continuation)pfnddds.Search();
         Map<string, System.HttpRequest> requests = conti.getRequests();

        system.assert(requests.size() == 1);
        system.assert(requests.get(pfnddds.requestLabel) != null);
        // (skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"amendState":true,"responseMessage":"SUCCESS"}');
        Test.setContinuationResponse(pfnddds.requestLabel, response);
        // Invoke callback method
        Object result = Test.invokeContinuationMethod(pfnddds, conti);
        // result is the return value of the callback
        System.assertEquals(null, result);
        //System.assertEquals('Mock response body', controller.result);
        pfnddds.selRecId='4698890';
        pfnddds.refStatus='success';
        //pfnddds.Response_Received__c='{"amendState":true,"responseMessage":"SUCCESS"}';
       pfnddds.updateInPaas();
       pfnddds.processUpdateResponse();
      
       
    }
}