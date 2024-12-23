@isTest
public class DeletingOrderItems_Test
{
    Static TestMethod void method()
    {
        Orders__c ori = new Orders__c();
        ori.Name='SampleName';
        Insert ori;
        
        Order_Items__c oris = new Order_Items__c();
        oris.Name='SampleName';
        oris.Creation_Time__c=System.Today().addDays(-Integer.Valueof(20));
        oris.Order_Name__c=ori.Id;
        Insert oris;
        
        Payment_Items__c pi = new Payment_Items__c();
        pi.Name='SampleName';
        pi.Order_Item_Name__c=oris.Id;
        Insert pi;
        
        PG_Payment_Items__c pgpi = new PG_Payment_Items__c();
        pgpi.Name='SampleName';
        pgpi.Order_Item_Name__c=oris.Id;
        Insert pgpi;
        
        Order_Item_Fare_Component__c orc = new Order_Item_Fare_Component__c();
        orc.Name='SampleNmae';
        orc.Order_Item_Name__c=oris.Id;
        Insert orc;
        
        Traveller_Info__c tra = new Traveller_Info__c();
        tra.Name='SampleName';
        tra.Order_Item_Name__c=oris.Id;
        Insert tra;
        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Order_Item_Name__c=oris.Id;
        Insert boi;
        
        Payment_Session__c ps = new Payment_Session__c();
        ps.Name='SampleName';
        ps.Order_Item_Name__c=oris.Id;
        Insert ps;
        
        Cancelled_Order_Items__c coi = new Cancelled_Order_Items__c();
        coi.Name='SampleName';
        coi.Order_Item_Name__c=oris.Id;
        Insert coi;
        
        Refund_Order_Items__c roi = new Refund_Order_Items__c();
        roi.Name='SampleName';
        roi.Order_Item_Name__c=oris.Id;
        Insert roi;
        
        Test.StartTest();
        DeletingOrderItems orcls = new DeletingOrderItems();
        Database.executeBatch(orcls);
        Test.StopTest();
    }
}