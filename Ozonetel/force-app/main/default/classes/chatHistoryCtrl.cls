/**
 * (c) 2023 RedBus
 *
 * Name           : chatHistoryCtrl
 * Created Date   : 29 MAY 2023
 * Created By     : VR Sudarshan
 * Purpose        : Controller to fetch chat history details from self help.
 * JiraId         : CRM - 1431
 * Test class     : chatHistoryCtrlTest
 *
 **/
public class chatHistoryCtrl {
    // { "uid": "919035593529", "orderId": "0deaf1dbf558f0055722993404010100", "orderItemId": "", "customerName": "Preethan", "country": "IND", "limit": 15, "offset": 0, "lang": "en" }
    @AuraEnabled
    public static string invokeSelfHelpAPI(string recordId){
        List<DBLog_Summary__c> dbLogListToUpdate = new List<DBLog_Summary__c>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c='SelfHelp ChatHistory';
        string responseValue;
        string countryCode;
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        try {
            chatHistryWrapper chstResponseWrapper = New chatHistryWrapper();
            List<LiveChatTranscript> liveChatTransList = [SELECT Mobile_No__c, Order_Uuid__c, OrderItem_Uuid__c, LiveChatButton.DeveloperName, Customer_Name__c FROM LiveChatTranscript WHERE Id=:recordId LIMIT 1];
            if(!liveChatTransList.isEmpty() && String.isNotBlank(liveChatTransList[0].Mobile_No__c)){
                map<string,object> labelData = (map<string,object>)JSON.deserializeUntyped(system.label.preChatHistory_Country_Cnfig);
                if(String.isNotBlank(liveChatTransList[0].LiveChatButton.DeveloperName) && labelData.containsKey(liveChatTransList[0].LiveChatButton.DeveloperName)){
                    countryCode = string.valueOf(labelData.get(liveChatTransList[0].LiveChatButton.DeveloperName));
                    System.debug(':: Country Code == '+countryCode);
                }else{
                    countryCode ='IND';
                }
                System.debug(':: countryCode = '+String.valueOf(countryCode));
                string jsonBody='{"uid":"'+liveChatTransList[0].Mobile_No__c+'","orderId":"'+liveChatTransList[0].Order_Uuid__c+'","orderItemId":"'+liveChatTransList[0].OrderItem_Uuid__c+'","customerName":"'+liveChatTransList[0].Customer_Name__c+'","country": "'+String.valueOf(countryCode)+'", "limit": 15, "offset": 0, "lang": "en"}';
                req = HttpRequestUtil.populateHeaders(req); 
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='chatHistoryForSF'].Endpoint__c);
                req.setMethod('POST');
                req.setBody(jsonBody);
                res = http.send(req);  
                System.debug(':: Request Data == '+req+'Body'+req.getBody());
                System.debug(':: Response == '+res);
                chstResponseWrapper = (chatHistryWrapper)JSON.deserialize(res.getBody(),chatHistryWrapper.class);  
                if(res.getStatusCode()==200 && !string.isBlank(res.getBody())){
                    responseValue = chstResponseWrapper.data;
                }else{
                    responseValue = 'Unable to process the request';
                }
            }

        } catch (Exception e) {
            System.debug('Exception has occured' +e+ 'at Line '+e.getLineNumber());
        }
        return responseValue;
    }

    public class chatHistryWrapper{
        public string data;
    } 
}