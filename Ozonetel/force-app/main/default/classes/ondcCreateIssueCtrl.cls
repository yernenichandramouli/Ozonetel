/**
 * (c) 2024 RedBus
 *
 * Name           : ondcCreateIssueCtrl
 * Created Date   : 05 JUL 2024
 * Created By     : VR Sudarshan
 * Purpose        : Controller to Create/Escalate case to ONDC.
 * JiraId         : CRM - 1853
 * Test class     : ondcCreateIssueCtrlTest
 *
 **/
public with sharing class ondcCreateIssueCtrl {
    
    @Auraenabled(cacheable=false)
    public static wrapperToReturn createOndcCase(string caseId, boolean isEscalated){
        wrapperToReturn retrunWrap = New wrapperToReturn();
        List<case> caseList =[SELECT Id, ownerId, CaseNumber, Issue_Type__c, createdDate, Ondc_Complaint_Actions__c, Description, LastModifiedDate, Issue_Sub_Category__c, Status,Activity_Id__r.Name, Activity_Id__r.Activity_uuid__c, Activity_Id__r.City_Id__c, Activity_Id__r.Booking_user_Name__c, Activity_Id__r.Sub_Order_Items__c, Activity_Id__r.Service_Provider_Id__c, Activity_Id__r.Fulfillment_List__c,Activity_Id__r.Booking_User_Mobile__c, Activity_Id__r.Booking_User_Email__c, Activity_Id__r.OrderUuid__c, Activity_Id__r.Transaction_Status__c, Activity_Id__r.Additional_Details__c, Activity_Id__r.Activity_Title__c ,Activity_Id__r.Sub_Items_Count__c FROM Case WHERE Id =: caseId LIMIT 1];
        
        if(!caseList.isEmpty()){
            List<ONDC_Enum__mdt> ondcEnumList = [SELECT Enum_Value__c FROM ONDC_Enum__mdt WHERE Issue_Type__c =:caseList[0].Issue_Type__c AND Category__c='FULFILLMENT' LIMIT 1];
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'Create ONDC Case';
            try{
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(caseList[0].Activity_Id__r.Additional_Details__c);
                List<string> qrList = New List<String>();
                // Fetch qrList
                if(jsonData.containsKey('QRStatusList')){
                    // Retrieve the QRStatusList array from the deserialized JSON
                    List<Object> qrStatusList = (List<Object>)jsonData.get('QRStatusList');
                    for (Object qrStatus : qrStatusList) {
                        qrList.add((String)qrStatus);
                    }
                }
                // Create fulfillmentList
                List<Fulfillment> fullFillmentList = New List<Fulfillment>();
                String fulfillmentField = String.valueOf(caseList[0].Activity_Id__r.Fulfillment_List__c);
                fulfillmentField = fulfillmentField.substring(1, fulfillmentField.length() - 1); // To Remove parentheses
                List<String> fullFillmentIds = new List<String>();
                List<String> elements = fulfillmentField.split(',\\s*');
                for (String element : elements) {
                    fullFillmentIds.add(element.trim());
                }
                System.debug('Fullfillment IDs: ' + fullFillmentIds);
                for (Integer i = 0; i < fullFillmentIds.size(); i++) {
                    Fulfillment fullFillmentWrap = New Fulfillment();
                    fullFillmentWrap.id = fullFillmentIds[i];
                    fullFillmentWrap.state = qrList[i];
                    fullFillmentList.add(fullFillmentWrap);
                }

                //Description Obj Wrapper
                Description descriptionObjWrap = New Description();
                descriptionObjWrap.long_desc = String.isNotBlank(caseList[0].Issue_Type__c)?caseList[0].Issue_Type__c:'';
                descriptionObjWrap.short_desc = String.isNotBlank(caseList[0].Issue_Sub_Category__c)?caseList[0].Issue_Sub_Category__c:'';

                List<ComplainantAction> complaintActionList = New List<ComplainantAction>();
                //Check for existing Complaint Actions
                if(String.isNotBlank(caseList[0].Ondc_Complaint_Actions__c)){
                    string prevOndcActions = caseList[0].Ondc_Complaint_Actions__c.replace(']+[', ',');
                    system.debug('::: prevOndcActions = '+prevOndcActions);
                    complaintActionList = (list<ComplainantAction>)JSON.deserialize(prevOndcActions,List<ComplainantAction>.class);
                    system.debug('::: listAddonsObj = '+complaintActionList);
                }
                // Wrap to the existing complaintActionList
                ComplainantAction cmpAction = New ComplainantAction();
                if(string.isNotBlank(caseList[0].Status) && caseList[0].Status =='Closed'){
                    cmpAction.complainant_action = 'CLOSE';
                }else{
                    cmpAction.complainant_action = 'OPEN';
                }

                if(isEscalated){
                    cmpAction.complainant_action = 'ESCALATE';
                }
                cmpAction.short_desc = caseList[0].issue_type__c;
                cmpAction.updated_at = System.now();
                cmpAction.email = 'ondctest@gmail.com';
                cmpAction.phone = '9999999999';
                cmpAction.name = 'Test User';
                complaintActionList.add(cmpAction);

                // Item wrapper.
                List<Item> finalItemListWrap = New List<Item>();
                Item itemWrapped = New Item();
                itemWrapped.id = caseList[0].Activity_Id__r.Activity_Title__c;
                itemWrapped.quantity = Integer.valueOf(caseList[0].Activity_Id__r.Sub_Items_Count__c);
                finalItemListWrap.add(itemWrapped);

                TicketDetails ticketDetailsWrapper = New TicketDetails();
                ticketDetailsWrapper.fulfillments = fullFillmentList;
                ticketDetailsWrapper.items = finalItemListWrap;
                ticketDetailsWrapper.orderStatus = caseList[0].Activity_Id__r.Transaction_Status__c;
                ticketDetailsWrapper.orderUuid = caseList[0].Activity_Id__r.OrderUuid__c;
                ticketDetailsWrapper.provider_id = caseList[0].Activity_Id__r.Service_Provider_Id__c;

                // Final Request wrapper to send
                requestWrapperToSend reqWrapper = New requestWrapperToSend();
                reqWrapper.category = 'FULFILLMENT'; // For now we have only Fulfillment.
                reqWrapper.sub_category = ondcEnumList[0].Enum_Value__c;
                reqWrapper.complainant_email = String.isNotBlank(caseList[0].Activity_Id__r.Booking_User_Email__c)?caseList[0].Activity_Id__r.Booking_User_Email__c:'';
                reqWrapper.complainant_name = String.isNotBlank(caseList[0].Activity_Id__r.Booking_user_Name__c)?caseList[0].Activity_Id__r.Booking_user_Name__c:'';
                reqWrapper.complainant_phone = String.isNotBlank(caseList[0].Activity_Id__r.Booking_User_Mobile__c)?caseList[0].Activity_Id__r.Booking_User_Mobile__c:'';
                reqWrapper.issue_status = caseList[0].Status =='Closed'?'CLOSED':'OPEN';
                if(isEscalated){
                    reqWrapper.issue_type = 'GRIEVANCE';
                }else{
                    reqWrapper.issue_type = 'ISSUE';
                }
                reqWrapper.id =caseList[0].CaseNumber;
                reqWrapper.description = descriptionObjWrap;
                reqWrapper.complainant_actions = complaintActionList;
                reqWrapper.ticketDetails = ticketDetailsWrapper;
                ///
                string jsonReqWrapper = json.serialize(reqWrapper);
                system.debug('::: Request to Send = '+jsonReqWrapper);
                // Complaint Actions Start
                Map<String, Object> respDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonReqWrapper);
                List<Object> complainant_Actions = (List<Object>) respDataMap.get('complainant_actions');
                system.debug('complainant_actions ::: '+complainant_Actions);
                // Complaint Actions End
                // Make an HTTP callout
                Http h= new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setTimeout(120000);
                req.setHeader('Content-Type', 'application/json');
                string endPointData;
                endPointData  =[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Ondc_Create_Case_Issue'].Endpoint__c;
                req.setEndpoint(endPointData);
                req.setMethod('POST');
                system.debug('reqWrapper ::: '+json.serialize(reqWrapper));
                req.setBody(json.serialize(reqWrapper));
                dbl.Request_Data__c = string.valueof(req)+'..'+json.serialize(reqWrapper);
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                res=h.send(req);
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                system.debug('res==>>'+res.getbody());
                dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                dbl.Case_Number__c = caseList[0].CaseNumber;
                string responseValue = res.getBody();
                responseWrapper wrappedResponse = new responseWrapper();
                List<CaseComment> caseCommentToInsert = New List<CaseComment>();
                casecomment ccm = New casecomment();
                ccm.parentId=caseList[0].Id;

                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    wrappedResponse= (responseWrapper)JSON.deserialize(responseValue,responseWrapper.class);
                    if(wrappedResponse.status=='SUCCESS'){
                        retrunWrap.isSuccess = true;
                        retrunWrap.successMsgToShw = !isEscalated?'A case has been reported with ONDC.':'The case has been escalated to ONDC.';
                        ccm.commentBody = !isEscalated?'A case has been reported with ONDC.':'The case has been escalated to ONDC.';
                        caseCommentToInsert.add(ccm);
                        caseList[0].ownerId = [Select id from Group where type='Queue' AND developername='ONDC_Suppport'].id;
                        if(isEscalated){
                            caseList[0].status='Escalated';
                        }else{
                            caseList[0].status='Awaiting Customer Response';
                        }
                    }else{
                        retrunWrap.isError = true;
                        retrunWrap.errorMsgToShw = string.valueOf(wrappedResponse.error);
                        ccm.commentBody = string.valueOf(wrappedResponse.error);
                        caseCommentToInsert.add(ccm);
                    }
                }else{
                    retrunWrap.isError = true;
                    retrunWrap.errorMsgToShw = 'The API has failed. Please contact Redbus ONDC.';
                }
                System.debug('cmpList: ' + complaintActionList);
                String jsonString = JSON.serialize(complainant_Actions);
                System.debug('jsonString: ' + jsonString);

                if(String.isNotBlank(caseList[0].Ondc_Complaint_Actions__c) && caseList[0].Ondc_Complaint_Actions__c!=null){
                    caseList[0].Ondc_Complaint_Actions__c += '+' +jsonString;
                }else{
                    caseList[0].Ondc_Complaint_Actions__c = jsonString;
                }
                update caseList[0];

                if(!caseCommentToInsert.isEmpty()){
                    insert caseCommentToInsert;
                }
                insert dbl;
                return retrunWrap;
            }catch (Exception e){
                dbl.Exception_Description__c=string.valueOf(e)+e.getLineNumber();
                system.debug('::: Exception Occured = ' +e.getMessage()+' at Line no '+e.getLineNumber());
                insert dbl;
                retrunWrap.isError = true;
                retrunWrap.errorMsgToShw = string.valueOf(e)+e.getLineNumber();
                return retrunWrap;
            }
        }
        retrunWrap.isError = true;
        retrunWrap.errorMsgToShw = 'Invalid transaction. Please select the correct transaction.';
        return retrunWrap;
    }

    // Wrapper Class
    public class ComplainantAction
    {
        @AuraEnabled
        public string complainant_action { get; set; }
        @AuraEnabled
        public string short_desc { get; set; }
        @AuraEnabled
        public DateTime updated_at { get; set; }
        @AuraEnabled
        public string email { get; set; }
        @AuraEnabled
        public string phone { get; set; }
        @AuraEnabled
        public string name { get; set; }
    }

    public class Description
    {
        @AuraEnabled
        public string long_desc { get; set; }
        @AuraEnabled
        public string short_desc { get; set; }
    }

    public class Fulfillment
    {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public string state { get; set; }
    }

    public class Item
    {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public Integer quantity { get; set; }
    }

    public class requestWrapperToSend
    {
        @AuraEnabled
        public string category { get; set; }
        @AuraEnabled
        public string sub_category { get; set; }
        @AuraEnabled
        public string complainant_email { get; set; }
        @AuraEnabled
        public string complainant_name { get; set; }
        @AuraEnabled
        public string complainant_phone { get; set; }
        @AuraEnabled
        public string issue_status { get; set; }
        @AuraEnabled
        public string issue_type { get; set; }
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public Description description { get; set; }
        @AuraEnabled
        public List<ComplainantAction> complainant_actions { get; set; }
        @AuraEnabled
        public TicketDetails ticketDetails { get; set; }
    }

    public class TicketDetails
    {
        @AuraEnabled
        public List<Fulfillment> fulfillments { get; set; }
        @AuraEnabled
        public List<Item> items { get; set; }
        @AuraEnabled
        public string orderStatus { get; set; }
        @AuraEnabled
        public string orderUuid { get; set; }
        @AuraEnabled
        public string provider_id { get; set; }
    }



    public class responseWrapper
    {
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public String Error { get; set; }
    }

    public class wrapperToReturn
    {
        @AuraEnabled
        public Boolean isError { get; set; }
        @AuraEnabled
        public Boolean isSuccess { get; set; }
        @AuraEnabled
        public String errorMsgToShw { get; set; }
        @AuraEnabled
        public String successMsgToShw { get; set; }
    }
}