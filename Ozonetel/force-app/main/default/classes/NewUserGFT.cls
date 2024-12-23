/**
 * (c) 2016 RedBus
 *
 * Name           : NewUserGFT
 * Created Date   : 10 Mar 2017
 * Created By     : Praveen
 * Modified By    : Sreenivas M 18-Apr-2017
 * Purpose        : class for hitting and checking for newUser and changing case owner as New_User_GFT
 *
 **/
 
 global without sharing class NewUserGFT
 {     
    public static List<NewUserGFTResponse> newUserGFTres{get;set;}
    public static Boolean flag=false;
    public static list<GFTrequest> GFTreqlist {get;set;} 
    public static set<Id> caseIds;
  
    @future (callout=true) 
    public static void isNewUser(string jsonCaseString)
    {
        system.debug('****in isNewUser****jsonCaseString***** '+jsonCaseString);  
        list<Case> caselist2 =new list<Case>();
        List<Case> caselist= (List<Case>)JSON.deserializeStrict(jsonCaseString,List<Case>.class);
        caseIds = new Set<Id>();
        
        for(Case cs : caselist)
        {
          caseIds.add(cs.Id);
        }
       
        GFTreqlist = new list<GFTrequest>();
        newUserGFTres = new List<NewUserGFTResponse>();
        Map<String,String> mapPhonetoId = new Map<String,String>();
        Map<String,String> mapEmailtoId = new Map<String,String>();
        
          DBLog_Summary__c dbl = new DBLog_Summary__c();
          dbl.Type__c = 'New User GFT';
          dbl.Payment_Request_Sent_Time__c = system.now();
          dbl.SentAt__c = system.now();
          list<case> cslist = new list<case>();
          
          for(Case c:[SELECT id,Customer_Phone_Number__c,Booking_Mobile_No__c,Customer_Email_ID__c,Booking_Email_ID__c FROM Case WHERE ID IN :caseIds])
        {
            cslist.add(c);
            String PhoneNum = String.isNotBlank(c.Customer_Phone_Number__c)? c.Customer_Phone_Number__c : c.Booking_Mobile_No__c;
            String Email = String.isNotBlank(c.Customer_Email_ID__c)? c.Customer_Email_ID__c : c.Booking_Email_ID__c;
            
            System.debug('PhoneNum ...'+PhoneNum +'..'+EMail);
            
            if(c.id!=null && (String.isNotBlank(PhoneNum) || String.isNotBlank(Email)))
            {
                GFTreqlist.Add(new GFTrequest(PhoneNum,Email));
                
                if(String.isNotBlank(PhoneNum))
                    mapPhonetoId.put(PhoneNum,c.id);
                
                else if(String.isNotBlank(Email))
                    mapEmailtoId.put(Email,c.id);
                    
            }
        }
        
        // dbl.Payment_Request_Sent_Data__c = string.valueof(GFTreqlist+'..'+cslist);
        dbl.Request_Data__c = string.valueof(GFTreqlist+'..'+cslist);
        API_EndPoints__mdt endPointData = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NewUserGFT'];
        
        if(!GFTreqlist.isEmpty())
        {
        
            
            newUserGFTres=new List<NewUserGFTResponse>();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req = HttpRequestUtil.populateHeaders(req);
            req.setEndpoint(endPointData.Endpoint__c);
            req.setMethod('POST');
           
            System.debug('****jsonBody**** '+json.serialize(GFTreqlist));
            req.setBody(json.serialize(GFTreqlist));
       
             //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+json.serialize(GFTreqlist); 
             dbl.Request_Data__c = string.valueof(req)+json.serialize(GFTreqlist); 
                    
            try
            {
                System.debug('****request*****'+req);
                res = http.send(req);
                string responseValue = res.getBody();
                dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
                dbl.Payment_Request_Response_Time__c = System.now();
                
                          
                system.debug('**** response ****** '+responseValue);
                if(res.getStatus()=='OK')
                {
                     dbl.Payment_Ping_Status__c = 'New User GFT Ping Success';
                    List<Case> listCasesToUpdate = new List<Case>();
                    
                    flag=true;
                    
                    Group newUserGroup = [select Id, Name, Type FROM Group where Type = 'Queue' and Name='New user GFT'];
                    
                    newUserGFTres = (List<NewUserGFTResponse>)JSON.deserialize( responseValue, List<NewUserGFTResponse>.class);
                    
                    for(NewUserGFTResponse gftRes : newUserGFTres)
                    {
                        if(gftRes.isNewUser)
                        {
                            Case cs = new Case();
                            cs.id = String.isNotBlank(gftRes.mobile)?mapPhonetoId.get(gftRes.mobile): mapEmailtoId.get(gftRes.email);
                            cs.OwnerId = newUserGroup.Id;
                            listCasesToUpdate.add(cs);
                        }
                    }
                    
                    if(!listCasesToUpdate.isEmpty())                    
                        update listCasesToUpdate;
                }
            }
            
            Catch(Exception e)
            {
                  dbl.Payment_Ping_Status__c = 'New User GFT Failed';
                  dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());   
                  system.debug('-------New_user_GFT_Trigger_Error--Exception---------------'+e);                 
            }
        }
        
        if(endPointData.EnableLog__c)
            insert dbl;
        
    }
    public class NewUserGFTResponse
    {
        public Boolean isNewUser{ get; set; }
        public string mobile{get;set;}
        public string email{get;set;}
    }
    
    public class GFTrequest
    {
        string mobile {get;set;}
        string email {get;set;}
        
        public GFTrequest(string p_mobile, string p_email)
        {
            email=p_email;
            mobile=String.isNotBlank(p_mobile)?p_mobile.replaceAll('[()-]','').replaceAll('\\s+', ''):'';
        }
    }    
 }