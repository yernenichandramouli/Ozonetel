/*
* Name           : API_Click2Call
* Created Date   : 1st Oct 2020
* Created By     : Veeramanikanta R
* Purpose        : API for capturing click 2 call call details
* Test class     : API_Click2CallTest
*/
@RestResource(urlMapping='/redBus/Click2CallDetails/*')
global without sharing class API_Click2Call
{
    static List<Call_Details__c> cdUpLs=new List<Call_Details__c>();
    @HttpPost
    global static Response callCapture()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper respObj=new ResponseWrapper();
        Response apiResp = new Response();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Click2Call Details';
        string channel=req.headers.get('channel');
        
        try{
            string requestData=req.requestBody.toString(); 
            dbl.Request_Data__c=requestData;
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class); 
            list<Call_Details__c> cdObjQ=new list<Call_Details__c>();
            cdObjQ=[select id,source__c,CrtObjectId__c,subject__c from Call_Details__c where CrtObjectId__c=:respObj.recordId];
            
            if(!cdObjQ.isEmpty())
            {
                for(Call_Details__c t:cdObjQ)
                    mapCallDetailFields(t,respObj,true,channel);           
            }
            else
            {
                mapCallDetailFields(new Call_Details__c(),respObj,false,channel);
            }
            
            if(!cdUpLs.isEmpty())  
                upsert cdUpLs Call_Details__c.Call_Unique_Id__c;
            
            dbl.User_Id__c=respObj.recordId;
            
            if(System.Label.IVR_Logs=='TRUE')
                insert dbl;
            apiResp.statusCode='200';
            apiResp.message='Successfully call details are created';
           
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            apiResp.statusCode='400';
            apiResp.message='Faield to create Call Detail, Exception->'+e;
        }   
        return apiResp;
    }
    
    private static void mapCallDetailFields(Call_Details__c exst,ResponseWrapper req,Boolean cdExist,string channel)
    {
        Call_Details__c cdObj=new Call_Details__c();
        if(cdExist)
        {
            cdObj.id=exst.id;
            if(channel!='CSAT'){
               cdObj.source__c= exst.source__c+'-->IVR API Call';
            }else{
               cdObj.source__c= exst.source__c+'-->IVR API Call CSAT';
            }
        }
        else
        {
            cdObj.subject__c='IVR Call';
            if(channel!='CSAT'){
               cdObj.source__c='IVR API Call';
            }else{
               cdObj.source__c='IVR API Call CSAT';
            }
        }
        Id recTypeId = Schema.getGlobalDescribe().get('Call_Details__c').getDescribe().getRecordTypeInfosByName().get('Click2Call').getRecordTypeId();
        cdObj.RecordTypeId = recTypeId;       
        cdObj.name=req.recordId;
        cdObj.Call_Unique_Id__c=req.recordId;
        if(channel=='CSAT'){
        cdObj.Rating__c=req.rating;
        }else{
        cdObj.User_Call_Status__c=req.userCallStatus;
        cdObj.CrtObjectId__c=req.recordId;
        cdObj.Actual_Talk_Time__c=req.talkTime;
        cdObj.Agent_ID__c=req.boNumber;
        cdObj.Call_Duration__c=req.callDuration;
        cdObj.Call_Status__c=req.callStatus;
        cdObj.Call_Type__c=req.callType;
        cdObj.Campaign_Name__c=req.campaignName;
        cdObj.Channel__c=req.channel;
        cdObj.Cust_Disposition__c=req.disposition;
        cdObj.Customer_Ph_No__c=req.phoneNo;
        cdObj.Disconnected_By__c=req.disconnectedBy;
        cdObj.Final_Call_Status__c=req.finalCallStatus;
        cdObj.business_unit__c=req.businessUnit;       

        if(String.isNotBlank(req.callDateTime) && req.callDateTime!='null'){
            cdObj.Date_Time__c= datetime.valueof(req.callDateTime.replace('T',' ')).addminutes(330);
            cdObj.Created_Time_Value__c=string.valueOf(cdObj.Date_Time__c.getTime()/1000);
        }  
        }
        cdUpLs.add(cdObj);
    }
    
    
    
    global class ResponseWrapper{ 
       public string boCallStatus;
       public string userCallStatus;
       public string boNumber;
       public string businessUnit;
       public string callDateTime;
       public string callDuration;
       public string callStatus;
       public string callType;
       public string campaignName;
       public string channel;
       public string disconnectedBy;
       public string disposition;
       public string finalCallStatus;
       public string phoneNo;
       public string recordId;
       public string talkTime;
       public string rating;
    }
    global class response
    {
        string statusCode;
        string message;
    }
}