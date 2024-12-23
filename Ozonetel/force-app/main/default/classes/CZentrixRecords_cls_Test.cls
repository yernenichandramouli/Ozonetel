@isTest
public class CZentrixRecords_cls_Test
{
    Static TestMethod void method()
    {
        Account acc = new Account();
        acc.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        acc.RecordTypeId = recordTypeId;
        Insert acc;
        
        CZentrix_Info__c ci = new CZentrix_Info__c();
        ci.Date_Time__c=System.Today()-7;
        ci.Account_Name__c=acc.Id;
        Insert ci;
        
        CZentrix_CSAT__c cc = new CZentrix_CSAT__c();
        cc.Name='SamleName';
        cc.answer__c='Test';
        cc.CZentrix_Info__c=ci.Id;
        Insert cc;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',acc.Id);
        ApexPages.StandardController apx = new ApexPages.StandardController(acc);
        CZentrixRecords_cls CzCls = new CZentrixRecords_cls(apx);
        Test.StopTest();
        
    }
}