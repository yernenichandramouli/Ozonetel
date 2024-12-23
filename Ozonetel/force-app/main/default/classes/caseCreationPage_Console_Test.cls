@isTest
public class caseCreationPage_Console_Test
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
        ori.Customer_Name__c=ac.Id;
        ori.Date_Of_Service__c=System.Today();
        ori.Order_Id__c='ORI32482';
        ori.Source__c='Bangalore';
        ori.Destination__c='Hyderabad';
        Insert ori;
        
        Case cs = new Case();
        cs.Trip_Details_ct__c='Trip';
        cs.AccountId=ac.Id;
        cs.Transaction_ID__c=ori.Id;
        Insert cs;
        
       
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('accId',ac.Id);
        ApexPages.StandardController apx = new ApexPages.StandardController(ac);
        caseCreationPage_Console  css = new caseCreationPage_Console(apx);
        try
        {
            css.saveAll();
        }
        catch(Exception e){}
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
        ori.Customer_Name__c=ac.Id;
        ori.Date_Of_Service__c=System.Today();
        ori.Order_Id__c='ORI32482';
        ori.Source__c='Bangalore';
        ori.Destination__c='Hyderabad';
        Insert ori;
        
        Case cs = new Case();
        cs.Trip_Details_ct__c='Trip';
        cs.AccountId=ac.Id;
        cs.Transaction_ID__c=ori.Id;
        Insert cs;
        
       
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('accId',ac.Id);
        ApexPages.StandardController apx = new ApexPages.StandardController(ac);
        caseCreationPage_Console  css = new caseCreationPage_Console(apx);
        try
        {
            css.saveAll();
        }
        catch(Exception e){}
        Test.StopTest();
    }
}