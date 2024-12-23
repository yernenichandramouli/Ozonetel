/**
 * (c) 2017 RedBus
 *
 * Name           : MergeAndDeleteAccountsTest
 * Created Date   : 18 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for MergeAndDeleteAccounts class
 *
 **/
 
@istest
class MergeAndDeleteAccountsTest{

   static testmethod void test() {
  

      List<Account> lstAccont = new List<Account>();
      Account acc = new Account();
      acc.lastName = 'testAcc';
      acc.User_Id__c = '64237472';
      acc.WalletId__c = 'hgdhdhqwgdhqwdh';
      acc.personMobilePhone = '918884876772';
      lstAccont.add(acc);
      
      Account acc1 = new Account();
      acc1.lastName = 'testAcc22';
      acc1.User_Id__c = '';
      acc1.WalletId__c = '';
      acc1.personMobilePhone = '08884876772';    
      lstAccont.add(acc1);      
      insert lstAccont;
      
      Case c = new Case();
      c.issue_type__c='Bus Cancellation';
      c.Status ='Initiated';
      insert c;
      
      Test.setCreatedDate(lstAccont[0].id, DateTime.newInstance(2016,11,11));
      Test.setCreatedDate(lstAccont[1].id, DateTime.newInstance(2016,11,11));
       Test.startTest();
       System.debug('Select ..'+[Select Id,Phone_10_Digits__c,LastModifiedDate,User_Id__c,WalletId__c,Business_Unit__c from Account where Id in :lstAccont]);
      String que ='Select Id,Phone_10_Digits__c FROM Account where (LastModifiedDate=LAST_90_DAYS AND Phone_10_Digits__c!=null AND User_Id__c!=null AND WalletId__c!=null and Business_Unit__c=\'IND\') order by Phone_10_Digits__c ASC';
      MergeAndDeleteAccounts macc = new MergeAndDeleteAccounts();
      AccountMergeAndDelete mac2 = new AccountMergeAndDelete(que);
      GenericHardDeleteBatch ghd = new GenericHardDeleteBatch(que);
      
      MarkAllCasesAsCompletedBatch mcBatch = new MarkAllCasesAsCompletedBatch('Select id,status from case');
      
      System.scheduleBatch(mac2, 'MergeAndDeleteAccount2', 2);
      System.scheduleBatch(macc, 'MergeAndDeleteAccounts', 2);
      System.scheduleBatch(ghd, 'HardDelete', 2);
      System.scheduleBatch(mcBatch, 'CaseCompleted', 2);
      
    Test.stopTest();
    }
 }