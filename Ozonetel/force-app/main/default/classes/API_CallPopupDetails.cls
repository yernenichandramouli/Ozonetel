/*
* Name           : API_CallPopupDetails
* Created Date   : 13 May 2019
* Created By     : Veeramanikanta R
* Purpose        : API for to store all call details information
* Test class     : API_CallPopupDetailsTest
*/
@RestResource(urlMapping='/redBus/CallPopupDetails/*')
global without sharing class API_CallPopupDetails
{   
    @HttpPost
    global static Reponse callCapture()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Reponse apiResp=new Reponse();     
        string redirectURL;
        String callCentName;
        Call_Details__c cd=new Call_Details__c();
        ResponseWrapper  respObj=new ResponseWrapper();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'IVR Call PopUp';
        
        try{
            string requestData=req.requestBody.toString(); 
            dbl.Request_Data__c=requestData;
            respObj= (ResponseWrapper)System.JSON.deserialize(requestData,ResponseWrapper.class);
            cd.Agent_Id__c=respObj.agentId;
            if(String.isNotBlank(cd.Agent_Id__c))
            {
                
                If(!Test.isRunningTest())
                {
                    String callCentId = [SELECT CallCenterId FROM User where username=:cd.Agent_Id__c limit 1].CallCenterId;
                    callCentName = [SELECT InternalName FROM CallCenter WHERE id=:callCentId].InternalName;
                }
                else
                {
                    callCentName ='DrishtiAdapterLightning';
                }
                if(String.isNotBlank(callCentName) && ('AmeyoCCAdapterLightning'.equalsIgnoreCase(callCentName) || 'DrishtiAdapterLightning'.equalsIgnoreCase(callCentName)))
                    redirectURL='one/one.app#/alohaRedirect/apex/CallPopUpLtngPage?mobile=';
                else
                    redirectURL='/apex/CallPopUpPage?mobile=';
            }
            cd.Menu_Options__c=respObj.menuOptions;
            cd.Mobile_Number__c= String.valueOf(respObj.mobile);
            cd.Name= respObj.uniqueCallId;
            cd.Trip_Id__c=respObj.orderId;
            cd.OrderUuid__c = respObj.orderUuid;
            cd.Business_Unit__c=respObj.businessUnit;
            cd.Language__c=respObj.preferredLanguage;
            cd.PredictedOrderUuid__c = respObj.predictedOrderUuid;
            cd.PredictedOrderItemUuid__c = respObj.predictedOrderItemUuid;
            cd.Call_Unique_Id__c = respObj.uniqueCallId;           
            cd.Predicted_Preferred_Language__c=respObj.predicatedPreferredLanguage;
            cd.Predicted_Source__c=respObj.predicatedSource;  
            cd.Remarks__c = respObj.remarks; 
            cd.Predicated_Issue__c = respObj.predicatedIssue; 
            cd.Predicated_SubIssue__c = respObj.predicatedSubIssue; 
            
            if(respObj.isIRchatFlow!=null && Boolean.valueof(respObj.isIRchatFlow)){
               cd.isIRchatFlow__c=Boolean.valueof(respObj.isIRchatFlow);
            }
              
            
            if(respObj.predicatedMenuOption!=null){
              cd.Predicted_Menu_Option__c=string.valueOf(respObj.predicatedMenuOption).replaceAll('[)( ]', '');
             }
            if(respObj.predicatedSubMenuOptions!=null){
              cd.Predicted_SubMenu_Options__c=string.valueOf(respObj.predicatedSubMenuOptions).replaceAll('[)( ]', '');
             }
            if(respObj.predicatedVerticalMenuOptions!=null){
             cd.Predicted_VerticalMenu_Options__c=string.valueOf(respObj.predicatedVerticalMenuOptions).replaceAll('[)( ]', '');
             }
            
            if(String.isNotBlank(respObj.callInitiationTime) && respObj.callInitiationTime!='null')
            {
                if(respObj.callInitiationTime.contains('T'))
                    cd.Customer_Called_Time__c = datetime.valueof(respObj.callInitiationTime.replace('T',' '));
                else
                    cd.Customer_Called_Time__c = datetime.valueof(respObj.callInitiationTime);
            }
           
            upsert cd Call_Details__c.Call_Unique_Id__c;
            
            //Using Lightning Adapter
            if('AmeyoCCAdapterLightning'.equalsIgnoreCase(callCentName) || 'DrishtiAdapterLightning'.equalsIgnoreCase(callCentName))
            {
                if(String.isNotBlank(cd.id) && cd.id!=null)
                   redirectURL = '/lightning/r/Call_Details__c/'+cd.id+'/view';
                  //redirectURL='one/one.app#/alohaRedirect/apex/CallPopUpLtngPage?mobile='+cd.Mobile_Number__c;
                else
                   redirectURL='one/one.app#/alohaRedirect/apex/CallPopUpLtngPage?mobile='+cd.Mobile_Number__c;
            }
            
            //Using Classic Adapter
            else
            {
                redirectURL=redirectURL+cd.Mobile_Number__c;
            }
           
            dbl.Phone_No__c=String.valueOf(respObj.mobile);
            res.statuscode = 200;
            apiResp.statusCode='200';
            apiResp.message='Success';
            apiResp.redirectionURL = redirectURL;
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            res.statuscode = 417;     
            apiResp.statusCode='417';
            apiResp.message='Failed, Error-->'+string.valueOf(e);
            apiResp.redirectionURL = redirectURL;
        }
        if(System.Label.IVR_Logs=='TRUE')
        {
            dbl.Response_Received__c = String.valueOf(apiResp);
            insert dbl;
        }
        
        return apiResp;
    }   
    global class ResponseWrapper{
        public string agentId;
        public string menuOptions;
        public long mobile;
        public Integer phoneCode;
        public string orderId;
        public string orderUuid;
        public string callInitiationTime;
        public string businessUnit;
        public string preferredLanguage;
        public string predictedOrderUuid;
        public string predictedOrderItemUuid;
        public string uniqueCallId;
        public string predicatedDestination;
        public string predicatedSource;
        public List<string> predicatedMenuOption;
        public List<string> predicatedSubMenuOptions;
        public List<string> predicatedVerticalMenuOptions;
        public string predicatedPreferredLanguage;  
        public string remarks; 
        public string predicatedIssue;
        public string predicatedSubIssue;
        public boolean isIRchatFlow;


    }    
    global class Reponse{
        public string statusCode;
        public string message;
        public string redirectionURL;
    } 
}