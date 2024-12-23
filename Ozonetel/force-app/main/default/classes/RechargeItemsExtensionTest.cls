@isTest
public class RechargeItemsExtensionTest {
    
    static testMethod void testRechargeTransactions()
    {
        Test.startTest();
        Account acc=new Account();
        acc.PersonEmail='mani.renus@gmail.com';
        acc.PersonMobilePhone='9491322718';
        acc.LastName='Test';
        insert acc;
        PostGres_Data__c p=new PostGres_Data__c();
        p.Mobile__c='9491322718';
        p.Email__c='mani.renus@gmail.com';
        p.Account__c=acc.id;
        insert p;
        System.currentPageReference().getParameters().put('id', acc.id);
        RechargeItemsExtension obj = new RechargeItemsExtension(new ApexPages.StandardController(acc));
        Test.stopTest();        
    }
    
}