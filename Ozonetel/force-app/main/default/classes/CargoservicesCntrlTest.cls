@isTest
public class CargoservicesCntrlTest {
    
    static testMethod void cargTest(){
           
       
        test.startTest(); 
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
        
        list<Activities__c> acL=CargoservicesCntrl.getActivites(aclist[0].Voucher_Id__c,aclist[0].Booking_User_Email__c,aclist[0].Booking_User_Mobile__c);
        string itm =CargoservicesCntrl.GetActivityDetails(aclist[0].id);    
        Test.stopTest();
    
    }
     static testMethod void cargTrackingTest(){
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
        
        test.startTest(); 
        string json = '{"status":"SUCCESS","errors":[],"data":{"updateType":"ammend","extraDetails":{"trackingInfo":[{"status":"SUCCESS","stageHeader":"Booking Successful","stage":"First mail Scheduled","reason":"Package picked successfully on DAY by AGENT","extraInfo":{"agentNumber":"1234567890","agentName":"SF testAgent"},"comments":"test comment SF"}]}}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        string trackngDetls=CargoservicesCntrl.UpdateTrackingDetails(aclist[0].id,'tracStageType','tracStage','tracStageStatus','tracReason','tracDelStatus','tracStageDate','tracAgentName','tracPhoneNo','tracComments');
     
        Test.stopTest();
    
    }
    
     static testMethod void cargMaxRefundTest(){
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
        
        test.startTest(); 
        string json ='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"GENERIC_ITEM":[{"CARGO":{"itemUuid":"4fcd0ead0abaf00679229b5e02020600","amount":998.0}},{"FIRST_MILE":{"itemUuid":"50ffbfd50abaf00679229b5e01020600","amount":10.0}}]},"currencyType":"PEN"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        list<object> maxrefund=CargoservicesCntrl.maxrefundApi(aclist[0].id);
     
        Test.stopTest();
    
    }
    
     static testMethod void cargCancelTest(){
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
        
        test.startTest(); 
        string selReqJson='[{"key":"CARGO","amount":365,"itemUuid":"689e356e0255f0067bf1fe8601020600","selRfndAmnt":8,"isSelected":true}]';
        string json ='{"status":"SUCCESS","errors":[],"data":[{"status":"CANCELLATION_COMPLETED","serviceProviderId":"15108","selectedPaymentCurrency":"PEN","refundAmount":28.0,"pnr":"","orderItemUuid":"689e356e0255f0067bf1fe8601020600","orderItemRefNumber":"S9431452","orderItemId":13531325687507825,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","newOrderItemUuid":null,"cnr":"","clientIp":"","cancellationCharges":0.0,"backToSource":true}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        string cancl=CargoservicesCntrl.CancellationCargoAPI(aclist[0].id,selReqJson,'cancelReason');
     
        Test.stopTest();
    
    }
}