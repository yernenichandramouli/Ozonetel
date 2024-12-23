@isTest
global class ExampleCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
   // res.setBody('{"Status": "success", "ErrorMessage": null, "AggMaster":""}');
    //res.setBody('{"employerId":"1234567","JobId":"12345","jobUrl":"https://www.babajob.com","SalesforceJobId":"001123344556","SalesforceEmployerId":"005000000101xy"}');
    return res;
  }
}