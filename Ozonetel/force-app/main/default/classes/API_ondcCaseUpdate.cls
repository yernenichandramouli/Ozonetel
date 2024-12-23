/**
* (c) 2024 RedBus
*
* Name           : API_ondcCaseUpdate
* Created Date   : 07 FEB 2024
* Created By     : VR Sudarshan
* Purpose        : Optimized class for syncing the ONDC cases.
* Test Class     : API_ondcCaseUpdateTest 
*
**/
@RestResource(urlMapping='/redBus/v1/ondcCaseUpdate/*')
global without sharing class API_ondcCaseUpdate {
    static string caseNumberToUpdate;
    static string issueShortDescription;
    static string issueResolution;
    static string resolutionActionTriggered;
    static string resolutionRefundAmount;
    static string issueLongDescription;
    static string latestrespondentAction;
    static string latestrespondentActionShrtDescp;
    
    @HttpPost
    global static response doPost(){
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Update ONDC Deatils';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string reqBody = req.requestBody.toString();     
        response resp = new response();
        try{
            dbl.Request_Data__c = String.valueOf(req.requestBody.toString());
            if(string.isNotBlank(reqBody)){ 

                responseWrapper respWrapper = new responseWrapper();
                respWrapper = (responseWrapper)JSON.deserialize(reqBody,responseWrapper.class);
                // Fetching message object...
                Message responseMessage = respWrapper.message;
                // Fetching Issue object...
                Issue issueObject = responseMessage.issue;
                caseNumberToUpdate = String.isNotBlank(issueObject.ID)?issueObject.ID:'';
                // Fetching Resolution object...
                Resolution descriptionObj = issueObject.Resolution;
                issueShortDescription = descriptionObj.short_desc;
                system.debug('::: issueShortDescription '+issueShortDescription);
                issueResolution = descriptionObj.resolution;
                resolutionActionTriggered = descriptionObj.action_triggered;
                resolutionRefundAmount = descriptionObj.refund_amount;
                issueLongDescription = String.isNotBlank(descriptionObj.long_desc)?descriptionObj.long_desc:'No Data';
                system.debug('::: issueLongDescription '+issueLongDescription);
                string commentBody;
                // commentBody = String.isNotBlank(issueLongDescription)?issueLongDescription:issueShortDescription;
                system.debug('::: commentBody '+commentBody);
                // Fetching respondActions List...
                List<RespondentAction> respondActions = New List<RespondentAction>();
                respondActions = issueObject.issue_actions.respondent_actions;
                if(respondActions!=null && respondActions.size()>0){
                    RespondentAction latestAction = New RespondentAction();
                    latestAction = respondActions[respondActions.size()-1];
                    latestrespondentAction = String.isNotBlank(latestAction.respondent_action)?latestAction.respondent_action:'No Response From ONDC.';
                    latestrespondentActionShrtDescp = String.isNotBlank(latestAction.short_desc)?latestAction.short_desc:'No Response From ONDC.';
                }

                if(latestrespondentAction=='RESOLVED'){
                    commentBody = string.isNotBlank(resolutionRefundAmount)?'Case has been '+latestrespondentAction+'\n Resolution Comments: '+issueResolution+'\n Description: '+issueShortDescription+'\n Action : '+resolutionActionTriggered+'\n Refund Amount: '+resolutionRefundAmount:'Case has been '+latestrespondentAction+'\n Resolution Comments: '+issueResolution+'\n Description: '+issueShortDescription+'\n Action : '+resolutionActionTriggered;
                }else{
                    commentBody = 'Case has been '+latestrespondentAction+'\n Description: '+latestrespondentActionShrtDescp;
                }

                system.debug('::: commentBody '+commentBody);
                system.debug('::: latestrespondentAction =  '+latestrespondentAction);
                system.debug('::: latestrespondentActionShrtDescp =  '+latestrespondentActionShrtDescp);

                dbl.Case_Number__c=caseNumberToUpdate;

                if(String.isNotBlank(caseNumberToUpdate)){
                    system.debug('::: caseNumberToUpdate2 '+caseNumberToUpdate);  
                    List<Case> cs =[Select id,Channel_ct__c,status from Case Where CaseNumber=:caseNumberToUpdate];
                    if(!cs.isEmpty()){
                        casecomment caseCommentToInsert = New casecomment();
                        caseCommentToInsert.parentid=cs[0].id;
                        caseCommentToInsert.commentbody = commentBody;
                        Database.saveResult updateResult = Database.insert(caseCommentToInsert,false);
                        if(updateResult!=null){
                            if(updateResult.isSuccess()){
                            res.statuscode = 200;
                            resp.isSuccess = 'true';
                            resp.caseNum = caseNumberToUpdate;
                            resp.error ='';
                            resp.errorDescription ='';
                            cs[0].status = 'Fulfillment revert';
                            update cs[0];
                        }else{
                            res.statuscode = 417;
                            resp.isSuccess = 'false';
                            resp.caseNum = caseNumberToUpdate;
                            resp.error ='Update Has Failed';
                            resp.errorDescription =string.valueof(updateResult.getErrors());
                        }
                        }
                        system.debug('::: caseStatus '+cs[0].status);
                        // To call the cancellation API if the response is cancel
                        if(resolutionActionTriggered=='CANCEL'){
                            Boolean isSoftCancelApplicable = metroIGMCancellationCtrl.invokeCancellationApi(cs[0].id,'SOFT_CANCEL');
                            if(isSoftCancelApplicable){
                                metroIGMCancellationCtrl.invokeCancellationApi(cs[0].id,'CONFIRM_CANCEL');
                            }
                        }
                    }else{
                        res.statuscode = 400;
                        resp.isSuccess = 'false';
                        resp.caseNum = caseNumberToUpdate;
                        resp.error ='Invalid Details..';
                        resp.errorDescription ='Case Number doesnot exist in SF.';
                    }
                }else {
                    res.statuscode = 400;
                    resp.isSuccess = 'false';
                    resp.caseNum = caseNumberToUpdate;
                    resp.error ='Invalid Input Received';
                    resp.errorDescription ='Case Number is Missing/Coming as Blank in Request';
                }

                
            }

        }catch(exception e){
            System.debug(':: error occured '+e.getMessage());
            res.statuscode = 400;
            resp.isSuccess = 'false';
            resp.error ='Unable To Process The Request.';
            resp.errorDescription =string.valueof(e) +e.getLineNumber();
        }
        dbl.Response_Received__c = String.valueOf(resp);
        insert dbl;
        return resp;
    }

    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    // public class Contact
    // {
    //     public string phone { get; set; }
    //     public string email { get; set; }
    // }

    // public class Gro
    // {
    //     public Person person { get; set; }
    //     public Contact contact { get; set; }
    //     public string gro_type { get; set; }
    // }

    public class Issue
    {
        public string id { get; set; }
        public IssueActions issue_actions { get; set; }
        // public ResolutionProvider resolution_provider { get; set; }
        public Resolution resolution { get; set; }
        // public DateTime created_at { get; set; }
        // public DateTime updated_at { get; set; }
    }

    public class IssueActions
    {
        public List<RespondentAction> respondent_actions { get; set; }
    }

    public class Message
    {
        public Issue issue { get; set; }
    }

    // public class Org
    // {
    //     public string name { get; set; }
    // }

    // public class Organization
    // {
    //     public Org org { get; set; }
    //     public Contact contact { get; set; }
    //     public Person person { get; set; }
    // }

    // public class Person
    // {
    //     public string name { get; set; }
    // }

    public class Resolution
    {
        public string resolution { get; set; }
        public string short_desc { get; set; }
        public string long_desc { get; set; }
        public string action_triggered { get; set; }
        public string refund_amount { get; set; }
    }

    // public class ResolutionProvider
    // {
    //     public RespondentInfo respondent_info { get; set; }
    // }

    // public class ResolutionSupport
    // {
    //     public string chat_link { get; set; }
    //     public Contact contact { get; set; }
    //     public List<Gro> gros { get; set; }
    // }

    public class RespondentAction
    {
        public string respondent_action { get; set; }
        public string short_desc { get; set; }
        // public DateTime updated_at { get; set; }
        // public UpdatedBy updated_by { get; set; }
        // public Integer cascaded_level { get; set; }
    }

    // public class RespondentInfo
    // {
    //     public string type { get; set; }
    //     public Organization organization { get; set; }
    //     public ResolutionSupport resolution_support { get; set; }
    // }

    public class Error
    {
        public string type { get; set; }
        public string code { get; set; }
        public string path { get; set; }
        public string message { get; set; }
    }

    public class responseWrapper
    {
        public Message message { get; set; }
        public Error error { get; set; }

    }

    // public class UpdatedBy
    // {
    //     public Org org { get; set; }
    //     public Contact contact { get; set; }
    //     public Person person { get; set; }
    // }

    global class Response
    {
        string caseNum;
        String isSuccess;
        string error;
        String errorDescription;
        public response()
        {


        }
    }


}