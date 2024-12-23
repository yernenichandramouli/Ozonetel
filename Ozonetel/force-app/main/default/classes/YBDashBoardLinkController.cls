/*
* Name           : YBDashBoardLinkController
* Created Date   : 13 OCT 2022
* Created By     : VR Sudarshan 
* Purpose        : Revamping YB Dashboard
* Test class     : YBDashBoardLinkControllerTest
* Jira Id        : CRM-1185
*/
public class YBDashBoardLinkController {
    @AuraEnabled
    Public Static String GetAllBps(String transactionId) {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='YB Status - Get Boarding Points';
        System.debug('::: transactionId ::: ' +transactionId);
        List<Order_Items__c> transactionList = [SELECT Id, Service_Provider_Id__c, ServiceID__c  FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        dbl.Payment_Transaction_Name__c =transactionList[0].Id;
        string jsonCM='{"rbOperatorId": '+transactionList[0].Service_Provider_Id__c+',"serviceId":'+transactionList[0].ServiceID__c+'}';
        System.debug('jsonCM-->'+jsonCM);
        try{
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='All_YB_Bp_Api'].Endpoint__c);
            req.setBody(jsonCM);
            dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+' -- Request Body --'+req.getBody();
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            res = http.send(req);
            dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            insert dbl;
            System.debug('res body--->'+res.getBody());
            return JSON.serialize(res.getBody());
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            System.debug('An exception occurred: ' + e.getMessage());
            return String.valueOf(e.getMessage());
        }
    }

    @AuraEnabled
    public static string Getarrivalpatterns(string transactionId, string boardingPointId) {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='YB Status - Get Arrival Patterns';
        System.debug('::: transactionId ::: ' +transactionId);
        System.debug('::: boardingPointId ::: ' +boardingPointId);
        List<Order_Items__c> transactionList = [SELECT Id, Service_Provider_Id__c, ServiceID__c, Boarding_Point_Id__c FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        string jsonCM='{"rbOperatorId": '+transactionList[0].Service_Provider_Id__c+',"serviceId":'+transactionList[0].ServiceID__c+',"rbBpId":'+boardingPointId+'}';
        dbl.Payment_Transaction_Name__c =transactionList[0].Id;
        System.debug('jsonCM-->'+jsonCM);
        try{
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setHeader('country','IND');
            req.setHeader('channel_name','android');
            req.setHeader('os','web');
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='YBArrivalTrends_API'].Endpoint__c);
            req.setBody(jsonCM);
            res = http.send(req);
            dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-country--'+req.getHeader('country')+'-Headers-Accept-Language--'+req.getHeader('Accept-Language')+'-Headers-channel_name--'+req.getHeader('channel_name')+'-Headers-os--'+req.getHeader('os')+' -- Request Body --'+req.getBody();
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            insert dbl;
            string resBody=res.getBody();
            System.debug('res body--->'+res.getBody());
            return resBody;
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            System.debug('An exception occurred: ' + e.getMessage());
            return String.valueOf(e.getMessage());
        }
    }

    @AuraEnabled
    Public Static String GetTrackingDetails(String transactionId) {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='YB Status - Get Tracking Details';
        System.debug('::: transactionId ::: ' +transactionId);
        List<Order_Items__c> transactionList = [SELECT Id, Order_Item_Reference_No__c, Corrected_Date_of_Journey__c  FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        dbl.Payment_Transaction_Name__c =transactionList[0].Id;
        DateTime dojDate=transactionList[0].Corrected_Date_of_Journey__c;
        Date d = dojDate.date().addDays(1);
        if(system.now()>d){
            string outOfJourney = 'JourneyExpired';
            return JSON.serialize(outOfJourney);
        }else{
            string jsonCM='{"tin": "'+transactionList[0].Order_Item_Reference_No__c+'"}';
            System.debug('jsonCM-->'+jsonCM);
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type','application/json');
                req.setMethod('POST');
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='YB_Tracking_Details'].Endpoint__c);
                req.setBody(jsonCM);
                res = http.send(req);
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string resBody=res.getBody();
                System.debug('res body--->'+res.getBody());
                return resBody;
            }catch(Exception e){
                dbl.Exception_Description__c=string.valueOf(e);
                insert dbl;
                System.debug('An exception occurred: ' + e.getMessage());
                return String.valueOf(e.getMessage());
            }
        }
    }
}