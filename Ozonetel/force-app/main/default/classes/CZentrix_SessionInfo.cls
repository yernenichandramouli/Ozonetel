@RestResource(urlMapping='/redBus/CZentrix_Info_SessionId/*')
global without sharing class CZentrix_SessionInfo
{
    @HttpPost
    global static string doPost()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
         dbs.cZentrix_Type__c = 'Info Session Ping';
         dbs.Type__c = 'cZentrix';
        try
        {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            system.debug('-----------data--------'+req);
            system.debug(LoggingLevel.ERROR, req.requestBody.toString());
            system.debug('-----------------Post method-------------------');
            
            System.Debug('@@==>> Params: '+String.Valueof(req.params));
            
            string responseValue = req.requestBody.toString();
            String xmlReceived = '';
            //xmlReceived = responseValue;
            xmlReceived = String.Valueof(req.params);
            System.Debug('@@==>> xmlReceived: '+xmlReceived);
            
            dbs.cZentrix_Request_Received__c = req.toString();
            dbs.cZentrix_Body_Received_XML__c = responseValue;
            
    
            
            if(!String.IsBlank(xmlReceived))
            {    
                //String finalXML = '<info>'+xmlReceived+'</info>';
                //String finalXML = xmlReceived;
                String finalXML = String.Valueof(req.params).removeEnd('=}');
                finalXML = String.Valueof(finalXML).removeStart('{');
                
                DOM.Document doc = new DOM.Document();
                doc.load(finalXML);    
                DOM.XMLNode finalXMLResult = doc.getRootElement();
                
                dbs.Cancelled_Order_Items_Fail_Description__c = finalXML+' XML Result: '+String.Valueof(finalXMLResult);
                
                Set<String> allElemetsReceived = new Set<String>();
                for (Dom.XMLNode child: finalXMLResult.getChildElements()) 
                {
                    allElemetsReceived.add(child.getName());
                }
                
                dbs.cZentrix_Body_Received_XML__c = finalXML+'----'+String.Valueof(allElemetsReceived); 
                
                if(allElemetsReceived.Contains('SessionID'))
                {
                    dbs.cZentrix_Session_Id__c = finalXMLResult.getChildElement('SessionID', null).getText();
                }
                
                CZentrix_Info__c cz_info = new CZentrix_Info__c();
                if(allElemetsReceived.Contains('SessionID'))
                {
                       cz_info.Session_ID__c = finalXMLResult.getChildElement('SessionID', null).getText();
                       dbs.cZentrix_Session_Id__c = finalXMLResult.getChildElement('SessionID', null).getText();
                }       
                if(allElemetsReceived.Contains('AgentID'))
                {
                    cz_info.Agent_ID__c = finalXMLResult.getChildElement('AgentID', null).getText();
                }
                if(allElemetsReceived.Contains('CallStartDateTime') && !String.IsBlank(finalXMLResult.getChildElement('CallStartDateTime', null).getText()))
                {
                    //DateTime dt = DateTime.Valueof(finalXMLResult.getChildElement('Date_Time', null).getText());
                    //cz_info.Date_Time__c = DateTime.Valueof(dt.format('dd/MM/yyyyHH:mm' , 'GMT+5:30'));
                    cz_info.Date_Time__c = DateTime.Valueof(finalXMLResult.getChildElement('CallStartDateTime', null).getText()).addMinutes(-330);
                }
                if(allElemetsReceived.Contains('Phone'))
                {
                    cz_info.Customer_Ph_No__c = finalXMLResult.getChildElement('Phone', null).getText();
                }
                 dbs.cZentrix_Status__c = 'Success';
                insert dbs;
                insert cz_info;
                return 'Success';
            }
            else
            {
                dbs.cZentrix_Status__c = 'Failure';
                dbs.cZentrix_Error_Message__c = 'No Data';
                insert dbs;
                return 'No Data Received.. Request Received: '+req.toString();
            }
        }
        catch(exception e)
        {
            String excep = String.Valueof(e);
            
            dbs.cZentrix_Error_Message__c = excep;
            dbs.cZentrix_Status__c = 'Failure';
            insert dbs;
            return 'Error: '+excep;
        }
    }
}