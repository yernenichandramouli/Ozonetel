@isTest 
public class caseLinkTocZentrixInfo_Test
{
    Static TestMethod void method()
    {
        Account ac = new Account();
        ac.name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
    
        Order_Items__c ori= new Order_Items__c();
        ori.Name='SampleName';
        Insert ori;
        
        CZentrix_Info__c cz = new CZentrix_Info__c();
        cz.Account_Name__c=ac.Id;
        //cz.Case__c=cs.Id;
        cz.OwnerId=UserInfo.getUserId();
        Insert cz;
        
        Case cs = new Case();
        //cs.LastModifiedById=UserInfo.getUserId();
        cs.AccountId=ac.Id;
        cs.Customer_Name__c=ac.Id;
        cs.Transaction_ID__c=ori.Id;
        Insert cs;
        
        
    }
}