@isTest
public class InitiateRefundCtrlTest
{
    static TestMethod void methodTest()
    {
        list<Activities__c> aclist = new list<Activities__c>();
        Id CargorecTypeId = Schema.SObjectType.Activities__c.getRecordTypeInfosByName().get('Cargo').getRecordTypeId(); 
        Activities__c ac= new Activities__c();
        ac.Voucher_Id__c ='123456';
        ac.Booking_User_Email__c = 'test@gmail.com';
        ac.Booking_User_Mobile__c ='123456789';
        ac.Business_Unit__c='REDBUS_PE';
        ac.recordTypeId = CargorecTypeId; 

        aclist.add(ac);
        insert aclist;
        HttpRequest req = new HttpRequest();

        HttpRequestUtil.populateCMAPIHeaders(req,aclist[0].Business_Unit__c);
        
        test.startTest(); 
        string json = '{"InitiatedTime":"2023-08-10T16:05:58.429","CartId":13533227796638489,"CustRefundId":0,"IsSuccess":true,"refundAmount":101900.0,"ResponseMessage":"REFUND_CREATED"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        string trackngDetls=CargoservicesCntrl.UpdateTrackingDetails(aclist[0].id,'tracStageType','tracStage','tracStageStatus','tracReason','tracDelStatus','tracStageDate','tracAgentName','tracPhoneNo','tracComments');
     
        Test.stopTest();
    
        InitiateRefundCtrl.initiateRefundMethod(aclist[0].id);
        
        
        }
        
   static TestMethod void failMethodTest()
    {
        list<Activities__c> aclist = new list<Activities__c>();
        Id CargorecTypeId = Schema.SObjectType.Activities__c.getRecordTypeInfosByName().get('Cargo').getRecordTypeId(); 
        Activities__c ac= new Activities__c();
        ac.Voucher_Id__c ='123456';
        ac.Booking_User_Email__c = 'test@gmail.com';
        ac.Booking_User_Mobile__c ='123456789';
        ac.Business_Unit__c='REDBUS_PE';
        ac.recordTypeId = CargorecTypeId; 

        aclist.add(ac);
        insert aclist;
        HttpRequest req = new HttpRequest();

        HttpRequestUtil.populateCMAPIHeaders(req,aclist[0].Business_Unit__c);
        
        test.startTest(); 
        string json = '{"InitiatedTime":"2023-08-10T16:05:58.429","CartId":13533227796638489,"CustRefundId":0,"IsSuccess":false,"refundAmount":101900.0,"ResponseMessage":"REFUND_CREATED"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        string trackngDetls=CargoservicesCntrl.UpdateTrackingDetails(aclist[0].id,'tracStageType','tracStage','tracStageStatus','tracReason','tracDelStatus','tracStageDate','tracAgentName','tracPhoneNo','tracComments');
     
        Test.stopTest();
    
        InitiateRefundCtrl.initiateRefundMethod(aclist[0].id);
        
        
        }
        
}