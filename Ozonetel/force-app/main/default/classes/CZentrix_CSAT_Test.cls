@isTest
public class CZentrix_CSAT_Test
{
    static testMethod void CZentrix_CSAT_try()
    {
        String xmlBody_CSAT = '<cust_ph_no>cust_ph_no</cust_ph_no><agent_id>agent_id</agent_id><agent_name>agent_name</agent_name><session_id>session_id</session_id><campaign_id>campaign_id</campaign_id><campaign_name>campaign_name</campaign_name><call_start_date_time></call_start_date_time><ivrs_path>ivrs_path</ivrs_path><skill_name>skill_name</skill_name><question>question</question><answer>answer</answer><CustUniqueId>CustUniqueId</CustUniqueId>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
       
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.StartTest();
        CZentrix_CSAT.doPost();
        Test.StopTest();
    }
    
    static testMethod void CZentrix_CSAT_Catch()
    {
        String xmlBody_CSAT = '<cust_ph_no>cust_ph_no</cust_ph_no><agent_id>agent_id</agent_id><agent_name>agent_name</agent_name><session_id>session_id</session_id><campaign_id>campaign_id</campaign_id><campaign_name>campaign_name</campaign_name><call_start_date_time></call_start_date_time><ivrs_path>ivrs_path</ivrs_path><skill_name>skill_name</skill_name><question>question</question><answer>answer</answer><CustUniqueId>CustUniqueId</CustUniqueId>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_CSAT);
        req.addParameter('<lead>'+xmlBody_CSAT+'</lead>', '');
        
        //RestContext.request = req;
        //RestContext.response= res;
        
        Test.StartTest();
        CZentrix_CSAT.doPost();
        Test.StopTest();
    }
}