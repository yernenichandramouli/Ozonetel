/*
* Name           : SelfHelplink
* Created Date   : 20 feb 2020
* Created By     : Mahendra reddy 
* Purpose        : Geting SelfHelplink
* Test class     : SelfHelplinkTest
*/
public class SelfHelplinkController{
    
    @Auraenabled(cacheable=true)
    public static string GetSelfHelpLink(string caseId){
        system.debug('caseId-->'+caseId);
        
        List<Case> caselst=new List<case>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        caselst=[select id,CaseNumber,Issue_API_Name__c,Country__c,Sub_Issue_API__c,Order_UUId__c,Transaction_UUID__c from case where Country__c!=Null and origin in ('InBound Call','Complaint Tracker','Chat') and id=:caseId];
        if(!caselst.isEmpty()){
            system.debug('--->>'+caselst);
             String codedUrl='';
              if(caselst[0].Country__c=='India'){
                  codedUrl = 'https://www.redbus.in/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }else if(caselst[0].Country__c=='Singapore'){
                  codedUrl = 'https://www.redbus.sg/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }else if(caselst[0].Country__c=='Indonesia'){
                  codedUrl = 'https://www.redbus.id/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }else if(caselst[0].Country__c=='Malaysia'){
                  codedUrl = 'https://www.redbus.my/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }else if(caselst[0].Country__c=='Peru'){
                  codedUrl = 'https://www.redbus.pe/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }else if(caselst[0].Country__c=='Colombia'){
                  codedUrl = 'https://www.redbus.co/info/redcare?path=mycases'+'&cId='+caselst[0].CaseNumber;
               }      
            //'https://www.redbus.in/info/redcare?intent=451'+'&cId='+caselst[0].CaseNumber+'&issue='+caselst[0].Issue_API_Name__c+'&subIssue='+caselst[0].Sub_Issue_API__c+'&uuid='+caselst[0].Order_UUId__c+'&itemuuid='+caselst[0].Transaction_UUID__c;
            String encodedUrl = EncodingUtil.urlEncode(codedUrl,'UTF-8');
            string urlBody='url='+encodedUrl;
            system.debug('--urlBody--->>'+urlBody);
            Http shrtHt = new Http();
            HttpRequest shrtReq = new HttpRequest();
            HttpResponse shrtResp = new HttpResponse(); 
            shrtResp.setHeader('Content-Type','multipart/form-data');                               
            shrtReq.setMethod('POST'); 
            shrtReq.setBody(urlBody);
            shrtReq.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Shorten'].Endpoint__c);
            system.debug('---shrtReq--'+shrtReq+'---body--'+shrtReq.getBody());
        try{     
            shrtResp=shrtHt.send(shrtReq);
            /*map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(shrtResp.getbody());
            map<string,object> resObj1=(map<string,object>)resObj.get('data');
            string shortenURL='https://s.redbus.com/'+resObj1.get('short'); og5t1ue*/ 
            
        if(shrtResp.getstatuscode()==200 && String.isNotBlank(shrtResp.getbody()))
        {
            system.debug('--respppp------->>'+shrtResp.getbody());
            map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(shrtResp.getbody());
            map<string,object> resObj1=(map<string,object>)resObj.get('data');
            string shortenURL= string.valueof(resObj1.get('short'));   
            return shortenURL;
              
           
        }else{
            return 'No API Response';
        }
        }catch(Exception e){
            return 'Apex Error';
        }
        }else{
            return 'No case Found-- SelfHelplink will work for only InBound Call,Complaint Tracker,Chat cases';
        }
    }
}