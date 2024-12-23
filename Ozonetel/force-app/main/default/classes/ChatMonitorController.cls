public class ChatMonitorController {

    @AuraEnabled    
        public static string getGptPrompt(string userMessage, string recordId){
            string messageToReturn;
            string promptLabel = System.Label.testPromptsMsgSuggestions;
            List<String> userPromptList = promptLabel.split(',');
            
            LiveChatTranscript lct = [SELECT Id,OrderItem_Uuid__c,Contact.Transaction_Id__c,Issue_Type__c,Sub_Issue_Type__c,Chat_Session_Key__c FROM LiveChatTranscript WHERE Id=:recordId LIMIT 1];
            Live_Chat_Monitor__c chatMonitorData = [SELECT Id,AgentLastMessage__c FROM Live_Chat_Monitor__c WHERE Chat_Session_Key__c=:lct.Chat_Session_Key__c LIMIT 1];
            list<Order_Items__c> orItemLst =[SELECT Id,Order_Uuid__c,Guid__c,Vendor_PNR__c,Amount_Recieved_Currency__c,Service_Provider_Id__c,Service_Provider_Name__c,Service_Provider_Reference_No__c,Route_Id__c, Date_Of_Service__c,ServiceID__c,Business_Unit__c,Order_Item_Reference_No__c FROM Order_Items__c where Guid__c =:lct.Contact.Transaction_Id__c];
    
            System.debug(':: Transaction_Id__c = '+lct.Contact.Transaction_Id__c);
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c='GPT UserMessage';   
            // if(String.isNotBlank(userMessage) && String.isNotBlank(recordId) && userMessage.length()>15 && lct.OrderItem_Uuid__c!= null ){
            if(String.isNotBlank(userMessage) && String.isNotBlank(recordId)){
                string genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c;    
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='getGPTSuggestionMessage'];
                string endpoint=APIMData.Endpoint__c;
                string jsBody='{ "message" :"'+userMessage+'","orderItemUUID" :"'+lct.Contact.Transaction_Id__c+'", "lastAgentReply" :"'+chatMonitorData.AgentLastMessage__c+'", "issueType" :"'+lct.Issue_Type__c+'",  "subIssueType" :"'+lct.Sub_Issue_Type__c+'"}';
                // string jsBody='{ "message" :"'+userMessage+'","orderItemUUID" :"'+recordId+'" }';
                jsBody=JSON.serialize(jsBody);
                system.debug('jsBody-->'+jsBody);
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                headers.put('X-CLIENT', 'SELF_HELP');
                list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                for(string o:headers.keyset()){
                    hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o))); 
                }
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);   
    
                string jsonCM='{"action":"POST","body":'+jsBody+',"endPoint":"'+endpoint+'","headers":'+headerJson2+'}';
                System.debug('jsonCM-->'+jsonCM);
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Channel_Name','WEB_DIRECT');
                req.setHeader('Content-Type','application/json');
                req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                req.setHeader('Country_Name', 'IND'); 
                req.setHeader('BusinessUnit', 'BUS');  
                req.setHeader('Language', 'en');             
                req.setMethod('POST');
                // req.setTimeout(120000);              
                req.setEndpoint(APIMData.Endpoint__c);
                req.setMethod('POST');
                req.setBody(jsonCM);
                System.debug('req-->'+req.getBody());
                try{
                    res = http.send(req);  
                    string jsonResponse = res.getBody();
                    dbl.Request_Data__c = string.valueOf(req.getBody())+jsonCM;
                    dbl.Response_Received__c = jsonResponse;
                    insert dbl;
                    
                    system.debug(':: ResponseBody = '+jsonResponse);
                    if(res.getstatuscode()==200 && res.getStatus()=='OK' && String.isNotBlank(res.getbody())){
                        gptResponseWrapper apiResponse = (gptResponseWrapper)JSON.deserialize(jsonResponse, gptResponseWrapper.class);
                       string respStatus =apiResponse.status;
                        if(respStatus=='SUCCESS'){
                           messageToReturn = apiResponse.data.message;
                           // boolean callAgent =apiResponse.data.callAgent;
                           
                          if(apiResponse.data.callAgent != null){
                             for (String promptLabelmsg : userPromptList) {
                                if (userMessage.toLowerCase().contains(promptLabelmsg.toLowerCase().trim())) {
                                 String resp ;
                                 if (promptLabelmsg.equalsIgnoreCase('Boarding Point') || promptLabelmsg.equalsIgnoreCase('Boarding Point Issue')) {
                                    
                                      resp = 'Your boarding point is at +bp+, +city+. The boarding time is at +boarding time+. Is this information helpful to you?';
    
                                    }
                                   return 'Please try -callgent true'; 
                                }
                              }
                          }else{
                          
                            return messageToReturn;
                          }
                        
                        }else{
                          //retry mech
                           return 'Please try-error';
                        }
                    }else{
                        messageToReturn = 'No suggestion found. Please go ahead with your reply!';
                        return messageToReturn;
                    }
                }catch(Exception e){
                    system.debug(':: Exception has occured at Line no: '+e.getLineNumber()+' with an error message - '+e.getMessage());
                    messageToReturn = 'No suggestion found. Please go ahead with your reply!';
                    return messageToReturn;
                }
                
            }
                messageToReturn = 'No suggestion found. Please go ahead with your reply!';
                return messageToReturn;
            
        }
        @AuraEnabled    
        public static user fetchUser(){
            User oUser = [select id,Name,Username,Alias,Country,Email,FirstName,LastName 
                          FROM User Where id =: userInfo.getUserId()];
            return oUser;
        }
        @AuraEnabled
        public static void onChatAccepted(string sessionKey ){
            system.debug('<<on chat Accepted sessionKey: '+sessionKey);
            List<LiveChatTranscript> lct = [select Chat_Session_Key__c from LiveChatTranscript where id =:sessionKey];
            List<MessagingSession> msList= [select name from MessagingSession where id=:sessionKey ];
            List<Live_Chat_Monitor__c> lmc = new List<Live_Chat_Monitor__c>();
            if(lct.size()>0){
                system.debug('<<<lct'+lct);
                lmc= [select id,Full_Transcript__c,Name,AgentLastMessage__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c ];                    
            }
            else if(msList.size()>0){
                system.debug('msList: '+msList);
                lmc= [select id,Full_Transcript__c,Name,AgentLastMessage__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:msList[0].name ];                 
            }
            if(lmc.size()>0){
                lmc[0].Action__c='Chat Accepted';
                lmc[0].AgentLastMessage__c='Hello! This is '+' '+userinfo.getName()+' from redBus! Please suggest how can I help you.';
                lmc[0].Full_Chat_Transcript__c=lmc[0].AgentLastMessage__c;
                lmc[0].Full_Chat__c= lmc[0].AgentLastMessage__c;
                lmc[0].Full_Transcript__c ='Agent :'+lmc[0].AgentLastMessage__c;
                update lmc[0];
            }
            else{
                Live_Chat_Monitor__c lm = new Live_Chat_Monitor__c();
                lm.Action__c='Chat Accepted';
                if(lct.size()>0){
                    system.debug('lct: '+lct);
                    lm.Chat_Session_Key__c=lct[0].Chat_Session_Key__c;            
                }
                else if(mslist.size()>0){
                    system.debug('msList: '+msList);
                    lm.Chat_Session_Key__c=mslist[0].name;                
                }
                lm.AgentLastMessage__c='Hello! This is '+' '+userinfo.getName()+' from redBus! Please suggest how can I help you.';
                lm.Full_Chat_Transcript__c=lm.AgentLastMessage__c;
                lm.Full_Chat__c=lm.AgentLastMessage__c;
                lm.Full_Transcript__c ='Agent :'+lm.AgentLastMessage__c;
          if(lm.Chat_Session_Key__c != null && lm.Chat_Session_Key__c !='')
                insert lm;
            }
        }
        @AuraEnabled
        public static void onChatEndMsg(string sessionKey){
            system.debug('<<<entered end chat');
            list<LiveChatTranscript> lct = [select Chat_Session_Key__c from LiveChatTranscript where id =:sessionKey];
            List<MessagingSession> msList= [select name from MessagingSession where id=:sessionKey ];
            List<Live_Chat_Monitor__c> lmc = new List<Live_Chat_Monitor__c>();
            if(lct.size()>0){
                system.debug('<<<lct'+lct);
                lmc= [select id,Name,AgentLastMessage__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c ];                    
            }
            else if(msList.size()>0){
                system.debug('msList: '+msList);
                lmc= [select id,Name,AgentLastMessage__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:msList[0].name ];                 
            }
            if(lmc.size()>0){
                lmc[0].Action__c='Chat Ended';
                OpenAIChatGptCntrl.GetChatSummarize(lmc[0].id);
                update lmc[0];            
            }
            else{
                Live_Chat_Monitor__c lm = new Live_Chat_Monitor__c();
                if(lct.size()>0)
                    lm.Chat_Session_Key__c=lct[0].Chat_Session_Key__c;
                else if(msList.size()>0)
                    lm.chat_session_key__c = msList[0].name;
                lm.Action__c='Chat Ended';
          if(lm.Chat_Session_Key__c != null && lm.Chat_Session_Key__c !='')
                insert lm;
            }        
        }
        @AuraEnabled
        public static void onAgentMsg(string sessionKey, string content, string name, Datetime timestamp){
            system.debug('<<<<sessionKey'+sessionKey+'<<content'+content);
            List<LiveChatTranscript> lct = [select Chat_Session_Key__c,OperatorMessageCount from LiveChatTranscript where id =:sessionKey];
            List<MessagingSession> msList= [select name,AgentMessageCount from MessagingSession where id=:sessionKey ];
            
            //if((lct.size()>0 && lct[0].OperatorMessageCount>1) || (mslist.size()>0 && mslist[0].AgentMessageCount>1)){        
                List<Live_Chat_Monitor__c> lmc= new List<Live_Chat_Monitor__c>();
                if(lct.size()>0){
                    system.debug('lct: '+lct);
                    lmc = [select id,Full_Transcript__c,Name,AgentFirstMessage__c,Agent_First_Message_Time__c,AgentLastMessage__c,Attachment_URL__c,Agent_Last_Reply__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c];            
                }
                else if(msList.size()>0){
                    system.debug('msList: '+msList);
                    lmc= [select id,Full_Transcript__c,Name,AgentFirstMessage__c,Agent_First_Message_Time__c,AgentLastMessage__c,Attachment_URL__c,Agent_Last_Reply__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:msList[0].name ];                         
                }
                system.debug('<<<lmc'+lmc);
                if(lmc.size()>0){
                    lmc[0].Action__c='Agent Replied';
                    lmc[0].Full_Chat_Transcript__c = lmc[0].Full_Chat_Transcript__c+'<br>('+timestamp+') Agent:'+content;
                    lmc[0].Full_Chat__c = lmc[0].Full_Chat__c+'<br>('+timestamp+') Agent:'+content;
                    lmc[0].Full_Transcript__c = lmc[0].Full_Transcript__c+ 'Agent:'+content;
                    
                    if(lmc[0].AgentFirstMessage__c  == null){
                       lmc[0].AgentFirstMessage__c =  content; // Store the agent's first message
                       lmc[0].Agent_First_Message_Time__c = System.now(); // Store the timestamp of the agent's first message
                    }
                    
                    lmc[0].AgentLastMessage__c=content;
                    lmc[0].Agent_Last_Reply__c=system.now();
    
                    lmc[0].Attachment_URL__c='';
                    if(string.isNotBlank(content) && content.contains(System.Label.ChatAWSURL)){
                    lmc[0].Attachment_URL__c=content;
                    lmc[0].AgentLastMessage__c='(AAT)'+content;
                    }
                    update lmc[0];            
                }
                else{
                    Live_Chat_Monitor__c lm = new Live_Chat_Monitor__c();
                    if(lct.size()>0)
                        lm.Chat_Session_Key__c=lct[0].Chat_Session_Key__c;
                    else if(msList.size()>0)
                       lm.chat_session_key__c = msList[0].name;
                    lm.Action__c='Agent Replied';
                    lm.AgentLastMessage__c=content;
                    lm.Full_Chat_Transcript__c='('+timestamp+') Agent:'+content;                
                    lm.Full_Chat__c='('+timestamp+') Agent:'+content;
                    lm.Full_Transcript__c =  'Agent:'+content;
                    if(lm.AgentFirstMessage__c  == null){
                       lm.AgentFirstMessage__c =content; // Store the agent's first message
                       lm.Agent_First_Message_Time__c = System.now(); // Store the timestamp of the agent's first message
                    }
                    
                    lm.Agent_Last_Reply__c=system.now();
                    lm.Attachment_URL__c='';
                    if(string.isNotBlank(content) && content.contains(System.Label.ChatAWSURL)){
                    lm.Attachment_URL__c=content;
                    lm.AgentLastMessage__c='(AAT)'+content;
                    }
                    system.debug('lm: '+lm);
            if(lm.Chat_Session_Key__c != null && lm.Chat_Session_Key__c !='')
                    insert lm;
                }
    
                List<User_Details__c> userdetailsList = new List<User_Details__c>();
                DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
                ddObj=[select id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName='OmniOnlineMissingAgents'];
                userdetailsList=database.query(ddObj.QueryDetails__c);
                if(!userdetailsList.isEmpty()){
                    userdetailsList[0].Logout_Time__c=null;
                    update userdetailsList[0];
                }
            //}
            
        }
        @AuraEnabled
        
        public static void onUsermessageSent(string sessionKey,string content, string name, datetime timestamp){
            system.debug('sessionKey'+sessionKey);
            system.debug('<<<<sessionKey'+sessionKey+'<<content'+content);
            List<LiveChatTranscript> lct = [select Chat_Session_Key__c from LiveChatTranscript where id =:sessionKey];
            List<MessagingSession> msList= [select name from MessagingSession where id=:sessionKey ];
            
            
            List<Live_Chat_Monitor__c> lmc= new List<Live_Chat_Monitor__c>();
        if(lct.size()>0)
              lmc = [select id,Full_Transcript__c,Name,UserFirstMessage__c,User_First_Message_Time__c,User_Last_Message__c,AgentLastMessage__c,User_Last_Reply__c,Full_Chat_Transcript__c,Full_Chat__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c];
             else if(msList.size()>0)
                lmc= [select id,Full_Transcript__c,Name,UserFirstMessage__c,User_First_Message_Time__c,User_Last_Message__c,AgentLastMessage__c,User_Last_Reply__c,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:msList[0].name ];                         
            system.debug('<<<lmc'+lmc);
            if(lmc.size()>0){
    //            lmc[0].Action__c='User Replied';
                lmc[0].Full_Chat_Transcript__c = lmc[0].Full_Chat_Transcript__c+'<br>('+timestamp+') User:'+content;
                lmc[0].Full_Chat__c = lmc[0].Full_Chat__c+'<br>('+timestamp+') User:'+content;
                lmc[0].User_Last_Reply__c=system.now();
                lmc[0].Full_Transcript__c =  lmc[0].Full_Transcript__c+'User:'+content;
                
                if (lmc[0].UserFirstMessage__c == null) {
                    lmc[0].UserFirstMessage__c = content;
                    lmc[0].User_First_Message_Time__c = timestamp;
                }
               lmc[0].User_Last_Message__c = content;
              
                update lmc[0];            
            }
            else{
                Live_Chat_Monitor__c lm = new Live_Chat_Monitor__c();
                if(lct.size()>0)
                    lm.Chat_Session_Key__c=lct[0].Chat_Session_Key__c;
                else if(msList.size()>0)
                  lm.chat_session_key__c = msList[0].name;
    //            lm.Action__c='User Replied';
                lm.Full_Chat_Transcript__c='('+timestamp+') User:'+content;
                lm.Full_Chat__c='('+timestamp+') User:'+content;
                lm.Full_Transcript__c = 'User:'+content;
                lm.User_Last_Reply__c=system.now();
                if (lm.UserFirstMessage__c == null) {
                    lm.UserFirstMessage__c = content;
                    lm.User_First_Message_Time__c = timestamp;
                }
                lm.User_Last_Message__c = content;
                
                if(lm.Chat_Session_Key__c != null && lm.Chat_Session_Key__c !='')
                insert lm;
            }
            
        }
        
        // GPT Response Wrapper.
        public class AgentConnectData
        {
            public string issue { get; set; }
            public string subIssue { get; set; }
            public string summary { get; set; }
        }
    
        public class Data
        {
            public AgentConnectData agentConnectData { get; set; }
            public boolean callAgent { get; set; }
            public boolean collectFeedback { get; set; }
            public boolean continueChat { get; set; }
            public string llmVersion { get; set; }
            public string message { get; set; }
            public boolean userInitiatedPartialCancellation { get; set; }
        }
    
        public class Errors
        {
        }
    
        public class gptResponseWrapper
        {
            public Data data { get; set; }
            public Errors errors { get; set; }
            public string status { get; set; }
        }
    }