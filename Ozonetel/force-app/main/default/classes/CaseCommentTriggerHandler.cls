/**
*
* Name           : CaseCommentTriggerHandler
* Created Date   : 04 Apr 2018
* Created By     : Veeramanikanta R
* Purpose        : Handling casecomment object events 
*
**/
public class CaseCommentTriggerHandler{
    
    public static void CommentAction(list<casecomment> ccList){
        
        set<id> agnComIds=new set<id>();
        set<id> commUpIds=new set<id>();
        set<id> cevIds=new set<id>();
        for(casecomment cc:ccList){
            if(cc.commentBody!=null && !cc.commentbody.startswith('(CEV)') && !cc.commentbody.startswith('BO Reply->')){  
                agnComIds.add(cc.parentId);                        
            }else if(cc.commentBody!=null && cc.commentbody.startswith('(CEV)')){                         
                cevIds.add(cc.parentId);                      
            }
            commUpIds.add(cc.parentId); 
        }
        
        list<case> caseList=new list<case>();
        list<case> csUpList=new list<case>();
        caseList=[select id,casenumber,rYde_Parnter_Users__c,status,ownerid,Agent_Comments__c,Customer_Comments__c,Record_Update__c,(select id from casecomments) from case where id in:commUpIds];
        
        for(case c:caseList){
            if(agnComIds.contains(c.id)){
                if(c.Agent_Comments__c==null){
                 c.Agent_Comments__c=1;
                }else{
                c.Agent_Comments__c+=1; 
                }               
                if(c.casecomments.size()==1)
                    c.First_Actioned_Time__c=system.now();
            }
            if(cevIds.contains(c.id)){
                 if(c.Customer_Comments__c==null)
                  c.Customer_Comments__c=1;
                  else
                  c.Customer_Comments__c +=1;
            }
            
          if(c.status=='Escalated to Partner' && string.isNotBlank(c.rYde_Parnter_Users__c)){
           //system.debug('==Partner test==');
              Id rydeParterReplyQueueId=[select id from Group where type='Queue' AND developername='rYde_partner_reply_Queue'].id;

              c.status='Reverted by Partner';
              c.ownerid=rydeParterReplyQueueId;
           }
        
           if(c.Record_Update__c==null){
            c.Record_Update__c =1;
           }else{
            c.Record_Update__c+=1;
           }
            
            csUpList.add(c);
        }
        if(!csUpList.isEmpty()){
            update csUpList;
        }
    }
    
    /*  
@future(callout=true)
public static void pushNotification(set<id> ccIds,string caseType){
List<case> cList=new List<case>();
cList=[select id,TAT_Notifier_Email__c,Email_Id_ct__c,casenumber from case where id in:ccIds];
string jsonBody;
string title;
string message;       
for(case c:cList){
if(caseType=='commentInsert'){
title='Service Request '+c.casenumber+' Update';
message='We have an update on your service request';
} else if(caseType=='caseClosure'){
title='Service Request '+c.casenumber+' Closed';
message='Your request has been resolved';
} 
PushWrapper pw=new PushWrapper(c.caseNumber,c.TAT_Notifier_Email__c,title,message);

System.debug('pw-->'+JSON.serialize(pw));
jsonBody=JSON.serialize(pw);
String feds=JSON.serialize(jsonBody);
API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PushNotification'];
Map<String, String> headers = new Map<String, String>();
headers.put('Content-Type','application/json');
headers.put('Channel_Name','WEB_DIRECT');
headers.put('Country_Name','IND');
headers.put('BusinessUnit','BUS');
headers.put('auth_key','fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
list<HeadersWrapper> hlist=new list<HeadersWrapper>();
for(string o:headers.keyset()){               
System.debug('key-->'+o+''+'Value-->'+headers.get(o));
hlist.add(new HeadersWrapper(o,headers.get(o))); 
}
String headerJson=json.serialize(hlist); 
String headerJson2=json.serialize(headerJson);  
string jsonCM='{"action":"Post","body":'+feds+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
string json='{"type":["pushdata"], "pushdata": { "EmailId" :["'+cList[0].Email_Id_ct__c+'"], "dataparams": { "message": "Your ticket has been booked successfully", "sid": "0"} } }';
System.debug('req jsonCM-->'+jsonCM);
Http ht= new http();
HttpRequest htReq = HttpRequestUtil.populateHeaders(new HttpRequest());
HttpResponse htResp = new HttpResponse();
htReq.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);
htReq.setBody(jsonCM);
htReq.setMethod('POST');
htResp = ht.send(htReq);
System.debug('resp-->'+htResp.getbody());            
}
}

public class PushWrapper{
public string template_name='SF_CASE_COMMENT_INSERT';
public string name='Test template';
public list<string> channels=new list<string>{'android'};
public DataparamsC data_params;
public addressC address;
public  PushWrapper(string caseNo,string mobile,string title,string message){
data_params=new DataparamsC(caseNo,title,message);
address=new addressC(mobile);
}      
} 
public class DataparamsC {
public string sid='10';
public string message;
public string caseId;
public string title;
public DataparamsC(string caseNo,string title,string message){
this.caseId=caseNo;
this.title=title;
this.message=message;          
} 
}
public class addressC{        
public list<string> links;
public addressC(string mobile){
links=new list<string>{mobile};
}
}
public class HeadersWrapper{       
public string key;
public string value;
public HeadersWrapper(string key,string value){
this.key=key;
this.value=value;
}
}*/
}