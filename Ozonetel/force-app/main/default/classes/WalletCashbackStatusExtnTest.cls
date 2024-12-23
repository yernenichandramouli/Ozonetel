/**
 * (c) 2017 RedBus
 *
 * Name           : WalletCashbackStatusExtnTest
 * Created Date   : 03 Jan 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for WalletCashbackStatusExtn class
 *
 **/
 
@isTest
private class WalletCashbackStatusExtnTest 
{
     @isTest static void testCashBackStatus() 
     {
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321722';          
        insert orIt;
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(orIt);
        WalletCashbackStatusExtn WCBExtn = new WalletCashbackStatusExtn(stdCntrl);        
        WCBExtn.fetchCashbackStatus();
        
        orIt.Order_Item_Reference_No__c = 'TJCN77774445';
        update orIt;  
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
            WCBExtn.fetchCashbackStatus();
        Test.stopTest();
     
     }
}