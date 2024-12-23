/**
 * (c) 2018 RedBus
 *
 * Name           : DeleteWFTOrderItems
 * Created Date   : 16 July 2018
 * Created By     : Sreenivas M
 * Purpose        : Batch class to delete WFT transactions on daily basis
 *
 **/
global class DeleteWFTOrderItems implements DataBase.Batchable<sObject>,Schedulable
{
    public void execute(SchedulableContext scon)
    {
        Database.executebatch(new DeleteWFTOrderItems());
    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        Date PriviousDays = System.Today().addDays(-Integer.Valueof(Label.WFTDeletionTime));
        return DataBase.getQueryLocator([Select Id,Order_Name__c From Order_Items__c Where Business_Unit__c='REDBUS_IN' AND Transaction_Status__c='WFT' AND Transaction_Latest_status__c!='SUCCESS' AND Creation_Time__c<=:PriviousDays]);
    }
    
    global void execute(DataBase.BatchableContext bc,List<Order_Items__c> orderItemList)
    {
        Set<Id> orIds = new Set<Id>();
        Set<String> ordersIds = new Set<String>();
        List<Orders__c> orderList = new List<Orders__c>();
        for(Order_Items__c ori : orderItemList)
        {
            orIds.add(ori.Id);            
            System.Debug('@@==>> ori.Order_Name__c Before: '+ori.Order_Name__c+'..'+ori.id);
            if(ori.Order_Name__c!=Null)
            {
                ordersIds.add(ori.Order_Name__c); 
             
            }
        }
        System.Debug('@@==>> orIds: '+orIds);
        System.Debug('@@==>> orderList: '+orderList);
        Delete [SELECT Id,Order_Item_Name__c FROM Payment_Items__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM PG_Payment_Items__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECt Id,Order_Item_Name__c FROM Order_Item_Fare_Component__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM Traveller_Info__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM Bus_Order_Item_Details__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM Payment_Session__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM Cancelled_Order_Items__c Where Order_Item_Name__c IN : orIds];
        Delete [SELECT Id,Order_Item_Name__c FROM Refund_Order_Items__c Where Order_Item_Name__c IN : orIds];
        Delete orderItemList;        
        Delete [SELECT Id,Name FROM Orders__c WHERE Id IN: ordersIds];  
             
    }
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.Delete_Transaction_Alert_Email.Split(','));
       mail.setToAddresses(toAddresses);
       mail.setSubject('Order Items Delete Status: '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}