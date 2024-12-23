@isTest
public class API_AgentStatusUpdateTest
{
    public static testMethod void TestStatusUpdate()
    {
        Test.startTest();

        string jsonBody='{"agentId":"2022","agentStatus":"Not ready"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/rredBus/v1/CallEnded';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        user usr=[select id,username,CZentrix_Agent_Id__c from user where id=:userinfo.getUserid()];
        usr.CZentrix_Agent_Id__c='2022';
        update usr;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        
        insert ud;
        API_AgentStatusUpdate.updateAgentStatus();
        Test.stopTest();
       // Test.setCreatedDate(ud.Id, system.today());
        
     }      
      public static testMethod void TestAssignment2()
    {
        Test.startTest();

        string jsonBody='{"agentId":"2022","agentStatus":"Logoff"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/rredBus/v1/CallEnded';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        user usr=[select id,username,CZentrix_Agent_Id__c from user where id=:userinfo.getUserid()];
        usr.CZentrix_Agent_Id__c='2022';
        update usr;
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        insert ud;
        API_AgentStatusUpdate.updateAgentStatus();
        string jsonBody2='{"agentId":"2022","agentStatus":"ready"}';
        req.requestBody = Blob.valueof(jsonBody2);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
      
          API_AgentStatusUpdate.updateAgentStatus();
        Test.stopTest();
       // Test.setCreatedDate(ud.Id, system.today());
        
     }      
 }