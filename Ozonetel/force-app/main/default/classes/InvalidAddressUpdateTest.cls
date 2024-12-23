@isTest
public class InvalidAddressUpdateTest {
    @istest static void methodToTest(){
    	Order_Items__c oi = new Order_Items__c();
        oi.Business_Unit__c='REDBUS__MY';
        oi.Transaction_Status__c='Open';
        oi.Boarding_Point__c='ABC';
        insert oi;
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS__MY';
        oritran.Auth_Key__c = 'SGMY';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS__MY';
        insert oritran;
        InvalidAddressUpdate.GetDetails(oi.id);
        InvalidAddressUpdate.InvalidAddressCaseCreate(oi.id,'asdf','Wrong Address',oi.Boarding_Point__c);
    }
}