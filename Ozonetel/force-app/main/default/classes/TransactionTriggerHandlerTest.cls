@isTest
public class TransactionTriggerHandlerTest {
    
    
     /*
Name:createOrder
Description: Creates Order Item data (Other methods can utilize) 
*/
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
    }
    public static testMethod void bpNumberCheckTest()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        ol[0].Wrong_BP_Number__c=true;
        update ol; 
        Bus_Order_Item_Details__c b=new Bus_Order_Item_Details__c();
        b.Boarding_Point__c='1234';
       // b.Boarding_Point_ID__c='9876';
        b.Order_Item_Name__c=ol[0].id;
        insert b;
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));

        Test.stopTest();
        
    }
    
      public static testMethod void busCancCloseTest()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        ol[0].Wrong_BP_Number__c=true;
      
        ol[0].Business_Unit__c='REDBUS_IN';
        ol[0].Order_Id__c='12344';       
        update ol; 
        case c=new case();
        c.status='Initiated';
        c.Issue_Type__c='Bus Cancellation';
        c.Transaction_ID__c=ol[0].id;
        c.Trip_Id_ct__c=ol[0].Order_Id__c;
        
        insert c;
system.debug('c->'+c.Trip_Id_ct__c);
          ol[0].Transaction_Status__c='Ticket Cancelled';
         update ol; 
        Test.stopTest();
        
    }
    
     public static testMethod void QuotaTest()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c];
        Order_Items__c ot=new Order_Items__c();
        ot.name='Test';
         ot.Transaction_Status__c='Booked';
        ot.Business_Unit__c='REDBUS_ID';
        ot.Order_Item_Reference_No__c='TN12345';
        ot.Service_Provider_Id__c='16418';

       insert ot;
      
        Test.stopTest();
        
    }
    
    public static testMethod void AllTest()
    {
       Service_Provider__c sp=new Service_Provider__c();
       sp.BO_Number__c='45678';
       sp.BO_Number2__c='67890'; 
       sp.Operator_Id__c='16418';
       insert sp;
       
        Cancelled_Order_Items__c cl=new Cancelled_Order_Items__c();
        cl.Cancellation_Reason__c='BUS_CANCELLED';
        cl.Business_Unit__c='REDBUS_IN';
        cl.Order_ID__c='3456789';
        insert cl;
        
        cl.Cancellation_Reason__c='SFA_Bus_Cancellation';
        update cl;
        
        case cs=new case();
        cs.Status ='Initiated';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Issue_Sub_Category__c='Initiate Bus Cancellation';
        cs.Trip_Id_ct__c= '3456789';
        insert cs;
        
        Transaction_Status_Category__c t=new Transaction_Status_Category__c ();
        t.Name='Confirmed';
        t.Status__c='Confirmed';
        t.Category__c='Confirmed';
        insert t;
        
        Order_Items__c ot=new Order_Items__c();
        ot.name='Test';
        ot.Transaction_Status__c='Booked';
        ot.Business_Unit__c='REDBUS_ID';
        ot.Order_Item_Reference_No__c='TN12345';
        ot.Service_Provider_Id__c='16418';
        ot.status__c='Confirmed';
        ot.Service_Provider_Info__c=sp.id;
        ot.BO_Number__c='1234567';
        
        insert ot;
       case c=new case();
        c.status='Open';
        
        c.Transaction_ID__c=ot.id;
        c.Trip_Id_ct__c=ot.Order_Id__c;
        c.RecordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        
        insert c;
        ot.Transaction_Latest_status__c='SUCCESS';
        ot.BO_Number__c='5678901234567';
        update ot;
        //TransactionTriggerHandler.BPNumberRequestWrapper bp= new TransactionTriggerHandler.BPNumberRequestWrapper('test','1234','open','test','123','open');
    }


    public static testMethod void processCaseRelinkingTest()
    {
        ID B2BRecTypeId= Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
        case cs=new case();
        cs.Status ='Initiated';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Issue_Sub_Category__c='Initiate Bus Cancellation';
        cs.Trip_Id_ct__c= '3456789';
        
        

        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c,Inventory_Type__c,Cancellation_Reason__c,Order_Item_Reference_No__c, Transaction_Status__c from Order_Items__c];
        cs.Transaction_ID__c=ol[0].id;
        insert cs;
        ol[0].Wrong_BP_Number__c=true;
        ol[0].Business_Unit__c='REDBUS_IN';
        ol[0].Order_Id__c='12344';   
        ol[0].Inventory_Type__c='MMT';
        ol[0].Cancellation_Reason__c='Bus cacnellation';
        ol[0].Transaction_Status__c='Cancelled';
        ol[0].Order_Item_Reference_No__c='TXTSDVD';
        update ol; 

        

        set<string> caseId = new set<string>();
        caseId.add(cs.id);
        TransactionTriggerHandler.closeBusCanCases(caseId);
    }
    
    public static testMethod void ZQPTest() {
        case c=new case();
        c.status='Open';
        c.Booking_Mobile_No__c='1234567890';
        c.Order_UUId__c='1test2';
        c.Refund_Amount__c=10;
        c.Total_Fare_Value__c=30;
        c.Issue_Sub_Category__c='ZQP';
        c.Issue_Type__c='Booking Error';
        insert c;
        
        Order_Items__c ot=new Order_Items__c();
        ot.name='Test';
        ot.Transaction_Status__c='Booked';
        ot.Business_Unit__c='REDBUS_ID';
        ot.Order_Item_Reference_No__c='TN12345';
        ot.Service_Provider_Id__c='16418';
        ot.status__c='Confirmed';
        ot.BO_Number__c='1234567';
        ot.Mobile__c='1234567890';
        insert ot;
    }
    
    public static testMethod void ZQPTestAfterUpdate() {
        case c=new case();
        c.status='Open';
        c.Booking_Mobile_No__c='1234567890';
        c.Order_UUId__c='1test2';
        c.Refund_Amount__c=10;
        c.Total_Fare_Value__c=30;
        c.Issue_Sub_Category__c='ZQP';
        c.Issue_Type__c='Booking Error';
        insert c;
        
        Order_Items__c ot=new Order_Items__c();
        ot.name='Test';
        ot.Transaction_Status__c='WFT';
        ot.Business_Unit__c='REDBUS_ID';
        ot.Order_Item_Reference_No__c='TN12345';
        ot.Service_Provider_Id__c='16418';
        ot.status__c='TR_CONFIRMED_PO';
        ot.BO_Number__c='1234567';
        ot.Mobile__c='1234567890';
        insert ot;
        
        ot.status__c='TR_CONFIRMED_PO_COMPLETED';
        update ot;
    }

    public static testMethod void giMMTcloseBusCanCasesTest() {
        Order_Items__c ot=new Order_Items__c();
        ot.name='Test';
        ot.Transaction_Status__c='Booked';
        ot.Business_Unit__c='REDBUS_ID';
        ot.Order_Item_Reference_No__c='TN12345';
        ot.Service_Provider_Id__c='16418';
        ot.status__c='Confirmed';
        ot.BO_Number__c='1234567';
        ot.Mobile__c='1234567890';
        insert ot;
        
        case c = new case();
        c.Status='Initiated';
        c.Transaction_ID__c =ot.Id;
        c.Refund_status__c='Initiated';
        c.redCare_Status__c='Initiated';
        c.Approved_By__c='TestApproval';
        c.Closed_By__c='Not Salesforce System';
        c.Issue_Type__c='Bus Cancellation';
        insert c;
        
        Set<string> tid = new Set<string>();
        tid.add(ot.Id);
        
        TransactionTriggerHandler.giMMTcloseBusCanCases(tid);
    }
}