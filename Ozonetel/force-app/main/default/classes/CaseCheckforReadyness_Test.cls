@isTest
public class CaseCheckforReadyness_Test
{
    static testMethod void CaseCheck_try()
    {
        Readiness_Validation_Bypass_PhoneNumbers__c rd = new Readiness_Validation_Bypass_PhoneNumbers__c();
        rd.Name='Exotel Number';
        rd.Phone_Number__c='8039510563';
        Insert rd;
    
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        dbs.cZentrix_Session_Id__c='1481575309.5474000000';
        
        String xmlBody_CSAT = '<agent_id>3317</agent_id><cust_ph_no>9881166222</cust_ph_no><session_id>1481575309.5474000000</session_id><call_start_date_time>2016-12-13 02:20:01</call_start_date_time>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
       
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
         User ud =new User();
         ud.CZentrix_Agent_Id__c='3317';
         //ud.RedBus_Location__c ='Bangalore';
         
         Case cs = new Case();
         Insert cs;
         
         CZentrix_Info__c cz_info = new CZentrix_Info__c();
         cz_info.Session_ID__c ='1481575309.5474000000';
         cz_info.Agent_ID__c ='3317';
         cz_info.Customer_Ph_No__c='9881166222';
         cz_info.call_start_date_time__c=System.Today()-1;
         Insert cz_info;
         
         cz_info.Case__c=cs.Id;
         update cz_info;  
        
       
        dbs.cZentrix_Request_Received__c = req.toString();
        dbs.cZentrix_Body_Received_XML__c = res.toString();
        dbs.cZentrix_Status__c = 'Success';
        Insert dbs;

       
        RestContext.request = req;
        RestContext.response= res;   
        
        Test.StartTest();
        CaseCheckforReadyness ccrc = new CaseCheckforReadyness();
        CaseCheckforReadyness.doPost();
        Test.StopTest();
    }
    
    static testMethod void CaseCheck_else()
    {
        Readiness_Validation_Bypass_PhoneNumbers__c rd = new Readiness_Validation_Bypass_PhoneNumbers__c();
        rd.Name='Exotel Number';
        rd.Phone_Number__c='8039510563';
        Insert rd;
    
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        dbs.cZentrix_Session_Id__c='1481575309.5474000000';
        
        String xmlBody_CSAT = '<agent_id>3317</agent_id><cust_ph_no>9881166222</cust_ph_no><session_id>1481575309.5474000000</session_id><call_start_date_time>2016-12-13 02:20:01</call_start_date_time>';

      //  String xmlBody_CSAT = '<agent_id>3317</agent_id><cust_ph_no>9881166222</cust_ph_no><session_id></session_id><call_start_date_time>2016-12-13 02:20:01</call_start_date_time>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        Case cs = new Case();
         Insert cs;
        
        RestContext.request = req;
        RestContext.response= res;   
        
        
        Test.StartTest();
        CaseCheckforReadyness ccrc = new CaseCheckforReadyness();
        CaseCheckforReadyness.doPost();
        Test.StopTest();
        
    }
    static testMethod void CaseCheck_else1()
    {
        Readyness_API_Validation_Switch__c re = new Readyness_API_Validation_Switch__c();
        re.Name='Validation';
        re.Active__c=true;
        Insert re;
    
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        dbs.cZentrix_Session_Id__c='1481575309.5474000000';
        
        String xmlBody_CSAT = '<agent_id>3317</agent_id><cust_ph_no>9881166222</cust_ph_no><session_id>1481575309.5474000000</session_id><call_start_date_time>2016-12-13 02:20:01</call_start_date_time>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
                 CZentrix_Info__c cz_info = new CZentrix_Info__c();
         cz_info.Session_ID__c ='1481575309.5474000000';
         cz_info.Agent_ID__c ='3317';
         cz_info.Customer_Ph_No__c='9881166222';
         cz_info.call_start_date_time__c=System.Today()-1;
         Insert cz_info;
         
        
       
        dbs.cZentrix_Request_Received__c = req.toString();
        dbs.cZentrix_Body_Received_XML__c = res.toString();
        dbs.cZentrix_Status__c = 'Success';
        Insert dbs;


         
        RestContext.request = req;
        RestContext.response= res;   
        
        
        Test.StartTest();
        CaseCheckforReadyness ccrc = new CaseCheckforReadyness();
        CaseCheckforReadyness.doPost();
        Test.StopTest();
        
    }
    static testMethod void CaseCheck_else2()
    {
        Readyness_API_Validation_Switch__c re = new Readyness_API_Validation_Switch__c();
        re.Name='Validation';
        re.Active__c=true;
        Insert re;
     
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Info Session Ping';
        dbs.Type__c = 'cZentrix';
        dbs.cZentrix_Session_Id__c='1481575309.5474000000';
        
        String xmlBody_CSAT = '<agent_id>3317</agent_id><cust_ph_no>9881166222</cust_ph_no><session_id>1481575309.5474000000</session_id><call_start_date_time>2016-12-13 02:20:01</call_start_date_time>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
         
        RestContext.request = req;
        RestContext.response= res;   
        
        
        Test.StartTest();
        CaseCheckforReadyness ccrc = new CaseCheckforReadyness();
        CaseCheckforReadyness.doPost();
        Test.StopTest();
        
    }

    static testMethod void CaseCheck_Catch()
    {
       
        Test.StartTest();
        CaseCheckforReadyness ccrc = new CaseCheckforReadyness();
        CaseCheckforReadyness.doPost();
        Test.StopTest();
        
    }
    

}