/**
* (c) 2019 RedBus
*
* Name           : BusHireAutoDailerCntrl
* Created Date   : 05 Jan 2019
* Created By     : Sreenivas M
* Purpose        : Controller class for BusHireAutoDailerPage 
*
**/

public class BusHireAutoDailerCntrl{
public User_Details__c usDet{get;set;}
public list<Lead> listLeads{get;set;}
public boolean assignmentLeadBt{get;set;}
public string leadQuery;
public list<Lead> listlast5CallLeads{get;set;}
Map<String,String> mapQueries;
public Id loggedInUserId ; 
public user uObj; 
public BusHireAutoDailerCntrl bd;
public string agentStatus{get;set;}


    public BusHireAutoDailerCntrl()
    {
       assignmentLeadBt=true;
       loggedInUserId =UserInfo.getUserId(); 
       System.debug('loggedInUserId ->'+loggedInUserId );
       uObj=[select id,username,Group__c,Primary__c,CZentrix_Agent_Id__c from user where id=:loggedInUserId]; 
        listLeads = new List<Lead>();
        listlast5CallLeads = new List<Lead>();
        usDet = new User_Details__c();
        mapQueries = new Map<String,String>();
        leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='My_Leads'].query__c;
        for(DataDeletionSetup__mdt dd:[SELECT Id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName IN('BusHireAutoDailerRnR','BusHireAutoDailerInProgress','BusHireAutoDailerLast5Calls','BusHireAutoDailerNew','BusHireAutoDailerRnrInprogress','BusHireAutoDailerCallBack','My_Leads')])
        {
            mapQueries.put(dd.DeveloperName,dd.QueryDetails__c);
        }
        
