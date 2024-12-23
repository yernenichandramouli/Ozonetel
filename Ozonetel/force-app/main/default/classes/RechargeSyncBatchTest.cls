@isTest
public class RechargeSyncBatchTest
{
    Static testMethod void TestRechargeSync()
    {
        PostGres_Data__c p=new PostGres_Data__c();
        p.Order_Status__c='GFT(Payment collected and recharge not successful)';
        p.Order_Id__c='123456';
        insert p;
        
        Test.startTest();
        string json=  '{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""},{"id":414,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":30,"type_of_payment":"DIRECT","additonal_details":""}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        RechargeSyncBatch recSync= new RechargeSyncBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RechargeSync', cronExp,recSync);
        Test.stopTest();
    }
    
}