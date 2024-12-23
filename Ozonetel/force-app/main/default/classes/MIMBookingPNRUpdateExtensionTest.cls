/**
* (c) 2018 RedBus
*
* Name           : WalletHistoryCntrlTest
* Created Date   : 16 Apr 2018
* Created By     : Praveen
* Purpose        : Test class for MIMBookingPNRUpdateExtension class
*
**/

@isTest
private class MIMBookingPNRUpdateExtensionTest
{
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID', isMIM_Booking__c=true,Seat_No__c='NA,NA,NA', isMIM_PNR_Updated__c=false, Service_Provider_Reference_PNR_No__c='NOT CONFIRMED'));
        } 
        insert orderList ;     
        OrderItemTransactionResource__c oit_tr= new OrderItemTransactionResource__c ();
        oit_tr.name='REDBUS_ID';
        oit_tr.Auth_Key__c='12424rter';
        
        // oit_tr.Service_Provider_Reference_No__c='1212';
        insert oit_tr;
    }
    
    @isTest static void MIMBookingPNRUpdate() 
    {
        Order_Items__c o=[select id,Service_Provider_Reference_No__c from Order_Items__c limit 1];
        
        ApexPages.StandardController sc= new ApexPages.StandardController(o);
        MIMBookingPNRUpdateExtension obj = new MIMBookingPNRUpdateExtension(sc);
        obj.showSeatWisePNR=true;
        MIMBookingPNRUpdateExtension.MIMSeatWrapper mm=new MIMBookingPNRUpdateExtension.MIMSeatWrapper();
        mm.seatNo='12';
        mm.seatPnr='12321';
        obj.busLevelSeats='1,2';
        obj.busLevelPnr='1232244';
        obj.isNotificationAllowed=true;
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.Operator_Id__c='123456';
        insert sp;
        o.Service_Provider_Reference_No__c=sp.id;
        update o;
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        string json='{"IsSuccess":true,"isNotificationAllowed":true,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        //MIMBookingPNRUpdateExtension ext= new MIMBookingPNRUpdateExtension();
        obj.mimPnrUpdation();
        Test.stopTest();
        
    }
}