        getAgentCallDetails();      
    }
    
    public void UpdateAgentStatus(){
    System.debug('test->');
    list<User_Details__c> listUserDetails=new list<User_Details__c>();
    listUserDetails=[select id,AgentStatus__c from User_Details__c where User__c=:UserInfo.getUserID() AND CreatedDate=Today limit 1];
    try{
    if(!listUserDetails.isEmpty()){
    listUserDetails[0].AgentStatus__c = agentStatus;
                            listUserDetails[0].CZ_Status_Updated_Hour__c = DateTime.now().hour();
                            listUserDetails[0].AgentStatus__c=agentStatus;
                          /*  if('ready'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c) || 'UnPaused'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c) || 'Progressive'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c))
                            {
                                listUserDetails[0].Next_Call_Time__c = System.now().addMinutes(1);
                                LeadAssignment ldAss = new LeadAssignment();
                                ldAss.LeadRouting(listUserDetails[0].UserId__c,'Agent Status Change');                                
                            }
                            
                            else
                                listUserDetails[0].Next_Call_Time__c = null;
                            
                            if(listUserDetails[0].AgentStatus__c=='Logoff'){
                               list<lead> ldList=new list<lead>();
                               ldList=[select id,ownerid from lead where ownerid=:listUserDetails[0].UserId__c];
                               Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
                               Id busHireQueue= [Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
                               list<lead> ldUpList=new list<lead>();
                               for(lead l:ldList)
                               {
                                  l.ownerid='New'.equalsIgnoreCase(l.status)?busHireQueue:busComQueue;  
                                  ldUpList.add(l);
                               }
                               
                               if(!ldUpList.isEmpty()){
                                    Database.saveResult[] leadUpdateResult = Database.update(ldUplist,false);
                               }                              
                               listUserDetails[0].Assigned_Cases_Count__c=listUserDetails[0].Assigned_Cases_Count__c-ldList.size();
                            }
                            */
                            Database.saveResult updateResult = Database.update(listUserDetails[0],false);
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Status Updated Succesfully!!'));

                            
                          
    }
    }catch(exception e){    
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Update Failed->'+e));
    }
    }
    
    public void getAgentCallDetails()
    {
        Id loggedInUserId =UserInfo.getUserId();
        user uObj=[select id,Group__c from user where id=:loggedInUserId];
        list<User_Details__c> listUserDet = new List<User_Details__c>();
        List<Id> listIds = new List<Id>();
        listLeads.clear();
        listlast5CallLeads.clear();
        
        listUserDet = [SELECT UserId__c,Last_5_Lead_Ids__c,is_Error_Occurred__c,Error_Description__c ,User__r.Phone,Last_Call_Start_Time__c,C_Zentrix_Id__c,Last_Call_End_Time__c,Next_Call_Time__c,User__r.username,User__r.CZentrix_Agent_Id__c,AgentStatus__c from User_Details__c where User__c=:UserInfo.getUserID() AND CreatedDate=Today];
        if(!listUserDet.isEmpty())
        {
            usDet = listUserDet[0];
            if(String.isNotBlank(usDet.Last_5_Lead_Ids__c))
               listIds = usDet.Last_5_Lead_Ids__c.split(',');  
            
        }
            
        if(!listIds.isEmpty())
        {
            listlast5CallLeads = DataBase.query(mapQueries.get('BusHireAutoDailerLast5Calls'));
        }
        datetime currTime=System.now();
        datetime currMinHr=System.now().addMinutes(-60);
        if(uObj.Group__c=='Group 1'){ 
            listLeads = DataBase.query(leadQuery); 
        }else if(uObj.Group__c=='Group 2'){
          leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='My_Leads2'].query__c;
          listLeads = DataBase.query(leadQuery); 
        }
        for(Lead l:listLeads){        
           if(listIds.contains(l.id)){
             // listLeads.remove(l);
           } 
        }
        
        if(listLeads.isEmpty()){
            assignmentLeadBt=false;
        }
        
    }
    public void callToCustomer()
    {
        System.debug('entered inside calling part..');
        String isError='';
        try
        {
            if(string.isNotBlank(usDet.C_Zentrix_Id__c))
            {
                if(listLeads.isEmpty())
                {
                   isError = 'Currently No Leads Are Availabe For Dialing';
                   usDet.is_Error_Occurred__c = true;
                   usDet.Error_Description__c = 'Currently No Leads Are Availabe For Dialing';
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Currently No Leads Are Availabe For Dialing.Please Try After Some Time'));
                }
                else
                {
                    string agentId =usDet.C_Zentrix_Id__c;
                    string seatsllrAgntNoOrCustmPhone='';
                    string channel =listLeads[0].Channel__c;
                                          
                    if(usDet.AgentStatus__c=='Available')
                    {
                       
                            //system.debug('DEBUG1-->>'+agentAvilResp.response+'agntrespagndtl-->>'+agentAvilResp.response.agent_detail+'Free-->>'+agentAvilResp.response.agent_detail.agentstate+'bushire_services-->>'+agentAvilResp.response.agent_detail.campaign_name+'SUCCESS-->>'+agentAvilResp.response.status);
                            system.debug('phone-->>'+listLeads[0].Phone+''+listLeads[0].Agent_Mobile__c);
                            if('RB_IND_SEATSELLER'.equalsIgnoreCase(channel)){
                              seatsllrAgntNoOrCustmPhone=listLeads[0].Agent_Mobile__c;
                            }else{
                               seatsllrAgntNoOrCustmPhone=listLeads[0].Phone;
                            }
                           datetime dt=system.now();
                           Long epochDate = dt.getTime()/1000;
                           string leadCallUniqueId='L'+listLeads[0].TCode__c+epochDate;
                           system.debug('leadCallUniqueId->'+leadCallUniqueId);
                           string custPhonNo=listLeads[0].Phone;
                           custPhonNo=custPhonNo.replaceAll('[^0-9]', '');

                          //  string jsPost='{"userId":"rohit","campaignId":"28","shouldAddCustomer":"false","phone":"9491322718","additionalParams":{"leadCallUniqueId":"'+leadCallUniqueId+'"}}';
                           // string jsPost='{"userId":"redbustestuser@redbus.com","campaignId":"29","shouldAddCustomer":"false","phone":"'+listLeads[0].Phone+'","additionalParams":{"leadCallUniqueId":"'+leadCallUniqueId+'"}}';
                            string jsPost='{"userId":"'+usDet.User__r.username+'","campaignId":"28","shouldAddCustomer":"false","phone":"'+custPhonNo+'","additionalParams":{"leadCallUniqueId":"'+leadCallUniqueId+'"}}';
                            jsPost=json.serialize(jsPost);
                            jsPost=jsPost.substring(1);
                            //string ameyoEndpoint='https://cc.redbus.in:8443/ameyowebaccess/command?command=clickToDialWithToken&data=\\'+jsb;
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
                            CZentrix_Info__c cInfObj=new CZentrix_Info__c();
                            cInfObj.Call_Type__c='BusHire Auto Dailing';
                            
                            callResp =h.send(req);
                            System.debug('callResp-->'+callResp.getBody());
                            if(callResp!=null && callResp.getStatusCode()==200 && String.isNotBlank(callResp.getbody()))
                            {
                                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(callResp.getbody());   
                                                           
                                if(resObj.containsKey('result') && string.valueof(resObj.get('result'))=='SUCCESS')
                                //if(string.valueof(resObj.get('status'))=='error')
                                {
                                    cInfObj.LeadCall_Id__c=leadCallUniqueId;
                                    cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                                    cInfObj.Lead__c=listLeads[0].id;
                                    cInfObj.Agent_Phone_Number__c=usDet.User__r.Phone;
                                    cInfObj.Campaign_Name__c='BusHire Auto Calling';
                                    cInfObj.Creation_Hour__c = DateTime.now().hour();   
                                    cInfObj.BO_Phone_Number__c=listLeads[0].Phone;                        
                                    cInfObj.Message__c='Success';
                                    cInfObj.Agent_ID__c = usDet.User__r.username;                   
                                    insert cInfObj;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call will connect soon->'+listLeads[0].id+'--'+cInfObj.id));
                                }
                                else if((resObj.containsKey('result') && string.valueof(resObj.get('result'))=='FAILURE') || (resObj.containsKey('status') && string.valueof(resObj.get('status'))=='error'))
                                {
                                    string reason='Something went wrong!!';
                                    if(resObj.containsKey('reason')){
                                     reason=string.valueof(resObj.get('reason'));
                                    }
                                    isError = reason;
                                    usDet.is_Error_Occurred__c = true;
                                    usDet.Error_Description__c =reason;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,reason+', Please try again'+resObj));
                                }else{                                
                                    isError = 'Call connection failed';
                                    usDet.is_Error_Occurred__c = true;
                                    usDet.Error_Description__c ='Call connection failed, Did not received correct response from Ameyo';
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Call connection failed!!, Please try again'));
                                }                               
                            }                           
                            else
                            {
                                isError = 'No Response Received From Telephony Service Provider';
                                usDet.is_Error_Occurred__c = true;
                                usDet.Error_Description__c = 'No Response Received From Telephony Service Provider';
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Response Received From Telephony Service Provider'));                      
                            }                                                
                    }
                    else
                    {
                        usDet.is_Error_Occurred__c = true;
                        isError = 'Received Invalid Response From Agent Availbility Check';
                        usDet.Error_Description__c = 'Received Invalid Response From Agent Availbility Check';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please change the status as Available in Salesforce'));
                    }
                }
            }
        }
        
        Catch(Exception e)
        {
            isError = 'Error Occered, Please try again!!'+e;
            usDet.is_Error_Occurred__c = true;
            usDet.Error_Description__c = String.valueOf(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'+e));
        }
        if(String.isNotBlank(isError))
        {
            usDet.Error_Time__c = System.now();
            update usDet;
            
            if(!'Currently No Leads Are Availabe For Dialing'.equalsIgnoreCase(usDet.Error_Description__c) && Boolean.valueOf(System.Label.EnableBusHireErrorReset))
            {
               /*usDet.is_Error_Occurred__c =False;
               usDet.Error_Description__c = '';
               usDet.Error_Time__c =null;
               usDet.Next_Call_Time__c = System.now();
               update usDet;
               */
               BusHireDialerErrorResetCntrl.resetError(String.valueOf(usDet.id));
            }
        }
    }
  
   
   
   public void AssginLeads(){
       loggedInUserId =UserInfo.getUserId(); 
       System.debug('loggedInUserIdm ->'+loggedInUserId );
       uObj=[select id,username,Group__c,Primary__c,CZentrix_Agent_Id__c from user where id=:loggedInUserId]; 
       System.debug('cze-->'+uObj.CZentrix_Agent_Id__c);
       LeadAssignment la=new LeadAssignment();
       la.LeadRouting(loggedInUserId,'dailer');
       listLeads = DataBase.query(leadQuery); 
       if(uObj.Group__c=='Group 1'){ 
            listLeads = DataBase.query(leadQuery); 
        }else if(uObj.Group__c=='Group 2'){
          leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='My_Leads2'].query__c;
          listLeads = DataBase.query(leadQuery); 
        }
      // listLeads=[select id,status,DOJStart__c,Agent_Mobile__c,Channel__c,Name,NextCallDate__c,owner.name,phone,Call_back_request_time__c,Call_Ended__c,Duration_of_DOJ__c,CB__c,New_Latest_DOJ__c,Priority__c,Previous_Owner__c  from lead where ownerId=:loggedInUserId];

   }
}