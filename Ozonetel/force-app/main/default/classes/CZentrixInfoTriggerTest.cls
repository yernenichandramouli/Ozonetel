/**
* (c) 2017 RedBus
*
* Name           : CZentrixInfoTrigger
* Created Date   : 06 Jun 2017
* Created By     : Sreenivas M
* Purpose        : Trigger to link C-Zentrix Info to Account
* Test class     : CZentrixInfoTriggerTest
*
**/

@isTest
private class CZentrixInfoTriggerTest{
    @isTest static void testLinking() 
    {
        Account acc = new Account();
        acc.PersonMobilePhone = '8823728832';
        acc.LastName ='Testing Acc';
        insert acc;
        
        
        
        lead ld=new lead();
        ld.lastname='Test';
        ld.Status='New';
        insert ld;
        CZentrix_Info__c cz = new CZentrix_Info__c();
        cz.Customer_Ph_No__c = '8823728832';
        cz.Campaign_Name__c ='redBus_Inbound';
        cz.Lead__c=ld.id;
        insert cz;
        cz = [Select id,Customer_Ph_No__c,Account_Name__c from CZentrix_Info__c where id=:cz.id];
        System.debug('--cz---'+cz);
    }
}