@isTest
public class PhysicalTicketCancellationBatch_Test
{
    static testMethod void physicalcancellation()
    {
     Datetime curntdt =system.now().addMinutes(-420); 

        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Country__c='Peru';
        oritran.Name = 'REDBUS_PE';
        oritran.Auth_Key__c = 'PER';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='Peru-Bus';
        insert oritran;
        
      list<Order_Items__c> ordrlst =new list<Order_Items__c>();
       
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Email_Copy__c = 'test@redbus.com';
        ordtm.Route_Id__c='TEST123';
        ordtm.Mobile__c = '1234567891';
        ordtm.Destination__c='bangalore';
        ordtm.Source__c='hyderabad';
        ordtm.Business_Unit__c = 'REDBUS_PE';
        ordtm.Cancellation_Time__c=curntdt;
        ordtm.status__c = 'TR_CANCELLATION_INITIATED_PO_COMPLETED';
        ordrlst.add(ordtm);
        insert ordrlst;
    
      
        
       Test.startTest();
        PhysicalTicketCancellationBatch physclbatch= new PhysicalTicketCancellationBatch();
       
        String sche ='0 0 22 * * ? *';
        system.schedule('Test',sche, physclbatch);
        Test.stopTest();
    }
  }