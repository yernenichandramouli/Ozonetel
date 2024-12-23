/**
* (c) 2017 RedBus
*
* Name           : LeadTriggerHandler
* Created Date   : 26 July 2017
* Created By     : Sreenivas M
* Purpose        : Handler class for LeadTrigger
* Test class     : LeadTriggerTest
*
**/

Public class LeadTriggerHandler
{
  public static Map<String,Decimal> mapQuotesToScore;
  public static Map<String,Decimal> mapEmailOpenCountToScore;
  public Static String strDefault = 'Default';
  public static boolean stopRnRNotification=false;
  public Static Integer callBackScore;
  public static Integer TripDivider;
  public Static Integer creationScore;
  public static boolean leadTraverseStop=true;
  public static boolean stopRnRwatsup=true;
  
  public LeadTriggerHandler()
  {
       mapQuotesToScore =  new Map<String,Decimal>();
       mapEmailOpenCountToScore = new Map<String,Decimal>();
       
       for(Lead_Scoring__mdt ldSt:[SELECT DeveloperName,CountKey__c, Lead_Score__c, Type__c, Duration__c FROM Lead_Scoring__mdt order by Type__c])
       {
         System.debug('ldSt.Type__c..'+ldSt.Type__c+'..key..'+ldSt.CountKey__c);
         
         if('No Of Quotes'.equalsIgnoreCase(ldSt.Type__c))
            mapQuotesToScore.put(ldSt.CountKey__c,ldSt.Lead_Score__c);
        
         else if('Email Open Count'.equalsIgnoreCase(ldSt.Type__c))
            mapEmailOpenCountToScore.put(ldSt.CountKey__c,ldSt.Lead_Score__c);
         
         else if('CallBack Request'.equalsIgnoreCase(ldSt.Type__c))
           callBackScore = Integer.valueOf(ldSt.Lead_Score__c);
       
         else if('Trip Value'.equalsIgnoreCase(ldSt.Type__c))
             TripDivider = Integer.valueOf(ldSt.Lead_Score__c);
         
         else if('Creation Time'.equalsIgnoreCase(ldSt.Type__c) && strDefault==ldSt.CountKey__c)
             creationScore = Integer.valueOf(ldSt.Lead_Score__c);
         
             
       }
  }
  

  
  public static void BeforeInsert(List<Lead> TriggerNew)
  {
        
    for(Lead ld: TriggerNew)
    {
      // Lead Score for Quotes
      if(ld.NumberOfQuotes__c>0)
      {
        String strNoQuotes = String.valueOf(Integer.valueOf(ld.NumberOfQuotes__c));
        System.debug('Insert No of Quotes..'+strNoQuotes+'...'+mapQuotesToScore.containsKey(strNoQuotes)+'..value...'+mapQuotesToScore.get(strNoQuotes));
        ld.Quotes_Score__c = mapQuotesToScore.containsKey(strNoQuotes)?mapQuotesToScore.get(strNoQuotes):mapQuotesToScore.get(strDefault);
        System.debug('Before Insert Quote Score..'+ld.Quotes_Score__c);
      }
          
      
      //Number of times email opens
      if(ld.NoOfEmailOpen__c>0)
      {
        if(ld.NoOfEmailOpen__c==1)
            ld.Open_EMail_Count_Score__c = mapEmailOpenCountToScore.get(String.valueOf(Integer.valueOf(ld.NoOfEmailOpen__c)));
        else
        {
            ld.Open_EMail_Count_Score__c = (ld.Open_EMail_Count_Score__c==null)?0:ld.Open_EMail_Count_Score__c;
            ld.Open_EMail_Count_Score__c = ld.Open_EMail_Count_Score__c+ mapEmailOpenCountToScore.get(strDefault);
            ld.Fire_EMail_Open_TT__c = true;
        }
            
      }
      
       if(ld.status=='New'){
              ld.Lead_Group__c='Group 1';
              ld.Lead_Traverse__c='New|';
         }
      
      //Number of Kilometers Divided by 100
      if(String.isNotBlank(ld.Distance__c))
      {
          String distance = (ld.Distance__c).replace(' km','').replace(' m','').replace(',','');
          ld.Kilometers_Score__c = Double.valueOf(distance)/TripDivider;
      }
      
      //Lead Creationtime Check
       ld.Creation_Time_Score__c = creationScore;
    }
  
  }
  
  public static void BeforeUpdate(List<Lead> TriggerNew,Map<id,Lead> TriggeroldMap)
  {
    Id businessHourId = [SELECT Id FROM BusinessHours Where IsActive=True AND Name='BusHireCallingHours'].id;
    Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
    String busHirerecordTypeId  = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BusHire').getRecordTypeId();
     Set<String> leadStatusChangeOwners= new Set<String>(System.Label.Lead_Status_Change_Owners.split(','));

    List<Lead> listRnRUnsucessfulLeads = new List<Lead>();
    string currentUserName=UserInfo.getUsername();
    
    list<user> usrlst=[Select id,Username,name from User where Team__c='Bus Hire' and IsActive=True];
    map<string,id> mapUserId =new map<string,Id>();
    for(user u:usrlst){
     mapUserId.put(u.username,u.id);
    }
    
    for(Lead ld : TriggerNew)
    {
        // Lead Score for Quotes
          if( (TriggeroldMap.get(ld.id).NumberOfQuotes__c!=ld.NumberOfQuotes__c) && ld.NumberOfQuotes__c>0)
          {
            String strNoQuotes = String.valueOf(Integer.valueOf(ld.NumberOfQuotes__c));
            System.debug('Insert No of Quotes..'+strNoQuotes+'...'+mapQuotesToScore.containsKey(strNoQuotes)+'..value...'+mapQuotesToScore.get(strNoQuotes));
            ld.Quotes_Score__c = mapQuotesToScore.containsKey(strNoQuotes)?mapQuotesToScore.get(strNoQuotes):mapQuotesToScore.get(strDefault);
            system.debug('update scorce..'+ld.Quotes_Score__c);
          }
          
        //Number of times email opens
          if((TriggeroldMap.get(ld.id).NoOfEmailOpen__c!=ld.NoOfEmailOpen__c) && ld.NoOfEmailOpen__c>0)
          {
            if(ld.NoOfEmailOpen__c==1)
                ld.Open_EMail_Count_Score__c = mapEmailOpenCountToScore.get(String.valueOf(Integer.valueOf(ld.NoOfEmailOpen__c)));
            else
            {
                System.debug('mapEmailOpenCountToScore..'+mapEmailOpenCountToScore);
                ld.Open_EMail_Count_Score__c = (ld.Open_EMail_Count_Score__c==null)?0:ld.Open_EMail_Count_Score__c;
                ld.Open_EMail_Count_Score__c = ld.Open_EMail_Count_Score__c+ mapEmailOpenCountToScore.get(strDefault);
                ld.Fire_EMail_Open_TT__c= true;
               
            }
                
          }
          
           if((TriggeroldMap.get(ld.id).status!=ld.status || TriggeroldMap.get(ld.id).Call_back_request_time__c!=ld.Call_back_request_time__c || TriggeroldMap.get(ld.id).RnR_Call_Time__c!=ld.RnR_Call_Time__c) && ld.RecordTypeId==busHirerecordTypeId){             
                  ld.ownerid=busComQueue;
                 
                  if(!leadStatusChangeOwners.contains(currentUserName) && TriggeroldMap.get(ld.id).status!='Escalated to redFlag'){
                  ld.Previous_Owner__c=currentUserName;
                  }     
           } 
                   
           if(TriggeroldMap.get(ld.id).status!=ld.status && TriggeroldMap.get(ld.id).status=='Escalated to redFlag'){
              if(mapUserId.containsKey(ld.Previous_Owner__c)){
                ld.ownerid=mapUserId.get(ld.Previous_Owner__c);
              }
           }
           
           if(TriggeroldMap.get(ld.id).status!=ld.status && leadTraverseStop){
                ld.Lead_Traverse__c=ld.Lead_Traverse__c+ld.status+'|';
                leadTraverseStop=false;
                
                 if(ld.Lead_Traverse__c.length()>254)
                 {
                    ld.Lead_Traverse__c =  ld.Lead_Traverse__c.substring(0,255);
                 }               
           }
         
             
           if((ld.status=='RnR' || ld.status=='In progress') && ld.Lead_Group__c=='Group 1'){
               ld.Lead_Group__c='Group 2';
           } 
        
        // CallBack Requested By Customer but We haven't done it
            if(ld.Call_back_requested__c && !TriggeroldMap.get(ld.id).Call_back_requested__c && !ld.Call_back_done__c)
            {
                ld.Call_Back_Score__c = (ld.Call_Back_Score__c==null)?0:ld.Call_Back_Score__c;
                ld.Call_Back_Score__c = ld.Call_Back_Score__c + callBackScore;
            }
            
            if(ld.Call_back_done__c && !TriggeroldMap.get(ld.id).Call_back_done__c)
            {
                 ld.Call_Back_Score__c = (ld.Call_Back_Score__c==null)?0:ld.Call_Back_Score__c;
                ld.Call_Back_Score__c = ld.Call_Back_Score__c - callBackScore;
            }
        
        //Number of Kilometers Divided by 100
            if(String.isNotBlank(ld.Distance__c) && (ld.Distance__c!=TriggeroldMap.get(ld.id).Distance__c))
            {
              String distance = (ld.Distance__c).replace(' km','').replace(' m','').replace(',','');
              ld.Kilometers_Score__c = Double.valueOf(distance)/TripDivider;
            }
            
            if(TriggeroldMap.get(ld.id).Status != 'In Progress' && ld.Status =='In Progress')           
               ld.NextCallDate__c= system.today().addDays(1);
     
            if(TriggeroldMap.get(ld.id).Status != 'RnR' && ld.Status =='RnR')
                ld.RnR_Call_Time__c= BusinessHours.add(businessHourId, System.now(), 21600000);
                
            if(TriggeroldMap.get(ld.id).RnR_Unsuccessful_Attempts__c!=ld.RnR_Unsuccessful_Attempts__c && String.isNotBlank(ld.Phone) && !'RB_IND_SEATSELLER'.equalsIgnoreCase(ld.Channel__c))
                listRnRUnsucessfulLeads.add(ld);
            
     }
     
     if(!stopRnRNotification && !listRnRUnsucessfulLeads.isEmpty() && !System.isFuture() && !System.isBatch())
     {
        stopRnRNotification= true;
        sendSMSToCustomer(JSON.serialize(listRnRUnsucessfulLeads));
     }
     
  
     
  }
  
    @future(callout=true)
   private static void sendSMSToCustomer(String listRnRLeads)
    {
        List<Lead> leadList=new List<Lead>();
        leadList = (List<Lead>)JSON.deserializeStrict(listRnRLeads,List<Lead>.class);
        HttpRequestWrappersUtil.SendSMSEMailReqWrapper smsReqJson = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
        smsReqJson.type= new List<String>{'smsdata'};
        List<HttpRequestWrappersUtil.SMSRequest> listSMSReq = new List<HttpRequestWrappersUtil.SMSRequest>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        
        for(Lead ld :leadList)
        {
            String phoneNum = ld.Phone.replaceAll('[()-]','').replace(' ','');
            System.debug('phone Num...'+phoneNum);
            //string bodyText = '{"name":"'+ld.lastName+'","link":"https://www.redbus.in/bushire/userquotes.html?tripId="'+ld.TCode__c+'","mobile":"'+ld.Phone+'"}';
            string bodyText = '{"name":"'+ld.lastName+'","link":"'+ld.CustomerUrl__c+'","mobile":"'+ld.Phone+'"}';
            listSMSReq.add(HttpRequestUtil.prepareSMSRequest('BusHire_RnR_SMS',bodyText,'','',phoneNum,'',false));
            
        }
        
        Http ht = new http();
        HttpRequest req =  HttpRequestUtil.populateCAPIHeaders(new HttpRequest());
        HttpRequestWrappersUtil.Smsdata smsdataReq = new HttpRequestWrappersUtil.Smsdata();
        System.debug('listSMSReq...'+listSMSReq);
        smsdataReq.SMSRequest = new List<HttpRequestWrappersUtil.SMSRequest>();
        smsdataReq.SMSRequest=listSMSReq;
        smsdataReq.NotificationType  ='SMS';
        smsdataReq.Language  ='en';
        smsdataReq.IsTemplateUsedForMessage  =true;
        
        smsReqJson.smsdata = smsdataReq;
        System.debug('smsReqJson...'+JSON.serialize(smsReqJson));
        System.debug('smsdataReq...'+smsdataReq);
        
        HttpResponse resp = new HttpResponse();
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'].Endpoint__c);
        req.setBody(JSON.serialize(smsReqJson));
        req.setMethod('POST');
        dbl.Type__c = 'Bus Hire SMS Notification ';
        dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(JSON.serialize(smsReqJson));
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'..'+String.valueOf(JSON.serialize(smsReqJson));
        
        try
        {
            resp = ht.send(req);
            dbl.Payment_Request_Response_Time__c = System.now();
           // dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
            System.debug('resp-->'+resp.getbody());
        }
        Catch(Exception e)
        {
            dbl.Payment_Request_Response_Time__c = System.now();
            //dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.Exception_Description__c=string.valueof(e);
                  
        }
        insert dbl;     
    
    }
    
   //After Update Logic
   public static void AfterUpdate(List<Lead> TriggerNew,Map<Id,Lead> TriggerOldMap)
   {
   
      List<case> csUpsList=new List<case>();
      map<string,case> mapTcodecase= new map<string,case>();
      Set<string> tCodelst=new Set<string>(); 
      set<id> rnrIds = new set<id>();
      list<lead>  leadList = new list<Lead>();
      map<string,case>mapCaseDetailswithLead= new map<string,case>();
      List<case> csUpLst=new List<case>();
      Set<string> tCodIds=new Set<string>(); 
      list<lead>  ledList = new list<Lead>();
      
      Id busHireSupQueueId = [Select id from Group where type='Queue' AND developername='BusHire_Support'].id;
       
    for(Lead ld : TriggerNew)
    {
   
      if(string.isNotBlank(ld.TCode__c) &&'Converted'.equalsIgnoreCase(ld.status)&&ld.Call_back_request_time__c!=null && ld.Call_back_request_time__c!=TriggerOldMap.get(ld.id).Call_back_request_time__c)
          {
             tCodelst.add(ld.TCode__c);
             leadList.add(ld);
          }
          
      if(string.isNotBlank(ld.TCode__c))
         {
            tCodIds.add(ld.TCode__c);
            ledList.add(ld);
         }
         
      if(string.isNotBlank(ld.TCode__c) && 'RnR'.equalsIgnoreCase(ld.status) && 'New RnR'.equalsIgnoreCase(TriggerOldMap.get(ld.id).status))
          {
            rnrIds.add(ld.id);
          }
     }
       
     if(!rnrIds.isEmpty()  && stopRnRwatsup && !system.isFuture() && !System.isBatch())
          {
            stopRnRwatsup = false;
            RnRwatsUpInteg(rnrIds);
          }
     for(case cs:[select id,status,Lead_TCode__c from case where Issue_Type__c='CallBack Requested' AND Lead_TCode__c in:tCodelst])
      
        {
           mapTcodecase.put(cs.Lead_TCode__c,cs);
        }
        
      for(case cs:[select id,SourceT__c,Phone_No_ct__c,status,DestinationT__c,Lead_TCode__c,Bus_Operator_Namee__c,Email_Id_ct__c,SS_DOJ__c,Region__c from case where Business_Type__c ='BusHire' and status!='Closed' and Lead_TCode__c in:tCodIds])
      
          {
             mapCaseDetailswithLead.put(cs.Lead_TCode__c,cs);
          } 
       
      for(Lead Ld:ledList){
       if(mapCaseDetailswithLead.containsKey(ld.TCode__c))
         {
            case cs=new case();
            cs.id=mapCaseDetailswithLead.get(ld.TCode__c).id;
            cs.SourceT__c=ld.SrcCityName__c;
            cs.DestinationT__c=ld.DestCityName__c;
            cs.Bus_Operator_Namee__c=ld.Operator_Name__c;
            cs.Email_Id_ct__c=ld.Email;
            cs.Region__c=ld.Region__c;
            cs.SS_DOJ__c=ld.DOJStart__c!=null?ld.DOJStart__c:null;
            cs.Phone_No_ct__c =ld.Phone;
            cs.CallBack_Requested_Time__c=ld.Call_back_request_time__c;
            cs.Does_Customer_Require_CallBack__c=ld.Call_back_requested__c;
            csUpLst.add(cs);
         }
      }    
        
     for(Lead led:leadList)
        {
          
          if(mapTcodecase.containsKey(led.TCode__c))
         {
            case c=new case();
            c.id=mapTcodecase.get(led.TCode__c).id;
            c.status='Closed'.equalsIgnoreCase(mapTcodecase.get(led.TCode__c).Status)?'Re-Open':mapTcodecase.get(led.TCode__c).Status;
            c.ownerid=busHireSupQueueId;
            csUpsList.add(c);
         }
         
         else{
            case c=new case();
            c.status='Open';
            c.Issue_Type__c='CallBack Requested';
            c.Lead_TCode__c=led.TCode__c;
            c.Lead__c=led.id;
            c.ownerid=busHireSupQueueId;
            csUpsList.add(c);
         }
         
        }
        if(!csUpsList.isEmpty()){
             upsert csUpsList;
        }
        
       if(!csUpLst.isEmpty()){
             update csUpLst;
        }
    }
    
   @future(callout=true)
   public static void RnRwatsUpInteg(set<id> ldIds){
     List<Lead> leadList=new List<Lead>();  
     leadList=[select id,Name,Phone,status,TCode__c,NumOfPax__c,DOJStart__c,DestCityName__c,SrcCityName__c from Lead where id in:ldIds]; 
     DBLog_Summary__c dbl = new DBLog_Summary__c();
     for(Lead ld :leadList){
     
      if(String.isNotBlank(ld.TCode__c))
          {
            DateTime dt =ld.DOJStart__c;
            string phoneNo = string.valueof(ld.Phone);
            String Str1=phoneNo.replaceAll('\\(','');
            String Str2=Str1.replaceAll('\\)','');
            String Str3=Str2.replaceAll('-','');
            String finalPhone=Str3.replaceAll(' ','');
            System.debug('--finalPhone--'+finalPhone);
 
            HttpRequestWrappersUtil.RnRrequestWrapper rnrReqWrap= new HttpRequestWrappersUtil.RnRrequestWrapper();
            HttpRequestWrappersUtil.Context cntxt= new HttpRequestWrappersUtil.Context ();
            
            cntxt.TCode =ld.TCode__c;
            cntxt.CustomerName =ld.Name;
            cntxt.source =ld.SrcCityName__c;
            cntxt.destination =ld.DestCityName__c;
            cntxt.JourneyDate =dt.format('dd-MMM-yyyy');
            cntxt.NoofPax=string.valueof(ld.NumOfPax__c);
            
            rnrReqWrap.uid='91'+finalPhone;
            rnrReqWrap.channel='whatsapp';
            rnrReqWrap.country='IND';
            rnrReqWrap.lang='en';
            rnrReqWrap.query='bushire callback';
            rnrReqWrap.sessionTime=integer.valueof(System.Label.RnRWatsUpSessionTime);
            rnrReqWrap.useCustomContext=false;
            rnrReqWrap.endpoint_identifier='BUS_HIRE';
            
            rnrReqWrap.context=cntxt;
            string Jsonbody = JSON.serialize(rnrReqWrap);
            system.debug('--RnrJsonbody--'+Jsonbody);
                       
            Http http = new Http(); 
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setTimeout(120000);       
            req.setBody(Jsonbody);
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusHireRnRwatsupIntgr'].Endpoint__c);
            dbl.Type__c = 'RnR WatsupIntg';
            //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'..'+String.valueOf(Jsonbody);
            dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(Jsonbody);
            system.debug('--Rnr Req--'+string.valueof(req));
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            res = http.send(req); 
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
               {
                 map<string,object> respMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                 
                if(respMap.containsKey('msg') && respMap.get('msg')!=null && respMap.get('msg')=='Success!')
                  {    
                    dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                     //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
                     dbl.Linking_Process_Status__c ='Updated successfully'+'--resp--'+respMap.get('msg');
                     
                 }else {
                    //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
                    dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                    dbl.Linking_Process_Status__c ='Failed re-try'+'--resp--'+respMap.get('msg');
                 }
             }
             else {
              
                  dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
                  dbl.Linking_Process_Status__c ='API fails'+res.getStatusCode()+'--'+res.getBody();
             }
         }
      }
      insert dbl;
   }
   
}