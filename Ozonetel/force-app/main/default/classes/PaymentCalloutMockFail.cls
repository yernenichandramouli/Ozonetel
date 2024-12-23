@isTest
global class PaymentCalloutMockFail implements HttpCalloutMock
{
  global HttpResponse respond(HTTPRequest req)
  {
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    //res.setBody('{"Status": "success", "ErrorMessage": null, "AggMaster":""}');
    res.setBody('{"PaymentItemId":"1234567","PgTransactionId":"12345","PaymentStatus":"FAIL","RbPgId":"001123344556","Amount":"500","PGType":"Online","GatewayName":"Paypal","IsOffline":"false"}');
    return res;
  }
}