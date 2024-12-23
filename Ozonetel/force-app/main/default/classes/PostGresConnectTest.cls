@isTest
public class PostGresConnectTest {
    
    /*
Name:createPostGresData
Description: Creates PostGres(Recharge Items) data 
*/
    @testsetup
    static void createPostGresData(){
        List<PostGres_Data__c> pgList = new List<PostGres_Data__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            pgList.add(new PostGres_Data__c(Order_Id__c = '422' , Email__c='mani.renus@gmail.com',Mobile__c='9491322718'));
        } 
        insert pgList ;
    }
    public static testMethod void successGetOrderTest()
    {
        Test.startTest();
        
        PostGres_Data__c p=[select id,order_id__c,email__c,mobile__c from postgres_data__c limit 1];
        
        System.currentPageReference().getParameters().put('orderId', p.Order_Id__c);
        System.currentPageReference().getParameters().put('id', p.id);
        PostGresConnect pObj = new PostGresConnect(new ApexPages.StandardController(p));
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI='https://capipp.redbus.com/api/Tel/v1/Order?Id='+p.Order_Id__c;
        req.httpMethod = 'GET';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string  json='{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""},{"id":414,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":30,"type_of_payment":"DIRECT","additonal_details":""}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        pObj.getOrders();
        pObj.checkValidWFTtoGFT();
        pObj.doRefundForValidGFT();
        PostGresConnect.ResponseWrapper pw=new PostGresConnect.ResponseWrapper();
        pw.OperatorType=45;
        pw.Plan='No Plans as of Now!!';
        pw.CreatedDate='11/04/2017';
        pw.RechargeAmount=25; 
        pw.TransactionRefNo='98786'; 
        pw.OperatorRefNo='123'; 
        pw.RechargeStatus='Success';
        pw.OperatorName='OperatorName';
        pw.EmailId='EmailId@Email.com'; 
        pw.MobileNo='9491322718';
        pw.OrderId=12345;
        pw.OrderStatus='OrderStatus';
        
        PostGresConnect.TransactionStatusWrapper pt=new PostGresConnect.TransactionStatusWrapper();
        pt.Status='Success';
        pt.Error='';
        PostGresConnect.PaymentStatus ps=new PostGresConnect.PaymentStatus();
        ps.GatewayName='SUCCESS';

        Test.stopTest();        
        
    }
    public static testMethod void successInitiateRefundTest()
    {
        Test.startTest();
        
        PostGres_Data__c p=[select id,order_id__c,email__c,mobile__c from postgres_data__c limit 1];
        
        System.currentPageReference().getParameters().put('orderId', p.Order_Id__c);
        System.currentPageReference().getParameters().put('id', p.id);
        PostGresConnect pObj = new PostGresConnect(new ApexPages.StandardController(p));
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI='https://capipp.redbus.com/api/Tel/v1/Refund';
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
      string response='{"Code":"11.24","Message":"Refund is alreday processed for the provided order id.","DetailedMessage":"Refund is alreday processed for the provided order id.","HttpStatusCode":200}';
    Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', response));
        
        pObj.initiateRefund();
         pObj.getOrders();
        pObj.checkValidWFTtoGFT();
        Test.stopTest();        
        
    }
    
}