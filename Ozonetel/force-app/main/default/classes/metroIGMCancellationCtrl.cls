/**
 * (c) 2023 RedBus
 *
 * Name           : metroIGMCancellationCtrl
 * Created Date   : 30 JUN 2024
 * Created By     : VR Sudarshan
 * Purpose        : Controller to handle cancellation and to fetch cancellation status for Metro IGM
 * JiraId         : CRM - 1821
 * Test class     : metroIGMCancellationCtrlTest
 *
 **/
public class metroIGMCancellationCtrl {

    // Method to initiate cancellation request at ONDC end.
    @Auraenabled(cacheable=false)
    public static Boolean invokeCancellationApi(String caseId, string cancellationType){
        Boolean isSuccess = false;
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        List<case> caseList = [SELECT Id, Activity_Id__r.OrderUuid__c, Activity_Id__r.Service_Provider_Name__c FROM Case WHERE Id =:caseId  AND Activity_Id__c!=Null AND RecordType.Name ='ONDC Metro' LIMIT 1];
        if(!caseList.isEmpty() && String.isNotBlank(caseList[0].Activity_Id__r.OrderUuid__c)){
            dbl.type__c ='IGM - Metro Cancellation';
            string cancellationReasonId = (String.isNotBlank(caseList[0].Activity_Id__r.Service_Provider_Name__c) && caseList[0].Activity_Id__r.Service_Provider_Name__c=='Chennai Metro Rail Limited')?'0':'';
            string jsonCM='{"cancellationType": "'+cancellationType+'","cancellationReason":"SFA","neonOrderId":"'+caseList[0].Activity_Id__r.OrderUuid__c+'","cancellationReasonId":"'+cancellationReasonId+'"}';
            System.debug('jsonCM-->'+jsonCM);
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Channel_Name','MOBILEAPP');
                req.setHeader('AuthToken','ce02aaf7-185e-4b9c-8d0a-15328d86279c,bf82f8d6-9e6b-440d-a2b6-6023b7fb178d,883b8f41-3cad-46c3-81a9-981fda5db115,58d58045-cda6-4c7f-91ec-93650268438b');
                req.setHeader('Content-Type','application/json');
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IGM_Metro_Cancellation'].Endpoint__c);
                req.setBody(jsonCM);
                res = http.send(req);
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'-Headers-AuthToken--'+req.getHeader('AuthToken')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                string responseValue=res.getBody();
                System.debug('res body--->'+res.getBody());
                cancellationResponse responseWrapper = New cancellationResponse();
                responseWrapper = (cancellationResponse)JSON.deserialize(responseValue, cancellationResponse.class);
                System.debug('::: responseWrapper = '+responseWrapper);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    isSuccess = true;
                    // cancellationResponse responseWrapper = New cancellationResponse();
                    // responseWrapper = (cancellationResponse)JSON.deserialize(responseValue, cancellationResponse.class);
                    string caseCommentToInsert = 'The ticket from '+responseWrapper.sourceStation+' to '+responseWrapper.destinationStation+' for '+responseWrapper.ticketQuantity+' person was cancelled by '+responseWrapper.cancelledBy+' at '+responseWrapper.cancellationTime+' with a total refundable amount of '+responseWrapper.cancelPrice.totalRefundableAmount+'.';
                    CaseComment parCaseCom = new CaseComment();
                    parCaseCom.ParentId = caseList[0].id;
                    parCaseCom.commentBody =caseCommentToInsert;
                    insert parCaseCom;
                }
                if(responseWrapper.error!= null){
                    System.debug('::: responseWrapper = '+responseWrapper.error);
                    CaseComment parCaseCom = new CaseComment();
                    parCaseCom.ParentId = caseList[0].id;
                    parCaseCom.commentBody =responseWrapper.error;
                    insert parCaseCom;
                }
                insert dbl;
                return isSuccess;
            }catch(Exception e){
                dbl.Exception_Description__c=string.valueOf(e);
                insert dbl;
                System.debug('An exception occurred: ' + e.getMessage());
                return isSuccess;
            }
        }
        return isSuccess;
    }

    // Method to fetch the cancellation status.
    @Auraenabled(cacheable=false)
    public static string fetchCancellationStatus(String caseId){
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        List<case> caseList = [SELECT Id, Activity_Id__r.OrderUuid__c FROM Case WHERE Id =:caseId  AND Activity_Id__c!=Null AND RecordType.Name ='ONDC Metro' LIMIT 1];
        if(!caseList.isEmpty() && String.isNotBlank(caseList[0].Activity_Id__r.OrderUuid__c)){
            dbl.type__c ='IGM - Metro Cancellation';
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();    
                req.setHeader('Content-Type','application/json');
                req.setMethod('GET');
                req.setTimeout(120000);
                // req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IGM_Metro_Cancellation'].Endpoint__c);
                API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='IGM_Fetch_ONDC_Cancellation_Status'];
                string endpoint=APIMData.Endpoint__c+caseList[0].Activity_Id__r.OrderUuid__c;
                // string endpoint = 'localhost:8085/igm/refund_status/4e5eac03135de0063597d7ad02011100';
                req.setEndpoint(endpoint);
                res = http.send(req);
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string responseValue=res.getBody();
                System.debug('res body--->'+res.getBody());
                fetchCancelResponse responseWrapper = New fetchCancelResponse();
                responseWrapper = (fetchCancelResponse)JSON.deserialize(responseValue, fetchCancelResponse.class);
                System.debug('::: responseWrapper = '+responseWrapper);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    responseWrapper.isSuccess = true;
                    return responseWrapper.refundDetails.refundStatus;
                }
                return responseValue;
            }catch(Exception e){
                dbl.Exception_Description__c=string.valueOf(e);
                insert dbl;
                System.debug('An exception occurred: ' + e.getMessage());
                return String.valueOf(e.getMessage());
            }
        }
        return 'Invalid Transaction';
    }

    public class CancelPrice
    {
        @AuraEnabled
        public Integer totalRefundableAmount { get; set; }
        @AuraEnabled
        public Integer totalOriginalAmount { get; set; }
        @AuraEnabled
        public Integer totalCancellationAmount { get; set; }
    }

    public class cancellationResponse
    {
        @AuraEnabled
        public string sourceStation { get; set; }
        @AuraEnabled
        public string destinationStation { get; set; }
        @AuraEnabled
        public Integer ticketQuantity { get; set; }
        @AuraEnabled
        public string cancellationStatus { get; set; }
        @AuraEnabled
        public CancelPrice cancelPrice { get; set; }
        @AuraEnabled
        public DateTime cancellationTime { get; set; }
        @AuraEnabled
        public string cancelledBy { get; set; }
        @AuraEnabled
        public string description { get; set; }
        @AuraEnabled
        public string error { get; set; }
    }

    // Fetch Cancellation wrapper class
    // public class Item
    // {
    //     @AuraEnabled
    //     public string itemType { get; set; }
    //     @AuraEnabled
    //     public Integer totalFare { get; set; }
    //     @AuraEnabled
    //     public Integer refundAmount { get; set; }
    //     @AuraEnabled
    //     public Integer totalPaid { get; set; }
    //     @AuraEnabled
    //     public List<RefundBreakUp> refundBreakUp { get; set; }
    //     @AuraEnabled
    //     public List<object> cancelPolicy { get; set; }
    // }

    // public class RefundBreakUp
    // {
    //     @AuraEnabled
    //     public string displayName { get; set; }
    //     @AuraEnabled
    //     public Integer amount { get; set; }
    //     @AuraEnabled
    //     public Integer refundAmount { get; set; }
    //     @AuraEnabled
    //     public Integer nonRefundAmount { get; set; }
    // }

    public class RefundDetails
    {
        // @AuraEnabled
        // public Integer refundAmount { get; set; }
        // @AuraEnabled
        // public object expectedTAT { get; set; }
        // @AuraEnabled
        // public object actualTAT { get; set; }
        // @AuraEnabled
        // public object refundMode { get; set; }
        @AuraEnabled
        public string refundStatus { get; set; }
        // @AuraEnabled
        // public object creditedTime { get; set; }
    }

    public class fetchCancelResponse
    {
        // @AuraEnabled
        // public Integer totalFare { get; set; }
        // @AuraEnabled
        // public Integer refundAmount { get; set; }
        // @AuraEnabled
        // public Integer totalPaid { get; set; }
        // @AuraEnabled
        // public string currencyType { get; set; }
        // @AuraEnabled
        // public string sourceLocation { get; set; }
        // @AuraEnabled
        // public string destinationLocation { get; set; }
        // @AuraEnabled
        // public Integer noOfSeatsBooked { get; set; }
        // @AuraEnabled
        // public string tin { get; set; }
        // @AuraEnabled
        // public string orderItemUuid { get; set; }
        // @AuraEnabled
        // public List<Item> items { get; set; }
        @AuraEnabled
        public RefundDetails refundDetails { get; set; }
        @AuraEnabled
        public boolean isError { get; set; }
        @AuraEnabled
        public boolean isSuccess { get; set; }
    }

}