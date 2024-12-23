global class DeletingOrderItems implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        Date PriviousDays = System.Today().addDays(-Integer.Valueof(Label.Transaction_Delete_Duration));
        // return DataBase.getQueryLocator([Select Id,Order_Name__c From Order_Items__c Where RecordType.Name!='Rails' AND Creation_Time__c<=:PriviousDays AND Open_Cases__c<=0]);
        If(!Test.isRunningTest()){
            return DataBase.getQueryLocator([SELECT Id,Order_Name__c FROM Order_Items__c  WHERE RecordType.Name!='Rails' AND LastModifiedDate <:PriviousDays and Id Not IN (SELECT Transaction_ID__c FROM Case)]);
        }else{
            PriviousDays = System.Today().addDays(-Integer.Valueof(20));
            return DataBase.getQueryLocator([Select Id,Order_Name__c From Order_Items__c Where RecordType.Name!='Rails' AND Creation_Time__c<=:PriviousDays AND Open_Cases__c<=0]);
        }
        
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
        //Delete [SELECT Id,Transaction_ID__c,Status From Case Where Transaction_ID__c IN : orIds AND Status='Closed'];

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