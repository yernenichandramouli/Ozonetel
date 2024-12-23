/**
* Name           : API_CallDetailsTest
* Created Date   : 09 April 2018
* Created By     : Veeramanikanta R
* Purpose        : Testing API functionality for Capturing call details 
**/

@isTest
public class API_CallDetailsTest
{
    /*
Name:SuccessTest
Description: Used to test test insert recharge items with New customer
*/
    public static testMethod void testCallDetailsCapture()
    {
        Test.startTest();
            //    string jsonBody='{"id":"c2c_5ac1ce3562a7d995","callfrom":"7263946106","callto":"434234234","start_time":"1522656283","end_time":"1522656289","duration":"4","billsec":"4","status1":"ANSWER","status2":"ANSWER","recording":"","location":"circle","provider":"network","ringtime":"4","Tin":"TM3456457567","OperatiorId":"Bitla","OperatorName":" Bitla"}';
                string jsonBody='{"id":"c2c_5ac1ce3562a7d995","callfrom":"7263946106","callto":"434234234","start_time":"","end_time":"","duration":"4","billsec":"4","status1":"ANSWER","status2":"ANSWER","recording":"","location":"circle","provider":"network","ringtime":"4","Tin":"TM3456457567","OperatiorId":"Bitla","OperatorName":" Bitla"}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/redBus/CallDetails';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
 API_CallDetails.callCapture();     
        Test.stopTest();
        
        }
        
        }