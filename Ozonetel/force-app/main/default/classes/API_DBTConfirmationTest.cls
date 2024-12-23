@isTest
public class API_DBTConfirmationTest
{
    
    @testsetup
    static void insertData(){
        Case c =new Case();
        c.Bank_Name__c='bca';
        c.Amount__c=200.00;
        c.issue_type__c = 'DBT' ;
        c.Trip_Id_ct__c = '1234';
        insert c;
        Payment_Items__c p = new Payment_Items__c();
        p.Order_ID__c = '1234';
        p.Guid__c= 'asdf';
        p.Payment_System__c ='ONLINE';
        insert p;
    }
    
    static testMethod void dbtConfirmTest()
    {
        
        case c = [select Bank_Name__c, caseNumber,Amount__c, createddate from case];
        system.debug('c'+c);
        string jsonBody='{"bankName":"bca","voucherId":"1233","amount":200,"createdDate":"'+c.createddate+'"}}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/redBus/DBTConfirmation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_DBTConfirmation.DBTConfirm();
        Test.stopTest();
    }
   static testMethod void test(){
        case c = [select id,casenumber,Trip_Id_ct__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate  from case];        
        //added
        
        test.startTest();
       	string json='{"status":"OK", "StatusCode":"200",  "isTicketGenrated":true, "isGFT":false,"IsvoucherExpired":false }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        //Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        DBTConfirmGeneric dbCf=new DBTConfirmGeneric();
        dbCf.ConfirmDBT('Email',c,234.0,'AXIS','XDFVC','teststst');
        test.stopTest();
    }
    static testMethod void testMethod2(){
        dateTime dt = DateTime.now();
        
        string jsonBody='{"bankName":"bca","voucherId":"1233","amount":20,"createdDate":"'+dt+'"}}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/redBus/DBTConfirmation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_DBTConfirmation.DBTConfirm();
        Test.stopTest();
        
        
        
    }
    static testMethod void voucherExpiredTest(){
        case c = [select id,casenumber,Trip_Id_ct__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate  from case];        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"status":"OK", "StatusCode":"200",  "isTicketGenrated":false, "isGFT":false,"IsvoucherExpired":true }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        DBTConfirmGeneric dbCf=new DBTConfirmGeneric();
        dbCf.ConfirmDBT('Email',c,234.0,'AXIS','XDFVC','teststst');
        Test.stopTest();
    }
    static testMethod void GFTTest(){
        case c = [select id,casenumber,Trip_Id_ct__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate  from case];        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"status":"OK", "StatusCode":"200",  "isTicketGenrated":false, "isGFT":true,"IsvoucherExpired":false }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        DBTConfirmGeneric dbCf=new DBTConfirmGeneric();
        dbCf.ConfirmDBT('Email',c,234.0,'AXIS','XDFVC','teststst');
        Test.stopTest();
    }
    static testMethod void TicketGenTest(){
        case c = [select id,casenumber,Trip_Id_ct__c,Transaction_ID__c,ID_ctp__c,Bank_Name__c,Amount__c,createddate  from case];        
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"status":"OK", "StatusCode":"200",  "isTicketGenrated":true, "isGFT":false,"IsvoucherExpired":false }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        DBTConfirmGeneric dbCf=new DBTConfirmGeneric();
        dbCf.ConfirmDBT('Email',c,234.0,'AXIS','XDFVC','teststst');
        Test.stopTest();
    }
    
}