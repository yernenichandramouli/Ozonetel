/**
 * (c) 2017 RedBus
 *
 * Name           : TravellerInfoCntrlTest
 * Created Date   : 24 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for TravellerInfoCntrl
 *
 **/
 
@isTest
public class TravellerInfoCntrlTest {    
    
    static testMethod void testCallout(){
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        Apexpages.currentpage().getparameters().put('tin','TKAB33611108');
         Apexpages.currentpage().getparameters().put('Bu','REDBUS_IN');
        
         OrderItemTransactionResource__c orTrans = new OrderItemTransactionResource__c();
         orTrans.Name = 'REDBUS_IN';
         orTrans.Auth_Key__c = 'IND';
         orTrans.Default_Currency__c= 'INR';
         insert orTrans;
         
        Order_Items__c oi = new Order_Items__c();
        oi.Order_Item_Reference_No__c = 'TKAB33611108';
        oi.Business_Unit__c=orTrans.Case_Business_Type__c;
        insert oi;
         
        TravellerInfoCntrl cntrl=new TravellerInfoCntrl();
        TravellerInfoCntrl.TravellerWarpper wrps = new TravellerInfoCntrl.TravellerWarpper();
        TravellerInfoCntrl.getPassangerDetails();
        
    }
}