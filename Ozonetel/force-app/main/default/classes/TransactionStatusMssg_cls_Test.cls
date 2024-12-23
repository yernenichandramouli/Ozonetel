@isTest
public class TransactionStatusMssg_cls_Test
{
    Static TestMethod void method()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='TRANSACTION_LIS_TENTATIVE_COMPLETE';
        ori.Primary_Contact_Customer__c=ac.Id;
        Insert ori;
        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Primary_Boarding_Time__c =System.Now();
        boi.Order_Item_Name__c=ori.Id;
        Insert boi;
        
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='WFT-INI';
        tsc.Category__c='WFT';
        tsc.Status__c='TRANSACTION_LIS_TENTATIVE_COMPLETE';
        Insert tsc;
        
        //Long Diff=((ori.Bus_Order_Item_Details__r[0].Primary_Boarding_Time__c.getTime())/1000/60/60-((DateTime.now().getTime())/1000/60/60));
        //ori= [Select Id,Name,status__c,Primary_Contact_Customer__c,(Select Id,Name,Primary_Boarding_Time__c From Bus_Order_Item_Details__r) From Order_Items__c Where Bus_Order_Item_Details__r.Primary_Boarding_Time__c =:Diff]; 
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        TransactionStatusMssg_cls tra = new TransactionStatusMssg_cls(con);
        Test.StopTest();
    }
    Static TestMethod void method1()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        ori.Primary_Contact_Customer__c=ac.Id;
        Insert ori;
        
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='GFT-GATE';
        tsc.Category__c='GFT';
        tsc.Status__c='TRANSACTION_PAYMENT_GATEWAY_COMPLETED';
        Insert tsc;
        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Primary_Boarding_Time__c =System.Now();
        boi.Order_Item_Name__c=ori.Id;
        Insert boi;
            
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        TransactionStatusMssg_cls tra = new TransactionStatusMssg_cls(con);
        Test.StopTest();
    }
    Static TestMethod void method2()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CANCELLATION_COMPLETED';
        ori.Primary_Contact_Customer__c=ac.Id;
        Insert ori;
        
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-CC';
        tsc.Category__c='Cancelled';
        tsc.Status__c='CANCELLATION_COMPLETED';
        Insert tsc;

        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Primary_Boarding_Time__c =System.Now();
        boi.Order_Item_Name__c=ori.Id;
        Insert boi;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        TransactionStatusMssg_cls tra = new TransactionStatusMssg_cls(con);
        Test.StopTest();
    }
    Static TestMethod void method3()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CANCELLATION_COMPLETED';
        ori.Primary_Contact_Customer__c=ac.Id;
        Insert ori;
        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Primary_Boarding_Time__c =System.Now();
        boi.Order_Item_Name__c=ori.Id;
        Insert boi;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        TransactionStatusMssg_cls tra = new TransactionStatusMssg_cls(con);
        Test.StopTest();
    }
    Static TestMethod void method4()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
                
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CANCELLATION_COMPLETED';
        ori.Primary_Contact_Customer__c=ac.Id;
        Insert ori;
        
        Bus_Order_Item_Details__c boi = new Bus_Order_Item_Details__c();
        boi.Name='SampleName';
        boi.Primary_Boarding_Time__c =System.Now()-2;
        boi.Order_Item_Name__c=ori.Id;
        Insert boi;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        TransactionStatusMssg_cls tra = new TransactionStatusMssg_cls(con);
        Test.StopTest();
    }
    
}