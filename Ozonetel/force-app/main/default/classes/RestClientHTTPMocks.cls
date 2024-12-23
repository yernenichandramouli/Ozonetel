/*
* Name           : RestClientHTTPMocks
* Created Date   : 30 May 2017
* Created By     : Veeramanikanta R
* Purpose        : To get mock response for callout functionality (It helps for Test Classes)
*/

public class RestClientHTTPMocks implements HttpCalloutMock {

    public Integer code;
    public String status;
    public String bodyAsString;

    /* Accepts parameters from Test Class */
    public RestClientHTTPMocks(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
    }

    public HTTPResponse respond(HTTPRequest req) {             
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        res.setBody(this.bodyAsString);
        System.debug('get status-->'+res.getstatus());   
        return res;
    }
}