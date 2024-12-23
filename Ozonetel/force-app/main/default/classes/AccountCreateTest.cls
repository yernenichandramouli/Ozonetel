@isTest
private class AccountCreateTest{
    
    /*Testing Account Creation */
    static testMethod void AccountCreateTest()
    {
        Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        acc.email_copy__c='te@r.com';
        insert acc;
        
        AccountCreate accObj = new AccountCreate(new ApexPages.StandardController(acc));
        accObj.acc.LastName='Test Account';
        accObj.save();
    }
    
    /*Testing Account Creation */
    static testMethod void AccountCreateTestFail()
    {
        Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        acc.email_copy__c='te@r.com';
        insert acc;
        
        AccountCreate accObj = new AccountCreate(new ApexPages.StandardController(acc));
        accObj.save();
    }
    
}