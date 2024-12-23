global class SyncAllWFT implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
   global final String query;
   
    public SyncAllWFT(){}
    public SyncAllWFT(String q)
    {
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncAllWFT'].QueryDetails__c;
    }
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncAllWFT'].Duration__c;
       Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();
       System.schedule('WFTReSync - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
       Database.executeBatch(new SyncAllWFT(query));
   }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WFT_GFT__c> scope) 
    {
        list<WFT_GFT__c> wgDomList = new list<WFT_GFT__c>();   
        list<WFT_GFT__c> wgIntlList = new list<WFT_GFT__c>();
        Map<id,WFT_GFT__c> mapWFTToUpdate = new Map<id,WFT_GFT__c>();
        String jsonDomBody = '{"tin":"","orderId":"';
        String jsonIntlBody = '{"tin":"","orderId":"';
        
        for(WFT_GFT__c wg:scope)
        {
            if(String.isNotBlank(wg.business_unit__c) && '_IN'.equalsIgnoreCase(wg.business_unit__c.right(3))){
                wg.sync_processed__c= true;   
                jsonDomBody = jsonDomBody+wg.Order_Id__c+',';
                wgDomList.add(wg);
            }
            else if(String.isNotBlank(wg.business_unit__c)){
                wg.sync_processed__c= true;                 
                jsonIntlBody = jsonIntlBody+wg.Order_Id__c+',';
                wgIntlList.add(wg);
            }
        }
        jsonDomBody = jsonDomBody.removeEnd(',')+'","emailId" : "","phone": "","caller":"SyncAllWFT"}';
        jsonIntlBody = jsonIntlBody.removeEnd(',')+'","emailId" : "","phone": "","caller":"SyncAllWFT"}';
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Content-Type', 'application/json');      
        req.setMethod('POST');      
        if(!wgDomList.isEmpty()){
            System.debug('called');
            req.setHeader('Country_Name','IND');
            req.setBody(jsonDomBody);
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPI'].Endpoint__c);
            res = http.send(req); 
            if(res!=null && res.getStatus()=='OK' && res.getStatusCode()==200)
                mapWFTToUpdate.putAll(wgDomList);
     
            
        }
        if(!wgIntlList.isEmpty()){
            req.setHeader('Country_Name','INTL');
            req.setBody(jsonIntlBody );
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPIIntl'].Endpoint__c);
            res = http.send(req); 
            if(res!=null && res.getStatus()=='OK' && res.getStatusCode()==200)
                mapWFTToUpdate.putAll(wgDomList);
           
        }
        if(!mapWFTToUpdate.isEmpty()){
            update mapWFTToUpdate.values();
        }
      
    } 
     global void finish(Database.BatchableContext BC) 
    {                 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addall(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('Sync WFT Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}