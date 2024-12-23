/*
* Name           : RechargeSyncBatch
* Created Date   : 05 Sep 2019
* Created By     : Veeramanikanta R
* Purpose        : To Sync recharge details 
* Test class     : RechargeSyncBatchTest
*/
global class RechargeSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{  
    global final String Query;
    global Map<string,string> ordStMap;
    public RechargeSyncBatch (){}
    public RechargeSyncBatch (String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RechargeSync'].QueryDetails__c;
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());        
        DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
        ddObj=[SELECT Duration__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RechargeSync'];
        Decimal nextInterval=ddObj.Duration__c;
        Integer batchSize=integer.valueOf(ddObj.Batch_Size__c);       
        System.schedule('RechargeSyncBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RechargeSyncBatch(Query),batchSize);   
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {    
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<PostGres_Data__c> listRecItems)
    {     
        List<PostGres_Data__c> lstRecs=new list<PostGres_Data__c>();
        for(PostGres_Data__c pg:listRecItems){
            PostGres_Data__c pit=new PostGres_Data__c();
            pit=pg;
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RechargeItems'];
            
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req);   
            req.setHeader('Channel_Name','MOBILE_APP');  
            req.setHeader('BusinessUnit','RECHARGE');            
            req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');
            req.setHeader('Accept', 'application/msgpack1');
            req.setMethod('GET');
            req.setEndpoint(APIMData.Endpoint__c+pg.Order_Id__c);
            res=h.send(req);       
            string  data=res.getBody();
            // data='{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""}]}';
            //  data='{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""},{"id":414,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":30,"type_of_payment":"DIRECT","additonal_details":""}]}';
            PostGresConnect.ResponseWrapper respWrapper=new PostGresConnect.ResponseWrapper();
            if(data!=''){
                respWrapper= (PostGresConnect.ResponseWrapper)System.JSON.deserialize(data,PostGresConnect.ResponseWrapper.class);
                string ordStatus=respWrapper.OrderStatus;             
                ordStMap=new Map<string,string>();
                ordStMap.put('ORDER_TRANS_FAIL','GFT(Payment collected and recharge not successful)');
                ordStMap.put('ORDER_TRANS_SUCCESS','Recharge successful');
                ordStMap.put('PAYMENT_TRANS_CREATED','WFT (Payment not collected from customer)');
                ordStMap.put('PAYMENT_TRANS_FAIL','WFT (Payment not collected from customer)');
                ordStMap.put('PAYMENT_TRANS_SUCCESS','GFT(Payment collected and recharge not successful)');
                pg.Order_Status__c=ordStMap.get(ordStatus); 
                pg.Operator_Name__c=respWrapper.OperatorName;
                pg.Plan__c=respWrapper.Plan;
                pg.Recharge_Amount__c=respWrapper.RechargeAmount;
                pg.sync__c=true;
                lstRecs.add(pg);             
            }      
        }
        if(!lstRecs.isEmpty()){
            update lstRecs;
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