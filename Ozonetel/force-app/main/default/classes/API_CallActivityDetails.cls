/*
* Name           : API_CallActivityDetails
* Created Date   : 10 June 2019
* Created By     : Veeramanikanta R
* Purpose        : API for capturing activity call details
* Test class     : API_CallActivityDetailsTest
*/
@RestResource(urlMapping='/redBus/CallActivityDetails/*')
global without sharing class API_CallActivityDetails
{
    static List<task> tskUpls=new List<task>();
    @HttpPost
    global static Response callCapture()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper respObj=new ResponseWrapper();
        Response apiResp = new Response();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'IVR Call Details';
        
        try{
            string requestData=req.requestBody.toString(); 
            dbl.Request_Data__c=requestData;
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class); 
            list<task> tisQ=new list<task>();
            tisQ=[select id,source__c,CrtObjectId__c,subject from task where CrtObjectId__c=:respObj.uniqueId];
            if(!tisQ.isEmpty())
            {
                for(task t:tisQ)
                    mapTaskFields(t,respObj,true);
                
            }
            else
            {
                mapTaskFields(new Task(),respObj,false);
            }
            
            if(!tskUpls.isEmpty())   
                upsert tskUpls; 
               // Database.UpsertResult[] upsertResult1 =Database.upsert(tskUpls,false);
            
            dbl.User_Id__c=respObj.uniqueId;
            
            if(System.Label.IVR_Logs=='TRUE')
                insert dbl;
            apiResp.statusCode='200';
            apiResp.message='Successfully tasks are created';
            
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            apiResp.statusCode='400';
            apiResp.message='Faield to create task, Exception->'+e;
        }   
        return apiResp;
    }
    
    private static void mapTaskFields(Task exst,ResponseWrapper req,Boolean taskExist)
    {
        task tis=new task();
        if(taskExist)
        {
            tis.id=exst.id;
            tis.source__c= exst.source__c+'-->IVR API Call';
        }
        else
        {
            tis.subject='IVR Call';
            tis.source__c='IVR API Call';
        }
        
        tis.Actual_Talk_Time__c=req.talkTime;
        tis.Agent_ID__c=req.agentId;
        tis.Agent_Name__c=req.agentName;
        tis.Call_Duration__c=req.callDuration;
        tis.Call_Remarks__c=req.remarks;
        tis.Call_Status__c=req.callStatus;
        tis.Call_Type__c=req.callType;
        tis.Campaign_Name__c=req.campaignName;
        tis.Channel__c=req.channel;
        tis.Cust_Category__c=req.custCategory;
        tis.Cust_Disposition__c=req.disposition;
        tis.Customer_Name__c=req.customerName;
        tis.Customer_Ph_No__c=req.phoneNo;
        tis.DID_Number__c=req.didnumber;
        tis.Disconnected_By__c=req.disconnectedBy;
        tis.Final_Call_Status__c=req.finalCallStatus;
        tis.Hold_Num_Times__c=req.holdNumTimes;
        tis.Hold_Time__c=req.holdTime;
        tis.IVRS_Path__c=req.ivrsPath;
        tis.List_Name__c=req.listName;
        tis.Monitor_File_Name__c=req.monitorFileName;
        tis.Monitor_File_Path__c=req.monitorFilePath;
        tis.Phone_Type__c=req.phoneType;
        tis.Queue_Time_Secs__c=req.queueTimeSecs;
        tis.Redial_Flag__c=req.redialFlag;
        tis.Session_ID__c=req.sessionId;
        tis.Skills__c=req.skills;
        tis.Transferred_From__c=req.transferredFrom;
        tis.Transferred_To__c=req.transferredTo;
        tis.Wait_Time__c=req.waitTime;
        tis.Wrapped_By__c=req.wrappedBy;
        tis.Wrapup_Time__c=req.wrapupTime;
        tis.CrtObjectId__c=req.uniqueId;
        tis.language__c=req.language;
        tis.PredictedOrderUuid__c=req.predictedOrderUuid;
        tis.PredictedOrderItemUuid__c=req.predictedOrderItemUuid;
        tis.Predicted_Destination__c=req.predicatedDestination;
        tis.Predicted_Preferred_Language__c=req.predicatedPreferredLanguage;
        tis.Predicted_Source__c=req.predicatedSource;
        tis.business_unit__c=req.businessUnit;
        if(req.predicatedMenuOption!=null){
              tis.Predicted_Menu_Option__c=string.valueOf(req.predicatedMenuOption).replaceAll('[)( ]', '');
        }
        if(req.predicatedSubMenuOptions!=null){
              tis.Predicted_Sub_Menu_Options__c=string.valueOf(req.predicatedSubMenuOptions).replaceAll('[)( ]', '');
        }
        if(req.predicatedVerticalMenuOptions!=null){
             tis.Predicted_Vertical_Menu_Options__c=string.valueOf(req.predicatedVerticalMenuOptions).replaceAll('[)( ]', '');
        }
        if(String.isNotBlank(req.callDateTime) && req.callDateTime!='null'){
            tis.Date_Time__c= datetime.valueof(req.callDateTime.replace('T',' ')).addminutes(330);
            tis.Created_Time_Value__c=string.valueOf(tis.Date_Time__c.getTime()/1000);
          }  
        tskUpls.add(tis);
    }

    global class ResponseWrapper{ 
        public string talkTime;
        public string agentId;
        public string agentName;
        public string callDuration;
        public string remarks;
        public string callStatus;
        public string callType;
        public string campaignName;
        public string channel;
        public string custCategory;
        public string disposition;
        public string customerName;
        public string phoneNo;
        public string callDateTime;
        public string didnumber;
        public string disconnectedBy;
        public string finalCallStatus;
        public string holdNumTimes;
        public string holdTime;
        public string ivrsPath;
        public string listName;
        public string monitorFileName;
        public string monitorFilePath;
        public string phoneType;
        public string queueTimeSecs;
        public string redialFlag;
        public string sessionId;
        public string skills;
        public string transferredFrom;
        public string transferredTo;
        public string waitTime;
        public string wrappedBy;
        public string wrapupTime;
        public string uniqueId; 
        public string language;
        public string predictedOrderUuid;
        public string predictedOrderItemUuid;
        public string predicatedDestination;
        public string predicatedSource;
        public List<string> predicatedMenuOption;
        public List<string> predicatedSubMenuOptions;
        public List<string> predicatedVerticalMenuOptions;
        public string predicatedPreferredLanguage;
        public string businessUnit;   
    }
    global class response
    {
        string statusCode;
        string message;
    }
    
    
}