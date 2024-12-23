/**
 * (c) 2022 RedBus
 *
 * Name           : BusServiceAgeingRefundBatch
 * Created Date   : 10 OCT 2022
 * Created By     : VR Sudarshan
 * Purpose        : Batch class to process the Bus Service cases Under Collectible from BO Refund
 * Test class     : BusServiceAgeingRefundBatchSchedulerTest
 *
 **/
global class BusServiceAgeingRefundBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;
    public List<String> issueTypeToCheck;
    public List<String> subIssueTypeToCheck;
    public Set<String> setRTCOpIds;
    public Map<String,Issue_Based_TAT__mdt> mapIssueBasedAmount;
    
    public BusServiceAgeingRefundBatch(String strQuery) {
        issueTypeToCheck = new list<String>();
        issueTypeToCheck.addAll(System.Label.BusService_Ageing_Refund_Issue_Types.Split(','));
        subIssueTypeToCheck = new list<String>();
        subIssueTypeToCheck.addAll(System.Label.BusService_Ageing_Refund_Sub_IssueTypes.Split(';'));
        setRTCOpIds = new Set<String>();
        setRTCOpIds.addAll(System.Label.RTC_BO_IDS.Split(','));

        mapIssueBasedAmount = new Map<string,Issue_Based_TAT__mdt>();
        for(Issue_Based_TAT__mdt issueTAT : [SELECT DeveloperName, Issue_Type__c, Issue_Sub_Category__c, Bus_Service_Ageing_Refund_Amount__c FROM Issue_Based_TAT__mdt WHERE Version__c='V3' And Bus_Service_Ageing_Refund_Amount__c != Null AND Issue_Type__c IN :issueTypeToCheck AND Issue_Sub_Category__c IN :subIssueTypeToCheck]){
            System.debug('::: issueTAT :::: '+issueTAT );
            mapIssueBasedAmount.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
        }

        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusServiceAgeingRefundQuery'].QueryDetails__c+' AND Issue_Type__c IN :issueTypeToCheck AND Issue_Sub_Category__c IN :subIssueTypeToCheck AND Service_Provider_Id__c NOT IN :setRTCOpIds';
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        system.debug(':: mapIssueBasedAmount :: '+mapIssueBasedAmount);
        List<CaseComment> caseCommentList = new List<CaseComment>();
        List<String> fullRefundOwnerEmail = New List<String>();
        List<String> PartialRefundOwnerEmail = New List<String>();
        List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();
        List<case> listCase = new List<case>();
        List<Cancellation_Process_DB_Log__c> listCp = new List<Cancellation_Process_DB_Log__c>();
        Set<Id> setCaseIdsToProcess = new Set<Id>();
        
        if(!lstcases.isEmpty()){
            for(Case csObj : lstcases){
                boolean isPreStatus=false;
                String allPreviousStatus=String.isNotBlank(csObj.All_Previous_Status_Dates__c)?csObj.All_Previous_Status_Dates__c:'';
                List<String> values = allPreviousStatus.split(';');
                for(String value:values){
                    if(value.Contains('Re-Open') || value.Contains('Closed')){  
                        isPreStatus=true;
                    }
                }
                String strIssueSubIssue = csObj.Issue_Type__c+csObj.Issue_Sub_Category__c;
                if(mapIssueBasedAmount.containsKey(strIssueSubIssue) && isPreStatus == false){
                    setCaseIdsToProcess.add(csObj.Id);
                    ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
                    exceRfndReq.ticketNo = csObj.TIN_No__c;
                    exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)?csObj.Booking_EMail_Copy__c:'';
                    exceRfndReq.mobileno = string.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'';
                    exceRfndReq.cancellationType = '1'; 
                    exceRfndReq.selectedSeat='';
                    exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
                    exceRfndReq.orderItemUuid = csObj.OrderItem_Uuid__c;
                    exceRfndReq.reason = 'Bus Service Ageing Exceptional Refund';
                    if(mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c == 1.00){
                        string fullRefundAmount = getExceptionalRefundAmount(string.valueOf(csObj.Transaction_ID__c));
                        system.debug('::: Converted Decimal Value ::: ' +Double.valueOf(fullRefundAmount));
                        exceRfndReq.operatorContribution = fullRefundAmount!=null?Double.valueOf(fullRefundAmount)*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c:0.00;
                    }else{
                        exceRfndReq.operatorContribution = csObj.Total_Fare_Value__c!=null?csObj.Total_Fare_Value__c*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c:0.00;
                    }
                    exceRfndReq.isExceptionalCancellation = true;
                    exceRfndReq.createdby = 'SF Auto Refund Scheduler';

                    ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
                    monyMod.amount = exceRfndReq.operatorContribution;
                    monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)?csObj.Price_Paid_Currency_ctp__c:'INR';
                    exceRfndReq.refund = monyMod;

                    system.debug(':::::: BODY ::::::'+Json.serialize(exceRfndReq));
                    HttpRequest req = new HttpRequest();
                    req = HttpRequestUtil.populateCAPIHeaders(req);
                    req.setTimeout(120000);
                    req.setMethod('POST');
                    req.setBody(Json.serialize(exceRfndReq));
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);

                    Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
                    cp.Transaction_Name__c = csObj.Transaction_ID__c;
                    cp.FC_API_Request_Data__c = string.valueof(req)+'Body :'+Json.serialize(exceRfndReq)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency :INR';
                    cp.Refund_Reason__c = 'Refund by service ageing scheduler';
                    cp.Amount_to_be_Refunded__c = exceRfndReq.refund.amount;
                    cp.TIN_Number__c = exceRfndReq.ticketNo;
                    cp.OrderItemUuid__c =exceRfndReq.orderItemUuid;

                    try{
                        res = http.send(req);
                        string responseValue = res.getBody();
                        cp.FC_API_Ping__c = true;
                        system.debug(':::::: responseValue ::::::'+res+ '::: statusCode ::: '+res.getStatusCode()+ '::: responseBody ::: '+res.getBody());
                        if(res.getStatusCode()==200 && string.isNotBlank(responseValue)){
                            ExceptionalRefundApprovalCntl.ExceptionalCanResponse exceRespone = new ExceptionalRefundApprovalCntl.ExceptionalCanResponse();
                            exceRespone = (ExceptionalRefundApprovalCntl.ExceptionalCanResponse)JSON.deserialize(responseValue,ExceptionalRefundApprovalCntl.ExceptionalCanResponse.class);
                            cp.FC_IsSuccess__c = 'SUCCESS'.equalsIgnoreCase(String.valueof(exceRespone.Status))?true:false;
                            cp.FC_Response_Message__c = cp.FC_IsSuccess__c?'Refund has Initiated Successfully.':String.valueof(exceRespone.Status);
                            cp.FC_API_Request_Response__c = string.valueof(exceRespone)+' Body : '+responseValue;
                            System.debug('::: exceRespone ::: ' +exceRespone+ '::: exceRespone.data :::: '+exceRespone.data);
                            
                            if(exceRespone!=null && exceRespone.data!=null){
                                cp.FC_New_Tin__c = string.valueof(exceRespone.data.get('OrderItemUuid'));
                                cp.FC_Refund_Amount__c = cp.Amount_to_be_Refunded__c;
                            }

                            if(cp.FC_IsSuccess__c){
                                csObj.Ageing_Refund_Status__c='Success';
                                csObj.Status ='Closed';
                                csObj.Refund_Reason__c = 'Refund by service ageing scheduler';
                                csObj.Refund_Amount__c = cp.Amount_to_be_Refunded__c;
                                CaseComment csComment = new CaseComment();
                                csComment.ParentId = csObj.id;
                                csComment.commentBody = 'Closed with refund of '+exceRfndReq.refund.amount+' due to service case ageing process';
                                caseCommentList.add(csComment);
                                CaseComment csComm = new CaseComment();
                                String STCcomment;
                                if(mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c == 1){
                                    STCcomment ='(STC) Dear Customer, We are glad to share that refund has been initiated from our end to your source account. As per the standard banking procedure the amount will be refunded within 5 to 7 bank working days in the name of IBIBO Group Pvt/redBus. Please refer to the email sent to your booking email ID for further details. Stay safe, stay healthy!Team redBus';
                                    fullRefundOwnerEmail.add(csObj.Booking_Email_ID__c);
                                }else if(mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c <1){
                                    STCcomment = '(STC) Dear Customer, We are happy to provide a partial refund of the ticket fare. The refund has been initiated from our end to your source account. As per the standard banking procedure the amount will be refunded within 5 to 7 bank working days in the name of IBIBO Group Pvt/redBus. Please refer to the email sent to your booking email ID for further details. Stay safe, stay healthy! Team redBus';
                                    PartialRefundOwnerEmail.add(csObj.Booking_Email_ID__c);
                                }
                                csComm.ParentId = csObj.id;
                                csComm.commentBody = STCcomment;
                                caseCommentList.add(csComm);
                                listCase.add(csObj);
                            }
                        }
                        else{
                            System.debug('Received invalid response from the API'+responseValue);
                            map<string,object> exceFailRespone = (map<string,object>)JSON.deserializeUntyped(responseValue);
                            if(exceFailRespone.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(exceFailRespone.get('DetailedMessage')))){
                                cp.FC_Response_Message__c = string.valueof(exceFailRespone.get('DetailedMessage'));
                                csObj.Ageing_Refund_Status__c='Cancellation Failed';
                                listCase.add(csObj);
                            }
                        }

                    }catch(Exception e){
                        System.debug('::: Exception Occured ::: '+e+' :::: Exception Line Number ::::: ' +e.getLineNumber());
                        cp.FC_API_Request_Response__c = string.valueof(e);
                        cp.Message__c ='Error Occuerd..'+String.valueOf(e).left(244);
                    }
                    listCp.add(cp);
                }else if(isPreStatus == true){
                    csObj.Ageing_Refund_Status__c='Re-Open/Closed Case';
                    listCase.add(csObj);
                }
            }

            if(!caseCommentList.isEmpty()){
                insert caseCommentList;
            }
            if(!listCase.isEmpty()){
                update listCase;
            }
            string mailAddress;
            mailAddress='noreply_feedback@redbus.in';
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :mailAddress];
            EmailTemplate FullRefundTemplate = [SELECT Id FROM EmailTemplate where DeveloperName ='BO_Service_Issue_FULL_Refund'];
            EmailTemplate PartialRefundTemplate = [SELECT Id FROM EmailTemplate where DeveloperName ='BO_Service_Issue_Partial_Refund'];

            system.debug(':: fullRefundOwnerEmail MailList ::' +fullRefundOwnerEmail);
            system.debug(':: PartialRefundOwnerEmail MailList ::' +PartialRefundOwnerEmail);

            if(!fullRefundOwnerEmail.isEmpty()){
                for(string EmailId:fullRefundOwnerEmail){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(owea.size() > 0){
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    } 
                    mail.setToAddresses(new String[]{EmailId});
                    mail.setTemplateId(FullRefundTemplate.id);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setsaveAsActivity(false);
                    maillist.add(mail);
                }
            }
            
            if(!PartialRefundOwnerEmail.isEmpty()){
                for(string EmailId:PartialRefundOwnerEmail){
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                    if(owea.size() > 0){
                        mail2.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mail2.setToAddresses(new String[]{EmailId});
                    mail2.setTemplateId(PartialRefundTemplate.id);
                    mail2.setTargetObjectId(UserInfo.getUserId());
                    mail2.setsaveAsActivity(false);
                    maillist.add(mail2);
                }
            }

            if(!maillist.isEmpty()){
                Messaging.sendEmail(maillist);
                system.debug(':: Sent MailList ::' +maillist);
            }

            System.debug(':::: setCaseIdsToProcess ::::: '+setCaseIdsToProcess);
            try{
                Database.insert(listCp,false);
                List<DBLog_Summary__c> listDBLogSumm = new List<DBLog_Summary__c>();
                for(Case cs :[Select id,caseNumber,ownerId,status,isAgening_Refund_Processed__c,isAgeing_Refund_Success__c,Transaction_ID__c from Case where Id In:setCaseIdsToProcess]){
                    DBLog_Summary__c dbLogSumm = new DBLog_Summary__c();
                    dbLogSumm.Payment_Transaction_Name__c = cs.Transaction_ID__c;
                    dbLogSumm.type__c ='Bus Service Ageing Refund Case Update';
                    dbLogSumm.Order_Items_Process_Status__c =cs.CaseNumber;
                    dbLogSumm.Orders_Process_Status__c = String.valueOf(cs.Transaction_ID__c);
                    dbLogSumm.Orders_Received_Data_Ids__c = ':: CaseIds :: '+String.valueOf(setCaseIdsToProcess);
                    listDBLogSumm.add(dbLogSumm);
                }
                insert listDBLogSumm;
            }catch(Exception e){
                System.debug('::: Exception Occured ::: '+e+' :::: Exception Line Number ::::: ' +e.getLineNumber());
            }
        }
    }

    public string getExceptionalRefundAmount(string transactionId){
        string maxRefundRespamount;
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Bus Service Ageing Full Refund Check';
        System.debug('::: transactionId ::::: ' +transactionId);
        if(Test.isRunningTest()){
            maxRefundRespamount='1.1';
        }else{
            if(String.isNotBlank(transactionId)){
                list<order_items__c> orItLs = [SELECT Id, OrderUuid__c, Order_Item_Reference_No__c FROM order_items__c WHERE Id =:transactionId LIMIT 1];
                HttpResponse res = new HttpResponse();
                Http http1 = new Http();
                HttpRequest req = new HttpRequest();
                req = HttpRequestUtil.populateHeaders(req); 
                req.setMethod('GET'); 
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CapiMaxRefundableAPI'].Endpoint__c+orItLs[0].OrderUuid__c+'&tin='+orItLs[0].Order_Item_Reference_No__c);
                dbl.Request_Data__c = String.valueOf(req);
                try{
                    res = http1.send(req);
                    dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                    System.debug('::: res ::::: ' +res.getBody());
                    if(res.getStatusCode()==200 && maxRefundRespamount!= '0'){
                        maxRefundRespamount = res.getBody();
                    }else{
                        maxRefundRespamount = '0';
                    } 
                }catch(Exception e){
                    System.debug('::: Exception Occured in getExceptionalRefundAmount ::: '+e+' :::: Exception Line Number ::::: ' +e.getLineNumber()+ '::: Error Message ::::' +e.getMessage());
                    dbl.Exception_Description__c = String.valueOf(e);
                }                                    
            }
        }
        System.debug('::: finalRefundAmount ::::: ' +maxRefundRespamount);
        return maxRefundRespamount;
    }
    
    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('Bus Service Ageing Refund Processing..'+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}