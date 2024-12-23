global class SyncAllCasesTransaction implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
   global final String query;
   
    public SyncAllCasesTransaction(){}
    public SyncAllCasesTransaction(String q)
    {
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncAllCaseMissTrans'].QueryDetails__c;
    }
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncAllCaseMissTrans'].Duration__c;
       Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();
       System.schedule('SyncAllCaseMissTrans - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
       Database.executeBatch(new SyncAllCasesTransaction(query));
   }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope) 
    {
        list<Case> wgDomList = new list<Case>();   
        list<Case> wgIntlList = new list<Case>();
        Boolean isDomestic= false;
        Boolean isIntl= false;
        Map<id,Case> mapWFTToUpdate = new Map<id,Case>();
        String jsonDomBody = '{"tin":"","orderId":"';
        String jsonIntlBody = '{"tin":"","orderId":"';
        
        for(Case wg:scope)
        {
            if(String.isNotBlank(wg.Country__c) && 'India'.equalsIgnoreCase(wg.Country__c)){
                isDomestic = true;
                jsonDomBody = jsonDomBody+wg.Trip_Id_ct__c+',';
               
            }
            else if(String.isNotBlank(wg.Country__c) || 'DBT'.equalsIgnoreCase(wg.Issue_Type__c)){
                              
                jsonIntlBody = jsonIntlBody+wg.Trip_Id_ct__c+',';
                isIntl = true;
             
            }
        }
        jsonDomBody = jsonDomBody.removeEnd(',')+'","emailId" : "","phone": "","caller":"SyncCaseMissTrans"}';
        jsonIntlBody = jsonIntlBody.removeEnd(',')+'","emailId" : "","phone": "","caller":"SyncCaseMissTrans"}';
        System.debug('jsonDomBody..'+jsonDomBody+'...'+jsonIntlBody);
        Http http = new Http();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('Content-Type', 'application/json');      
        req.setMethod('POST');      
        if(isDomestic){
            System.debug('called');
            req.setHeader('Country_Name','IND');
            req.setBody(jsonDomBody);
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPI'].Endpoint__c);
            res = http.send(req); 
            if(res!=null && res.getStatus()=='OK' && res.getStatusCode()==200)
            {
             System.debug('India sync is successs');    
            }
     
            
        }
        if(isIntl){
            req.setHeader('Country_Name','INTL');
            req.setBody(jsonIntlBody );
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SyncAPIIntl'].Endpoint__c);
            res = http.send(req); 
            if(res!=null && res.getStatus()=='OK' && res.getStatusCode()==200)
                 System.debug('Intl sync is successs');
           
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