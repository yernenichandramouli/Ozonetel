@isTest
global class PaymentCalloutMock2 implements HttpCalloutMock
{
  global HttpResponse respond(HTTPRequest req)
  {
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    //res.setBody('{"Status": "success", "ErrorMessage": null, "AggMaster":""}');
    //string res='{"status":"SUCCESS","errors":[],"data":{"zeroCancApplied":false,"status":"CANCELLATION_COMPLETED","serviceProviderId":"123456","refundAmount":{"currencyType":"PEN","amount":1100.0},"pnr":"TestPNR123","orderItemRefNumber":"PEP9J82414444","orderItemId":12783279536210433,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","cnr":"test12345678","clientIp":"","cancellationCharges":{"currencyType":"PEN","amount":0.0},"backToSource":true}}';
      res.setBody('{"status":"SUCCESS","errors":[],"data":{"zeroCancApplied":false,"status":"CANCELLATION_COMPLET","serviceProviderId":"123456","refundAmount":{"currencyType":"PEN","amount":1100.0},"pnr":"TestPNR123","orderItemRefNumber":"PEP9J82414444","orderItemId":12783279536210433,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","cnr":"test12345678","clientIp":"","cancellationCharges":{"currencyType":"PEN","amount":0.0},"backToSource":true}}');
      //res.setBody('{"data":"test","status":"SUCCESS","PaymentItemId":"1234567","PgTransactionId":"12345","PaymentStatus":"SUCCESS","RbPgId":"001123344556","Amount":"500","PGType":"Online","GatewayName":"Paypal","IsOffline":"false"}');
      return res;
  }
}