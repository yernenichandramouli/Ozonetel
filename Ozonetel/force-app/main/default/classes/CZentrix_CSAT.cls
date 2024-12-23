@RestResource(urlMapping='/redBus/CZentrix_CSAT/*')
global without sharing class CZentrix_CSAT
{
    @HttpPost
    global static string doPost()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
         dbs.cZentrix_Type__c = 'CSAT';
         dbs.Type__c = 'cZentrix';
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            system.debug('-----------data--------'+req);
            system.debug(LoggingLevel.ERROR, req.requestBody.toString());
            
            system.debug('-----------------Post method-------------------');
            
            string responseValue = req.requestBody.toString();
            String xmlReceived = '';
            //xmlReceived = responseValue;
            xmlReceived = String.Valueof(req.params);
            System.Debug('@@==>> xmlReceived: '+xmlReceived);
            
            dbs.cZentrix_Request_Received__c = req.toString();
            dbs.cZentrix_Body_Received_XML__c = responseValue;
            if(!String.IsBlank(xmlReceived))
            {            
                //String finalXML = '<csat>'+xmlReceived+'</csat>';
                
                String finalXML = String.Valueof(req.params).removeEnd('=}');
                    finalXML = String.Valueof(finalXML).removeStart('{');
                    
                    dbs.Cancelled_Order_Items_Fail_Description__c = finalXML;
                
                DOM.Document doc = new DOM.Document();
                doc.load(finalXML);    
                DOM.XMLNode finalXMLResult = doc.getRootElement();
                
                Set<String> allElemetsReceived = new Set<String>();
                for (Dom.XMLNode child: finalXMLResult.getChildElements()) 
                {
                    allElemetsReceived.add(child.getName());
                }
                
                dbs.cZentrix_Body_Received_XML__c = responseValue+'----'+String.Valueof(allElemetsReceived); 
                Map<String,Id> mapInfoId = new Map<String,Id>();
                if(allElemetsReceived.contains('session_id'))
                {
                    dbs.cZentrix_Session_Id__c = finalXMLResult.getChildElement('session_id', null).getText();
                    
                    for(CZentrix_Info__c info : [SELECT Id,Session_ID__c FROM CZentrix_Info__c WHERE Session_ID__c =: finalXMLResult.getChildElement('session_id', null).getText() AND Call_Status__c = 'answered'])
                    {
                        mapInfoId.put(info.Session_ID__c,info.Id);
                    }
                }
                
                CZentrix_CSAT__c csat = new CZentrix_CSAT__c();
                if(allElemetsReceived.contains('agent_name'))
                {
                    csat.Name = finalXMLResult.getChildElement('agent_name', null).getText();
                }
                if(allElemetsReceived.contains('skill_name'))
                {
                    csat.skill_name__c = finalXMLResult.getChildElement('skill_name', null).getText();
                }
                if(allElemetsReceived.contains('session_id'))
                {
                    csat.session_id__c = finalXMLResult.getChildElement('session_id', null).getText();
                    
                    if(mapInfoId.ContainsKey(finalXMLResult.getChildElement('session_id', null).getText()))
                    {
                        csat.CZentrix_Info__c = mapInfoId.get(finalXMLResult.getChildElement('session_id', null).getText());
                    }
                }
                if(allElemetsReceived.contains('question'))
                {
                    csat.question__c = finalXMLResult.getChildElement('question', null).getText();
                }
                if(allElemetsReceived.contains('ivrs_path'))
                {
                    csat.ivrs_path__c = finalXMLResult.getChildElement('ivrs_path', null).getText();
                }
                if(allElemetsReceived.contains('cust_ph_no'))
                {
                    csat.cust_ph_no__c = finalXMLResult.getChildElement('cust_ph_no', null).getText();
                }
                if(allElemetsReceived.contains('CustUniqueId'))
                {
                    csat.CustUniqueId__c = finalXMLResult.getChildElement('CustUniqueId', null).getText();
                }
                if(allElemetsReceived.contains('campaign_name'))
                {
                    csat.campaign_name__c = finalXMLResult.getChildElement('campaign_name', null).getText();
                }
                if(allElemetsReceived.contains('campaign_id'))
                {
                    csat.campaign_id__c = finalXMLResult.getChildElement('campaign_id', null).getText();
                }
                if(allElemetsReceived.contains('call_start_date_time') && !String.IsBlank(finalXMLResult.getChildElement('call_start_date_time', null).getText()))
                {
                    csat.call_start_date_time__c = DateTime.Valueof(finalXMLResult.getChildElement('call_start_date_time', null).getText()).addMinutes(-330);
                }
                if(allElemetsReceived.contains('answer'))
                {
                    csat.answer__c = finalXMLResult.getChildElement('answer', null).getText();
                }
                if(allElemetsReceived.contains('agent_name'))
                {
                    csat.agent_name__c = finalXMLResult.getChildElement('agent_name', null).getText();
                }
                if(allElemetsReceived.contains('agent_id'))
                {
                    csat.agent_id__c = finalXMLResult.getChildElement('agent_id', null).getText();
                }
                insert csat;
                
                dbs.cZentrix_Status__c = 'Success';
                insert dbs;
                
                return 'Thanks for visiting';
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