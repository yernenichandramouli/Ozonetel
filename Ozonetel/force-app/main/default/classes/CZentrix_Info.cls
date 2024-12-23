@RestResource(urlMapping='/redBus/CZentrix_callInfo/*')
global without sharing class CZentrix_Info
{
    @HttpPost
    global static string doPost()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
         dbs.cZentrix_Type__c = 'Info';
         dbs.Type__c = 'cZentrix';
        try{
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
                String sessionId = '';
                String calldateTime = '';
                String callStatus = '';
                String agentId = '';
                
                
                    //cz_info.Name = finalXMLResult.getChildElement('agent_name', null).getText();
                    if(allElemetsReceived.Contains('ActualTalkTime'))
                    {
                        cz_info.Actual_Talk_Time__c = finalXMLResult.getChildElement('ActualTalkTime', null).getText();
                    }
                    if(allElemetsReceived.Contains('Agent_ID'))
                    {
                        cz_info.Agent_ID__c = finalXMLResult.getChildElement('Agent_ID', null).getText();
                        if(!String.IsBlank(finalXMLResult.getChildElement('Agent_ID', null).getText()))
                        {
                            agentId = finalXMLResult.getChildElement('Agent_ID', null).getText();
                        }
                    }
                    if(allElemetsReceived.Contains('Agent_Name'))
                    {
                        cz_info.Agent_Name__c = finalXMLResult.getChildElement('Agent_Name', null).getText();
                    }
                    if(allElemetsReceived.Contains('CallDuration'))
                    {
                        cz_info.Call_Duration__c = finalXMLResult.getChildElement('CallDuration', null).getText();
                    }
                    if(allElemetsReceived.Contains('CallRemarks'))
                    {
                        cz_info.Call_Remarks__c = finalXMLResult.getChildElement('CallRemarks', null).getText();
                    }
                    if(allElemetsReceived.Contains('CallStatus'))
                    {
                        cz_info.Call_Status__c = finalXMLResult.getChildElement('CallStatus', null).getText();
                        if(!String.IsBlank(finalXMLResult.getChildElement('CallStatus', null).getText()))
                        {
                            callStatus = finalXMLResult.getChildElement('CallStatus', null).getText();
                        }
                    }
                    if(allElemetsReceived.Contains('CallType'))
                    {
                        cz_info.Call_Type__c = finalXMLResult.getChildElement('CallType', null).getText();
                    }
                    if(allElemetsReceived.Contains('Campaign_Name'))
                    {
                        cz_info.Campaign_Name__c = finalXMLResult.getChildElement('Campaign_Name', null).getText();
                    }
                    if(allElemetsReceived.Contains('Channel'))
                    {
                        cz_info.Channel__c = finalXMLResult.getChildElement('Channel', null).getText();
                    }
                    if(allElemetsReceived.Contains('CustCategory'))
                    {
                        cz_info.Cust_Category__c = finalXMLResult.getChildElement('CustCategory', null).getText();
                    }
                    if(allElemetsReceived.Contains('CustDisposition'))
                    {
                        cz_info.Cust_Disposition__c = finalXMLResult.getChildElement('CustDisposition', null).getText();
                    }
                    if(allElemetsReceived.Contains('CustomerName'))
                    {
                        cz_info.Customer_Name__c = finalXMLResult.getChildElement('CustomerName', null).getText();
                    }
                    if(allElemetsReceived.Contains('Customer_Ph_No'))
                    {
                        cz_info.Customer_Ph_No__c = finalXMLResult.getChildElement('Customer_Ph_No', null).getText();
                    }
                    if(allElemetsReceived.Contains('Date_Time') && !String.IsBlank(finalXMLResult.getChildElement('Date_Time', null).getText()))
                    {
                        //DateTime dt = DateTime.Valueof(finalXMLResult.getChildElement('Date_Time', null).getText());
                        //cz_info.Date_Time__c = DateTime.Valueof(dt.format('dd/MM/yyyyHH:mm' , 'GMT+5:30'));
                        cz_info.Date_Time__c = DateTime.Valueof(finalXMLResult.getChildElement('Date_Time', null).getText()).addMinutes(-330);
                        calldateTime = String.Valueof(DateTime.Valueof(finalXMLResult.getChildElement('Date_Time', null).getText()).addMinutes(-330));
                    }
                    if(allElemetsReceived.Contains('DIDNumber'))
                    {
                        cz_info.DID_Number__c = finalXMLResult.getChildElement('DIDNumber', null).getText();
                    }
                    if(allElemetsReceived.Contains('DisconnectedBy'))
                    {
                        cz_info.Disconnected_By__c = finalXMLResult.getChildElement('DisconnectedBy', null).getText();
                    }
                    if(allElemetsReceived.Contains('FinalCallStatus'))
                    {
                        cz_info.Final_Call_Status__c = finalXMLResult.getChildElement('FinalCallStatus', null).getText();
                    }
                    if(allElemetsReceived.Contains('HoldNumTimes') && !String.IsBlank(finalXMLResult.getChildElement('HoldNumTimes', null).getText()))
                    {
                        cz_info.Hold_Num_Times__c = Decimal.Valueof(finalXMLResult.getChildElement('HoldNumTimes', null).getText());
                    }
                    if(allElemetsReceived.Contains('HoldTime'))
                    {
                        cz_info.Hold_Time__c = finalXMLResult.getChildElement('HoldTime', null).getText();
                    }
                    if(allElemetsReceived.Contains('IVRSPath'))
                    {
                        cz_info.IVRS_Path__c = finalXMLResult.getChildElement('IVRSPath', null).getText();
                    }
                    if(allElemetsReceived.Contains('Campaign_Name'))
                    {
                        cz_info.Campaign_Name__c = finalXMLResult.getChildElement('Campaign_Name', null).getText();
                    }
                    if(allElemetsReceived.Contains('ListName'))
                    {
                        cz_info.List_Name__c = finalXMLResult.getChildElement('ListName', null).getText();
                    }
                    if(allElemetsReceived.Contains('MonitorFileName'))
                    {
                        cz_info.Monitor_File_Name__c = finalXMLResult.getChildElement('MonitorFileName', null).getText();
                    }
                    if(allElemetsReceived.Contains('MonitorFilePath'))
                    {
                        cz_info.Monitor_File_Path__c = finalXMLResult.getChildElement('MonitorFilePath', null).getText();
                    }
                    if(allElemetsReceived.Contains('NextCallTime'))
                    {
                        cz_info.Next_Call_Time__c = finalXMLResult.getChildElement('NextCallTime', null).getText();
                    }
                    if(allElemetsReceived.Contains('OrientationType'))
                    {
                        cz_info.Orientation_Type__c = finalXMLResult.getChildElement('OrientationType', null).getText();
                    }
                    if(allElemetsReceived.Contains('PhoneType'))
                    {
                        cz_info.Phone_Type__c = finalXMLResult.getChildElement('PhoneType', null).getText();
                    }
                    if(allElemetsReceived.Contains('QueueTime') && !String.IsBlank(finalXMLResult.getChildElement('QueueTime', null).getText()))
                    {
                        cz_info.Queue_Time_Secs__c = Decimal.Valueof(finalXMLResult.getChildElement('QueueTime', null).getText());
                    }
                    if(allElemetsReceived.Contains('RedialFlag'))
                    {
                        cz_info.Redial_Flag__c = finalXMLResult.getChildElement('RedialFlag', null).getText();
                    }
                    if(allElemetsReceived.Contains('SessionID'))
                    {
                        cz_info.Session_ID__c = finalXMLResult.getChildElement('SessionID', null).getText();
                        if(!String.IsBlank(finalXMLResult.getChildElement('SessionID', null).getText()))
                        {
                            sessionId = finalXMLResult.getChildElement('SessionID', null).getText();
                        }
                    }
                    if(allElemetsReceived.Contains('Skills'))
                    {
                        cz_info.Skills__c = finalXMLResult.getChildElement('Skills', null).getText();
                    }
                    if(allElemetsReceived.Contains('TransferredFrom'))
                    {
                        cz_info.Transferred_From__c = finalXMLResult.getChildElement('TransferredFrom', null).getText();
                    }
                    if(allElemetsReceived.Contains('TransferredTo'))
                    {
                        cz_info.Transferred_To__c = finalXMLResult.getChildElement('TransferredTo', null).getText();
                    }
                    if(allElemetsReceived.Contains('WaitTime'))
                    {
                        cz_info.Wait_Time__c = finalXMLResult.getChildElement('WaitTime', null).getText();
                    }
                    if(allElemetsReceived.Contains('WrappedBy'))
                    {
                        cz_info.Wrapped_By__c = finalXMLResult.getChildElement('WrappedBy', null).getText();
                    }
                    if(allElemetsReceived.Contains('WrapupTime'))
                    {
                        cz_info.Wrapup_Time__c = finalXMLResult.getChildElement('WrapupTime', null).getText();
                    }
                    cz_info.Unique_Key__c = sessionId+'-'+agentId;
                    if(callStatus ==  'answered')
                    {
                        upsert cz_info Unique_Key__c;
                    }
                    else
                    {
                        insert cz_info;
                    }
                
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