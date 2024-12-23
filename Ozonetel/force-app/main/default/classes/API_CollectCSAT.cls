/*
* Name           : API_CSATUpdate
* Created Date   : 03 May 2019
* Created By     : Veeramanikanta R
* Purpose        : API for capture CSAT for IVR call
* Test class     : 
*/
@RestResource(urlMapping='/redBus/collectCSAT/*')
global without sharing class API_CollectCSAT
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
            List<Task> listTask=new list<Task>();
            List<Task> listTaskToUpsert=new list<Task>();
            string callId=string.valueOf(respObj.call_Id);
            listTask=[select id,Rating__c,source__c,CrtObjectId__c from Task where CrtObjectId__c=:callId limit 1];
            if(!listTask.isEmpty())
            {
                for(Task t:listTask)
                {
                    t.CrtObjectId__c=respObj.call_Id;
                    t.source__c=t.source__c+'-->IVR CSAT';
                    t.Rating__c=respObj.rating;
                    t.Customer_Ph_No__c=string.valueOf(respObj.mobile);
                    t.Phone_Code__c=string.valueOf(respObj.phoneCode);
                    listTaskToUpsert.add(t);
                }
            }
            else
            {
                task ts=new task();
                ts.CrtObjectId__c=respObj.call_Id;
                ts.Subject = 'IVR Call';
                ts.source__c='IVR CSAT';
                ts.Rating__c=respObj.rating;
                ts.Customer_Ph_No__c=string.valueOf(respObj.mobile);
                ts.Phone_Code__c=string.valueOf(respObj.phoneCode);
                listTaskToUpsert.add(ts);
            }
            if(!listTaskToUpsert.isEmpty())    
                Database.UpsertResult[] upsertResult1 =Database.upsert(listTaskToUpsert,false);
            
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