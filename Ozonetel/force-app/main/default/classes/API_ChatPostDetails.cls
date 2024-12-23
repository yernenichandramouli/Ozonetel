/*
* Name           : API_ChatPostDetails
* Created Date   : 01 Jul 2021
* Created By     : Veeramanikanta R
* Purpose        : API for capture chat details
* Test class     : API_ChatPostDetailsTest
*/
@RestResource(urlMapping='/redBus/ChatPostDetails/*')
global without sharing class API_ChatPostDetails
{
    @HttpPost
    global static ResponceWrapper chatCapture()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        RequestWrapper  reqObj=new RequestWrapper();
        ResponceWrapper respObj=new ResponceWrapper();
        reqObj= (RequestWrapper)System.JSON.deserialize(req.requestBody.toString(),RequestWrapper.class);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'ChatPostDetails';
        dbl.Request_Data__c = req.requestBody.toString();
        List<LiveChatTranscript> lct=new List<LiveChatTranscript>();
        List<Live_Chat_Monitor__c> lcm=new List<Live_Chat_Monitor__c>();
        lct=[select id,ChatKey,Chat_Ended_By__c from LiveChatTranscript where ChatKey=:reqObj.chatSessionId];
        lcm=[select id,Chat_Ended_By__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:reqObj.chatSessionId];
        if(!lct.isEmpty()){
            try{
                lct[0].Chat_Ended_By__c=reqObj.chatEndedBy;
                update lct;
                if(!lcm.isEmpty()){
                 lcm[0].Chat_Ended_By__c=reqObj.chatEndedBy;
                 update lcm;
                }
                respObj.message='Successfully updated';
                respObj.statusCode='200';
            }catch(exception e){
                respObj.message='Something error occurred, Please contact SF Team!! Error Message->'+e;
                respObj.statusCode='400';
            }
        }else{
            respObj.message='Session id not found';
            respObj.statusCode='200.1';
        }
        dbl.Response_Received__c = string.valueOf(respObj);
        insert dbl;
        return respObj;
    }
    
    global class RequestWrapper{
        public string chatSessionId;
        public string chatEndedBy;     
    }
    
    global class ResponceWrapper
    {
        public string statusCode;
        public string message;        
    }
}