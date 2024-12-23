@isTest
private class CallControllerTest{
    public static testMethod void  testCall() 
    {        
        string mJson='{ "status": true, "Message": "Call sent successfully!", "id": "c2c_5afbe64dd9cae811" }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mjson));
        lead l=new lead();
        l.lastname='Test';
        l.phone='9898989898';
        insert l;
        ApexPages.currentPage().getParameters().put('id', l.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        CallController c=new CallController(sc);
        c.mobileNo='9878765676';
        Test.StartTest();
        c.call();
        Test.stopTest();  
    } 
    
}