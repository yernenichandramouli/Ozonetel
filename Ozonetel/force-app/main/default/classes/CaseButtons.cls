/*
* Name           : CaseButtons
* Created Date   : 8th June 2021
* Created By     : Veeramanikanta R
* Purpose        : Controller for Case buttons functionality
* Test class     : CaseButtonsTest
*/
public class CaseButtons{
    @Auraenabled(cacheable=true)
    public static string SendCSATNotification(string caseId,string type){
        List<Case> csList=new List<Case>();
        System.debug('called apex'+caseId);
        csList=[select id,Lead_TCode__c,Lead__c from case where id=:caseId];
        if(!csList.isEmpty()){
            String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketDetails'].Endpoint__c;
            http ht=new http(); 
            HttpResponse res = new HttpResponse();
            HttpRequest httpReq= new HttpRequest();  
            //string jsBody='{"TripId":"M4ER5","CaseId":"50010000011CGtVAAW"}';
            string jsBody='{"TripId":"'+csList[0].Lead_TCode__c+'","CaseId":"'+csList[0].id+'"}';           

            httpReq = HttpRequestUtil.populateBusHireHeaders(new HttpRequest());          
            httpReq.setBody(jsBody);     
            httpReq.setEndpoint('callout:BushireSendNotification');                       
            httpReq.setMethod('POST');
            System.debug('httpReq-->'+httpReq);
            System.debug('httpReq body-->'+httpReq.getBody());
            res = ht.send(httpReq);
            system.debug('resbody-->'+res.getBody());
            string mockResp='{ "Error": null, "Response": { "Data": "The SMS and Whatsapp message have been triggered already" }, "Status": { "StatusCode": 200, "StatusMsg": "OK" } }';
            return res.getBody();
        }
        return null;
    }
}