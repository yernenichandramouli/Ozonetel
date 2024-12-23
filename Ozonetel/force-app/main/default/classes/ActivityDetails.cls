global class ActivityDetails
{
    public static Id recId{get;set;}
    
    public ActivityDetails(ApexPages.StandardController controller){
        recId = controller.getId();
    }
    
    @AuraEnabled
    public static string getActivityDetails(string actId)
    {
        System.debug('actId-->'+actId);
        Activities__c actObj=new Activities__c();
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='IsActivityCancellableURL'];        
        string endpoint=APIMData.Endpoint__c+actId+'/meta-info';
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);              
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        res = http.send(req);  
        string  mockJson =JSON.serialize(res.getBody());
        return mockJson;    
    }
    
    @AuraEnabled
    public static string getActivityAddOnDetails(string actId)
    {
        System.debug('actId-->'+actId);
        Activities__c actObj=new Activities__c();
        actObj=[select id,Activity_uuid__c,OrderUuid__c from Activities__c where Activity_uuid__c=:actId];
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='AddOn_Other_Details'];
        string endpoint=APIMData.Endpoint__c+actObj.OrderUuid__c+'/details?loadMeta=true';
        string jsBody='{ "addonItems" : [ { "addonType" : "ACTIVITY", "orderItemUUID" : "'+actId+'" } ] }';
        jsBody=JSON.serialize(jsBody);
        system.debug('jsBody-->'+jsBody);
        string jsonCM='{"action":"Put","body":'+jsBody+',"endPoint":"'+endpoint+'","headers": "[]"}';
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
        res = http.send(req);  
        System.debug('res body--->'+res.getBody());
        return JSON.serialize(res.getBody());
    }
}