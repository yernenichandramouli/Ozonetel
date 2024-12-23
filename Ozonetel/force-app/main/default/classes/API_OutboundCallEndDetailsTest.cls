@isTest
public class API_OutboundCallEndDetailsTest
{
    
    public static testMethod void successTest()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c,username from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"busy","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_OutboundCallEndDetails ap=new API_OutboundCallEndDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='New';
        ld.lead_group__c='Group 1';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='23456789';
        ci.LeadCall_Id__c='L8888823456789';
        ci.Agent_ID__c='2054';
        ci.Agent_ID__c=usr.username;
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;             
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/v1/OutboundCallEndDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        //API_OutboundCallEndDetails.callDetails();
        
        string jsonBody2='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"answered","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req; 
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ld.Call_back_request_time__c=System.now().addMinutes(-20);
        update ld;
        API_OutboundCallEndDetails.callDetails();
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }
    
    public static testMethod void failMethod()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c,username from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"call_to":"","call_status":"busy","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_OutboundCallEndDetails ap=new API_OutboundCallEndDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='New';
        ld.lead_group__c='Group 1';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='123456789';
        ci.LeadCall_Id__c='123456789';
        ci.Agent_ID__c=usr.username;
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;      
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/v1/OutboundCallEndDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_OutboundCallEndDetails.callDetails();
    }
    
    public static testMethod void FeedbckCallTest()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c,username from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"leadCallUniqueId":"FBC23456789","call_to":"","call_status":"busy","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_OutboundCallEndDetails ap=new API_OutboundCallEndDetails();
        
        OutBound_Feedback_Calling__c fb=new OutBound_Feedback_Calling__c();
        fb.Call_Unique_Id__c='FBC23456789';
        fb.Phone_No__c='1234567890';
        fb.OrderItem_Uuid__c='fg4567890';
        fb.TIN_no__c='TI567890';
        fb.Call_Back_Time__c=system.now();
        insert fb;
        
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='23456789';
        ci.LeadCall_Id__c='FBC23456789';
        ci.Agent_ID__c='2054';
        ci.Agent_ID__c=usr.username;
        ci.OutBound_Feedback_Calling__c=fb.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;             
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/v1/OutboundCallEndDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        //API_OutboundCallEndDetails.callDetails();
        
        string jsonBody2='{"leadCallUniqueId":"FBC23456789","call_to":"","call_status":"answered","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req; 
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_OutboundCallEndDetails.callDetails();
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }

    public static testMethod void Group2Test()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c,username from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"busy","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_OutboundCallEndDetails ap=new API_OutboundCallEndDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='New';
        ld.lead_group__c='Group 2';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='23456789';
        ci.LeadCall_Id__c='L8888823456789';
        ci.Agent_ID__c='2054';
        ci.Agent_ID__c=usr.username;
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;             
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/v1/OutboundCallEndDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        //API_OutboundCallEndDetails.callDetails();
        
        string jsonBody2='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"answered","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req; 
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ld.Call_back_request_time__c=System.now().addMinutes(-20);
        update ld;
        API_OutboundCallEndDetails.callDetails();
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }
    
    public static testMethod void NotAnsweredTest()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c,username from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"busy","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_OutboundCallEndDetails ap=new API_OutboundCallEndDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='RnR';
        ld.lead_group__c='Group 2';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='23456789';
        ci.LeadCall_Id__c='L8888823456789';
        ci.Agent_ID__c='2054';
        ci.Agent_ID__c=usr.username;
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;             
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/v1/OutboundCallEndDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        //API_OutboundCallEndDetails.callDetails();
        
        string jsonBody2='{"leadCallUniqueId":"L8888823456789","call_to":"","call_status":"answered","callStartTime":"2019-11-24 08:41:49","endTime":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req; 
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ld.Call_back_request_time__c=System.now().addMinutes(-20);
        update ld;
        API_OutboundCallEndDetails.callDetails();
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }
}