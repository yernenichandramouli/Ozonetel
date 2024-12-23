/**
 * (c) 2020 RedBus
 *
 * Name           : B2BBusCanclAgeingRefundBatch 
 * Created Date   : 
 * Created By     : 
 * Purpose        : Batch class to process the pending Bus Cancellation Case Under Customer Delight Exceptional Refund
 * Test class     : 
 *
 **/
 
global class B2BBusCanclAgeingRefundBatch implements DataBase.Batchable<sObject>, Database.AllowsCallouts,Schedulable
{
 global final String Query;
    
    public B2BBusCanclAgeingRefundBatch (){}
  
    public B2BBusCanclAgeingRefundBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='B2BBusCancelAgeningQuery'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='B2BBusCancelAgeningQuery'].Duration__c;
        System.schedule('B2BBusCancelAgeningQuery - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new B2BBusCanclAgeingRefundBatch(Query));
   }
   global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
  global void execute(DataBase.BatchableContext bc,List<Case> lstcases)
  {
     List<HttpRequestWrappersUtil.CaseRequestWrapper> cReqList=new list<HttpRequestWrappersUtil.CaseRequestWrapper>(); 
     Set<Id> setCaseIdsToProcess = new Set<Id>();
     Map<String,Case> csMap = new Map<String,Case>();
     List<Case> listCaseToUpdate = new List<Case>();
     List<CaseComment> listComm = new List<CaseComment>();
     for(Case c:lstcases)
      {
        setCaseIdsToProcess.add(c.id);
        csMap.put(c.tin_no__c,c);
        cReqList.add(new HttpRequestWrappersUtil.CaseRequestWrapper(c.TIN_No__c,'AUTOREFUND')); 
        system.debug('--cReqList---'+cReqList);
      }
      
     if(!cReqList.isEmpty())
       {
             
        Http h= new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SSBusCancellation'].Endpoint__c);
        req.setMethod('POST');
        req.setBody(json.serialize(cReqList));
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'B2B BusCanclAgngRefBatch';
        dbl.SentAt__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(json.serialize(cReqList));
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        ID autoRefundQueueId =[Select id from Group where type='Queue' AND developername='Bus_Cancellation_Auto_Refund_Queue'].id;
        try
          {
            res=h.send(req);
            System.debug('Response-->'+res.getBody());          
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());  
            List<HttpRequestWrappersUtil.ResponseWrapper> respWprlist = new List<HttpRequestWrappersUtil.ResponseWrapper>();
            respWprlist = (list<HttpRequestWrappersUtil.ResponseWrapper>)system.JSON.deserialize(res.getBody(), list<HttpRequestWrappersUtil.ResponseWrapper>.class);
            
            for(HttpRequestWrappersUtil.ResponseWrapper reswpr:respwprlist)
            {
              System.debug('reswpr.tin...'+reswpr.tin);
               System.debug('csMap...'+csMap);
               System.debug('csMap contains...'+csMap.containsKey(reswpr.tin));
               case cs = new case();
               CaseComment csComm = new CaseComment();
               cs=csMap.get(reswpr.tin);
               cs.isAgening_Refund_Processed__c = true;
               system.debug('---reswpr---'+reswpr);
               if(reswpr.responseCode =='200' && reswpr.responseMessage=='SUCCESS')
                  {
                     cs.isAgeing_Refund_Success__c = true; 
                     system.debug('--status--'+cs.Status);                  
                     if(!'Escalated to BD'.equalsIgnoreCase(cs.Status))
                     {
                       cs.Status ='Refunded By Ageing Scheduler';
                       cs.ownerId=autoRefundQueueId;
                       csComm.commentBody = 'System Update- Refunded By Ageing Scheduler Under Bus Cancellation Customer Delight';
                       csComm.ParentId = cs.id;
                       listComm.add(csComm);
                       
                     }
                  }
                  else{
                     cs.isAgeing_Refund_Success__c = false;
                     csComm.commentBody ='System Failed -'+'--Respmessage--'+reswpr.responseMessage;
                     csComm.ParentId = cs.id;
                     listComm.add(csComm);
                     
                  }
                  
                
                listCaseToUpdate.add(cs);
            }
            
            if(!listCaseToUpdate.isEmpty())
            {
                if(!listComm.isEmpty())
                    dataBase.insert(listComm,false);                
                DataBase.update(listCaseToUpdate,false);
            
            }
        
        }
        
        Catch(Exception e)
        {
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Response_Received__c  = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());                
        }
        
        DataBase.insert(dbl,false);
     }
  
  }
  
  global void finish(DataBase.BatchableContext bc)
  {
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                       WHERE Id =:BC.getJobId()];
    
    if(a.NumberOfErrors>0)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('sreenivasa.mariyavula@redbus.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('B2B Bus Cancellation Ageing Refund Processing..'+a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }
  
}