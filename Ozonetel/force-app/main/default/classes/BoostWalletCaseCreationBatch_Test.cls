@isTest
public class BoostWalletCaseCreationBatch_Test
{
    static testMethod void caseInsert()
    {
    OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
    oritran.Case_Country__c='peru';
    oritran.Name = 'REDBUS_SG';
    oritran.Auth_Key__c = 'SGP';
    oritran.Channel_Name__c = 'MOBILE_APP';
    oritran.Case_Business_Type__c='REDBUS_SG';
    insert oritran;
        
    Order_Items__c ordtm = new Order_Items__c();
    ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
    ordtm.Order_Id__c = '12410791449275457';
    ordtm.Email_Copy__c = 'test@redbus.com';
    ordtm.Route_Id__c='TEST123';
    ordtm.Mobile__c = '1234567891';
    ordtm.Destination__c='bangalore';
    ordtm.Total_Fare_Currency__c='MY';
    ordtm.Source__c='hyderabad';
    ordtm.Business_Unit__c = 'REDBUS_SG';
    insert ordtm;
        
    list<Refund_Order_Items__c> listrefundorditem = new list<Refund_Order_Items__c>();
    Refund_Order_Items__c rfnord= new Refund_Order_Items__c();
    rfnord.PG_Name__c='BoostWallet';
    rfnord.PG_Type__c='BoostWalle';
    rfnord.Status__c='REFUND_CREATED';
    rfnord.Refunded_Amount__c=10;
    rfnord.PG_Reference_No__c='12334';
    rfnord.Payment_Item_ID__c='123456';
    rfnord.Refunded_Time__c=system.now().addMinutes(-930); 
    rfnord.Order_Item_Name__c=ordtm.id;
    listrefundorditem.add(rfnord);
    insert listrefundorditem;
    System.debug('ttt-->'+listrefundorditem[0].id);
    Refund_Order_Items__c rs=[select id,Refund_Initiation_Age__c from Refund_Order_Items__c where id=:listrefundorditem[0].id];
    
    system.debug('test-->'+rs+'time-->>'+listrefundorditem[0].Refunded_Time__c+'age--'+rs.Refund_Initiation_Age__c);
    
    
    Test.startTest();
    BoostWalletCaseCreationBatch boostcsecrtn= new BoostWalletCaseCreationBatch();
    String sche = '0 0 0 ? * * *';
    system.schedule('Test',sche, boostcsecrtn);
    Test.stopTest();
    
    }
}