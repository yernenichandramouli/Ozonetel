/**
* Name           : WalletcreditControllerTest
* Created Date   : 20 June 2017
* Created By     : Veeramanikanta
* Purpose        : Test class for WalletCreditController
*
**/

@isTest
public class WalletcreditControllerTest {
    
    @testsetup
    static void createOrder(){
        List<Account> accList = new List<Account>();
        ID RedTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();        
        for(Integer i = 0 ; i<2 ; i++) {
            accList.add(new Account(name = 'testLName'+i , RecordTypeId=RedTypeId, email__c='mani.renus@gmail.com'));
        } 
        insert accList ;
        
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Business_Unit__c='REDBUS_IN',Mobile__c='09491322718'));
        } 
        insert orderList ;
        
    }
    
    public static testMethod void walletCreditSuccessTest()
    {
        Test.startTest();
        Account acc=[select id from Account limit 1];
        Order_Items__c oi=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c limit 1];
        wallet_credit__c wc=new wallet_credit__c();
        wc.Name='INR';
        wc.Amount__c=500;
        insert wc;
        case c=new case();
        c.Issue_Type__c='Bus Cancellation';
        c.status='Initiated';
        c.Transaction_ID__c=oi.id;
        insert c;
        
        System.currentPageReference().getParameters().put('id', oi.id);
        
        WalletCreditController w=new WalletCreditController(); 
        w.selParentCase = c.Id;
        w.submit();
        
        string json='[{"tin":"TJCN774445","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233},{"tin":"TJCN4444446","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233},{"tin":"TIN6473553","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233}]';
        WalletCreditController wc1=new WalletCreditController();
        wc1.getWalletStatus(json);
        
        Test.stopTest();
        
    }
    public static testmethod void mandatoryFieldsTest(){
        
        Test.startTest();       
        Account acc=[select id from Account limit 1];
        Order_Items__c oi=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c limit 1];
        
        System.currentPageReference().getParameters().put('id', oi.id);
        
        wallet_credit__c wc=new wallet_credit__c();
        wc.Name='INR';
        wc.Amount__c=500;
        insert wc;
        WalletCreditController w=new WalletCreditController();
        List<SelectOption> selOpts=w.currencyCodes;
        List<SelectOption> selOpts2=w.subCategory;
        List<SelectOption> selOpts3=w.refundOptions;
        w.amount=1200;
        w.email='';
        w.description='Test';
        w.mobile='9491322718';
        w.submit();
        Test.stopTest();
        
    }
    
    public static testMethod void amountLimitTest()
    {
        Test.startTest();
        Account acc=[select id from Account limit 1];
        Order_Items__c oi=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c limit 1];
        
        System.currentPageReference().getParameters().put('id', oi.id);
        
        wallet_credit__c wc=new wallet_credit__c();
        wc.Name='INR';
        wc.Amount__c=500;
        insert wc;
        WalletCreditController w=new WalletCreditController();
        w.amount=505;
        w.submit();
        
        Test.stopTest();
        
    }
    
    public static testMethod void caseInsertionFailedTest()
    {
        Test.startTest();
        Account acc=[select id from Account limit 1];
        Order_Items__c oi=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c limit 1];
        case c = new case();
        c.Issue_Type__c='Bus Cancellation';
        c.status='Initiated';
        c.Transaction_ID__c=oi.id;
        insert c;
        
        System.currentPageReference().getParameters().put('id', oi.id);
        
        wallet_credit__c wc=new wallet_credit__c();
        wc.Name='INR';
        wc.Amount__c=500;
        insert wc;
        WalletCreditController w=new WalletCreditController();
        w.email='test@t@t.com';
        w.selParentCase = c.Id;
        w.submit();
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        Test.stopTest();
        
    }
    
     public static testMethod void caseInsertionFailedTest2()
    {
        Test.startTest();
        Account acc=[select id from Account limit 1];
        Order_Items__c oi=[select id,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c limit 1];
        case c=new case();
        c.Issue_Type__c='Bus Cancellation';
        c.status='Initiated';
        c.Transaction_ID__c=oi.id;
        insert c;
        System.currentPageReference().getParameters().put('id', oi.id);
        
        wallet_credit__c wc=new wallet_credit__c();
        wc.Name='INR';
        wc.Amount__c=500;
        insert wc;
        WalletCreditController w=new WalletCreditController();
        w.selParentCase = c.Id;
        w.email='test@t@t.com';
       
        
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));        
       w.submit();
        Test.stopTest();
        
    }
    
}