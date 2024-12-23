/**
 * (c) 2023 RedBus
 *
 * Name           : MMTTransactionSyncBatch
 * Created Date   : 12 JUN 2023
 * Created By     : VR Sudarshan
 * Purpose        : Batch class to sync MMT transactions when MMT case is created.
 * Test class     : MMTTransactionSyncBatchSchedulerTest
 *
 **/
global class MMTTransactionSyncBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;

    public MMTTransactionSyncBatch(String strQuery) {
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }else{
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MMTTransactionSync'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        set<string> pnrCaseSet = New set<string>();
        set<string> pnrSetToSync = New set<string>();
        if(!lstcases.isEmpty()){
            for(Case csObj : lstcases){
                pnrCaseSet.add(csObj.PNR__c);
            }
        }
        List<Order_Items__c> oritList = [SELECT ID, Order_Item_Reference_No__c FROM Order_Items__c WHERE Order_Item_Reference_No__c =: pnrCaseSet];
        if(!oritList.isEmpty()){
            for(Order_Items__c o : oritList){
                if(!pnrCaseSet.contains(string.valueOf(o.Order_Item_Reference_No__c))){
                    pnrCaseSet.remove(string.valueOf(o.Order_Item_Reference_No__c));
                }
            }
        }

        system.debug('::: pnrCaseSet = '+pnrCaseSet);

        if(!pnrCaseSet.isEmpty()){
            pushToRedisB2b(pnrCaseSet);
        }
    }

    //Method to push tins to PNR for SYNC
    public void pushToRedisB2b(Set<String> itemsToSent){
        Map<String, String> dataMap = new Map<String, String>();
        Map<String, Object> jsonData = new Map<String, Object>();
        if(!itemsToSent.isEmpty()){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='PushToRedisMMT';
            Http ht = new Http();
            HttpRequest shrtReq = new HttpRequest();
            HttpResponse shrtResp = new HttpResponse();
            shrtReq = HttpRequestUtil.populateHeaders(shrtReq);
            for (String item : itemsToSent) {
                dataMap.put(item,'{}');
            }
            jsonData.put('data', dataMap);
            jsonData.put('region', 'IND');
            List<string> redisDbNumList = System.Label.RedisDBNum.split(',');
            Integer redisNum = redisDbNumList.size()>=4?Integer.valueOf(System.Label.RedisDBNum.split(',')[3]):15;
            jsonData.put('dbNum', redisNum);
            shrtReq.setMethod('POST');  
            string finjsBody = JSON.serialize(jsonData);
            System.debug('jsBody...'+finjsBody ); 
            shrtReq.setBody(finjsBody);
            shrtReq.setTimeout(120000);
            API_EndPoints__mdt config = new API_EndPoints__mdt();
            config = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PushToRedisB2b' limit 1];
            shrtReq.setendpoint(config.Endpoint__c);
            dbl.Request_Data__c = 'Request..'+shrtReq+'..'+shrtReq.getBody()+'..Response..'+shrtReq.getEndpoint();
            dbl.EndPoint__c = String.valueOf(shrtReq.getEndpoint());
            if(config.EnableLog__c){
                shrtResp=ht.send(shrtReq);
                dbl.Response_Received__c = String.valueOf(shrtResp+'...Body..'+shrtResp.getBody());
                dbl.CallOut_Status_Code__c = string.valueOf(shrtResp.getStatusCode());
                dbl.CallOut_Status__c = string.valueOf(shrtResp.getStatus());   
                insert dbl;
            }
        }
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('MMT Sync is completed '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}