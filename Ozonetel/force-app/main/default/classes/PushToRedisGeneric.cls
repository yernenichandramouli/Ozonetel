/**
 * (c) 2017 RedBus
 *
 * Name           : PushToRedisGeneric
 * Created Date   : 05 July 2022
 * Created By     : Sreenivas M
 * Purpose        : Insert order ids into redis from TempProcessing__c table.
 * Test class     : PushToRedisGenericTest
 *
 **/
 
global class PushToRedisGeneric implements DataBase.Batchable<sObject>,Database.AllowsCallouts
{
    public string dbNum;
    public string region;
    
    public PushToRedisGeneric(String redisdb,String reg)
    {
      dbNum = redisdb;
      region = reg;
    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        List<String> listTins = new List<String>();
        return Database.getQueryLocator([Select id,name,processed__c from TempProcessing__c where processed__c=false limit 50000]);

    }
    
    global void execute(DataBase.BatchableContext bc,List<TempProcessing__c> items)
    {
       Set<String> itemsToSent = new Set<String>();

        for(TempProcessing__c orIt:items)
        {
          if(String.isNotBlank(orIt.Name))
            itemsToSent.add(orIt.Name);
        }
        
        if(!itemsToSent.isEmpty() && String.isNotBlank(dbNum) && String.isNotBlank(region))
        {
        
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='PushToRedisTemp';
            Http ht = new Http();
            HttpRequest shrtReq = new HttpRequest();
            HttpResponse shrtResp = new HttpResponse(); 
            shrtReq = HttpRequestUtil.populateHeaders(shrtReq);
            API_redBusBookingSyncingFuture.RedisPushRequest jsbody = new API_redBusBookingSyncingFuture.RedisPushRequest();
            jsbody.listOrdIds =new List<String>(itemsToSent);
            jsbody.dbNum =dbNum;
            jsbody.region =region;                                   
            shrtReq.setMethod('POST');   
            string finjsBody = JSON.serialize(jsBody);
            System.debug('jsBody...'+finjsBody );          
            shrtReq.setBody(finjsBody);
            shrtReq.setTimeout(120000);
            API_EndPoints__mdt config = new API_EndPoints__mdt();
            config = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PushToRedis' limit 1];
            shrtReq.setendpoint(config.Endpoint__c);
            dbl.Request_Data__c = 'Request..'+shrtReq+'..'+shrtReq.getBody()+'..Response..'+shrtReq.getEndpoint();
            dbl.EndPoint__c = String.valueOf(shrtReq.getEndpoint());
            
            if(config.EnableLog__c)
            {
                shrtResp=ht.send(shrtReq);
                dbl.Response_Received__c = String.valueOf(shrtResp+'...Body..'+shrtResp.getBody());
                dbl.CallOut_Status_Code__c = string.valueOf(shrtResp.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(shrtResp.getStatus());   
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
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}