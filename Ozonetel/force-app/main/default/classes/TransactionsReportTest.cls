@isTest
public class TransactionsReportTest {
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
    }
   
    static testMethod void testTransactionsReport()
    {
       list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Test.StartTest();   
        TransactionsReport t= new TransactionsReport ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, t);
        Test.StopTest();
    }
    
}