/*
* Name           : API_OrderIds
* Created Date   : 3 Aug 2017
* Created By     : Veeramanikanta R
* Purpose        : API for insert mobile recharge items in SF
* Test class     : API_OrderIdsTest
*/
@RestResource(urlMapping='/redBus/Orders/*')
global without sharing class API_OrderIds
{
    @HttpPost
    global static string doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('-----------data--------'+req.requestBody.toString());
        system.debug(LoggingLevel.ERROR, req.requestBody.toString());
        API_OrderIds_Future.RechargeCreation(req.requestBody.toString());
   
        return 'Success';
    }
    
}