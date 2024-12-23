@isTest
public class TicketDetailsControllerTest{
    
    public static testMethod void fetchTicketDetailsTest(){
        Order_Items__c ot=new Order_Items__c ();
        ot.Order_Item_Reference_No__c='TP2V93248582';
        ot.Business_Unit__c='REDBUS_IN';
        insert ot;
        OrderItemTransactionResource__c ott=new OrderItemTransactionResource__c();
        ott.name='REDBUS_IN';
        ott.Auth_Key__c='2334';
        ott.Default_Currency__c='INR';
        insert ott;
        Test.startTest();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        TicketDetailsController.GetTicketDetails(ot.id,'');
        Test.stopTest();
    }
    
    public static testMethod void fetchTicketDetailsFailedComTest(){
        Order_Items__c ot=new Order_Items__c ();
        ot.Order_Item_Reference_No__c='TP2V93248582';
        ot.Business_Unit__c='REDBUS_COM';
        ot.Amount_Recieved_Currency__c='INR';
        insert ot;
        OrderItemTransactionResource__c ott=new OrderItemTransactionResource__c();
        ott.name='REDBUS_IN';
        ott.Auth_Key__c='2334';
        ott.Default_Currency__c='INR';
        insert ott;
        Test.startTest();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'OK', json));
        TicketDetailsController.GetTicketDetails(ot.id,'');
        Test.stopTest();
    } 
    
     public static testMethod void CoPassengerDetailsTest(){
        Order_Items__c ot=new Order_Items__c ();
        ot.Order_Item_Reference_No__c='TP2V93248582';
        ot.Business_Unit__c='REDBUS_IN';
        ot.Boarding_Time__c=System.now();
        ot.Dropping_Time__c=System.now();
        insert ot;
        OrderItemTransactionResource__c ott=new OrderItemTransactionResource__c();
        ott.name='REDBUS_IN';
        ott.Auth_Key__c='2334';
        ott.Default_Currency__c='INR';
        insert ott;
        Country_Codes__c cc=new Country_Codes__c();
        cc.name='REDBUS_IN';
        cc.ou__c='1';
        insert cc;
        Test.startTest();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        TicketDetailsController.GetCoPassengerDetails(ot.id,'');
        Test.stopTest();
    }
}