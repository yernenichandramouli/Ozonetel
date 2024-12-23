/*
* Name           : API_CallBacks
* Created Date   : 21 May 2019
* Created By     : Veeramanikanta R
* Purpose        : API for to store all call back details
* Test class     : API_CallBacks_Test
*/
@RestResource(urlMapping='/redBus/CallBack/*')
global without sharing class API_CallBacks
{   
    @HttpPost
    global static Reponse CaptureCallBacks()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Reponse apiResp=new Reponse();
        string event=req.headers.get('actionType');
        System.debug('calling here-->'+event);
        Call_Back_Records__c cd=new Call_Back_Records__c();
        ResponseWrapper  respObj=new ResponseWrapper();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'IVR CallBack';
        try{
            string requestData=req.requestBody.toString();
            System.debug('requestData->'+requestData);
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class);
            System.debug('respObj-->'+respObj);
            System.debug('cb-->'+respObj.callBackTime);          
            if(String.isBlank(event) || String.isBlank(respObj.agentId) || respObj.mobile==null)
            {
                res.statusCode = 400;
                apiResp.statusCode='400';
                apiResp.message='Bad Request, Some value is missing!!';
                return apiResp; 
            }else if(event=='Insert'){          
                cd.Name=String.valueOf(respObj.mobile);
                cd.Agent_id__c=respObj.agentId;
                cd.CB_Status__c='Open'; 
                System.debug('callBack dtime-->'+respObj.callBackTime);
                
                if(String.isNotBlank(respObj.callBackTime) && respObj.callBackTime!='null')
                {
                    if(respObj.callBackTime.contains('T'))
                        cd.Call_Back_Time__c= datetime.valueof(respObj.callBackTime.replace('T',' '));
                    else
                        cd.Call_Back_Time__c= datetime.valueof(respObj.callBackTime);
                }
                
                insert cd;
            }else if(event=='Update' && (String.isBlank(respObj.callBackTime))){
                System.debug('inside update null..');
                list<Call_Back_Records__c> cbList=new list<Call_Back_Records__c>();
                list<Call_Back_Records__c> cbUpList=new list<Call_Back_Records__c>();
                String mobileNum = String.valueOf(respObj.mobile);
                cbList=[select id,name,CB_Status__c from Call_Back_Records__c  where name=:mobileNum ];
                System.debug('cbList-->'+cbList);
                for(Call_Back_Records__c c:cbList){
                    c.CB_Status__c='Closed';
                    cbUpList.add(c);
                }
                if(!cbUpList.isEmpty()){
                    update cbUpList;
                }
            }else if(event=='Update' && string.isNotBlank(respObj.callBackTime)){
                List<Call_Back_Records__c> cbrLs=new List<Call_Back_Records__c>();
                List<Call_Back_Records__c> cbrUpLs=new List<Call_Back_Records__c>();
                String mobileNum = String.valueOf(respObj.mobile);
                String agentId=String.valueOf(respObj.agentId);
                cbrLs=[select id,name,CB_Status__c from Call_Back_Records__c where name=:mobileNum];
                for(Call_Back_Records__c cbObj:cbrLs){
                    if(String.isNotBlank(respObj.callBackTime))
                    {
                        if(respObj.callBackTime.contains('T'))
                            cbObj.Call_Back_Time__c= datetime.valueof(respObj.callBackTime.replace('T',' '));
                        else
                            cbObj.Call_Back_Time__c= datetime.valueof(respObj.callBackTime);
                    }
                    cbrUpLs.add(cbObj);
                }
                
                if(!cbrUpLs.isEmpty()){  
                    update cbrUpLs;                 
                }
            }
            apiResp.statusCode='200';
            res.statusCode = 200;
            apiResp.message='Success';
            dbl.Request_Data__c=requestData;
            dbl.Response_Received__c=string.valueOf(apiResp);
            if(System.Label.IVR_Logs=='TRUE')
                insert dbl;
            
        }
        catch(Exception e){            
            apiResp.statusCode='417';
            res.statusCode = 417;
            apiResp.message='Error While Processing.Error Details-->'+string.valueOf(e); 
            dbl.Response_Received__c=string.valueOf(apiResp);
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
        }
        return apiResp;        
    }
    
    global class ResponseWrapper{
        public string agentId ;
        public long mobile;
        public Integer phoneCode;
        public string callBackTime;        
    }    
    global class Reponse{
        public string statusCode;
        public string message;
    } 
}