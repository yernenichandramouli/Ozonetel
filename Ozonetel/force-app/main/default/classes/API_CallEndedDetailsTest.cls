@isTest
public class API_CallEndedDetailsTest
{
    
    public static testMethod void Group1Test()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"call_to":"","call_status":"busy","start_time":"2019-11-24 08:41:49","end_time":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_CallEndedDetails ap=new API_CallEndedDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='New';
        ld.lead_group__c='Group 1';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='ec150b0b-c096-4d0f-aa33-5b9a0c897b3e';
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;             
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/rredBus/v1/CallEnded';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallEndedDetails.callDetails();
        
        string jsonBody2='{"call_to":"","call_status":"answered","start_time":"2019-11-24 08:41:49","end_time":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ld.Call_back_request_time__c=System.now().addMinutes(-20);
        update ld;
        API_CallEndedDetails.callDetails();
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }
    
    public static testMethod void Group2Test()
    {
        Test.startTest();
        
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c from user where id=:userInfo.getuserid()];
        string agentId=usr.CZentrix_Agent_Id__c;
        string jsonBody='{"call_to":"","call_status":"busy","start_time":"2019-11-24 08:41:49","end_time":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        API_CallEndedDetails ap=new API_CallEndedDetails();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='RnR';
        ld.lead_group__c='Group 2';
        ld.RnR_Unsuccessful_Attempts__c=3;
        insert ld;
        CZentrix_Info__c ci=new CZentrix_Info__c();
        ci.CustUniqueId__c='ec150b0b-c096-4d0f-aa33-5b9a0c897b3e';
        ci.Call_Status__c='busy';
        ci.Lead__c=ld.id;
        insert ci;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        
        insert ud;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/rredBus/v1/CallEnded';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallEndedDetails.callDetails();
        
        string jsonBody2='{"call_to":"","call_status":"answered","start_time":"2019-11-24 08:41:49","end_time":"2019-11-24 08:41:52","agentid":"'+agentId+'","id":"ec150b0b-c096-4d0f-aa33-5b9a0c897b3e"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        ld.Call_back_request_time__c=System.now().addMinutes(-20);
        update ld;
        API_CallEndedDetails.callDetails();
        
        Test.stopTest();
        Test.setCreatedDate(ud.Id, system.today());
    }
    
}