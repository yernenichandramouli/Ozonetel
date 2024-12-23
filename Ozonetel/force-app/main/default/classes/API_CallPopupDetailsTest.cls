/*
* Name           : API_CallPopupDetailsTest
* Created Date   : 13 June 2019
* Created By     : Sreenivas M
* Purpose        : Test Class for API_CallPopupDetails
*/
@isTest
public class API_CallPopupDetailsTest
{
    static testMethod void popupDetails()
    {
     string jsonBody='{"mobile":555,"phoneCode":91,"orderUuid":"","orderId":"162737737737","callInitiationTime":"2019-05-23T09:28:00.000Z","agentId":"1234","menuOptions":"1,2,3","uniqueCallId":"XY-733718388183"}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/CallPopupDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_CallPopupDetails.callCapture();
              
        Test.stopTest();
       } 
    }