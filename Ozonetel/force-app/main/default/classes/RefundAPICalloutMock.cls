@isTest
global class RefundAPICalloutMock implements HttpCalloutMock
{
  global HttpResponse respond(HTTPRequest req)
  {
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    //res.setBody('{"Status": "success", "ErrorMessage": null, "AggMaster":""}');
    res.setBody('{"CustRefundId":"1234567","InitiatedTime":"0001-01-01T00:00:00","IsSuccess":"true","ResponseMessage":"001123344556"}');
    return res;
  }
}