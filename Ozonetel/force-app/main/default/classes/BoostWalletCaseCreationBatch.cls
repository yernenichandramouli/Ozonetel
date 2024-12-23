/**
* (c) 2019 RedBus
*
* Name           : Boost Wallet Case Creation Batch
* Created Date   : 07 March 2019
* Created By     : Sreenivas M
* Purpose        : Scheduler/Batch to create Boost Cases For Refund Processing
*
**/

global class BoostWalletCaseCreationBatch implements Database.Batchable<sObject>,Schedulable
{      
    
    global final String query;
    DateTime currentStartTime;
    DateTime currentEndTime;
    
    Id queueId=[Select Id from Group where type='Queue' AND developername='BoostWalletQueue'].Id;
    
    public BoostWalletCaseCreationBatch(){}
    
    public BoostWalletCaseCreationBatch(String q)
    {
        if(String.isNotBlank(q))
           query = q;
        else
         query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BoostWalletQueue'].QueryDetails__c;
    
    }
    
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BoostWalletQueue'].Duration__c;
        System.schedule('BoostWallet- '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new BoostWalletCaseCreationBatch(query),90);   
    }
       
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, list<Refund_Order_Items__c> refOrderItmlst)
    {
      List<Case> listCaseToInsert = new List<Case>();
      System.debug('query.44.'+query);
      try
      {
          Map<String,String> mapTripToTransId = new Map<String,String>();
          Map<String,Refund_Order_Items__c> mapTripToOrderItem = new Map<String,Refund_Order_Items__c>();
          
          for(Refund_Order_Items__c ordtm : refOrderItmlst)
          {
               mapTripToOrderItem.put(ordtm.Trip_ID__c,ordtm);
          }
          
          for(Case cs :[Select id,trip_id__c from Case Where Trip_Id_ct__c IN :mapTripToOrderItem.keySet() AND Issue_Type__c='Boost Wallet' AND Issue_Sub_Category__c='Boost Wallet Refund'])
          {
              if(mapTripToOrderItem.containsKey(cs.trip_id__c))
                  mapTripToOrderItem.remove(cs.trip_id__c);
                          
          }
          
          for(Refund_Order_Items__c refOrd :mapTripToOrderItem.values())
          {
            case cs = new case();
            cs.country__c=OrderItemTransactionResource__c.getValues(refOrd.Business_UnitF__c).Case_Country__c;
            cs.Business_Type__c=OrderItemTransactionResource__c.getValues(refOrd.Business_UnitF__c).Case_Business_Type__c;
            cs.Issue_Type__c='Boost Wallet';
            cs.Issue_Sub_Category__c='Boost Wallet Refund';
            cs.tin_no__c = refOrd.TIN__c;
            cs.origin = 'Salesforce System';
            cs.Transaction_ID__c =refOrd.Order_Item_Name__c;
            cs.Refund_Amount__c = Double.ValueOf(refOrd.Refund_Amount__c.split(' ')[1]);
            cs.Price_Paid_Currency_ctp__c = String.valueOf(refOrd.Refund_Amount__c.split(' ')[0]);
            cs.PG_Name__c=refOrd.PG_Name__c;
            cs.PG_Type__c = refOrd.PG_Type__c;
            cs.PG_Ttransaction_Id__c =refOrd.PG_Reference_No__c;
            cs.Paas_OrderId__c = refOrd.Payment_Item_ID__c;
            cs.Trip_Id_ct__c = refOrd.Trip_ID__c;
            
            if(String.isNotBlank(refOrd.Order_Item_Name__c))
            {
                cs.SourceT__c = refOrd.Order_Item_Name__r.Source__c;
                cs.DestinationT__c = refOrd.Order_Item_Name__r.Destination__c;
                cs.Customer_Email_ID__c = refOrd.Order_Item_Name__r.Email_Copy__c;
                cs.Customer_Phone_Number__c = refOrd.Order_Item_Name__r.Mobile__c;
                cs.Email_Id_ct__c = refOrd.Order_Item_Name__r.Email_Copy__c;
                cs.Phone_No_ct__c = refOrd.Order_Item_Name__r.Mobile__c;
                cs.SS_Route_Id__c = refOrd.Order_Item_Name__r.Route_Id__c;
            }
            cs.ownerid=queueId;
            listCaseToInsert.add(cs);
        
          }
    
          if(!listCaseToInsert.isEmpty())
                Database.saveResult[] insertResult = Database.insert(listCaseToInsert,false);
        }
        Catch(Exception e)
        {
          System.debug('An error occured in Boost Wallet Cases..'+e);
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