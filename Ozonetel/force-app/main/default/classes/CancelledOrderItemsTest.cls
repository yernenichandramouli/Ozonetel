@isTest
private class CancelledOrderItemsTest {
    
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
    }
    
    static testMethod void testSuccess()
    {
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Group g= new Group();
        g.Name = 'Force Cancellation Queue';
        insert g;
        Cancelled_Order_Items__c co=new Cancelled_Order_Items__c ();
        co.Order_Item_Name__c=ol[0].id;
        co.Operator_Cancellation_Status__c='OPERATOR_CANCELLATION_INITIATED';
        co.Seates_to_be_cancelled__c='21,23';
        insert co;
        
        co.Operator_Cancellation_Status__c='OPERATOR_CANCELLATION_SUCCESS';
        
       update co;
    }
  
    
}