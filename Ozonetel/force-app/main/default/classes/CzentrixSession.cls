public class CzentrixSession 
{

    public CzentrixSession(ApexPages.StandardController controller) 
    {
        
    }
    public static void SessionIdPing()
    {
        string userid =  userinfo.getuserid();
        string accid = ApexPages.currentPage().getParameters().get('id');
        user ud = new user();
        ud = [select id, name,CZentrix_Agent_Id__c, RedBus_Location__c from user where id=:userid limit 1];
        if(!string.isBlank(string.valueof(ud.RedBus_Location__c)) && !string.isBlank(string.valueof(ud.CZentrix_Agent_Id__c)))
        {
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            HttpResponse res = new HttpResponse();
            Http http = new Http(); 
            string URL;
            Map<String,CZentrixSessionURL__c> mapauth = CZentrixSessionURL__c.getAll();
            if(string.valueof(ud.RedBus_Location__c)=='Bangalore')
            {
                //URL = 'http://blr-b.redbus.in:22082/apps/appsHandler.php?transaction_id=CTI_GET_LIVE_AGENT_DETAILS&agent_id='+ud.CZentrix_Agent_Id__c+'&resFormat=0';
                //URL = mapauth.get('Bangalore').API_EndPoint__c+ud.CZentrix_Agent_Id__c+'&resFormat=0';
                URL = System.Label.CZentrix_Bangalore_Session_API+ud.CZentrix_Agent_Id__c+'&resFormat=0';
            }
            else
            if(string.valueof(ud.RedBus_Location__c)=='Pune')
            {
                //URL = 'http://115.248.228.161:2080/apps/appsHandler.php?transaction_id=CTI_GET_LIVE_AGENT_DETAILS&agent_id='+ud.CZentrix_Agent_Id__c+'&resFormat=0';
                //URL = mapauth.get('Pune').API_EndPoint__c+ud.CZentrix_Agent_Id__c+'&resFormat=0';
                URL = System.Label.CZentrix_Pune_Session_API+ud.CZentrix_Agent_Id__c+'&resFormat=0';
            }
            req.setEndpoint(URL);
            req.setMethod('GET');
             
             DBLog_Summary__c dbs = new DBLog_Summary__c();
             dbs.cZentrix_Type__c = 'Info Session Ping';
             dbs.Type__c = 'cZentrix';
             dbs.Complaint_Tracker_Body_Received__c = 'for cZentrix:- AccountId: '+accId+'Request Sent: '+req.toString();
            
            try
            {
                res = http.send(req);
                string responseValue = res.getBody();
                system.debug('---------------responseValue----------------'+responseValue);
                
                dbs.cZentrix_Request_Received__c = responseValue;
                dbs.cZentrix_Body_Received_XML__c = responseValue;
                
                Response  resp = new Response();
                if(res.getStatus()=='OK')
                {
                   XmlStreamReader reader = new XmlStreamReader(responseValue);
                   system.debug('----------xsr-------------------'+reader);
                   Dom.Document doc = res.getBodyDocument();
                   system.debug('----------doc-------------------'+doc);
                   Dom.XMLNode address = doc.getRootElement();
                   system.debug('----------address-------------------'+address);
                   if(!string.isBlank(address.getChildElement('SessionID', null).getText()))
                   {
                       CZentrix_Info__c CI = new CZentrix_Info__c();
                       CI.Session_ID__c = address.getChildElement('SessionID', null).getText();
                       dbs.cZentrix_Session_Id__c = address.getChildElement('SessionID', null).getText();
                       if(!string.IsBlank(accid))
                       {
                           CI.Account_Name__c = accid;
                       }
                       String AgentID = address.getChildElement('AgentID', null).getText();
                       String Phone = address.getChildElement('Phone', null).getText();
                       if(!string.isBlank(address.getChildElement('AgentID', null).getText()))
                       {
                           CI.Agent_ID__c = address.getChildElement('AgentID', null).getText();
                           //CI.Name = CI.Agent_ID__c;
                       }
                       if(!string.isBlank(address.getChildElement('Phone', null).getText()))
                       {
                           CI.Customer_Ph_No__c = address.getChildElement('Phone', null).getText();
                       } 
                       
                       dbs.cZentrix_Status__c = 'Success';
                        insert dbs;
                       
                       database.upsert(CI,CZentrix_Info__c.Session_ID__c,false);
                   }
                }
            }
            catch(exception e)
            {
                String excep = String.Valueof(e);
                
                dbs.cZentrix_Error_Message__c = excep;
                dbs.cZentrix_Status__c = 'Failure';
                insert dbs;
            }
        }
    }
    public class Response
    {
        string AgentID;
        string Phone;
        string SessionID;
    }

}