/**
 * (c) 2019 RedBus
 *
 * Name           : ReSyncingScheduler 
 * Created Date   : 02 April 2019
 * Created By     : Sreenivas M
 * Purpose        : Scheduler class to process the failed booing/cancellation data
 * Test class     : ReSyncingSchedulerTest
 *
 **/
 
global class ReSyncingScheduler implements Schedulable
{  
   
   public ReSyncingScheduler()
   {
   
   }
   
   public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        DataDeletionSetup__mdt dataSetup = new DataDeletionSetup__mdt();
        dataSetup = [SELECT QueryDetails__c,Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='ReSyncSchedular' limit 1];
        Id jobId = System.schedule('ReSyncSchedular-'+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(dataSetup.Duration__c )).minute()+' */1 ? * *', this); 
        invokeReProcessing(dataSetup.QueryDetails__c,jobId);
    }
    @future(callout=true)
    public static void invokeReProcessing(String qry,Id latJobId)
    {
      List<attachment> listAttachment = new List<attachment>();
      List<DBLog_Summary__c> listDBSummToUpdate = new List<DBLog_Summary__c>();
      listAttachment = DataBase.Query(qry);
      
      DBLog_Summary__c dbl = new DBLog_Summary__c();
      dbl.type__c = 'RedBus Booking Sync Retry';
      dbl.SentAt__c = System.now();
      dbl.Request_Data__c = '';
      dbl.Response_Received__c ='';
      
      if(!listAttachment.isEmpty())
        {
            string BookingData;
            for(attachment att: listAttachment)
            {
                BookingData = att.Body.tostring();
                dbl.Request_Data__c = dbl.Request_Data__c+','+String.valueOf(att.ParentId);
                
                if(!string.isBlank(BookingData))
                {
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(120000);
                    HttpResponse res = new HttpResponse();
                    Http http = new Http(); 
                    req.setEndpoint(system.Label.SalesforceAPI+'/services/apexrest/redBus/redBus_Booking/');
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
                    req.setMethod('POST');
                    req.setBody(BookingData);
                    
                    try
                    {
                        res = http.send(req);
                        string responseValue = res.getBody();
                        if(res.getStatusCode()==200)
                        {
                            listDBSummToUpdate.add(new DBLog_Summary__c(id=att.ParentId,X0_PG_Reference_ID__c=True));
                            dbl.Response_Received__c = dbl.Response_Received__c+','+ String.valueOf(att.ParentId);
                        }
                       
                    }
                    catch(exception e)
                    {
                        System.debug('Error while reprocessing..'+e);
                    }
                }
            }
            
            if(dbl.Request_Data__c.split(',').size()== dbl.Response_Received__c.split(',').size())
                dbl.Complaint_Tracker_Status__c = 'Success';
            else
                dbl.Complaint_Tracker_Status__c = 'Partial';
            
            listDBSummToUpdate.add(dbl);
                
            if(!listDBSummToUpdate.isEmpty())
            {
              upsert listDBSummToUpdate;
            }
        }
        
        System.abortJob(latJobId);
        System.schedule('ReSyncSchedular-'+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(1).minute()+' */1 ? * *',new ReSyncingScheduler()); 
   
    }
}