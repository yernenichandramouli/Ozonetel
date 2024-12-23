/*
* Name           : API_CallActivityDetailsNew
* Created Date   : 10 June 2019
* Created By     : Veeramanikanta R
* Purpose        : API for capturing activity call details
* Test class     : API_CallActivityDetailsNewTest
*/
@RestResource(urlMapping='/redBus/CallActivityDetails/v1/*')
global without sharing class API_CallActivityDetailsNew
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
        dbl.Type__c = 'IVR Call Details';
        
        try{
            string requestData=req.requestBody.toString(); 
            dbl.Request_Data__c=requestData;
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            
            // Access the caseId from the Map
            String caseId = (String) jsonMap.get('caseId');
            
            if (jsonMap.containsKey('caseId') && String.isNotBlank(caseId)) {
                 CallbackSchedulerController.callDispositionMethod(requestData);
                 dbl.Type__c = 'Supervisor Call Details';
                 dbl.User_Id__c=caseId;
                 insert dbl;
                 apiResp.statusCode='200';
                 apiResp.message='Successfully call details are created';
            } else {
               System.debug('Case ID is blank or null');
           
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class); 
            list<Call_Details__c> cdObjQ=new list<Call_Details__c>();
            cdObjQ=[select id,source__c,CrtObjectId__c,subject__c from Call_Details__c where CrtObjectId__c=:respObj.uniqueId];
            dbl.cZentrix_Type__c = respObj.businessUnit;
            if(!cdObjQ.isEmpty())
            {
                for(Call_Details__c t:cdObjQ)
                    mapCallDetailFields(t,respObj,true);           
            }
            else
            {
                mapCallDetailFields(new Call_Details__c(),respObj,false);
            }
            
            if(!cdUpLs.isEmpty())  
                upsert cdUpLs Call_Details__c.Call_Unique_Id__c;
            
            dbl.User_Id__c=respObj.uniqueId;
           
           
            if(System.Label.IVR_Logs=='TRUE')
                insert dbl;
            apiResp.statusCode='200';
            apiResp.message='Successfully call details are created';
          } 
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            apiResp.statusCode='400';
            apiResp.message='Faield to create Call Detail, Exception->'+e;
        }  
        
        return apiResp;
        
        
    }
    
    private static void mapCallDetailFields(Call_Details__c exst,ResponseWrapper req,Boolean cdExist)
    {
        Call_Details__c cdObj=new Call_Details__c();
        if(cdExist)
        {
            cdObj.id=exst.id;
            cdObj.source__c= exst.source__c+'-->IVR API Call';
        }
        else
        {
            cdObj.subject__c='IVR Call';
            cdObj.source__c='IVR API Call';
        }
        
        cdObj.name=req.uniqueId;
        cdObj.Call_Unique_Id__c=req.uniqueId;
        cdObj.Actual_Talk_Time__c=req.talkTime;
        cdObj.Agent_ID__c=req.agentId;
        cdObj.Agent_Name__c=req.agentName;
        cdObj.Call_Duration__c=req.callDuration;
        cdObj.Call_Remarks__c=req.remarks;
        cdObj.Call_Status__c=req.callStatus;
        cdObj.Call_Type__c=req.callType;
        cdObj.Campaign_Name__c=req.campaignName;
        cdObj.Channel__c=req.channel;
        cdObj.Cust_Category__c=req.custCategory;
        cdObj.Cust_Disposition__c=req.disposition;
        cdObj.Customer_Name__c=req.customerName;
        cdObj.Customer_Ph_No__c=req.phoneNo;
        cdObj.DID_Number__c=req.didnumber;
        cdObj.Disconnected_By__c=req.disconnectedBy;
        cdObj.Final_Call_Status__c=req.finalCallStatus;
        cdObj.Hold_Num_Times__c=req.holdNumTimes;
        cdObj.Hold_Time__c=req.holdTime;
        cdObj.IVRS_Path__c=req.ivrsPath;
        cdObj.List_Name__c=req.listName;
        cdObj.Skills__c=req.skills;
        cdObj.Transferred_From__c=req.transferredFrom;
        cdObj.Transferred_To__c=req.transferredTo;
        cdObj.Wrapped_By__c=req.wrappedBy;
        cdObj.Wrapup_Time__c=req.wrapupTime;
        cdObj.CrtObjectId__c=req.uniqueId;
        cdObj.language__c=req.language;
        cdObj.business_unit__c=req.businessUnit;
        cdObj.PredictedOrderUuid__c=req.predictedOrderUuid;
        cdObj.PredictedOrderItemUuid__c=req.predictedOrderItemUuid;
        cdObj.Predicted_Destination__c=req.predicatedDestination;
        // cdObj.Predicted_Preferred_Language__c=req.predicatedPreferredLanguage;
        cdObj.Predicted_Source__c=req.predicatedSource;
        cdObj.Menu_Last_Value__c=req.menuLastValue;
        cdObj.Queue_Time__c=req.queueTimeSecs;
        cdObj.Wait_Time__c=req.waitTime;
        cdObj.recordingurl__c=req.recordingFileUrl;
        cdObj.hft_flag__c=req.hft_flag;
        // cdObj.FlowName__c=req.flowSource;
        cdObj.Predicated_Issue__c=req.predicatedIssue;
        cdObj.Predicated_SubIssue__c=req.predicatedSubIssue;
        cdObj.Sales_Channel__c=req.salesChannel;
        cdObj.OrderUuid__c=req.uuid;
        cdObj.TransactionStatus__c=req.finalstatus;
        cdObj.PredicatedTIN__c=req.predicatedTIN;
        cdObj.selectedTIN__c=req.tin;

        if (req.predicatedPreferredLanguage != null) {
            cdObj.Predicted_Preferred_Language__c=req.predicatedPreferredLanguage;        
        }
        else {
            cdObj.Predicted_Preferred_Language__c=req.preferredLanguage;
        }
        
        if(req.flowSource != null) {
            cdObj.FlowName__c=req.flowSource;
        }
        else {
            cdObj.FlowName__c=req.flowName;
        }
        
        if(req.isIRchatFlow!=null && Boolean.valueof(req.isIRchatFlow)){
          cdObj.isIRchatFlow__c=Boolean.valueof(req.isIRchatFlow);
        }
       
        if(req.predicatedMenuOption!=null){
              cdObj.Predicted_Menu_Option__c=string.valueOf(req.predicatedMenuOption).replaceAll('[)( ]', '');
        }
        if(req.predicatedSubMenuOptions!=null){
              cdObj.Predicted_SubMenu_Options__c=string.valueOf(req.predicatedSubMenuOptions).replaceAll('[)( ]', '');
        }
        if(req.predicatedVerticalMenuOptions!=null){
             cdObj.Predicted_VerticalMenu_Options__c=string.valueOf(req.predicatedVerticalMenuOptions).replaceAll('[)( ]', '');
        }
        if(String.isNotBlank(req.callDateTime) && req.callDateTime!='null'){
            cdObj.Date_Time__c= datetime.valueof(req.callDateTime.replace('T',' ')).addminutes(330);
            cdObj.Created_Time_Value__c=string.valueOf(cdObj.Date_Time__c.getTime()/1000);
        }  
        cdUpLs.add(cdObj);
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
        public string menuLastValue;    
        public string recordingFileUrl;
        public string hft_flag;
        public string flowSource;
        public string predicatedIssue;
        public string predicatedSubIssue;
        public boolean isIRchatFlow;
        public string salesChannel;
        public string flowName;
        public string uuid;
        public string preferredLanguage;
        public string predicatedTIN;
        public string finalstatus;
        public string tin;
    }
    global class response
    {
        string statusCode;
        string message;
    }
    
    
}