/**
 * (c) 2018 RedBus
 *
 * Name           : RTCescalatedtoBDBclose
 * Created Date   : 27 JUNLY 2023
 * Created By     : Mahendra k
 * Purpose        : Batch class to close RTC cases in Escalated to BD for 10 days
 **/
 
global class RTCescalatedtoBDBclose implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public RTCescalatedtoBDBclose(){}
  
    public RTCescalatedtoBDBclose(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RTC_EscalatedBD_Close'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RTC_EscalatedBD_Close'].Duration__c;
        System.schedule('RTCescalatedtoBDBclose - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RTCescalatedtoBDBclose(Query));
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
     global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
      System.debug('## ..'+listCase.size()+' records'+'..'+listCase);
      
      
      if(!listCase.isEmpty())
      {
      
         DateTime currTime = System.Now(); 
         
        Set<String> setRTCIssuTypes = new Set<String>(System.label.RTCissuetypes.split(','));

        Set<String> rtcBOIds = new Set<String>(System.Label.RTC_BO_IDS.split(','));
        rtcBOIds.addAll(System.Label.RTC_BO_IDS.split(','));


        List<case> listCasesToUpdate = new List<Case>();
        list<casecomment> listCommToInsert = new List<casecomment>();
        Group BDQ=[select id from Group where type='Queue' AND developername='BD_Queue']; 

        Map<String,RTCBODetails__c> mapRTCdtls = new Map<String,RTCBODetails__c>();
        
        for(RTCBODetails__c r: RTCBODetails__c.getAll().Values())
        {
            mapRTCdtls.put(r.ServiceOperatorID__c,r);
        }
        
        for(Case cs : listCase)
        {
           datetime sevendaysinBD=cs.Assigned_to_BD__c.addDays(7);
           //addMinutes(10);
           
           //addDays(7);
           
           string serviceProvId =  String.isNotBlank(cs.Service_Provider_Id__c)?cs.Service_Provider_Id__c:String.isNotBlank(cs.Service_Providerr_Id__c)?cs.Service_Providerr_Id__c:'';

           if(currTime > sevendaysinBD && rtcBOIds.contains(serviceProvId) && setRTCIssuTypes.contains(cs.Issue_Type__c)){
            CaseComment comm= new CaseComment();
               cs.RTCclosed__c=true;
                String optarName= String.isNotBlank(cs.Bus_Operator_Name__c)?cs.Bus_Operator_Name__c:String.isNotBlank(cs.Bus_Operator_Namee__c)?cs.Bus_Operator_Namee__c:'';

                if(mapRTCdtls.containsKey(serviceProvId)){
                    cs.BO_Phone__c=mapRTCdtls.get(serviceProvId).BOphone__c;
                    cs.BO_Email__c=mapRTCdtls.get(serviceProvId).BOemail__c;
                }
                cs.Description='issueTypes days 10';
                cs.Status ='Closed';
                comm.commentbody='(STC)We regret the unpleasant experience.We had raised your complaint with the'+optarName+'.We have been multiple follow-ups from our end for the resolution. As on date, we have not received an update from'+' '+cs.Service_Provider_Name__c+'.Hence we would request you to take up the issue directly to RTC counter';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listCasesToUpdate.add(cs);
          }
        }
        
         if(!listCommToInsert.isEmpty()){
          insert listCommToInsert;
        }
         
         
        if(!listCasesToUpdate.isEmpty())
            update listCasesToUpdate;
      }
    }
    
       global void finish(Database.BatchableContext BC) 
    {                 
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('Mahendrareddy.k@redbus.com.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Case Assignment Has Finished '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
  }