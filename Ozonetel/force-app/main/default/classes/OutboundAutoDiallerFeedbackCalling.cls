public class OutboundAutoDiallerFeedbackCalling {
    
    
    public OutboundAutoDiallerFeedbackCalling(){
        for(OutBound_Feedback_Calling__c busHrFed : [select id,name,ownerid,BO_id__c,BO_Name__c,Call_Back_Time__c,Call_Disposition_Status__c,Customer_Name__c,Destination__c,Phone_No__c,Source__c from OutBound_Feedback_Calling__c where id=:UserInfo.getUserid()])
        {
            system.debug('--constructor--'+busHrFed);
            
        }
    }
    @AuraEnabled(cacheable=false)
    public static List<OutBound_Feedback_Calling__c> getDetails(){
        List<OutBound_Feedback_Calling__c> busHrList = new List<OutBound_Feedback_Calling__c>();       
        map<id,OutBound_Feedback_Calling__c> mapBusHr = new map<id,OutBound_Feedback_Calling__c>();
        map<id,OutBound_Feedback_Calling__c> mapwOnerIdslst =new map<id,OutBound_Feedback_Calling__c>();
        Id outbdFdbckQueue = [Select id from Group where type='Queue' AND developername='Outbound_Feedback_Queue'].id;
        
        List<Id> avilableUserIds = new List<Id>();
        
        string curUserId=UserInfo.getUserid();
        
        system.debug('--curUserId--'+curUserId);
        
        for(OutBound_Feedback_Calling__c busHrFed : [select id,name,ownerid from OutBound_Feedback_Calling__c where Call_Status__c=null and ownerid=:curUserId])
        {
            system.debug('==24-busHrFed==='+busHrFed);
            mapBusHr.put(busHrFed.id,busHrFed); 
            mapwOnerIdslst.put(busHrFed.ownerid,busHrFed); 
            avilableUserIds.add(busHrFed.ownerid);                    
        }  
        system.debug('--.size()--'+avilableUserIds.size());
        
        datetime curTime=system.now();
        
        integer assgnedCount = avilableUserIds.isEmpty()?0:avilableUserIds.size();
       
          List<OutBound_Feedback_Calling__c> busHrFedLst =[select id,Call_Unique_Id__c,name,ownerID,BO_id__c,BO_Name__c,Call_Status__c,createddate,Call_Back_Time__c,Call_Disposition_Status__c,Customer_Name__c,Destination__c,Phone_No__c,Source__c from OutBound_Feedback_Calling__c where Call_Disposition_Status__c in ('Callback Requested','Open','New RnR','RnR') and OwnerId=:outbdFdbckQueue ORDER BY Call_Back_Time__c Limit 2];
           if(!busHrFedLst.isEmpty()){
            for(OutBound_Feedback_Calling__c busHrFed:busHrFedLst)
             {
                if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='Callback Requested' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }else if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='New RnR' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }else if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='RnR' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }else if(busHrFed.Call_Disposition_Status__c=='Open'){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }
               system.debug('==busHrList=='+busHrList); 
             }
           }else{
            for(OutBound_Feedback_Calling__c busHrFed:[select id,Call_Unique_Id__c,name,ownerID,BO_id__c,BO_Name__c,Call_Status__c,createddate,Call_Back_Time__c,Call_Disposition_Status__c,Customer_Name__c,Destination__c,Phone_No__c,Source__c from OutBound_Feedback_Calling__c where Call_Disposition_Status__c in ('Callback Requested','Open','New RnR','RnR') and OwnerId=:curUserId ORDER BY Call_Back_Time__c Limit 2])
             {
                if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='Callback Requested' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }else if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='New RnR' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                  }else if(busHrFed.Call_Back_Time__c!=null && busHrFed.Call_Disposition_Status__c=='RnR' && (curTime > busHrFed.Call_Back_Time__c)){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }else if(busHrFed.Call_Disposition_Status__c=='Open'){
                  busHrFed.ownerID=curUserId;
                  busHrList.add(busHrFed);
                }
             }
           } 
          
        Update busHrList; 
        
        return busHrList;    
    }
    
    @Auraenabled(cacheable=false)
    public static string  callToCustomer(string recId){
        
        List<User> usDet=[Select id,CZentrix_Agent_Id__c,Username from User Where id=:UserInfo.getUserid() limit 1];
        system.debug('---userName--'+usDet[0].username);
        list<OutBound_Feedback_Calling__c> busHrFedlst =[select id,Dialled_Count__c,Call_Unique_Id__c,Call_Status__c,is_Call_Connected__c,is_Error_Occurred__c,Error_Description__c,name,ownerid,BO_id__c,BO_Name__c,Call_Back_Time__c,Call_Disposition_Status__c,Customer_Name__c,Destination__c,Phone_No__c,Source__c from OutBound_Feedback_Calling__c where id=:recId ];
        
        string  respMessage;
        
        if(!busHrFedlst.isEmpty())
        {
            datetime dt=system.now();
            Long epochDate = dt.getTime()/1000;
            string leadCallUniqueId='FBC'+busHrFedlst[0].BO_id__c+epochDate;
            system.debug('leadCallUniqueId->'+leadCallUniqueId);
            string custPhonNo=busHrFedlst[0].Phone_No__c;
            custPhonNo=custPhonNo.replaceAll('[^0-9]', '');
            
            string username =usDet[0].Username;
            //'redbustestuser@redbus.com';
            //'usDet[0].Username';
            
            string jsPost='{"userId":"'+username+'","campaignId":"28","shouldAddCustomer":"false","phone":"'+custPhonNo+'","additionalParams":{"leadCallUniqueId":"'+leadCallUniqueId+'"}}';
            jsPost=json.serialize(jsPost);
            jsPost=jsPost.substring(1);
            string ameyoEndpoint=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='AmeyoOutboundCall'].Endpoint__c+jsPost;
            
            Map<String, String> headers = new Map<String, String>();
            headers.put('hash-key','fecace70bf6ea0c450c5b2071cbabc9');
            headers.put('policy-name','token-based-authorization-policy');
            headers.put('requesting-host','redbus');
            list<CaseTriggerHandler.HeadersWrapper> hlist=new list<CaseTriggerHandler.HeadersWrapper>();
            for(string o:headers.keyset()){
                hlist.add(new CaseTriggerHandler.HeadersWrapper(o,headers.get(o))); 
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);
            string jsonReqBody='{"action":"Post","body":"","endPoint":"'+ameyoEndpoint+',"headers":'+headerJson2+'}';
            System.debug('jsonReqBody-->'+jsonReqBody);
            
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse callResp=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req); 
            req.setMethod('POST');
            req.setBody(jsonReqBody);
            req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);  
            list<CZentrix_Info__c> cInfObjLst=new list<CZentrix_Info__c>();
            CZentrix_Info__c cInfObj=new CZentrix_Info__c();
            cInfObj.Call_Type__c='Feedback Dailing';
            
            callResp =h.send(req);
            System.debug('callResp-->'+callResp.getBody());
            
            if(callResp!=null && callResp.getStatusCode()==200 && String.isNotBlank(callResp.getbody()))
            {
                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(callResp.getbody());   
                
                if(resObj.containsKey('result') && string.valueof(resObj.get('result'))=='SUCCESS')
                {
                   CZentrix_Info__c updatecInfObj=new CZentrix_Info__c();
                    cInfObj.LeadCall_Id__c=leadCallUniqueId;
                    cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                    cInfObj.OutBound_Feedback_Calling__c=busHrFedlst[0].id;
                    cInfObj.Campaign_Name__c='BusHire Feedback Calling';
                    cInfObj.Creation_Hour__c = DateTime.now().hour();   
                    cInfObj.BO_Phone_Number__c=custPhonNo;                        
                    cInfObj.Message__c='Success';
                    cInfObj.Agent_ID__c =usDet[0].username;                   
                    insert cInfObj;
                    
                    busHrFedlst[0].is_Call_Connected__c=true;
                    busHrFedlst[0].Call_Unique_Id__c=leadCallUniqueId;
                    busHrFedlst[0].Call_Status__c='Success';
                    if(busHrFedlst[0].Dialled_Count__c==null){
                      busHrFedlst[0].Dialled_Count__c=1;
                    }else{
                      busHrFedlst[0].Dialled_Count__c=busHrFedlst[0].Dialled_Count__c+1;
                    }
                        
                    
                     
                    Update busHrFedlst;
                    
                    respMessage='Call will be connect soon';
                    return respMessage;
                    
                }
                else if((resObj.containsKey('result') && string.valueof(resObj.get('result'))=='FAILURE') || (resObj.containsKey('status') && string.valueof(resObj.get('status'))=='error'))
                {
                    string reason='Something went wrong!!';
                    if(resObj.containsKey('reason')){
                        reason=string.valueof(resObj.get('reason'));
                    }
                    CZentrix_Info__c updatecInfObj=new CZentrix_Info__c();
                    cInfObj.Update_Type__c = 'Feedback calling Real Time';   
                    cInfObj.LeadCall_Id__c=leadCallUniqueId;
                    cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                    cInfObj.OutBound_Feedback_Calling__c=busHrFedlst[0].id;
                    cInfObj.Campaign_Name__c='Feedback Calling';
                    cInfObj.Creation_Hour__c = DateTime.now().hour();   
                    cInfObj.BO_Phone_Number__c=custPhonNo;                        
                    cInfObj.Message__c='FAILURE';
                    cInfObj.Agent_ID__c =usDet[0].username; 
                    insert cInfObj;
                    
                    busHrFedlst[0].is_Error_Occurred__c = true;
                    busHrFedlst[0].Call_Status__c='Failed';
                    busHrFedlst[0].Call_Unique_Id__c=leadCallUniqueId;
                    busHrFedlst[0].Error_Description__c =reason;
                    if(busHrFedlst[0].Dialled_Count__c==null){
                      busHrFedlst[0].Dialled_Count__c=1;
                    }else{
                      busHrFedlst[0].Dialled_Count__c=busHrFedlst[0].Dialled_Count__c+1;
                    }
                    
                    if(busHrFedlst[0].Call_Status__c=='Failed' && busHrFedlst[0].Dialled_Count__c==3){
                       busHrFedlst[0].Call_Disposition_Status__c ='Manual Retry';
                     } 
                    update busHrFedlst;
                    
                    respMessage='Something went wrong';
                    return respMessage;
                }else{     
                    CZentrix_Info__c updatecInfObj=new CZentrix_Info__c();
                    cInfObj.Update_Type__c = 'Feedback calling Real Time';   
                    cInfObj.LeadCall_Id__c=leadCallUniqueId;
                    cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                    cInfObj.OutBound_Feedback_Calling__c=busHrFedlst[0].id;
                    cInfObj.Campaign_Name__c='Feedback Calling';
                    cInfObj.Creation_Hour__c = DateTime.now().hour();   
                    cInfObj.BO_Phone_Number__c=custPhonNo;                        
                    cInfObj.Message__c='Call connection failed, Did not received correct response from Ameyo';
                    cInfObj.Agent_ID__c =usDet[0].username; 
                    insert cInfObj;
                    
                    busHrFedlst[0].Call_Unique_Id__c=leadCallUniqueId;
                    busHrFedlst[0].Call_Status__c='Failed';
                    busHrFedlst[0].is_Error_Occurred__c = true;
                    busHrFedlst[0].Error_Description__c ='Call connection failed, Did not received correct response from Ameyo';
                    if(busHrFedlst[0].Dialled_Count__c==null){
                      busHrFedlst[0].Dialled_Count__c=1;
                    }else{
                      busHrFedlst[0].Dialled_Count__c=busHrFedlst[0].Dialled_Count__c+1;
                    }
                     
                    if(busHrFedlst[0].Call_Status__c=='Failed' && busHrFedlst[0].Dialled_Count__c==3){
                       busHrFedlst[0].Call_Disposition_Status__c ='Manual Retry';
                     } 
                      
                    update busHrFedlst;
                    
                    respMessage= 'Call connection failed';
                    return respMessage;
                }                               
            }                           
            else
            {
                CZentrix_Info__c updatecInfObj=new CZentrix_Info__c();
                cInfObj.Update_Type__c = 'Feedback calling Real Time';   
                cInfObj.LeadCall_Id__c=leadCallUniqueId;
                cInfObj.OutBound_Feedback_Calling__c=busHrFedlst[0].id;
                cInfObj.Campaign_Name__c='Feedback Calling';
                cInfObj.Creation_Hour__c = DateTime.now().hour();   
                cInfObj.BO_Phone_Number__c=custPhonNo;                        
                cInfObj.Message__c='No Response Received From Telephony Service Provider';
                cInfObj.Agent_ID__c =usDet[0].username; 
                insert cInfObj;
                
                busHrFedlst[0].Call_Unique_Id__c=leadCallUniqueId;
                busHrFedlst[0].Call_Status__c='Failed';
                busHrFedlst[0].is_Error_Occurred__c= true;
                busHrFedlst[0].Error_Description__c = 'No Response Received From Telephony Service Provider';
                if(busHrFedlst[0].Dialled_Count__c==null){
                    busHrFedlst[0].Dialled_Count__c=1;
                  }else{
                   busHrFedlst[0].Dialled_Count__c=busHrFedlst[0].Dialled_Count__c+1;
                 }
                   
               
               if(busHrFedlst[0].Call_Status__c=='Failed' && busHrFedlst[0].Dialled_Count__c==3){
                   busHrFedlst[0].Call_Disposition_Status__c ='Manual Retry';
                 }
                         
                update busHrFedlst;
                
                respMessage= 'No Response from Ameyo';
                return respMessage;
            }
            
            
        }else{
                CZentrix_Info__c cInfObjInsert=new CZentrix_Info__c();
                cInfObjInsert.Update_Type__c = 'Feedback calling Real Time';   
                cInfObjInsert.Campaign_Name__c='Feedback Calling';
                cInfObjInsert.Creation_Hour__c = DateTime.now().hour();                       
                cInfObjInsert.Message__c='No leads';
                insert cInfObjInsert;
              }  
        return 'Currently No Leads Are Availabe For Dialing';
    }
    
}