/**
 * (c) 2019 RedBus
 *
 * Name           : BookingReSyncingScheduler 
 * Created Date   : 02 April 2019
 * Created By     : Sreenivas M
 * Purpose        : Scheduler class to process the failed booing/cancellation data
 * Test class     : ReSyncingSchedulerTest
 *
 **/
 
global class BookingReSyncingScheduler implements Schedulable
{  
   
   public BookingReSyncingScheduler()
   {
   
   }
   
   public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        DataDeletionSetup__mdt dataSetup = new DataDeletionSetup__mdt();
        dataSetup = [SELECT QueryDetails__c,Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BookingReSyncSchedular' limit 1];
        
        
        for(attachment att : DataBase.Query(dataSetup.QueryDetails__c))
        {
            invokeReProcessing(att.Body.tostring(),att.ParentId);
        }
        
        Id jobId = System.schedule('BookingReSyncSchedular-'+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(dataSetup.Duration__c )).minute()+' */1 ? * *', this); 
    
    }
    
    @future(callout=true)
    public static void invokeReProcessing(String bookingdata,Id parentId)
    {
      List<DBLog_Summary__c> listDBSummToUpdate = new List<DBLog_Summary__c>();
      
      DBLog_Summary__c exstdbl = new DBLog_Summary__c();
      exstdbl = [Select id,name,Total_Success_count__c,X0_PG_Reference_ID__c,Total_Fail_count__c from DBLog_Summary__c WHERE Id =:parentId];
            
      DBLog_Summary__c dbl = new DBLog_Summary__c();
      dbl.type__c = 'RedBus Booking Sync Retry';
      dbl.SentAt__c = System.now();
      dbl.Request_Data__c = '';
      dbl.Response_Received__c ='';
      dbl.Orders_Success_Count__c = exstdbl.Total_Success_count__c;
      dbl.Orders_Failed_Count__c = exstdbl.Total_Fail_count__c;
      dbl.Parent_DBLog_Summary__c = parentId;
      
      if(String.isNotBlank(bookingdata))
        {
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            HttpResponse res = new HttpResponse();
            Http http = new Http(); 
            req.setEndpoint(system.Label.ReSyncURI);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization','Bearer '+UserInfo.getSessionId());
            req.setMethod('POST');
            req.setBody(bookingdata);
                    
            try
            {
                res = http.send(req);
                string responseValue = res.getBody();
                if(res.getStatusCode()==200)
                {
                    exstdbl.X0_PG_Reference_ID__c=True;
                    listDBSummToUpdate.add(exstdbl);
                    dbl.Response_Received__c = String.valueOf(res);
                    dbl.Complaint_Tracker_Status__c = 'Success';
                }
                
                else
                {
                    dbl.Complaint_Tracker_Status__c = 'Failure';
                    dbl.Response_Received__c = String.valueOf(res);
                }
               
            }
            catch(exception e)
            {
                System.debug('Error while reprocessing..'+e);
                dbl.Complaint_Tracker_Status__c = 'Failure';
                dbl.Exception_Description__c = String.valueOf(e);
            }
           
            listDBSummToUpdate.add(dbl);
                
            if(!listDBSummToUpdate.isEmpty())
            {
              upsert listDBSummToUpdate;
            }
        }
    }
}