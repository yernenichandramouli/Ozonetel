@isTest
public class API_Activities_Test
{
    static testMethod void storetivities()
    {
    
       string jsonBody='{ "type": "Activities Sync", "sentAt": "2019-02-26 18:08:42", "activities": [ {"id":"9878675665", "rbTransactId": "tId", "ACMEtransId": "test" }, {"id":"3565344276","rbTransactId": "tId22", "ACMEtransId": "test22" } ] }';
       Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/redBus/Activities';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Activities.LoadActivities();
        Test.stopTest();
    }
  static testMethod void errormethod(){
   Test.startTest();
  string jsonBody='{ "type": "Activities Sync", "sentAt": "2019-02-26 18:08:42", "activities": [ {"id":"", "rbTransactId": "", "ACMEtransId": "" }, {"id":"","rbTransactId": "", "ACMEtransId": "" } ] }';
      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/redBus/Activities';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Activities.LoadActivities();
        Test.stopTest();
  }
 }