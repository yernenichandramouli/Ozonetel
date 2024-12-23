@isTest
global class CzentrixSession_Test_CalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req)
  {
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('<xml><AgentID>3317</AgentID><Phone>123456</Phone><SessionID>123456</SessionID></xml>');
    //res.setBody('{"employerId":"1234567","JobId":"12345","jobUrl":"https://www.babajob.com","SalesforceJobId":"001123344556","SalesforceEmployerId":"005000000101xy"}');
    return res;
  }
}