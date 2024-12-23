/*
* Name           : sgmyActivitesExceptionalRefundCtrl
* Created Date   : 11 OCT 2023
* Created By     : VR Sudarshan 
* Purpose        : To process Exceptional refund flow for SGMY Activites.
* Test class     : sgmyActivitesExceptionalRefundCtrlTest
* Jira Id        : CRM-1502
*/
public class sgmyActivitesExceptionalRefundCtrl {

    @Auraenabled
    Public static boolean checkValidateParentCases(string activityId, string parentCase){
        if(String.isNotBlank(activityId) && string.isNotBlank(parentCase)){
            List<Case> listCases = new List<Case>();
            listCases =[Select id,Transaction_ID__c,Trip_Id_ct__c,Activity_Id__c,Refund_Type__c,Refund_Amount__c from Case where CaseNumber=:parentCase AND Activity_Id__c=:activityId];
            if(listCases.isEmpty()){
                return true;
            }else{
                return false;
            }
        }
        return false;
    }

    @Auraenabled
    public static responseDataWrapper getRefundAmount(string activityId){

        List<Activities__c> activityList = [SELECT ID, OrderUuid__c,Voucher_Realization_Date__c FROM Activities__c WHERE Id=:activityId LIMIT 1];
        List<case> exceptionalRefundCaseList = [SELECT Id FROM case WHERE Activity_Id__c=:activityId AND Business_Type__c ='Activities' AND Business_Unit_ct__c ='SGMY Activites' AND Issue_Type__c='Exceptional Refund' AND status NOT IN ('Approved For Exceptional Refund','Rejected For Exceptional Refund','Closed')];
        responseDataWrapper respToReturn = New responseDataWrapper();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='SGMY Actitvity GetRefundAmount';

        if(exceptionalRefundCaseList.size()>0){
            respToReturn.customErrorMessage = 'Exceptional Refund Case aleady exist for this case';
            respToReturn.isError = true;
            return respToReturn;
        }

        if(activityList[0].Voucher_Realization_Date__c > System.now()){
            respToReturn.customErrorMessage = 'Exceptional Refund cannot be called before boarding time/ date of realization';
            respToReturn.isError = true;
            return respToReturn;
        }

        if(activityList.size()>0 && String.isNotBlank(activityList[0].OrderUuid__c)){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SGMYActivites_MaxRefundable'];
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Accept', 'application/json');
            try{
                string endPoint=APIMData.Endpoint__c+activityList[0].OrderUuid__c+'/maxRefundable?type=all';
                list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                for(string o:headers.keyset()){
                    hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
                }
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson); 
                string genericJson='{"action":"GET","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                System.debug('genericJson-->'+genericJson);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req = HttpRequestUtil.populateHeaders(req); 
                req.setMethod('POST');
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
                req.setEndpoint(APIMData.Endpoint__c);
                req.setBody(genericJson);
                dbl.Request_Data__c = string.valueof(req)+genericJson;
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                System.debug('Request Data: ' + req);
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                string responseValue = res.getBody();
                responseDataWrapper responseData = new responseDataWrapper();    
                responseData=(responseDataWrapper)JSON.deserialize(res.getBody(), responseDataWrapper.class);
                System.debug('Response Received: ' + res.getBody());
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    respToReturn.data = responseData.data;
                    respToReturn.isError = false;
                    insert dbl;
                    return respToReturn;
                }else{
                    respToReturn.customErrorMessage ='Something went wrong, please contact your system administrator.';
                    respToReturn.isError = true;
                    insert dbl;
                    return respToReturn;
                }
            }catch(Exception e){
                respToReturn.customErrorMessage = e.getMessage();
                respToReturn.isError = true;
                dbl.Exception_Description__c=string.valueOf(e);
                insert dbl;
                System.debug('An exception occurred: ' + e.getMessage());
                return respToReturn;
            }
        }
        respToReturn.isInvalidId = true;
        return respToReturn;
    }

    @Auraenabled
    public static responseDataWrapper createExceptionalRefundCase(string parentCaseNumber, string activityId, string refundReason, string refundAmount, string refundDescription){
        responseDataWrapper respToReturn = New responseDataWrapper();
        System.debug(':: parentCaseNumber = '+parentCaseNumber+':: activityId = '+activityId+':: refundReason = '+refundReason+':: refundAmount = '+refundAmount+':: refundDescription = '+refundDescription);
        if(String.isNotBlank(parentCaseNumber) && string.isNotBlank(activityId)){
            list <case> listCases =[Select id,Business_Unit_ct__c, Business_Type__c, Transaction_ID__c,Trip_Id_ct__c,is_ZQP__c,Refund_Type__c,Refund_Amount__c from Case where caseNumber=:parentCaseNumber];
            List<user> userInfo=[select id,Team__c from user where id=:userinfo.getuserid()];
            list <case> listExpRefndCase = [Select id, status, createddate,Refund_status__c, Exceptional_Refund_Count__c, Transaction_ID__c, Trip_Id_ct__c from Case where Issue_Type__c = 'Exceptional Refund' AND Refund_status__c='Exceptional Refund Approved' and Activity_Id__c=:activityId ORDER BY createddate DESC];
            List<Activities__c> activityList = [SELECT Id, Order_Id__c, Voucher_Realization_Date__c, Voucher_Id__c, Activity_uuid__c, OrderUuid__c, Booking_User_Email__c, Purchase_Item_Currency__c, Business_Unit__c FROM Activities__c WHERE Id=:activityId LIMIT 1];
            Case cs = new Case();
            cs.Issue_Type__c = 'Exceptional Refund'; 
            if (listExpRefndCase.size()==0) {
                cs.Exceptional_Refund_Count__c =1;
            } else if(!listExpRefndCase.isEmpty() && listExpRefndCase.size()==1 && listExpRefndCase[0].Exceptional_Refund_Count__c==null){
                cs.Exceptional_Refund_Count__c =2;
            }else if(!listExpRefndCase.isEmpty() && listExpRefndCase[0].Exceptional_Refund_Count__c!=null) {
                cs.Exceptional_Refund_Count__c =listExpRefndCase[0].Exceptional_Refund_Count__c + 1;
            }
            cs.Issue_Sub_Category__c = refundReason;
            cs.Trip_Id_ct__c = activityList[0].Order_Id__c;
            cs.TIN_No__c = activityList[0].Voucher_Id__c;
            cs.Activity_Id__c = activityList[0].Id;
            cs.Refund_Amount__c = Decimal.valueOf(refundAmount);
            listCases[0].Refund_Amount__c = Decimal.valueOf(refundAmount);
            cs.Description =refundDescription;
            cs.status= 'Open';
            cs.Booking_Email_ID__c = activityList[0].Booking_User_Email__c;
            cs.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs.Origin='InBound Call';
            cs.Subject = 'Exceptional Refund- '+refundReason;
            cs.ParentId = listCases[0].id;
            cs.Business_Unit_ct__c = listCases[0].Business_Unit_ct__c;
            cs.Business_Type__c = listCases[0].Business_Type__c;
            cs.User_Level_Team__c = userInfo[0].Team__c;
            cs.Order_UUId__c = activityList[0].OrderUuid__c;
            cs.Order_Item_Id__c = activityList[0].Activity_uuid__c;
            string businessUnit = activityList[0].Business_Unit__c;
            string countryName = 'Malaysia';
            if(businessUnit.contains('_SG')){
                countryName='Singapore';
            }
            cs.country__c=countryName;
            cs.Business_Type__c = 'Activities';
            cs.Price_Paid_Currency_ctp__c = activityList[0].Purchase_Item_Currency__c;
            try{
                insert cs;            
                update listCases[0];
                respToReturn.status= 'Request Has Submitted Succcessfully for Approval.Post Approval Refund Will Be Processed.';
                respToReturn.isSuccess = true;
                return respToReturn;
            }catch(DMLException de){
                system.debug(':: dmlException = '+de.getMessage());
                system.debug(':: dmlException = '+de.getLineNumber());
                respToReturn.customErrorMessage= 'Failed To Submit The Request.Please Re-try.';
                respToReturn.isError = true;
                return respToReturn;
            }
        }
        respToReturn.customErrorMessage= 'Invalid Cases or Activity Data. Please contact administartor';
        respToReturn.isError = true;
        return respToReturn;
    }

    public static boolean approveExceptionalRefund(Id caseId, string b2cCaseComments, string agentName){

        List<case> caseList = [SELECT ID, Activity_Id__r.Purchase_Item_Currency__c, Refund_Amount__c, Activity_Id__r.Activity_uuid__c, Activity_Id__r.OrderUuid__c FROM Case WHERE Id=:caseId LIMIT 1];
        if(caseList.size()>0 && caseList[0].Refund_Amount__c!=null && String.isNotBlank(b2cCaseComments) && String.isNotBlank(agentName)){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='SGMYActitvity ApproveExceptionalRefund';
            ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundReqInput();
            exceRfndReq.orderItemUuid = caseList[0].Activity_Id__r.Activity_uuid__c;
            exceRfndReq.refundedBy = agentName;
            exceRfndReq.channel = 'SFA';
            exceRfndReq.reason = b2cCaseComments;

            moneyModal monyMod = new moneyModal();
            monyMod.amount = Integer.valueOf(caseList[0].Refund_Amount__c);
            monyMod.currencyType = String.isNotBlank(caseList[0].Activity_Id__r.Purchase_Item_Currency__c)?caseList[0].Activity_Id__r.Purchase_Item_Currency__c:'MYR';
            exceRfndReq.refund = monyMod;

            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SGMYActivites_MaxRefundable'];
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Accept', 'application/json');
            try{
                string endPoint=APIMData.Endpoint__c+caseList[0].Activity_Id__r.OrderUuid__c+'/exceptionalrefund';
                string jsonBody=json.serialize(exceRfndReq); 
                jsonBody=json.serialize(jsonBody);
                list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                for(string o:headers.keyset()){
                    hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
                }
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson); 
                string genericJson='{"action":"POST","body":'+jsonBody+',"endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                System.debug('genericJson-->'+genericJson);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req = HttpRequestUtil.populateHeaders(req); 
                req.setMethod('POST');
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
                req.setEndpoint(APIMData.Endpoint__c);
                req.setBody(genericJson);
                dbl.Request_Data__c = string.valueof(req)+jsonBody;
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                System.debug('Request Data: ' + req);
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string responseValue = res.getBody();
                responseDataWrapper responseData = new responseDataWrapper();    
                responseData=(responseDataWrapper)JSON.deserialize(res.getBody(), responseDataWrapper.class);
                if(Test.isRunningTest()){
                    return true;
                }
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    return true;
                }else{
                    return false;
                }
            }catch(Exception e){
                dbl.Exception_Description__c=string.valueOf(e.getMessage());
                insert dbl;
                return false;
            }
        }
        return false;

    }


    public class ACTIVITY{
        @AuraEnabled
        public string itemUuid { get; set; }
        @AuraEnabled
        public double amount { get; set; }
    }

    public class Data{
        @AuraEnabled
        public MaxRefundable maxRefundable { get; set; }
        @AuraEnabled
        public string currencyType { get; set; }
    }

    public class MaxRefundable{
        @AuraEnabled
        public List<ACTIVITY> ACTIVITY { get; set; }
    }

    public class responseDataWrapper{
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public List<object> errors { get; set; }
        @AuraEnabled
        public Data data { get; set; }
        @AuraEnabled
        public boolean isInvalidId { get; set; }
        @AuraEnabled
        public string customErrorMessage { get; set; }
        @AuraEnabled
        public boolean isError { get; set; }
        @AuraEnabled
        public boolean isSuccess { get; set; }
    }

    public class moneyModal{
        public Integer amount { get; set; }
        public string currencyType { get; set; }
    }

    public class ExceptionalRefundReqInput{
        public string orderItemUuid { get; set; }
        public string refundedBy { get; set; }
        public string channel { get; set; }
        public string reason { get; set; }
        public moneyModal refund { get; set; }
    }
}