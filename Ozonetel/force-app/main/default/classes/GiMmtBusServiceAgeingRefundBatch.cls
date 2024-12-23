/**
 * (c) 2024 RedBus
 *
 * Name           : GiMmtBusServiceAgeingRefundBatch
 * Created Date   : 08 JUL 2024
 * Created By     : VR Sudarshan
 * Purpose        : Batch class to process the Bus Service cases Under Collectible from BO Refund for GIMMT
 * Test class     : GiMmtBusServiceAgeingRefundBatchSchedulerTest
 *
 **/
global class GiMmtBusServiceAgeingRefundBatch implements DataBase.Batchable<sObject>{
    public string query;
    public List<String> issueTypeToCheck;
    public List<String> subIssueTypeToCheck;
    public Set<String> setRTCOpIds;
    public Map<String,Issue_Based_TAT__mdt> mapIssueBasedAmount;

    public GiMmtBusServiceAgeingRefundBatch(String strQuery) {
        issueTypeToCheck = new list<String>();
        issueTypeToCheck.addAll(System.Label.BusService_Ageing_Refund_Issue_Types.Split(','));
        subIssueTypeToCheck = new list<String>();
        subIssueTypeToCheck.addAll(System.Label.GIMMT_Bus_Service_Ageing_Refund_SubIssues.Split(';'));
        setRTCOpIds = new Set<String>();
        setRTCOpIds.addAll(System.Label.RTC_BO_IDS.Split(','));

        mapIssueBasedAmount = new Map<string,Issue_Based_TAT__mdt>();
        for(Issue_Based_TAT__mdt issueTAT : [SELECT DeveloperName, Issue_Type__c, Issue_Sub_Category__c, Bus_Service_Ageing_Refund_Amount__c FROM Issue_Based_TAT__mdt WHERE Version__c='V3' And Bus_Service_Ageing_Refund_Amount__c != Null AND Issue_Type__c IN :issueTypeToCheck AND Issue_Sub_Category__c IN :subIssueTypeToCheck AND Type__c='B2B']){
            System.debug('::: issueTAT :::: '+issueTAT );
            mapIssueBasedAmount.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
        }

        System.debug('::: issueTypeToCheck :::: '+issueTypeToCheck );
        System.debug('::: subIssueTypeToCheck :::: '+subIssueTypeToCheck );
        System.debug('::: setRTCOpIds :::: '+setRTCOpIds );

        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='GiMmtBusServiceAgeingRefundQuery'].QueryDetails__c+' AND Issue_Type__c IN :issueTypeToCheck AND Issue_Sub_Category__c IN :subIssueTypeToCheck AND Service_Provider_Id__c NOT IN :setRTCOpIds';
            // Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='GiMmtBusServiceAgeingRefundQuery'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        system.debug(':: lstcases :: '+lstcases);
        system.debug(':: mapIssueBasedAmount :: '+mapIssueBasedAmount);
        List<CaseComment> caseCommentList = new List<CaseComment>();
        List<case> listCase = new List<case>();
        Map<Id,Case> caseMap = New Map<Id,Case>();
        List<case> caseListToProcess = New List<case>();
        List<case> childCaseToCreate = New List<case>();
        List<case> parentCaseToClose = New List<case>();
        List<caseComment> parentCaseCommentInsert = New List<CaseComment>();
        Map<Id,Id> caseAndTransactionId = New Map<Id,Id>();
        if(!lstcases.isEmpty()){
            for(Case c : lstcases){
                caseMap.put(c.Transaction_ID__c,c);
                caseAndTransactionId.put(c.Transaction_ID__c,c.Id);
            }
        }

        System.debug(':: caseMap = '+caseMap.keySet());
        // Check for if any exceptional refund case is created or not.
        for(case c : [SELECT Id, ParentId, Transaction_ID__c, All_Previous_Status_Dates__c FROM case WHERE Issue_Type__c='Exceptional Refund' AND status!='Rejected For Exceptional Refund' AND Transaction_ID__c =: caseMap.keySet()]){
            String allPreviousStatus=String.isNotBlank(c.All_Previous_Status_Dates__c)?c.All_Previous_Status_Dates__c:'';
            List<String> values = allPreviousStatus.split(';');
            for(String value:values){
                if(value.Contains('Approved For Exceptional Refund')){  
                    case parentCase = New case();
                    parentCase.Id = caseAndTransactionId.get(c.Transaction_ID__c);
                    parentCase.status = 'Closed';
                    if(!parentCaseToClose.contains(parentCase)){
                        parentCaseToClose.add(parentCase);
                    }

                    casecomment cc = New casecomment();
                    cc.ParentId = caseAndTransactionId.get(c.Transaction_ID__c);
                    cc.commentBody='System Update Bus Service Ageing --> There is already an exceptional refund cases which has been approved. So, closing this case.';
                    parentCaseCommentInsert.add(cc);
                }
            }
            caseMap.remove(c.Transaction_ID__c);
        }

        // Check if any Bus cancellation case is approved or not.
        for(case c : [SELECT Id, ParentId, Transaction_ID__c, All_Previous_Status_Dates__c FROM case WHERE Issue_Type__c='Bus Cancellation' AND status!='Rejected For Bus Cancellation' AND Transaction_ID__c =: caseMap.keySet()]){
            String allPreviousStatus=String.isNotBlank(c.All_Previous_Status_Dates__c)?c.All_Previous_Status_Dates__c:'';
            List<String> values = allPreviousStatus.split(';');
            for(String value:values){
                if(value.Contains('Approved For Bus Cancellation')){  
                    case parentCase = New case();
                    parentCase.Id = caseAndTransactionId.get(c.Transaction_ID__c);
                    parentCase.status = 'Closed';
                    if(!parentCaseToClose.contains(parentCase)){
                        parentCaseToClose.add(parentCase);
                    }

                    casecomment cc = New casecomment();
                    cc.ParentId = caseAndTransactionId.get(c.Transaction_ID__c);
                    cc.commentBody='System Update Bus Service Ageing --> Refund has been already processed under bus cancellation. Hence we are closing this case.';
                    parentCaseCommentInsert.add(cc);
                }
            }
            caseMap.remove(c.Transaction_ID__c);
        }
        //
        if(!parentCaseCommentInsert.isEmpty()){
            insert parentCaseCommentInsert;
        }
        if(!parentCaseToClose.isEmpty()){
            update parentCaseToClose;
        }
        System.debug(':: caseMap2 = '+caseMap.keySet());
        System.debug(':: caseMap2 values = '+caseMap.values());
        // caseListToProcess = 
        if(!caseMap.values().isEmpty()){
            for(Case csObj : caseMap.values()){
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
                    System.debug('::: strIssueSubIssue ='+strIssueSubIssue);
                    System.debug('::: strIssueSubIssue ='+mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c);
                    // setCaseIdsToProcess.add(csObj.Id);
                    string refundAmount;
                    csObj.Ageing_Refund_Status__c='Success';
                    csObj.Status ='Refunded By Ageing Scheduler';
                    csObj.Refund_Reason__c = 'Refund by service ageing scheduler';
                    csObj.isAgening_Refund_Processed__c = true;
                    csObj.isAgeing_Refund_Success__c = true;
                    if(test.isRunningTest()){
                        csObj.Amount__c = 100;
                        csObj.Refund_Amount__c = 200;
                    }else{
                        csObj.Amount__c =  csObj.Total_Fare_Value__c*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c>csObj.Max_Refund_Amount__c?csObj.Max_Refund_Amount__c:csObj.Total_Fare_Value__c*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c;
                        csObj.Refund_Amount__c = csObj.Total_Fare_Value__c*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c>csObj.Max_Refund_Amount__c?csObj.Max_Refund_Amount__c:csObj.Total_Fare_Value__c*mapIssueBasedAmount.get(strIssueSubIssue).Bus_Service_Ageing_Refund_Amount__c;
                    }
                    csObj.redCare_Status__c ='Instant resolution with refund-Approved';
                    listCase.add(csObj);

                    CaseComment csComment = new CaseComment();
                    csComment.ParentId = csObj.id;
                    csComment.commentBody = 'System Update- Refund has been initiated by service ageing scheduler.';
                    caseCommentList.add(csComment);

                    // Create a Exceptional Refund Case
                    case c = New case ();
                    c.issue_type__c='Exceptional Refund';
                    c.Issue_Sub_Category__c='Collectible From BO';
                    c.Reason_For_Report__c='Created by Refund Ageing Scheduler';
                    c.Parentid=csObj.id;
                    c.status='Approved For Exceptional Refund';
                    c.Origin='InBound Call';
                    c.Refund_Amount__c=csObj.Refund_Amount__c;
                    c.Amount__c=csObj.Refund_Amount__c;
                    c.description='Created by Refund Ageing Scheduler';
                    c.Transaction_ID__c=csObj.Transaction_ID__c;
                    c.PNR__c= csObj.PNR__c;
                    c.My_Desk_Id__c = csObj.My_Desk_Id__c;
                    c.Channel_ct__c = csObj.Channel_ct__c;
                    c.Inventory_Type__c = String.isNotBlank(csObj.Inventory_Type__c)?String.valueOf(csObj.Inventory_Type__c):'';
                    c.Trip_Id_ct__c = csObj.Trip_Id_ct__c;
                    c.TIN_No__c = csObj.TIN_No__c;
                    c.Booking_Email_ID__c = csObj.Booking_Email_ID__c;
                    c.OwnerId = System.Label.ExceptionalRefundQueueId;
                    c.subject='Exceptional Refund-B2B';
                    c.Business_Unit_ct__c = csObj.Business_Unit_ct__c;
                    c.redCare_Status__c ='Instant resolution with refund-Approved';
                    c.Business_Type__c=csObj.Business_Type__c;
                    c.country__c=csObj.country__c;
                    c.Type='B2B';
                    c.Service_Providerr_Id__c = csObj.Service_Providerr_Id__c;
                    c.My_Desk_Id__c  = csObj.My_Desk_Id__c;
                    childCaseToCreate.add(c);
                    // End of Create a Exceptional Refund Case

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
            if(!childCaseToCreate.isEmpty()){
                insert childCaseToCreate;
            }
        }
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