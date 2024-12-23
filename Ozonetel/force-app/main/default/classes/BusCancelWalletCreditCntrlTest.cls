@isTest
public class BusCancelWalletCreditCntrlTest
{
    
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID'));
        } 
        insert orderList;
        Case cs = new Case();
        cs.Status = 'Open';
        cs.Issue_Type__c ='DBT';
        cs.Transaction_ID__c=orderList[0].id;
        cs.tin_no__c=orderList[0].Order_Item_Reference_No__c;
        cs.Trip_Id_ct__c='123';
        insert cs;
    }
    
    static testMethod void WalletCreditTest(){
        
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.email__c='test@t.com';
        o.Mobile__c='9491322718';
        o.Rb_User_ID__c='12345';
        o.Business_Unit__c='REDBUS_IN';
        o.Order_Item_Reference_No__c='TN67890';
        o.Transaction_Status__c='Ticket 2';
        o.Date_Of_Service__c=System.now();
        o.Route_Id__c='1234';
        insert o;
        Case cs = new Case();
        cs.Status = 'Approved For Bus Cancellation';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Transaction_ID__c=o.id;
        cs.tin_no__c=o.Order_Item_Reference_No__c;
        insert cs;
        
        //  System.currentPageReference().getParameters().put('csId', cs.id);
        System.currentPageReference().getParameters().put('id', cs.id);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.startTest();
        BusCancelWalletCreditCntrl  bobj = new BusCancelWalletCreditCntrl (new ApexPages.StandardController(cs));
        bobj.refundintoWallet();
        
        Test.stopTest();
    }
    static testMethod void TestChatEnable(){
        
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.email__c='test@t.com';
        o.Mobile__c='9491322718';
        o.Rb_User_ID__c='12345';
        o.Business_Unit__c='REDBUS_IN';
        o.Order_Item_Reference_No__c='TN67890';
        o.Transaction_Status__c='Ticket 2';
        o.Date_Of_Service__c=System.now();
        o.Route_Id__c='1234';
        insert o;
        Case cs = new Case();
        cs.Status = 'Open';
        cs.Issue_Type__c ='Quota Management';
        cs.Transaction_ID__c=o.id;
        cs.tin_no__c=o.Order_Item_Reference_No__c;
        cs.BO_Mobile_Number__c='989878987,323243232';
        insert cs;
        
        //  System.currentPageReference().getParameters().put('csId', cs.id);
        System.currentPageReference().getParameters().put('id', cs.id);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.startTest();
        BusCancelWalletCreditCntrl  bobj = new BusCancelWalletCreditCntrl (new ApexPages.StandardController(cs));
        bobj.UserSelectVal='989878987';
        bobj.chatEnable();
        bobj.ChatProcess();
        
        Test.stopTest();
    }
    /*
Name:TestDBT_Success
Description: Testing DBT conclude call functionality
*/
    public static testMethod void TestDBT_Success()
    {
        
        List<Order_Items__c> oList=[select id from order_items__c limit 1];
        case cObj=[select id from case limit 1];
        cObj.Issue_Type__c='DBT';
        cObj.Trip_Id_ct__c='12345';
        update cObj;
        Test.startTest();
        System.currentPageReference().getParameters().put('id', cObj.id);
        BusCancelWalletCreditCntrl  dct = new BusCancelWalletCreditCntrl (new ApexPages.StandardController(cObj));
        String jsonBody='{"isTicketGenrated":false,"isGFT":false,"concludeResponse":"","IsvoucherExpired":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        dct.submit();
        Test.stopTest();
        
    }
    public static testMethod void TestGFT_Success()
    {
        Test.startTest();
        List<Order_Items__c> oList=[select id from order_items__c limit 1];
        case cObj=[select id from case limit 1];
        System.currentPageReference().getParameters().put('id', cObj.id);
        BusCancelWalletCreditCntrl  dct = new BusCancelWalletCreditCntrl (new ApexPages.StandardController(cObj));
        String jsonBody='{"isTicketGenrated":false,"isGFT":true,"concludeResponse":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        dct.submit();
        Test.stopTest();
        
    }
    public static testMethod void TestTicketGenerated_Success()
    {
        Test.startTest();
        List<Order_Items__c> oList=[select id from order_items__c limit 1];
        case cObj=[select id from case limit 1];
        System.currentPageReference().getParameters().put('id', cObj.id);
        BusCancelWalletCreditCntrl  dct = new BusCancelWalletCreditCntrl (new ApexPages.StandardController(cObj));
        String jsonBody='{"isTicketGenrated":true,"isGFT":false,"concludeResponse":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        dct.submit();
        Test.stopTest();
        
    }
}