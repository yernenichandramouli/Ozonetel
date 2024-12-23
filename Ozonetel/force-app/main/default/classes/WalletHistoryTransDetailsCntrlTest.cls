@isTest
public class WalletHistoryTransDetailsCntrlTest {  
    @isTest
    public static void WalletHistoryTest(){
    
    Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oi.Transaction_Status__c ='Booked';
        oi.Rb_User_ID__c = '48191371';
        insert oi;
        
    WalletHistoryTransDetailsCntrl.GetWalletHistoryDetails(oi.id);
     WalletHistoryTransDetailsCntrl.GetWalletHistoryDetails('');
  }
  
   @isTest
   public static void WalletHistoryFail(){
    
    Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oi.Transaction_Status__c ='Booked';
        //oi.Rb_User_ID__c = '48191371';
        insert oi;
        
    WalletHistoryTransDetailsCntrl.GetWalletHistoryDetails(oi.id);
  }
}