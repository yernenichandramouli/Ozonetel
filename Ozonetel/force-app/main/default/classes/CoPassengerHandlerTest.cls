@isTest
private class CoPassengerHandlerTest{
    
    
    static testMethod void test()
    {
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i,Flag__c=0,Business_Unit__c='REDBUS_IN',Transaction_Status__c='Booked',Order_Item_Reference_No__c='TN123456',Date_Of_Service__c =system.now(),Route_Id__c='2345876', Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
        case cObj=new case();
        cObj.Transaction_ID__c=orderList[0].id;
        cObj.Service_Id__c='1234';
        insert cObj;
        CoPassengerHandler.coPassengerCases(cObj.id,'Case');
    }   
}