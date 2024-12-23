/**
 * (c) 2017 RedBus
 *
 * Name           : WalletHistoryCntrlTest
 * Created Date   : 03 Jan 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for WalletHistoryCntrl class
 *
 **/
 
@isTest
private class WalletHistoryCntrlTest 
{
     @isTest static void testWalletHistory() 
     {
        Account testAccount = new Account();
        testAccount.Name = 'AccountTest';
        testAccount.BillingCity = 'Pune';
        testAccount.phone='5678900009';
        testAccount.BillingState = 'Maharashtra';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert testAccount;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(testAccount);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        WalletHistoryCntrl hist = new WalletHistoryCntrl(sc);
        WalletHistoryCntrl.WalletHistoryResponse wresp= new WalletHistoryCntrl.WalletHistoryResponse();
        wresp.TransactionDate ='testDate';
        wresp.TransactionMode ='systemMode';
        wresp.TransactionType ='Online';
        wresp.Amount ='345';
        wresp.ExprationDate ='today';
        wresp.OfferName ='prime';
        wresp.AmountUsed ='67';
        wresp.OpeningBalance ='67';
        wresp.ClosingBalance ='tsr';
        wresp.SalesChannel ='web';
        wresp.ReferenceNo ='345678';
        hist.fetchWalletHistoryDetails();
        Test.stopTest();
     
     }
}