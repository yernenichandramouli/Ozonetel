@isTest
public class ReSyncingSchedulerTest
{
    static testMethod void ReSync()
    {
    DBLog_Summary__c  dbl = new DBLog_Summary__c ();
    dbl.type__c='BOOKING';
    dbl.BusOrder_Item_Details_Failed_Count__c=1;
    dbl.Cancelled_Order_Items_Failed_Count__c=1;
    dbl.Order_Item_Fare_Components_Failed_Count__c =1;
    dbl.Order_Items_Failed_Count__c =1;
    dbl.Orders_Failed_Count__c =1;
    dbl.Payment_Items_Failed_Count__c =1;
    dbl.Payment_Sessions_Failed_Count__c =1;
    dbl.PG_Payment_Items_Failed_Count__c =1;
    dbl.Refund_Order_Items_Failed_Count__c =1;
    dbl.Traveller_Info_Failed_Count__c=1;
    insert dbl;
    
    Attachment attach=new Attachment();       
    attach.Name='Test Attachment';
    Blob bodyBlob=Blob.valueOf('Test Attachment Body');
    attach.body=bodyBlob;
    attach.parentId=dbl.id;
    insert attach;
    
    test.starttest();
    Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
    ReSyncingScheduler Resch= new ReSyncingScheduler();
    String sche ='0 0 22 * * ? *';
    system.schedule('Test', sche, Resch);
    
    BookingReSyncingScheduler Rescyh= new BookingReSyncingScheduler();
 
    system.schedule('Test2', sche, Rescyh);
    
    
    Test.stopTest();
    }
}