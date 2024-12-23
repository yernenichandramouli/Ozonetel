/*
* Name           : API_CollectCSATNew
* Created Date   : 03 May 2019
* Created By     : Veeramanikanta R
* Purpose        : API for capture CSAT for IVR call
* Test class     : API_CollectCSATNewTest
*/
@RestResource(urlMapping='/redBus/collectCSAT/v1/*')
global without sharing class API_CollectCSATNew
{
    @HttpPost
    global static Response callCapture()
    {
        System.debug('Inside Collect CSAT');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        response apiResp = new response();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'IVR CSAT';
        try{
            
            System.debug('--Body--'+req.requestBody.toString());
            ResponseWrapper  respObj=new ResponseWrapper();
            String requestData=req.requestBody.toString();
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class);
            System.debug('CSAT Request data..'+respObj);
            List<Call_Details__c> cdList=new List<Call_Details__c>();
            List<Call_Details__c> cdUpsLs=new List<Call_Details__c>();
            
            string callId=string.valueOf(respObj.call_Id);
            cdList=[select id,Rating__c,Call_Unique_Id__c,Source__c from Call_Details__c where Call_Unique_Id__c=:callId limit 1];
            
            if(!cdList.isEmpty())
            {
                for(Call_Details__c c:cdList)
                {
                    c.Call_Unique_Id__c=respObj.call_Id;
                    c.source__c=c.source__c+'-->IVR CSAT';
                    c.Rating__c=respObj.rating;                 
                    cdUpsLs.add(c);
                }
            }
            else
            {
                Call_Details__c cd=new Call_Details__c();
                cd.name=respObj.call_Id;
                cd.Call_Unique_Id__c=respObj.call_Id;
                cd.Subject__c = 'IVR Call';
                cd.source__c='IVR CSAT';
                cd.Rating__c=respObj.rating;
                cd.Customer_Ph_No__c=string.valueOf(respObj.mobile);
                cd.Phone_Code__c=string.valueOf(respObj.phoneCode);
                cdUpsLs.add(cd);
            }
            if(!cdUpsLs.isEmpty())    
                  upsert cdUpsLs Call_Details__c.Call_Unique_Id__c;
            //Database.UpsertResult[] upsertResult1 =Database.upsert(cdUpsLs,false);
            
            dbl.Request_Data__c=requestData;
            dbl.User_Id__c=callId;
            if(System.Label.IVR_Logs=='TRUE')
                insert dbl;
            apiResp.statusCode='200';
            apiResp.message='Review Submitted Successfully';
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            apiResp.statusCode='400';
            apiResp.message='Review Submission Failed->'+e;
        }
        return apiResp;
    }    
    global class ResponseWrapper{
        public string call_Id;
        public long mobile;
        public Integer phoneCode;
        public string rating;
        
    }  
    global class Response
    {
        string statusCode;
        string message;
    }
}