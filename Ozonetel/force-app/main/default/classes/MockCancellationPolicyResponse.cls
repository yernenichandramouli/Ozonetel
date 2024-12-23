/**
 * (c) 2016 RedBus
 *
 * Name           : MockCancellationPolicyResponse
 * Created Date   : 12 Dec 2016
 * Created By     : Sreenivas M
 * Purpose        : Mock response to test CancelationPolicyCntrl class. 
 *
 **/
 
@isTest
global class MockCancellationPolicyResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(System.Label.Cancelation_Policy_URI+'TJCZ94752967', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"cancelpolicy": [{"chargeAssociated": "Rs. 2044/","duration": "After 06:00 PM  on 24th Dec","RefundAmount": "Rs. 0","percentage": "100%"},{"chargeAssociated": "Rs. 1022/","duration": "Between 10:00 AM on 24th Dec - 06:00 PM on 24th Dec","RefundAmount": "Rs. 1022","percentage": "50%"}],"IsPartialCancellation": true}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}