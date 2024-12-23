/**
 * (c) 2017 RedBus
 *
 * Name           : TempTransactionSyncBatch
 * Created Date   : 06 July 2022
 * Created By     : CRM Team
 * Purpose        : Insert order ids into redis from TempProcessing__c table.
 * Test class     : TempTransactionSyncBatchTest
 *
 **/
 
global class TempTransactionSyncBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts, Schedulable
{
    public string query;
    public TempTransactionSyncBatch(){

    }

    public TempTransactionSyncBatch (String q)
    {
        if(String.isNotBlank(q))
           query = q;
        else
         
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='TempTransactionSync'].QueryDetails__c;
          
    }
    
    public void execute(SchedulableContext scon)
    {
        Integer batchSize = Integer.valueOf([SELECT Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='TempTransactionSync'].Batch_Size__c);
       Database.executeBatch(new TempTransactionSyncBatch(query),batchSize);

    }


    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        List<String> listTins = new List<String>();
        return Database.getQueryLocator(query);

    }
    
    global void execute(DataBase.BatchableContext bc,List<TempProcessing__c> items)
    {
        Set<String> itemsToSent = new Set<String>();
        for(TempProcessing__c orIt:items){
            itemsToSent.add(orIt.Name);
        }
        list<string> finalSet = new list<string>(itemsToSent);
        string finalStr = string.join(finalSet, ',').removeEnd(',');
        system.debug(':::: finalStr :::: '+finalStr);
        Http ht = new Http();
        HttpRequest shrtReq = new HttpRequest();
        HttpResponse shrtResp = new HttpResponse(); 
        shrtReq = HttpRequestUtil.populateHeaders(shrtReq);
        string jsonBody ='{ "orderId": "'+finalStr+'", "emailId": "", "phone": "", "isRails": true, "caller": "IVR_Temp_Processing" }';
        system.debug(':::: jsonBody :::: '+jsonBody);
        shrtReq.setBody(jsonBody);
        shrtReq.setMethod('POST');   
        API_EndPoints__mdt config = new API_EndPoints__mdt();
        config = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='TempTransactionSync' limit 1];
        shrtReq.setEndpoint(config.Endpoint__c);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='TempTransactionSyncBatch';
        dbl.Payment_Request_Sent_Data__c= 'Request..'+shrtReq+'..'+shrtReq.getBody()+'..Response..'+shrtReq.getEndpoint();
        if(config.EnableLog__c)
        {
            shrtResp=ht.send(shrtReq);
            system.debug(':::: shrtResp :::: '+shrtResp);
            system.debug(':::: shrtResp Body :::: '+shrtResp.getBody());
            dbl.Payment_Request_Response_Data__c = String.valueOf(shrtResp+'...Body..'+shrtResp.getBody());
            insert dbl;
            
            if(shrtResp!=null && shrtResp.getStatus()=='OK' && shrtResp.getStatusCode()==200)
            {
              List<TempProcessing__c> listTemp = new List<TempProcessing__c>();
              for(TempProcessing__c orIt:items)
              {
               orIt.processed__c = true;
               listTemp.add(orIt);
               }
               
               if(!listTemp.isEmpty())
                update listTemp;
            }
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('PushToRedis is Completed'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
       
    }
}