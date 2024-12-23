/**
* (c) 2018 RedBus
*
* Name           : HTTPUtil
* Created Date   : 29 May 2018
* Created By     : Sreenivas M
* Purpose        : Generic class to send Http Request from Salesforce 
* Test class     : 
*
**/

public class HTTPUtil{
        
    public static HttpResponse sendGenericHTTPRequest(String endpoint,String method,String body,Map<String,String> headerMap,Integer timeOut){
       /* Http http = new Http();
        HttpRequest req =HttpRequestUtil.populateHeaders(new HttpRequest());
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);
        req.setMethod('POST');
        
        if(timeOut!=null)
           req.setTimeout(timeOut);
        else
            req.setTimeout(120000);
                
        String finalHeaderJson='';
        if(headerMap!=null)
        {
            list<CaseTriggerHandler.HeadersWrapper> hlist=new list<CaseTriggerHandler.HeadersWrapper>();
            for(string o:headerMap.keyset())                       
                hlist.add(new CaseTriggerHandler.HeadersWrapper(o,headerMap.get(o)));
            
            finalHeaderJson=json.serialize(json.serialize(hlist));
        }    
        string finalJsonBody ='{"action":"'+method+'","body":'+body+',"endPoint":"'+endpoint+'","headers":'+finalHeaderJson+'}';
        System.debug('finalJsonBody...'+finalJsonBody);
        
        if(String.isNotBlank(finalJsonBody))
            req.setBody(finalJsonBody);
        HttpResponse res = http.send(req);
        System.debug('gen res-->'+res.getBody());
        return res;*/
        return sendGenericHTTPRequest(endpoint,method,body,headerMap,timeOut,'Generic API Default Log');
    }
    
    public static HttpResponse sendGenericHTTPRequest(String endpoint,String method,String body,Map<String,String> headerMap,Integer timeOut,String dblogType){

        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c = dblogType;

        Http http = new Http();
        HttpRequest req =HttpRequestUtil.populateHeaders(new HttpRequest());
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);
        req.setMethod('POST');

        if(timeOut!=null)
           req.setTimeout(timeOut);
        else
            req.setTimeout(120000);
                
        String finalHeaderJson='';
        string finalJsonBody;
        
        if(headerMap!=null)
        {
            list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
            for(string o:headerMap.keyset())                       
                hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headerMap.get(o)));
            
            finalHeaderJson=json.serialize(json.serialize(hlist));
        }   
       
     

        if('DBT Fuzzy Logic'.equalsIgnoreCase(dblogType)){ 
           finalJsonBody ='{"action":"'+method+'","body":'+body+',"endPoint":"'+endpoint+'","headers":'+finalHeaderJson+',"isIncreasedTimeout":true}';
        }else{
           finalJsonBody ='{"action":"'+method+'","body":'+body+',"endPoint":"'+endpoint+'","headers":'+finalHeaderJson+'}';
         }
           System.debug('finalJsonBody...'+finalJsonBody);

        dbl.Request_Data__c = String.valueOf(finalJsonBody);
        dbl.Payment_Ping_Status__c = dblogType +' Ping Initiated';

        if(String.isNotBlank(finalJsonBody))
            req.setBody(finalJsonBody);
        HttpResponse res = http.send(req);
        System.debug('gen res-->'+res.getBody());
        dbl.Response_Received__c=String.valueof(res)+'.Response Body..'+String.valueOf(res.getbody());
        if(!'AgentAvailabilityCheck'.equalsIgnoreCase(dblogType))
            insert dbl;
    
        return res;
    }
     
    
    public static HttpResponse sendHTTPRequest(String endpoint, String method,String body){
       return sendHTTPRequest(endpoint,method,null,body,null);
    }
    public static HttpResponse sendHTTPRequest(String endpoint, String method,String body,String certfName){
       return sendHTTPRequest(endpoint,method,null,body,null,certfName);
    }
    
    public static HttpResponse sendHTTPRequest(String endpoint, String method, Integer timeOut,String body,Map<String,String> headerMap){
       return sendHTTPRequest(endpoint,method,timeOut,body,headerMap,null);
    }
    
    public static HttpResponse sendHTTPRequest(String endpoint, String method, Integer timeOut,String body,Map<String,String> headerMap,String certfName){
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        
        if(timeOut!=null){
           req.setTimeout(timeOut);
        }else{
            req.setTimeout(120000);
        }
        if(certfName != null){
            req.setClientCertificateName(certfName);
        }
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if(body != null){
            req.setBody(body);
        }
        
        //Header Map to populate html headers
        if(headerMap != null){
            for(String key: headerMap.keySet()){
                req.setHeader(key,headerMap.get(key));
            }
        }
        HttpResponse res = http.send(req);
        return res;
    }
}