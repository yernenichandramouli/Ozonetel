/**
* Name           : AccountTriggerTest
* Created Date   : 17 Aug 2017
* Created By     : Veeramanikanta R
* Purpose        : Test class for AccountTrigger and AccountTriggerHangler class
*
**/

@isTest
private class AccountTriggerTest {
    
    /*Testing for Valid HF Account */
    static testMethod void testValidHF()
    {
        High_Frequency_Data__c hf=new High_Frequency_Data__c ();
        hf.Name='Test HF';
        hf.Email__c='test@redbus.in';
        hf.Phone__c='9491322718';
        insert hf;
        Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        insert acc;
            
    }
    /*Testing not valid HF Account */
    static testMethod void testNotValidHF()
    {
        High_Frequency_Data__c hf=new High_Frequency_Data__c ();
        hf.Name='Test HF';
        hf.Email__c='best@redbus.in';
        hf.Phone__c='9491322719';
        insert hf;
        Account acc=new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.lastname='Test Account';
        acc.PersonEmail='test@redbus.in';
        acc.PersonMobilePhone='9491322718';
        acc.email_copy__c='te@r.com';
        insert acc;
            
    }
}