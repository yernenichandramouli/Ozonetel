/**
* (c) 2017 RedBus
*
* Name           : NEFTCustAccntDetailPopup_Test
* Created Date   : 04 Mar 2017
* Created By     : Sreenivas M
* Purpose        : Test class for NEFTCustAccntDetailPopup class
*
**/

@isTest
public class NEFTCustAccntDetailPopup_Test
{
    
    Static TestMethod void method()
    {
        
        ApexPages.currentPage().getParameters().put('busCancelBit','true');
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
        list<Order_Items__c> lstorder = new list<Order_Items__c>();
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Order_Item_Reference_No__c='234234';
        orItem.status__c = 'Initiated';
        orItem.Date_Of_Service__c = Datetime.now();
        orItem.Route_Id__c = '12311';
        orItem.Guid__c='125341';
        lstorder.add(orItem);
        insert lstorder;
        ApexPages.currentPage().getParameters().put('orItId',lstorder[0].id);
        
        ApexPages.CurrentPage().getParameters().put('recId',lstorder[0].Id);
        Account accnt= new Account();
        accnt.Review__c = 'test';
        accnt.Amount__c  = 10;
        accnt.lastName= 'test';
        accnt.firstName = 'NEFT';
        accnt.PersonMobilePhone = '12123123';
        accnt.PersonEmail = 'test@gmail.com';
        accnt.User_Id__c = '123';
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accnt.RecordTypeId = recordTypeId;
        insert accnt;
        
        ApexPages.CurrentPage().getParameters().put('id',accnt.Id);
        NEFTCustAccntDetailPopup.Status resStatus = new NEFTCustAccntDetailPopup.Status ();
        resStatus.code ='test';
        resStatus.statusMessage ='confirm';
        resStatus.error='fail';
        resStatus.type='text';
        NEFTCustAccntDetailPopup detail = new NEFTCustAccntDetailPopup();
        detail.BusCancelSubmit();
        detail.getItems();
        detail.setcaseOrigin('INDIA');
        detail.getcaseOrigin();
        detail.AgentName='test';
        detail.accntId='';
        detail.showTicketConfirm=true;
        detail.arnNumber='123';
        detail.refundedDate=date.parse('7/6/2018');
        detail.updateARNNumber();
      List<Payment_Items__c> listPayitems = new List<Payment_Items__c>();
        Payment_Items__c pi = new Payment_Items__c();
        pi.Guid__c='125341';
        pi.Payment_Status__c='COMPLETED';
        pi.Latest_Payment_Status__c='SUCCESS';
        pi.Payment_System__c='OnlinePGTxn';
        pi.Order_Item_Name__c=lstorder[0].id;
        insert pi;
              
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());   
        // Set mock callout class       
        test.startTest();  
        detail.updateRefundStatus();
     detail.markPaymentCompelted();
        
