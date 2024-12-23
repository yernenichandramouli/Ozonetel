@isTest
public class ListofCasesBasedonAcc_Test
{
    Static TestMethod void method()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Case cs = new Case();
        cs.AccountId=ac.Id;
        Insert cs;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id',ac.Id);
        ApexPages.StandardController apx = new ApexPages.StandardController(ac);
        ListofCasesBasedonAcc acc = new ListofCasesBasedonAcc(apx);
        fetchAllFields.getFields('Case');
        Test.StopTest();
    }
    
}