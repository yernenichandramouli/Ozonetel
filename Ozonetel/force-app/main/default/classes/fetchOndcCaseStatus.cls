/**
 * (c) 2024 RedBus
 *
 * Name           : fetchOndcCaseStatus
 * Created Date   : 05 JUL 2024
 * Created By     : VR Sudarshan
 * Purpose        : To fetch the case status from ONDC
 * JiraId         : CRM - 1853
 * Test class     : fetchOndcCaseStatusTest
 *
 **/
public with sharing class fetchOndcCaseStatus {

    @Auraenabled(cacheable=false)
    public static wrapperToReturn fetchCaseStatus(string caseId){
        wrapperToReturn retrunWrap = New wrapperToReturn();
        List<case> caseList =[SELECT Id, CaseNumber, Activity_Id__r.OrderUuid__c FROM Case WHERE Id =: caseId LIMIT 1];
        if(!caseList.isEmpty()){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'Fetch ONDC Case status';
            try{
                requestWrapperToSend reqWrapper = New requestWrapperToSend();
                reqWrapper.issueId = caseList[0].CaseNumber;
                reqWrapper.orderId = caseList[0].Activity_Id__r.OrderUuid__c;

                system.debug('::: Request to Send = '+json.serialize(reqWrapper));

                Http h= new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setTimeout(120000);
                req.setHeader('Content-Type', 'application/json');
                string endPointData = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Ondc_Create_Case_Issue_status'].Endpoint__c;     
                req.setEndpoint(endPointData);
                req.setMethod('POST');
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
                wrappedResponse= (responseWrapper)JSON.deserialize(responseValue,responseWrapper.class);
                List<CaseComment> caseCommentToInsert = New List<CaseComment>();
                casecomment ccm = New casecomment();
                ccm.parentId=caseList[0].Id;
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    if(wrappedResponse.status=='SUCCESS'){
                        retrunWrap.isSuccess = true;
                        retrunWrap.successMsgToShw = 'Request has been made to Ondc to check the case status.';
                        ccm.commentBody = 'Request has been made to Ondc to check the case status.';
                        caseCommentToInsert.add(ccm);
                    }else{
                        retrunWrap.isError = true;
                        retrunWrap.errorMsgToShw = string.valueOf(wrappedResponse.Error);
                        ccm.commentBody = string.valueOf(wrappedResponse.Error);
                        caseCommentToInsert.add(ccm);
                    }
                }
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

    public class requestWrapperToSend
    {
        @AuraEnabled
        public string issueId { get; set; }
        @AuraEnabled
        public string orderId { get; set; }
    }

    // Response Wrapper
    public class responseWrapper
    {
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public string Error { get; set; }
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