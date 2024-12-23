/**
 * (c) 2018 RedBus
 *
 * Name           : BusCAlternativeRefundBatch
 * Created Date   : 02 Huly 2018
 * Created By     : Sreenivas M
 * Purpose        : Bacth class to process the pedning Alternative Bus Cancellation Case
 * Test class     : BusCAlternativeRefundBatchTest
 *
 **/
 
global class BusCAlternativeRefundBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
    public string query;
      
    public BusCAlternativeRefundBatch()
    {
    }
    
    public BusCAlternativeRefundBatch(String strQuery)
    {
       query = strQuery;
    }
    
    public void execute(SchedulableContext scon)
    {

      Database.executeBatch(new BusCAlternativeRefundBatch(query),5);

    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        if(String.isBlank(query))
        {
            query = System.Label.BusCAlternativeRefund;        
            Set<String> setTins = new Set<String>();
            Set<String> setFinTins = new Set<String>();

            for(Case cs:DataBase.query(query))
            {
                if(String.isNotBlank(cs.TIN_No__c))
                {
                    setTins.add(cs.TIN_No__c);
                    setFinTins.add(cs.TIN_No__c);
                }
            }
        
            System.debug('Final Tins.Before.'+setFinTins);
            
            for(Refund_Order_Items__c refnd :[Select TIN__c from Refund_Order_Items__c Where TIN__c IN:setTins])
            {
                if(setFinTins.contains(refnd.TIN__c))
                    setFinTins.remove(refnd.TIN__c);
            }
            List<String> listTins = new List<String>();
            listTins.addAll(setFinTins);
            System.debug('Final Tins..'+listTins);
            String qry = System.Label.BusCAlternativeRefundQuery+' AND TIN_No__c IN:setFinTins ORDER BY TIN_No__c ';
            System.Debug('qry...'+qry);
            return DataBase.getQueryLocator(qry);
        }
        else
            return DataBase.getQueryLocator(query);
    
    }
    
    global void execute(DataBase.BatchableContext bc,List<Case> lstcases)
    {
        Map<String,List<Case>> mapTinToCases = new Map<String,list<Case>>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<CaseComment> listCaseComm = new List<CaseComment>();
        List<SPOCBusCancellationExtn.JsonBodyWrapper> jsBodyWraper = new List<SPOCBusCancellationExtn.JsonBodyWrapper>();
        Set<String> setTins = new Set<String>();
        
        for(Case c:lstcases)
        {
            if(mapTinToCases.containsKey(c.TIN_No__c ))
                mapTinToCases.get(c.TIN_No__c).add(c);
            else
            {
                mapTinToCases.put(c.TIN_No__c,new List<Case>{c});
                
                SPOCBusCancellationExtn.JsonBodyWrapper jsonWarper = new SPOCBusCancellationExtn.JsonBodyWrapper(c,'CLOSED','Cancel Ticket');
            
                if(String.isBlank(c.Transaction_ID__c))
                {
                  jsonWarper.routeId =Integer.valueOf(c.SS_Route_Id__c);
                  jsonWarper.orderItemUuid = c.Transaction_UUID__c;
                  
                  if(jsonWarper.doj==null && c.SS_DOJ__c!=null)
                    jsonWarper.doj = String.valueOf(c.SS_DOJ__c.format('yyyy-MM-dd 00:00:00','Asia/Kolkata'));
                }
                jsBodyWraper.add(jsonWarper);
            }
            
        }
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusCancellation'].Endpoint__c+'Update');
        req.setMethod('POST');
        req.setBody(JSON.serialize(jsBodyWraper));
        
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'BusC Alternative Refund Scheduler';
        dbl.Payment_Request_Sent_Time__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+JSON.serialize(jsBodyWraper);
        dbl.Order_Items_Data_Received_Ids__c = String.valueOf(mapTinToCases);
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());

        
        try
        {
            res = http.send(req);     
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());  
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            string responseValue = res.getBody();
            dbl.Payment_Ping_Status__c = 'Ping Initiated';
            dbl.Response_Received__c = responseValue;
            
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
                dbl.Payment_Ping_Status__c = 'Ping Success';
                List<BusCancellationHandler.ViaRouteTinsResponse> listTinsForViaRoute = new  List<BusCancellationHandler.ViaRouteTinsResponse>();
                listTinsForViaRoute = (List<BusCancellationHandler.ViaRouteTinsResponse>)System.JSON.deserialize(responseValue ,List<BusCancellationHandler.ViaRouteTinsResponse>.class);
                
                for(BusCancellationHandler.ViaRouteTinsResponse re : listTinsForViaRoute)
                {
                    if(re.isSuccess)
                    {
                        for(Case c:mapTinToCases.get(re.tin))
                        {
                            Case cs= new Case();
                            cs.notes__c = 'Refund by redBus';
                            cs.Id = c.id;
                            listCaseToUpdate.add(cs);

                            CaseComment csComm = new CaseComment();
                            csComm.ParentId = cs.Id;
                            csComm.commentBody = 'System Update-Refunded By SF Scheduler';
                            listCaseComm.add(csComm);
                        }                                                          
                    }     
                }
                insert listCaseComm;
                update listCaseToUpdate;
            }

            else
            {
                dbl.Payment_Ping_Status__c = 'Received Invalid Response..'+responseValue+'..Resp..'+res;
                System.debug('Received invalid response from the API'+responseValue);
             
            }
        }
            
        Catch(Exception e)
        {
            dbl.Exception_Description__c ='Error Occuerd..'+String.valueOf(e).left(244);
            System.debug('Error...'+e);
        }
     insert dbl;
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('BusC Alternative Arrangement Refund Processing..'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}