        NEFTCustAccntDetailPopup details = new NEFTCustAccntDetailPopup();
        details.NEFTSubmit();
        test.stopTest();
    }
    
    /* Static TestMethod void cnfrmGft()
{
Order_Items__c orItem = new Order_Items__c();
orItem.name = '23456';
orItem.id__c = '23456';
orItem.Order_Id__c = '123456';
orItem.Email_Copy__c = 'test@redbus.com    ';
orItem.Mobile__c = '1234567891';
orItem.Business_Unit__c = 'REDBUS_IN';
orItem.Transaction_Source__c = 'MOBILEAPP';
orItem.Item_Type__c = 'BUS';
orItem.Email_Copy__c = 'Test@gmail.com';
orItem.Mobile__c = '124521234';
orItem.Order_Item_Reference_No__c='234234';
orItem.status__c = 'Initiated';
orItem.Date_Of_Service__c = Datetime.now();
orItem.Route_Id__c = '12311';
orItem .Guid__c='125341';
insert orItem;

list<OrderItemTransactionResource__c>  lstOrdrtrs= new list<OrderItemTransactionResource__c>();
OrderItemTransactionResource__c orItmtr = new OrderItemTransactionResource__c ();
orItmtr .Name = 'REDBUS_IN';
orItmtr .Auth_Key__c = 'IND';
orItmtr .Channel_Name__c = '';
orItmtr . Default_Currency__c = 'INR';
orItmtr .UTC_time_difference_in_min__c = 0;
insert orItmtr ;
ApexPages.currentPage().getParameters().put('orItId',orItem.id);

test.startTest(); 
Test.setMock(HttpCalloutMock.class, new MockResponseCallout());    
NEFTCustAccntDetailPopup details = new NEFTCustAccntDetailPopup();
details.pnrvalue='132456786';
details.seatno='11a';
details.confirmGFT();
test.stopTest();
}*/
    Static TestMethod void msgCodecover()
    {
        test.startTest();  
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());   
        NEFTCustAccntDetailPopup details= new NEFTCustAccntDetailPopup();
        details.mobileNo='123455677';
        details.callToBo();
        details.showRefundStatus=false;
        details.showCallPopup=false;
        details.pnrvalue='123344';
        details.seatno='22';
        details.refundRefNum='12334345';
        details.refStatus='open';
        details.showTicketConfirm =false;
        test.stopTest();
    } 
    static TestMethod void VaildBPnumber()
    {
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem .Agent_IP__c='125341';
        orItem.Order_Item_Reference_No__c='234234';
        orItem.Service_Provider_Id__c='12345';
        orItem.Service_Provider_Name__c='testt';
        orItem.Boarding_Point__c='tesxt'; 
        insert orItem;
        
        Bus_Order_Item_Details__c buss = new Bus_Order_Item_Details__c();
        buss.Boarding_Point_ID__c ='1234567';
        buss.Order_Item_Name__c=orItem.id;
        insert buss;
        
        test.startTest(); 
        ApexPages.currentPage().getParameters().put('orItId',orItem.id);
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());   
        NEFTCustAccntDetailPopup bPNubr = new NEFTCustAccntDetailPopup();
        bPNubr.getCallOptions();
        bPNubr.wrongBPnumber();
        bPNubr.BPnumberr=true;
        bPNubr.sendSMS=true;
        test.stopTest();
    }
    
    public static TestMethod void sendSMSTest()
    {
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem .Guid__c='125341';
        orItem.Order_Item_Reference_No__c='234234';
        insert orItem;
        test.startTest();
        ApexPages.currentPage().getParameters().put('orItId',orItem.id);
        NEFTCustAccntDetailPopup neft = new NEFTCustAccntDetailPopup();
        neft.mobileno='99898989876';
        neft.description='Test';
        string json='{"type":["pushdata"], "pushdata": { "EmailId" :["test"], "dataparams": { "message": "Your ticket has been booked successfully", "sid": "0"} } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        neft.sendSMS();
        json='';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        neft.sendSMS();
//        List<String> listPayType = new List<String>();
//        listPayType = System.Label.PaymentItemType.split(',');
//        neft.updateRefundStatus();
        test.stopTest();
        
    }
    
    public static testMethod void TestB2BBusCancellation()
    {
        Test.startTest();
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem .Agent_IP__c='125341';
        orItem.Order_Item_Reference_No__c='234234';
        orItem.Service_Provider_Id__c='12345';
        orItem.Service_Provider_Name__c='testt';
        orItem.Boarding_Point__c='tesxt'; 
        insert orItem;
        ApexPages.currentPage().getParameters().put('recId', orItem.id);
        NEFTCustAccntDetailPopup np=new NEFTCustAccntDetailPopup();
        Continuation conti = (Continuation)np.B2BBusCancellationInitiation();
        HttpResponse response = new HttpResponse();
        string mockResp='{ "message":null, "processedBySfa":false, "status":"Initiated", "tin":"843FNR9N" }';
        response.setBody(mockResp);
        Test.setContinuationResponse(np.busCReq, response);
        Object result = Test.invokeContinuationMethod(np, conti);
        Test.stopTest();
    }    
    public static testMethod void BusCancellationFail()
    {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('recId', '1234');
       
        NEFTCustAccntDetailPopup np=new NEFTCustAccntDetailPopup();
      //  np.BusCancelSubmit();
        Test.stopTest();
    }
     Static TestMethod void methodC()
    {
        
        ApexPages.currentPage().getParameters().put('busCancelBit','true');
        ApexPages.currentPage().getParameters().put('CmpltPaymnt','true');
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
        list<Order_Items__c> lstorder = new list<Order_Items__c>();
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'BUS';
        orItem.Email_Copy__c = 'Test@gmail.com';
        orItem.Mobile__c = '124521234';
        orItem.Order_Item_Reference_No__c='234234';
        orItem.status__c = 'Initiated';
        orItem.Date_Of_Service__c = Datetime.now();
        orItem.Route_Id__c = '12311';
        orItem.Guid__c='125341';
        lstorder.add(orItem);
        insert lstorder;
        ApexPages.currentPage().getParameters().put('orItId',lstorder[0].id);
        
        ApexPages.CurrentPage().getParameters().put('recId',lstorder[0].Id);
        Account accnt= new Account();
        accnt.Review__c = 'test';
        accnt.Amount__c  = 10;
        accnt.lastName= 'test';
        accnt.firstName = 'NEFT';
        accnt.PersonMobilePhone = '12123123';
        accnt.PersonEmail = 'test@gmail.com';
        accnt.User_Id__c = '123';
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accnt.RecordTypeId = recordTypeId;
        insert accnt;
        
        ApexPages.CurrentPage().getParameters().put('id',accnt.Id);
        NEFTCustAccntDetailPopup.Status resStatus = new NEFTCustAccntDetailPopup.Status ();
        resStatus.code ='test';
        resStatus.statusMessage ='confirm';
        resStatus.error='fail';
        resStatus.type='text';
        NEFTCustAccntDetailPopup detail = new NEFTCustAccntDetailPopup();
        detail.BusCancelSubmit();
        detail.getItems();
        detail.setcaseOrigin('INDIA');
        detail.getcaseOrigin();
        detail.AgentName='test';
        detail.accntId='';
        detail.showTicketConfirm=true;
        detail.arnNumber='123';
        detail.refundedDate=date.parse('7/6/2018');
        detail.updateARNNumber();
      List<Payment_Items__c> listPayitems = new List<Payment_Items__c>();
        Payment_Items__c pi = new Payment_Items__c();
        pi.Guid__c='125341';
        pi.Payment_Status__c='INITIATED';
        pi.Latest_Payment_Status__c='Failed';
        pi.Payment_System__c = 'ONLINE';
        pi.Order_Item_Name__c=lstorder[0].id;
        insert pi;
              
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());   
        // Set mock callout class       
        test.startTest();  
        detail.CmpltPaymnt=true;
     detail.markPaymentCompelted();
        
        NEFTCustAccntDetailPopup details = new NEFTCustAccntDetailPopup();
        details.NEFTSubmit();
        test.stopTest();
    }
 }