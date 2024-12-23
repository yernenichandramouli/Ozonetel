@isTest
public class PayAtBusReleaseSeatCntrlTest{
    @testsetup
    static void testCreateOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<200 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i ,Guid__c='234567890',status__c='TR_TENTATIVE_BLOCK_FOR_OFFLINE_PO_INITIATED', Service_Provider_Id__c = 'Salesforce',Order_Id__c='123456789',Order_Item_Reference_No__c='12345678',Business_Unit__c='REDBUS_PE',email__c='mani.renus@gmail.com',Mobile__c='09491322718',Date_Of_Purchase__c=system.now()));
        } 
        insert orderList ;
    }
    
    public static testMethod void methodTest()
    {
        list<Order_Items__c> ol=[select id,status__c,Guid__c,Order_Item_Reference_No__c,name,email__c,Mobile__c from Order_Items__c];
       
        case cs = new case();
        cs.Issue_Type__c='Pay at bus';
        cs.Issue_Sub_Category__c='I have generated Pay at Bus voucher';
        cs.TIN_No__c=ol[0].Order_Item_Reference_No__c;
        insert cs;
        
        string mockResp='true';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
         Test.startTest();
        PayAtBusReleaseSeatCntrl.GetPayAtBusTrans(ol[0].id);   
        Test.stopTest();
    }
    
    public static testMethod void failTest()
    {
        list<Order_Items__c> ol=[select id,status__c,Guid__c,name,email__c,Mobile__c from Order_Items__c];
        Test.startTest();
        string mockResp='{"code":"700.15","Message":"Invalid Response","DetailedMessage":"unable to get ticket details"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        
        PayAtBusReleaseSeatCntrl.GetPayAtBusTrans(ol[0].id);   
        Test.stopTest();
    }
  
   public static testMethod void failTest1()
    {
        list<Order_Items__c> ol=[select id,status__c,Guid__c,Order_Item_Reference_No__c,name,email__c,Mobile__c from Order_Items__c];
       
        case cs = new case();
        cs.Issue_Type__c='Pay at bus';
        cs.Issue_Sub_Category__c='I have generated Pay at Bus voucher';
        cs.TIN_No__c=ol[0].Order_Item_Reference_No__c;
        insert cs;
        
        string mockResp='false';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
         Test.startTest();
        PayAtBusReleaseSeatCntrl.GetPayAtBusTrans(ol[0].id);   
        Test.stopTest();
    }
    
 }