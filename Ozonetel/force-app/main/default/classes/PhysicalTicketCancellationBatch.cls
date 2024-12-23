/**
* (c) 2019 RedBus
*
* Name           : Physical Cancellation Case Creation Batch
* Created Date   : 28 feb 2019
* Created By     : Mahendra K
* Purpose        : Scheduler/Batch to move Physical Cancellation to saprate queue
*
**/

global class PhysicalTicketCancellationBatch implements Database.Batchable<sObject>,Schedulable
{      
    
    global final String query;
    DateTime currentStartTime;
    DateTime currentEndTime;
    
    Id queueId=[Select Id from Group where type='Queue' AND developername='Physical_Cancellation_Latam_Queue'].Id;
    
    public PhysicalTicketCancellationBatch(){}
    
    public PhysicalTicketCancellationBatch (String q)
    {
        currentEndTime = System.now().addMinutes(-630);
        system.debug('currentEndTime-->>'+currentEndTime);
        currentStartTime = currentEndTime.addMinutes(-180);
        system.debug('currentStartTime-->'+currentStartTime);
        if(String.isNotBlank(q))
           query = q;
        else
         query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='PhysicalCancellationTransactions'].QueryDetails__c;
    
    }
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='PhysicalCancellationTransactions'].Duration__c;
       System.schedule('PhysicalCancellationTransactions-'+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
       Database.executeBatch(new PhysicalTicketCancellationBatch(query),99);

    }
  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       
        System.debug('query..'+query);
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, list<Order_Items__c> orderItmlst)
    {
      List<Case> listCaseToInsert = new List<Case>();
      System.debug('query.44.'+query);
      try
      {
          for(Order_Items__c ordtm : orderItmlst)
          {  
          system.debug('ordtm-->>'+ordtm);
            if(ordtm.Cases__r.isEmpty())
            {
             system.debug('case-->>'+ordtm.Cases__r);
                case cs = new case();
                string comnBusUnit =ordtm.Business_Unit__c;
                comnBusUnit = 'REDBUS_'+comnBusUnit.split('_')[1];
                cs.country__c=OrderItemTransactionResource__c.getValues(comnBusUnit).Case_Country__c;
                cs.Business_Type__c=OrderItemTransactionResource__c.getValues(comnBusUnit).Case_Business_Type__c;
                cs.Issue_Type__c='Physical Cancellation';
                cs.Issue_Sub_Category__c='Initiate Physical Cancellation';
                cs.origin = 'Salesforce System';
                cs.tin_no__c = ordtm.Order_Item_Reference_No__c;
                cs.Transaction_ID__c =ordtm.id;
                cs.Trip_Id_ct__c = ordtm.Order_Id__c;
                cs.SS_Route_Id__c = ordtm.Route_Id__c;
                cs.SourceT__c = ordtm.Source__c;
                cs.DestinationT__c = ordtm.Destination__c;
                cs.Customer_Email_ID__c = ordtm.Email_Copy__c;
                cs.Customer_Phone_Number__c = ordtm.Mobile__c;
                cs.Email_Id_ct__c = ordtm.Email_Copy__c;
                cs.Phone_No_ct__c =ordtm.Mobile__c;
                cs.ownerid=queueId;
                listCaseToInsert.add(cs);
            }
          }
    
          if(!listCaseToInsert.isEmpty())
                Database.saveResult[] insertResult = Database.insert(listCaseToInsert,false);
        }
        Catch(Exception e)
        {
          System.debug('An error occured in physical cancellation..'+e);
        }     
          
    }
    
    global void finish(Database.BatchableContext BC)
    {
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       if(a.NumberOfErrors>0)
       {
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           List<String> toAddresses = new List<String>();
           toAddresses.add('sreenivasa.mariyavula@redbus.com');
           mail.setToAddresses(toAddresses);
           mail.setSubject('Physical Ticket Cancellation Case Creation Error..'+a.Status);
           mail.setPlainTextBody
           ('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
     
    
    }
    
  
}