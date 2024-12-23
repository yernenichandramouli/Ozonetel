/**
* (c) 2017 RedBus
*
* Name           : SyncAPICntrl
* Created Date   : 17 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Extension class for SyncAPI Page
*
**/

public class SyncAPICntrl 
{
    public string ordId{get;set;}
    public string rcOrdId{get;set;}
    public string emailId{get;set;}
    public string phone{get;set;}
    public string tin{get;set;}
    public string region{get;set;}
    
    
    public pagereference addToQueue()
    {
        if(String.isBlank(ordId) && String.isBlank(emailId) && String.isBlank(phone) && String.isBlank(tin))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input at least one field value to process your request'));
            return null;    
        }
        
        try
        {   
            string body = '{"orderId":"'+ordId+'","emailId":"'+emailId+'","phone":"'+phone+'","tin":"'+tin+'","caller":"SF Agent"}';
            System.debug('body...'+body);
            String selCountry = 'IND'.equalsIgnoreCase(region)?region:'INTL';
            asyncProcess(body,selCountry);
            ordId ='';emailId =''; phone = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your request has processed sucessfully'));
            return null;
        }
        
        Catch(Exception e)
        {
            system.debug('---SyncAPI call is failure...---------------');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;            
        }
    }
    
    @future(callout=true)
    public static void asyncProcess(String jsonbody,String CountryCode)
    {    
        Http http = new Http();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Country_Name',CountryCode);
        req.setMethod('POST');       
        System.debug('body....'+jsonbody+'..Country Code..'+CountryCode);
        req.setBody(jsonbody);
        
        string reqBody=jsonbody;
        Map<String, Object> ordrParams = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
        system.debug('==previousParams='+ordrParams);
        string tripid =string.valueof(ordrParams.get('orderId'));
        system.debug('==id=='+tripid);
        
        map<string,id> guidMap = new map<string,id>(); 
        List<case> listCaseToUpdate = new List<Case>(); 
        List<Order_Items__c> ListOI = new List<Order_Items__c>();
        
        if(String.isNotBlank(tripid)){
         ListOI = [Select id,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c,Order_Item_Reference_No__c,Guid__c from Order_Items__c where Order_Id__c=:tripid AND Flag__c = 0];
        }
        
        if(!ListOI.isEmpty())
        {
          for(Order_Items__c orIt : ListOI){
            if(string.isNotBlank(orIt.Guid__c)){
               guidMap.put(orIt.Guid__c,orIt.id);
            }
          }
        }
        
        for(Case c: [Select id,Transaction_UUID__c,Trip_Id_ct__c From Case WHERE Transaction_ID__c=NULL AND Transaction_UUID__c IN :guidMap.keySet()])
        {
            if(String.isNotBlank(c.Transaction_UUID__c))
            c.Transaction_ID__c = guidMap.containsKey(c.Transaction_UUID__c)?guidMap.get(c.Transaction_UUID__c):null;
            listCaseToUpdate.add(c);
        }   
        
        if('INTL'.equalsIgnoreCase(CountryCode))
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPIIntl'].Endpoint__c);
        else
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPI'].Endpoint__c);
        
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.Type__c='User Trips Sync';
        dbLog.User_Id__c=UserInfo.getUserName();
        dbLog.Send_To__c=CountryCode;
        dbLog.Request_Data__c = string.valueof(req)+'===jsonbody=='+jsonbody+'-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--Content-Type--'+req.getHeader('Content-Type');
        if(!Test.isRunningTest())
        {
            res = http.send(req);  
            dbLog.Response_Received__c = String.valueOf(res+'...Body..'+res.getBody());    
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
                System.debug('SyncAPI call is success...');    
                
        }
        
        if(!listCaseToUpdate.isEmpty()){
          update listCaseToUpdate;
        }
        insert dbLog;
    }
    
    @future(callout=true)
    public static void B2BAsyncProcess(String jsonbody,String CountryCode)
    {    
        Http http = new Http();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Country_Name',CountryCode);
        req.setMethod('POST');       
        System.debug('body....'+jsonbody+'..Country Code..'+CountryCode);
        req.setBody(jsonbody);       
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='B2BSync'].Endpoint__c);
        
        if(!Test.isRunningTest())
        {
            res = http.send(req);      
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
                System.debug('SyncAPI call is success...');  
        }
    }
    
    public void syncOldRecharge(){       
        if(String.isBlank(rcOrdId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter order id to sync'));            
        }else{
            Http http = new Http();
            HttpResponse res = new HttpResponse();   
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setHeader('Channel_Name', 'MOBILE_APP');
            req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Country_Name','IND');
            req.setHeader('BusinessUnit','BUS');
            req.setMethod('GET');   
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncOldRechargeOrder'].Endpoint__c+rcOrdId);    
            res = http.send(req);  
            System.debug('res.getStatus()-->'+res.getStatus()+'res.getStatusCode()-->'+res.getStatusCode());
            if(res.getStatus()=='OK' && res.getStatusCode()==200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Order has been synced sucessfully')); 
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please try again!!')); 
            }  
        }
    }

    public PageReference hotelSync()
    {
        
        if (String.isBlank(ordId) && String.isBlank(tin))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input at least one field value to process your request'));
            return null;    
        }
        string jsonbody='{"orderId":"'+ordId+'","emailId":"'+emailId+'","phone":"'+phone+'","tin":"'+tin+'"}';
        Http http = new Http();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        req.setTimeout(30000);//120,000 
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Country_Name','INTL');
        req.setMethod('POST');       
        System.debug('body....'+jsonbody);
        req.setBody(jsonbody);
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Hotel_Sync'].Endpoint__c);
        res = http.send(req);
        system.debug('res==>>'+res+'...'+'resbody==>>'+res.getBody());  
        if(res.getStatus()=='OK' && res.getStatusCode()==200) {
            System.debug('SyncAPI call is success...'); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Your request has processed sucessfully')); 
        }
        return null;
    }
}