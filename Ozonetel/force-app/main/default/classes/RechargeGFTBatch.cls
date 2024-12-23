/*
* Name           : RechargeGFTBatch
* Created Date   : 05 Sep 2019
* Created By     : Veeramanikanta R
* Purpose        : To process Recharge GFT refunds  
* Test class     : RechargeGFTBatchTest
*/
global class RechargeGFTBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{  
    global final String Query;
    public RechargeGFTBatch (){}
    public RechargeGFTBatch (String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RechargeGFT'].QueryDetails__c;   
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());        
        DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
        ddObj=[SELECT Duration__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RechargeGFT'];
        Decimal nextInterval=ddObj.Duration__c;
        Integer batchSize=integer.valueOf(ddObj.Batch_Size__c);       
        System.schedule('RechargeGFTBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RechargeGFTBatch (Query),batchSize);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<PostGres_Data__c> listRecItems)
    {     
        List<PostGres_Data__c> lstRecs=new list<PostGres_Data__c>();
        List<DBLog_Summary__c> dbLogls=new List<DBLog_Summary__c>();
        for(PostGres_Data__c p: listRecItems){ 
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();       
            gen.writeStringField('OrderId', p.Order_Id__c);
            gen.writeEndObject();
            String orderJson= gen.getAsString();
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Recharge_InitiateRefund'];
            
            
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req);   
            req.setHeader('Channel_Name','SFA');  
            req.setHeader('BusinessUnit','RECHARGE');            
            req.setHeader('auth_key', 'a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
            req.setHeader('Accept', 'application/msgpack1');
            req.setMethod('GET');
            req.setEndpoint(APIMData.Endpoint__c+p.Order_Id__c);  
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            try{
                
                dbl.Request_Data__c=p.Order_Id__c;
                res=h.send(req); 
                System.debug('response-->'+res+'....'+res.getBody()+'...'+String.isBlank(res.getbody()));
                string response=res.getBody();          
                dbl.Type__c = 'Initiate Recharge Refund';
                dbl.Order_Items_Success__c=string.valueof(res.getbody());          
                System.debug('response-->'+res);
                System.debug('response body-->'+res.getbody()); 
                String mResp='{"Code":"11.22","Message":"Refund is alreday processed for the provided order id.","DetailedMessage":"Refund is alreday processed for the provided order id.","HttpStatusCode":200}';
                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
                Map<string,string> respCodeValues=new Map<string,string>();
                respCodeValues.put('11.22','Refund is processed successfully');
                respCodeValues.put('11.25','This order is not a valid GFT');
                respCodeValues.put('11.24','Refund is already processed');
                respCodeValues.put('11.23','Refund is failed');
                p.GFT_Status_Code__c=string.valueof(resObj.get('Code'));
                p.GFT_Process_Status__c=respCodeValues.get(p.GFT_Status_Code__c);
                
            }catch(Exception e){ 
                dbl.Type__c = 'Initiate Recharge Refund';
                dbl.Exception_Description__c='Error-->'+e;   
                p.GFT_Process_Status__c='Exception';        
            }
            lstRecs.add(p);
            dbLogls.add(dbl);
        } 
        
        if(!lstRecs.isEmpty()){
            update lstRecs;
        }
        if(!dbLogls.isEmpty()){
            insert dbLogls;
        } 
    }
 
    global void finish(Database.BatchableContext BC) 
    {           
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  
    }    
}