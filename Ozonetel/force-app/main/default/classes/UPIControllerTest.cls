@isTest
public class UPIControllerTest
{
    static testMethod void UPITest(){
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.startTest();
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Guid__c='34512345';
        ordtm.Payment_Details__c='{ "uuid": "1ea568b56f0ef005e2483f9f02010100", "id": "12235850543482282", "paymentItemList": [{ "uuid": "20dcc3bc6f0ef0055722993402030100", "id": "12235850840940002" },{ "uuid": "20df44346f0ef005e2483f9f01030100", "id": "12235850842251681" } ] }';
        insert ordtm;
         ApexPages.currentPage().getParameters().put('id', ordtm.id);
          UPIController  upincntr = new UPIController ();
        upincntr.tId='test';
        upincntr.refStResp='success';
        upincntr.pgOrderId='20dcc3bc6f0ef0055722993402030100';
        upincntr.trexOrderItmId='34512345';
        upincntr.enableRefund=false;
        upincntr.disInputs=true;
        upincntr.vpa='test@t.com';
        upincntr.refAmount='12';
        upincntr.pgTransactionId='1234';
        
        upincntr.RefundStatusCheck();
        upincntr.RefundInitiate();
        upincntr.RefundStatusCheckProcess();
        upincntr.RefundInitiateProcess();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        String jsonBody='{"status":true,"message":"Balance Amount is 5000"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        //upincntr.RefundStatusCheckProcess();
        Test.stopTest();
    }
}