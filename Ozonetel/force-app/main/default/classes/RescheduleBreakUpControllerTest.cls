/**
* Name           : RescheduleBreakUpControllerTest
* Created Date   : 17 Aug 2017
* Created By     : Veeramanikanta R
* Purpose        : Test class for RescheduleBreakUpController
*
**/

@isTest
private class RescheduleBreakUpControllerTest {
    
    static testMethod void testescheduleBreakUp()
    {              
        ApexPages.CurrentPage().getParameters().put('orderId','');
        RestRequest req = new RestRequest(); 
        RestResponse resp = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'GET';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= resp;        
        string json='[{"Type":"Total_Fare","DisplayName":"Total Fare","Value":{"currencyType":"IDR","amount":237500}},{"Type":"OFFERS","DisplayName":"Offers Used","Value":{"currencyType":"IDR","amount":237500}},{"Type":"Reschedule Charges","DisplayName":"Reschedule Charges","Value":{"currencyType":"IDR","amount":20000}},{"Type":"Reschedule Amount","DisplayName":"Amount available for booking","Value":{"currencyType":"IDR","amount":-7500}}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        RescheduleBreakUpController res=new RescheduleBreakUpController();
        List<RescheduleBreakUpController.RefundBreakUpWrapper> R=new List<RescheduleBreakUpController.RefundBreakUpWrapper>();
       
      
    }
}