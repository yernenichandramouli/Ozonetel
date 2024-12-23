@RestResource(urlMapping='/redBus/CaseCheckforReadyness_API/*')
global without sharing class CaseCheckforReadyness
{
    @HttpPost
    global static response doPost()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        dbs.cZentrix_Type__c = 'Readiness Ping';
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
            xmlReceived = String.Valueof(req.params);
            System.Debug('@@==>> xmlReceived: '+xmlReceived);
            
            dbs.cZentrix_Request_Received__c = req.toString();
            dbs.cZentrix_Body_Received_XML__c = responseValue;
            //insert dbs;
            
            if(!String.IsBlank(xmlReceived))
            //if(!String.IsBlank(responseValue))
            {    
                //String finalXML = responseValue;
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
                    system.debug('SessionId'+allElemetsReceived);
                }
                system.debug('SessionId'+allElemetsReceived);
                dbs.cZentrix_Body_Received_XML__c = finalXML+'----'+String.Valueof(allElemetsReceived); 
                if(allElemetsReceived.Contains('session_id'))
                {
                    dbs.cZentrix_Session_Id__c = finalXMLResult.getChildElement('session_id', null).getText();
                }
               
               if(!String.IsBlank(dbs.cZentrix_Session_Id__c))
               {
                   CZentrix_Info__c recentInfo;
                   for(CZentrix_Info__c ci : [SELECT Id,Agent_ID__c,Customer_Ph_No__c,Case__c,cust_ph_no__c,Session_ID__c,Date_Time__c FROM CZentrix_Info__c WHERE Session_ID__c =: dbs.cZentrix_Session_Id__c LIMIT 1])
                   {
                       recentInfo=ci;
                   }
                   if(recentInfo!=Null)
                   {
                       String phNumber = recentInfo.Customer_Ph_No__c.right(10);
                        Set<String> byPassedNumbers = new Set<String>();
                        
                        System.debug('-----phNumber-----'+phNumber);
                        
                        for(Readiness_Validation_Bypass_PhoneNumbers__c p : Readiness_Validation_Bypass_PhoneNumbers__c.getAll().Values())
                        {
                            byPassedNumbers.add(p.Phone_Number__c);
                        }
                        
                        Account acc;
                        try{
                        acc = [SELECT Id,Phone_10_Digits__c,CreatedDate FROM Account WHERE Phone_10_Digits__c =: phNumber LIMIT 1];
                        }catch(exception e){}
                        
                        System.debug('-----account-----'+acc);
                        
                       Case recentCase;
                       for(Case cs : [Select Id From Case Where (CreatedDate >=:recentInfo.Date_Time__c OR LastModifiedDate >=: recentInfo.Date_Time__c) AND (LastModifiedBy.CZentrix_Agent_Id__c =:recentInfo.Agent_ID__c OR CreatedBy.CZentrix_Agent_Id__c  =: recentInfo.Agent_ID__c)LIMIT 1])
                       {
                            recentCase=cs;
                       }
                       if(recentCase!=Null)
                       {
                           recentInfo.Case__c=recentCase.Id;
                           update recentInfo;
                           
                           dbs.cZentrix_Status__c = 'Success';
                            dbs.cZentrix_Error_Message__c = '';
                            insert dbs;
                            
                            
                            response rs = new response();
                            rs.Status = 'Success';
                            rs.ErrorMessage = '';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                           //return '{"SessionId":"0000111","ErrorMessage":"","Status":"Success"}';
                       }
                       else if((Readyness_API_Validation_Switch__c.getInstance('Validation')!=Null && Readyness_API_Validation_Switch__c.getInstance('Validation').Active__c && ((acc==Null) || (acc!=Null && acc.CreatedDate >= recentInfo.Date_Time__c))) || (byPassedNumbers.Contains(phNumber)))
                       {
                           dbs.cZentrix_Status__c = 'Success';
                            dbs.cZentrix_Error_Message__c = 'Bypassed';
                            insert dbs;
                            
                            
                            response rs = new response();
                            rs.Status = 'Success';
                            rs.ErrorMessage = '';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                       }
                       else
                       {
                           dbs.cZentrix_Status__c = 'Failure';
                            dbs.cZentrix_Error_Message__c = 'No Cases Created/Updated for this Session';
                            insert dbs;
                            
                           response rs = new response();
                            rs.Status = 'Failure';
                            rs.ErrorMessage = 'No Cases Created/Updated for this Session';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                           //return '{"SessionId":"0000111","ErrorMessage":"No Cases Created/Updated for this Session","Status":"Failure"}';
                       }
                   }
                   else
                   {
                        CZentrix_Info__c cz_info = new CZentrix_Info__c();
                        if(allElemetsReceived.Contains('session_id'))
                        {
                            cz_info.Session_ID__c = finalXMLResult.getChildElement('session_id', null).getText();
                            dbs.cZentrix_Session_Id__c = finalXMLResult.getChildElement('session_id', null).getText();
                        }
                        if(allElemetsReceived.Contains('agent_id'))
                        {
                            cz_info.Agent_ID__c = finalXMLResult.getChildElement('agent_id', null).getText();
                        }
                        if(allElemetsReceived.Contains('call_start_date_time') && !String.IsBlank(finalXMLResult.getChildElement('call_start_date_time', null).getText()))
                        {
                            cz_info.Date_Time__c = DateTime.Valueof(finalXMLResult.getChildElement('call_start_date_time', null).getText()).addMinutes(-330);
                        }
                        if(allElemetsReceived.Contains('cust_ph_no') && !String.IsBlank(finalXMLResult.getChildElement('cust_ph_no', null).getText()))
                        {
                            cz_info.Customer_Ph_No__c = finalXMLResult.getChildElement('cust_ph_no', null).getText();
                        }
                        
                        insert cz_info;
                        
                        String phNumber = cz_info.Customer_Ph_No__c.right(10);
                        Set<String> byPassedNumbers = new Set<String>();
                        
                        System.debug('-----phNumber-----'+phNumber);
                        
                        for(Readiness_Validation_Bypass_PhoneNumbers__c p : Readiness_Validation_Bypass_PhoneNumbers__c.getAll().Values())
                        {
                            byPassedNumbers.add(p.Phone_Number__c);
                        }
                        
                        Account acc;
                        try{
                        acc = [SELECT Id,Phone_10_Digits__c,CreatedDate FROM Account WHERE Phone_10_Digits__c =: phNumber LIMIT 1];
                        }catch(exception e){}
                        
                        System.debug('-----account-----'+acc);
                        
                        Case createdCase;
                        for(Case cs : [Select Id From Case Where (CreatedDate >=:cz_info.Date_Time__c OR LastModifiedDate >=: cz_info.Date_Time__c) AND (LastModifiedBy.CZentrix_Agent_Id__c =:cz_info.Agent_ID__c OR CreatedBy.CZentrix_Agent_Id__c  =: cz_info.Agent_ID__c)LIMIT 1])
                        {
                            createdCase=cs;
                        }
                        if(createdCase!=null)
                        {
                            cz_info.Case__c=createdCase.Id;
                            update cz_info;
                            
                            dbs.cZentrix_Status__c = 'Success';
                            dbs.cZentrix_Error_Message__c = '';
                            insert dbs;
                            
                            response rs = new response();
                            rs.Status = 'Success';
                            rs.ErrorMessage = '';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                            //return '{"SessionId":"0000111","ErrorMessage":"","Status":"Success"}';
                        }
                        else if((Readyness_API_Validation_Switch__c.getInstance('Validation')!=Null && Readyness_API_Validation_Switch__c.getInstance('Validation').Active__c && ((acc==Null) || (acc!=Null && acc.CreatedDate >= cz_info.Date_Time__c))) || (byPassedNumbers.Contains(phNumber)))
                        {
                           dbs.cZentrix_Status__c = 'Success';
                            dbs.cZentrix_Error_Message__c = 'Bypassed';
                            insert dbs;
                            
                            
                            response rs = new response();
                            rs.Status = 'Success';
                            rs.ErrorMessage = '';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                        }
                        else
                        {
                            dbs.cZentrix_Status__c = 'Failure';
                            dbs.cZentrix_Error_Message__c = 'No Cases Created/Updated for this Session';
                            insert dbs;
                            
                            response rs = new response();
                            rs.Status = 'Failure';
                            rs.ErrorMessage = 'No Cases Created/Updated for this Session';
                            rs.SessionId = dbs.cZentrix_Session_Id__c;
                            return rs;
                            //return '{"SessionId":"0000111","ErrorMessage":"No Cases Created/Updated for this Session","Status":"Failure"}';
                        }
                    }
                }
                //insert dbs;
                return Null;
            }
            else
            {
                dbs.cZentrix_Status__c = 'Failure';
                dbs.cZentrix_Error_Message__c = 'No Data';
                insert dbs;
                
                response rs = new response();
                rs.Status = 'Failure';
                rs.ErrorMessage = 'Error: No Data Received';
                rs.SessionId = dbs.cZentrix_Session_Id__c;
                return rs;
                //return ' {"SessionId":"0000111","ErrorMessage":"No Data Received","Status":"Failure"}';
            }
        }
        catch(exception e)
        {
            String excep = String.Valueof(e);
            
            dbs.cZentrix_Error_Message__c = excep;
            dbs.cZentrix_Status__c = 'Failure';
            insert dbs;
            //return '{"SessionId":"0000111","ErrorMessage":"Exception Error Message","Status":"Failure"}​';
            response rs = new response();
            rs.Status = 'Failure';
            rs.ErrorMessage = 'Error: '+excep;
            rs.SessionId = dbs.cZentrix_Session_Id__c;
            return rs;
 
        }
         
    }   
    
    global class response
    {
        public String Status;
        public String ErrorMessage;
        public String SessionId;
    }
}