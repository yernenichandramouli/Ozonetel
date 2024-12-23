/**
 * (c) 2022 RedBus
 *
 * Name           : RedrailsRefundReconBatch
 * Created Date   : 30 Mar 2022
 * Created By     : Sreenivas M
 * Purpose        : Batch class to process the pending RedRails Refund Recon
 * Test class     : BusCancellationAgeingRefundScheduler
 *
 **/
 
global class RedrailsRefundReconBatch implements Schedulable,DataBase.Batchable<sObject>,Database.AllowsCallouts
{
    public string query;
      
    public RedrailsRefundReconBatch(String strQuery)
    {
       
       if(String.isNotBlank(strQuery))
           query = strQuery;
         else
            query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RedrailsRefundReconQuery'].QueryDetails__c;
    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RedrailsRefundReconQuery'].Duration__c;
        Decimal batchSize = [SELECT Batch_size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RedrailsRefundReconQuery'].Batch_size__c;

        System.schedule('RedrailsRefundReconQuery - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RedrailsRefundReconBatch(query),Integer.valueOf(batchSize));
    }
   
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        System.Debug('query...'+query);
        return DataBase.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext bc,List<Refund_Recon__c> lstRecons)
    {
       
        List<HttpRequestWrappersUtil.CancellationDetail> listCanDet = new List<HttpRequestWrappersUtil.CancellationDetail>();
        map<string,string> mapPnrToRecId = new Map<String,String>();
         map<string,list<Refund_Recon__c>> mapPnrToRecords = new Map<String,list<Refund_Recon__c>>();
        
        for(Refund_Recon__c rr:lstRecons)
        {
            if(mapPnrToRecords.containsKey(rr.pnr_no__c))
            {
                mapPnrToRecords.get(rr.pnr_no__c).add(rr);
            }
            else
            {
                mapPnrToRecords.put(rr.pnr_no__c,new List<Refund_Recon__c>{rr});
                
            }
        }
        
        List<Refund_Recon__c> listRefundsToUpdate = new List<Refund_Recon__c>();
         
        for(Refund_Recon__c rc :lstRecons)
        {
            if(mapPnrToRecords.containsKey(rc.pnr_no__c) && mapPnrToRecords.get(rc.pnr_no__c).size()==1)
            {
                mapPnrToRecId.put(rc.pnr_no__c,rc.id);
                HttpRequestWrappersUtil.CancellationDetail cd = new HttpRequestWrappersUtil.CancellationDetail();
                cd.pnr = rc.pnr_no__c;
                cd.refundAmount = rc.refund_amount__c;
                listCanDet.add(cd);
            }
            
            else
            {
                rc.Status__c='Duplicate PNRs Found';
                listRefundsToUpdate.add(rc);
                
            }
        }
        
        if(!listCanDet.isEmpty())
        {
            HttpRequestWrappersUtil.RedRailsReconResponse respWrap = new HttpRequestWrappersUtil.RedRailsReconResponse();
            HttpRequestWrappersUtil.RedRailsReconRequest reqUtil = new HttpRequestWrappersUtil.RedRailsReconRequest();
            reqUtil.isMultiSeatCancel = true;
            reqUtil.cancellationDetails = listCanDet;
            Map<String, String> recHeaders= new Map<String, String>();
            recHeaders.put('Content-Type','application/json');
             DBLog_Summary__c dbl= new DBLog_Summary__c();
            try
            {
               
                dbl.type__c ='RedRails Refund Recon Callback';
                
                HttpResponse res = new HttpResponse();
                res=HTTPUtil.sendGenericHTTPRequest([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RedrailsRefundReconQuery'].Endpoint__c,'POST',json.serialize(json.serialize(reqUtil)),recHeaders,120000,'RedRails Refund Recon');
                string responseBody = res.getBody();
                dbl.Response_Received__c =String.valueOf(res+'..Body..'+responseBody);
                
                if(res.getBody()!='null' && res.getStatusCode()==200 && String.isNotBlank(responseBody))
                {
                    respWrap = (HttpRequestWrappersUtil.RedRailsReconResponse)JSON.deserialize(responseBody,HttpRequestWrappersUtil.RedRailsReconResponse.class);

                    if(String.isNotBlank(respWrap.status) && 'SUCCESS'.equalsIgnoreCase(respWrap.status))
                    {
                      dbl.Order_Items_Process_Status__c ='Received The Expected Response And Processed Successfully';
                      
                      if(!respWrap.data.isEmpty())
                      {
                          for(HttpRequestWrappersUtil.DataCls d:respWrap.data)
                          {
                              if(mapPnrToRecId.containsKey(d.pnr))
                              {
                                  Refund_Recon__c r = new Refund_Recon__c(id=mapPnrToRecId.get(d.pnr),Refunded_Amount__c=d.refundAmount,Status__c='Refund Processed Successfully');
                                  listRefundsToUpdate.add(r);
                              }
                          }
                      }
                    
                      if(!respWrap.errors.isEmpty())
                      {
                          for(HttpRequestWrappersUtil.ErrorCls err:respWrap.errors)
                          {
                              if(mapPnrToRecId.containsKey(err.pnr))
                              {
                                  Refund_Recon__c r = new Refund_Recon__c(id=mapPnrToRecId.get(err.pnr),Status__c=err.error);
                                  listRefundsToUpdate.add(r);
                              }
                          } 
                          
                      }
                      
                      if(!listRefundsToUpdate.isEmpty())
                        DataBase.update(listRefundsToUpdate,false);
                      
                    }
                    else
                        dbl.Order_Items_Process_Status__c ='Received an Unexpected Response Status From Server';

                }
                else
                    dbl.Order_Items_Process_Status__c ='Received an Unexpected Response Status Code From Server';

                    
            }
            Catch(Exception e)
            { 
              dbl.Exception_Description__c = String.valueOf(e);
            }
        
        insert dbl;
        }
        
        else
        {
             if(!listRefundsToUpdate.isEmpty())
                   DataBase.update(listRefundsToUpdate,false);
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
       mail.setSubject('RedRails Refund Recon Status-'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}