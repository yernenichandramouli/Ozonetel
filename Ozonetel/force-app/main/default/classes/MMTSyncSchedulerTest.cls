@isTest
public class MMTSyncSchedulerTest
{
    // public static testMethod void MMTSyncTest()
    // {
    //     case c=new case();
    //     c.tin_no__c='1234';
    //     c.My_Desk_Id__c='1212';
    //     insert c;
    //     MMTSyncScheduler bpSch= new MMTSyncScheduler();
    //     String sche ='0 0 22 * * ? *';
    //     RestRequest req = new RestRequest(); 
    //     RestResponse res = new RestResponse();                
    //     req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
    //     req.httpMethod = 'GET';//HTTP Request Type       
    //     RestContext.request = req;
    //     RestContext.response= res;        
    //     System.debug('test resp--->'+res);
    //     Test.startTest();
    //     string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
    //     Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));    
    //     system.schedule('Test', sche, bpSch);
    //     Test.stopTest();
    // }
    
    public static testMethod void MMTSyncTest2()
    {
        case c=new case();
        c.tin_no__c='1234';
        c.My_Desk_Id__c='1212';
        insert c;
        set<string> sIds=new set<string>();
        sIds.add('1234');
        Test.startTest();
        MMTSyncScheduler bpSch= new MMTSyncScheduler();
        String sche ='0 0 22 * * ? *';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        MMTTransactionSync.postDetails(sIds);
        Test.stopTest();
    }
    
}