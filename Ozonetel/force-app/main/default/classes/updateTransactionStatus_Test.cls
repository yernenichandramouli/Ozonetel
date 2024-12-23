@isTest
public class updateTransactionStatus_Test
{
    Static TestMethod void method()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='WFT-COT';
        tsc.Status__c='TENTATIVE_COMPLETED';
        tsc.Category__c='WFT';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='TENTATIVE_COMPLETED';
        oi.Service_Provider_Reference_No__c='SP2361';
        oi.Order_Item_Reference_No__c='O462@1';
        oi.Transaction_Status__c ='White Failed Transaction (WFT)';
        oi.Transaction_Status_WFT_GFT__c='TENTATIVE_COMPLETED';
        Insert oi;
        Update oi;
        
    }
    Static TestMethod void method1()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='GFT-GATE';
        tsc.Status__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        tsc.Category__c='GFT';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        oi.Transaction_Status__c ='GFT - Payment Debited but Ticket not Generated';
        oi.Transaction_Status_WFT_GFT__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        Insert oi;
        Update oi;
        
    }
    Static TestMethod void method2()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='GFT-GATE';
        tsc.Status__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        tsc.Category__c='GFT';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='CONFIRMED';
        oi.Service_Provider_Reference_No__c='SP2361';
        oi.Order_Item_Reference_No__c='';
        oi.Transaction_Status__c ='Misbooking - PNR generated but ticket not confirmed';
        oi.Transaction_Status_WFT_GFT__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        Insert oi;
        Update oi;
        
    }
    Static TestMethod void method3()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C C-C';
        tsc.Status__c='CANCELLATION_COMPLETED';
        tsc.Category__c='Cancelled';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='CANCELLATION_COMPLETED';
        oi.Service_Provider_Reference_No__c='SP2361';
        oi.Order_Item_Reference_No__c='O462@1';
        oi.Transaction_Status__c ='Ticket Cancelled';
        Insert oi;
        Update oi;
        
        Payment_Items__c pi = new Payment_Items__c();
        pi.Name='SampleName';
        pi.Payment_Status__c='Confirm';
        pi.Payment_System__c='Booked';
        pi.Order_Item_Name__c=oi.Id;
        Insert pi;
        Update oi;  
    }
    Static TestMethod void method4()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-C';
        tsc.Status__c='CONFIRMED';
        tsc.Category__c='Confirmed';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='CONFIRMED';
        oi.Service_Provider_Reference_No__c='SP2361';
        oi.Order_Item_Reference_No__c='O462@1';
        oi.Transaction_Status__c ='Booked';
        Insert oi;
        Update oi;
        
        Payment_Items__c pi = new Payment_Items__c();
        pi.Name='SampleName';
        pi.Payment_Status__c='FAILED';
        pi.Payment_System__c='Online';
        pi.Order_Item_Name__c=oi.Id;
        Insert pi;
        Update oi;
        
    }
    Static TestMethod void method5()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C C-C';
        tsc.Status__c='CANCELLATION_COMPLETED';
        tsc.Category__c='Cancelled';
        Insert tsc;
        
        Order_Items__c  oi = new Order_Items__c();
        oi.Name='SampelName';
        oi.Status__c='CANCELLATION_COMPLETED';
        oi.Service_Provider_Reference_No__c='SP2361';
        oi.Order_Item_Reference_No__c='O462@1';
        oi.Transaction_Status__c ='Ticket Cancelled';
        Insert oi;
        Update oi;
    }
    
}