public class LiveAgentRESTAPIPageCntrl {
    
    public class SessionRespCls
    {
        public string id { get; set; }
        public string key { get; set; }
        public string affinityToken { get; set; }
        public string clientPollTimeout { get; set; }
    }

    public void getSessionId() {
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('X-LIVEAGENT-API-VERSION','54');
       // headerMap.put('X-LIVEAGENT-AFFINITY','NULL');
       // headerMap.put('Content-Type','application/json');
        
      //  HttpResponse res = HTTPUtil.sendHTTPRequest('https://d.la1-core1.sfdc-y37hzm.salesforceliveagent.com/chat/rest/System/SessionId','GET',120000,'',headerMap,null);
         //System.Label.CZentrix_Bangalore_Session_API+ud.CZentrix_Agent_Id__c+'&resFormat=0';
          string URL;
           URL=System.Label.TestSalesforceliveagentSessionId+'chat/rest/System/SessionId';
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('X-LIVEAGENT-API-VERSION','54');
        req.setHeader('X-LIVEAGENT-AFFINITY','null');
        
        HttpResponse res = ht.send(req);
         string responseValue = res.getBody();
           apiResp = responseValue;
            if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue))
            {
                LiveAgentRESTAPIPageCntrl.SessionRespCls se = new LiveAgentRESTAPIPageCntrl.SessionRespCls();
                se = (LiveAgentRESTAPIPageCntrl.SessionRespCls)JSON.deserialize(responseValue,LiveAgentRESTAPIPageCntrl.SessionRespCls.class);
                sessionId = se.id;
                sessionKey= se.key;
                affinityToken = se.affinityToken;
                clientPollTimeout = se.clientPollTimeout;                
            
            }
    }


    public PageReference sendMessage() {
        return null;
    }


    public void getChasitorInit() {
    
    string orgId=System.Label.TestChatOrgId;
    string buttonId=System.Label.TestChatButtonId;
    string deplymntId=System.Label.TestChatDeploymentId;
    String reqBody ='{"organizationId":"'+orgId+'","buttonId":"'+buttonId+'","deploymentId":"'+deplymntId+'","userAgent":"","language":"en-US","screenResolution":"1920x1080","visitorName":"John A","prechatDetails":[],"prechatEntities":[],"receiveQueueUpdates":true,"isPost":true,"sessionId":"'+sessionId+'"}';
        
        string URL;
           URL=System.Label.TestSalesforceliveagentSessionId+'chat/rest/Chasitor/ChasitorInit';
           
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL);
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('X-LIVEAGENT-API-VERSION','54');
        req.setHeader('X-LIVEAGENT-AFFINITY',affinityToken);
        req.setHeader('X-LIVEAGENT-SESSION-KEY',sessionKey);
        req.setHeader('X-LIVEAGENT-SEQUENCE','1');
        compReqBody = reqBody;
        req.setBody(reqBody);
        
        HttpResponse res = ht.send(req);
        string responseValue = res.getBody();
        apiResp2 = responseValue;
        visStatus = res.getStatus();
        visStatusCode = res.getStatusCode();        
        pullAgentMsgs(affinityToken,sessionKey);
     }  
     
     public static void dummyFetch()
     {
                

     }
     
     
@Future(callout=true)
  public static void pullAgentMsgs(String affinityToken1,String sessionKey1)
     {
        if(true) //visStatus=='OK'
        {
         Integer seqAck = -1;
         
         Live_Chat_Monitor__c l = new Live_Chat_Monitor__c();
         l.Chat_Session_Key__c = sessionKey1;
         
         
         do
         {
         string URL;
           URL=System.Label.TestSalesforceliveagentSessionId+'chat/rest/System/Messages?ack='+seqAck;
           
           //https://d.la1-c1cs-ukb.salesforceliveagent.com/chat/rest/System/Messages?ack='+seqAck
           
            Http ht1 = new Http();
            HttpRequest req1 = new HttpRequest ();
            req1.setEndpoint(URL);
            req1.setMethod('GET');
            req1.setTimeout(120000);
            req1.setHeader('X-LIVEAGENT-API-VERSION','34');
            req1.setHeader('X-LIVEAGENT-AFFINITY',affinityToken1);
            req1.setHeader('X-LIVEAGENT-SESSION-KEY',sessionKey1);
                   
            HttpResponse res1 = ht1.send(req1);
            apiResp3 = res1.getBody();
            msgsStatus = res1.getStatus();
            msgsStatusCode = res1.getStatusCode();
            System.debug('..apiResp3...'+apiResp3);
            l.Reason__c = l.Reason__c+'...sequnce..'+seqAck+'...body...'+STring.valueOf(apiResp3);
           
            
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The latest value..at -'+System.now()+'..'+apiResp3)); 
            
            if(String.isNotBlank(apiResp3))
            {
            map<string,object> callObjMap= (map<string,object>)JSON.deserializeUntyped(apiResp3);
            
            seqAck = Integer.valueOf(callObjMap.get('sequence'));
            }
            
            if(Integer.valueOf(msgsStatusCode) != 200 && Integer.valueOf(msgsStatusCode)!= 204) {
                break; // We didn't get a valid response
             }
  
          }While(true);
           upsert l;
        
        }
        
           
    }



    public String msgText{get;set;}
    public String agentMsgText{get;set;}
    public String sessionId{get;set;}
    public String sessionKey{get;set;}
    public String affinityToken{get;set;}
    public string clientPollTimeout{get;set;}
    public Integer visStatusCode{get;set;}
    public String visStatus{get;set;}
    public string apiResp{get;set;}
     public string apiResp2{get;set;}
      public static string apiResp3{get;set;}
      public string compReqBody{get;set;}
       public static Integer msgsStatusCode{get;set;}
    public static String msgsStatus{get;set;}


    
    public LiveAgentRESTAPIPageCntrl()
    {
    
    }
    

}