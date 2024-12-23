@isTest
public class SendSmsEmailExtensionTest
{
    /*
Name:createOrder
Description: Creates Order Item data (Other methods can utilize) 
*/
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID'));
        } 
        insert orderList ;
      Country_Codes__c ccObj=new Country_Codes__c();
        ccObj.name='REDBUS_ID';
        ccObj.Country_Code__c='62';
        ccObj.Business_Unit__c='Indonesia';
        ccObj.Country_Header__c='IDR';
        insert ccObj;
    }
    /*
Name:TestSMS_Success
Description: Testing sending sms functionality
*/
    public static testMethod void TestSMS_Success()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='mTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.mCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Country_Codes__c ccObj= Country_Codes__c.getValues(ol[0].Business_Unit__c); 
       List<SelectOption> options = obj.countryCodes;
        
        obj.send();        
        Test.stopTest();
        
    }  
    /*
Name:TestEmail_Success
Description: Testing sending Email functionality
*/
    public static testMethod void TestEmail_Success()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c,Business_Unit__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='eTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.eCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();               
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":true,"IsSMSSent":false,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
       Country_Codes__c ccObj= Country_Codes__c.getValues(ol[0].Business_Unit__c);        
        obj.send();       
        Test.stopTest();
        
    }   
    /*
Name:TestEmail_Fail
Description: Testing failure sending Email functionality
*/ 
    public static testMethod void TestEmail_Fail()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='eTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.eCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":false,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        obj.send();       
        Test.stopTest();
        
    }   
    /*
Name:TestSMS_Fail
Description: Testing failure sending SMS functionality
*/ 
    public static testMethod void TestSMS_Fail()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='mTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.eCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();               
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":false,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        obj.send();      
        Test.stopTest();
        
    } 
    /*
Name:TestAPIError_Mobile
Description: Testing API functionality for Mobile
*/ 
    public static testMethod void TestAPIError_Mobile()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='mTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.mCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();               
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(404, 'ERROR', json));
        obj.send();
        Test.stopTest();
        
        
    } 
    /*
Name:TestAPIError_Email
Description: Testing API functionality for Email
*/ 
    public static testMethod void TestAPIError_Email()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='eTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.eCheck=true;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(404, 'ERROR', json));
        obj.send();
        Test.stopTest();
    } 
     public static testMethod void TestB2BMticket()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='mTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.mCheck=true;
        Continuation conti = (Continuation)obj.sendTicket();
        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        Test.setContinuationResponse(obj.sendRequestData, response);
        Object result = Test.invokeContinuationMethod(obj, conti);   
    }
     public static testMethod void TestB2BEticket()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c]; 
        SendSmsEmailExtension obj = new SendSmsEmailExtension(new ApexPages.StandardController(ol[0]));
        obj.paramValue='eTicket';
        obj.mobile='9491322718';
        obj.email='Mani.Renus@gmail.com';
        obj.eCheck=true;
        Continuation conti = (Continuation)obj.sendTicket();
        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        Test.setContinuationResponse(obj.sendRequestData, response);
        Object result = Test.invokeContinuationMethod(obj, conti);   
    }
    
    public static testMethod void methodTosendNotification(){
        list<Order_Items__c> ol=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        ApexPages.StandardController con = new ApexPages.StandardController(ol[0]);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        SendSmsEmailExtension tra=new SendSmsEmailExtension(con);
        tra.sendNotification();
        test.stopTest();
    }

}