@isTest
public class RechargeGFTBatchTest
{
    Static testMethod void TestRechargeGFT()
    {
        PostGres_Data__c p=new PostGres_Data__c();
        p.Order_Status__c='GFT(Payment collected and recharge not successful)';
        p.Order_Id__c='123456';
        insert p;
        Test.startTest();
        String json='{"Code":"11.22","Message":"Refund is alreday processed for the provided order id.","DetailedMessage":"Refund is alreday processed for the provided order id.","HttpStatusCode":200}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        RechargeGFTBatch recgft= new RechargeGFTBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RechargeSync', cronExp,recgft);
        Test.stopTest();
    }
}