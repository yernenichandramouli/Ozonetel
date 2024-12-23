/**
 * (c) 2018 RedBus
 *
 * Name           : DeleteWFTOrderItemsTest
 * Created Date   : 05 Nov 2018
 * Created By     : Mahendra K
 * Purpose        : Test class for DeleteWFTOrderItems
 *
 **/
@isTest
public class DeleteWFTOrderItemsTest
{
    static testMethod void deleteWFTOrderItems_Batch()
    {
        Set<Id> orIds = new Set<Id>();
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        insert order;
        
        List<Order_Items__c> orderList = new List<Order_Items__c>();
        Order_Items__c o = new Order_Items__c();
        o.Business_Unit__c='REDBUS_IN';
        o.Transaction_Status__c='WFT';
        o.Transaction_Latest_status__c='';
        o.Creation_Time__c=System.Today().addDays(-5);
        o.Order_Name__c =order.id;
        insert o;
        
        Payment_Items__c p = new Payment_Items__c();
        p.Order_Item_Name__c=o.id;
        insert p;
        
        DeleteWFTOrderItems cls= new DeleteWFTOrderItems();
        Database.executeBatch(cls,1);
      
    }
}