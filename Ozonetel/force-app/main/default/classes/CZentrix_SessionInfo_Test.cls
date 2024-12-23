@isTest
public class CZentrix_SessionInfo_Test
{
    Static TestMethod void method()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        
        /*CZentrix_Info__c cz_info = new CZentrix_Info__c();
        cz_info.Session_ID__c 
        cz_info.Agent_ID__c 
        cz_info.Customer_Ph_No__c 
        Insert cz_info;*/

        String xmlBody_CSAT = '<AgentID>2000</AgentID><Phone>9717476872</Phone><SessionID>24373297432.09091</SessionID><CallStartDateTime>2016-12-02 13:04:56</CallStartDateTime>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
       
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        RestContext.request = req;
        RestContext.response= res;
        
        dbs.cZentrix_Request_Received__c = req.toString();
        dbs.cZentrix_Body_Received_XML__c = res.toString();
        dbs.cZentrix_Status__c = 'Success';
        Insert dbs;
        
        Test.StartTest();
        CZentrix_SessionInfo czInfo = new CZentrix_SessionInfo();
        CZentrix_SessionInfo.doPost();
        Test.StopTest();
        
    }
    Static TestMethod void method0()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        
        String xmlBody_CSAT = '<AgentID>2000</AgentID><Phone>9717476872</Phone><SessionID>24373297432.09091</SessionID><CallStartDateTime>2016-12-02 13:04:56</CallStartDateTime>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        dbs.cZentrix_Request_Received__c = req.toString();
        dbs.cZentrix_Body_Received_XML__c = res.toString();
        dbs.cZentrix_Status__c = 'Failure';
        dbs.cZentrix_Error_Message__c = 'No Data';
        Insert dbs;
        
        Test.StartTest();
        CZentrix_SessionInfo czInfo = new CZentrix_SessionInfo();
        CZentrix_SessionInfo.doPost();
        Test.StopTest();
        
    }
    Static TestMethod void method1()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        
        String xmlBody_CSAT = '<AgentID>2000</AgentID><Phone>9717476872</Phone><SessionID>24373297432.09091</SessionID><CallStartDateTime>2016-12-02 13:04:56</CallStartDateTime>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        dbs.cZentrix_Request_Received__c = req.toString();
        dbs.cZentrix_Body_Received_XML__c = res.toString();
        dbs.cZentrix_Status__c = 'Failure';
        dbs.cZentrix_Error_Message__c = 'excep';
        Insert dbs;
        
        Test.StartTest();
        CZentrix_SessionInfo czInfo = new CZentrix_SessionInfo();
        CZentrix_SessionInfo.doPost();
        Test.StopTest();
        
    }
}