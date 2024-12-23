Global class ShortRouteBoardingPoints {
    public String transactionId{get;set;}
    public String sourceId{get;set;}
    public String destinationId{get;set;}
    public String dateOfJourney{get;set;}
    
    public ShortRouteBoardingPoints(ApexPages.StandardController sc) {
        
        Order_Items__c ord=[select id,Name ,Destination_City_Id__c ,Source_City_Id__c,Date_of_Realization__c, Corrected_Date_of_Journey__c from Order_Items__c where id =:sc.getRecord().id];
        if(ord!=null){
            transactionId=ord.Name;
            sourceId=ord.Source_City_Id__c;
            destinationId=ord.Destination_City_Id__c;
            dateOfJourney=string.valueOf(ord.Date_of_Realization__c); 
           
            List<string> dateAndTime=new List<String>();
            if(String.isNotBlank(dateOfJourney))
                dateAndTime = dateOfJourney.split(' ');
            if(!dateAndTime.isEmpty())
                dateOfJourney=dateAndTime[0];
        }
    }
    
    @AuraEnabled 
    public static list<HttpRequestWrappersUtil.bplist> getBoardingPoints( string bp, string dp, string doj)
    {
        try
        {
        DBLog_Summary__c dbLog = new DBLog_Summary__c(); 
            string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='ShortRouteBordingPoints'].Endpoint__c;
            endpoint = endpoint +bp+'/'+dp+'/'+doj;
            
            Http http = new Http();
            HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
            HttpResponse res = new HttpResponse();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            res = http.send(req);
            system.debug('<< request'+req);
            dbLog.Request_Data__c = req.toString();
            dbLog.Response_Received__c =res.getBody();
            insert dbLog;
            
            if(res.getStatusCode() == 200){
                HttpRequestWrappersUtil.ShortRouteStops busStopPoints = new HttpRequestWrappersUtil.ShortRouteStops();
                busStopPoints = (HttpRequestWrappersUtil.ShortRouteStops)system.JSON.deserialize(res.getbody(), HttpRequestWrappersUtil.ShortRouteStops.class); 
                list<HttpRequestWrappersUtil.bplist> bplist=busStopPoints.bpList;
                return bpList;
            }
            else {
                System.debug(res.getBody());
            }
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }  
        return Null;
    } 

    @AuraEnabled 
    public static List<HttpRequestWrappersUtil.inv> getBusesDetails(string dp, string bp, string selectedbp, string doj){
        try
        {   
        DBLog_Summary__c dbLog = new DBLog_Summary__c(); 
            string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='ShortRouteBusDetails'].Endpoint__c;
            endpoint = endpoint +bp +'/'+dp+'/'+selectedbp+'/'+doj+'?meta=true'; 
            Http http = new Http();
            HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
            req.setHeader('Content-Length', '0');
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            HttpResponse res = new HttpResponse(); 
            res = http.send(req);
            
            dbLog.Request_Data__c = req.toString();
            dbLog.Response_Received__c =res.getBody();
            insert dbLog;
            
            if(res.getStatusCode() == 200){
                HttpRequestWrappersUtil.busDetails busDetails = new HttpRequestWrappersUtil.busDetails();
                busDetails = (HttpRequestWrappersUtil.busDetails)system.JSON.deserialize(res.getbody(), HttpRequestWrappersUtil.busDetails.class); 
                list<HttpRequestWrappersUtil.inv> invlist=busDetails.inv;
                return invList;
            }
            else {
                System.debug('response'+res.getBody());
            }
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }   
        return null;
    }
}