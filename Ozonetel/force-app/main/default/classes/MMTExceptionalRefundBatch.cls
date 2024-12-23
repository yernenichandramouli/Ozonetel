/**
 * (c) 2023 RedBus
 *
 * Name           : MMTExceptionalRefundBatch
 * Created Date   : 06 JUN 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1369
 * Purpose        : Batch class to process the exceptional refund for MMT cases. For bolt invocing will happen instantely and for non bolt 3 days from case created.
 * Test class     : MMTExceptionalRefundBatchSchedulerTest
 *
 **/
global class MMTExceptionalRefundBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;
    public string excepRefReq;
    public static list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
    public MMTExceptionalRefundBatch(string strQuery) {
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='B2bMMTCasesInvoicing'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        List<case> caseListToProcess = New List<case>();
        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
        for(case c: lstcases){
            
            if(string.isNotBlank(c.Service_Providerr_Id__c) && instantRefundBoIds.contains(c.Service_Providerr_Id__c) && c.Case_Age__c>3 && ('Instant refund - collectible from BO'.equalsIgnoreCase(c.Issue_Sub_Category__c) || 'Instant refund - customer delight'.equalsIgnoreCase(c.Issue_Sub_Category__c))){
                caseListToProcess.add(c);
            }else if(string.isNotBlank(c.Service_Providerr_Id__c)){
                caseListToProcess.add(c);
            }
        }
        List<DBLog_Summary__c> dbLogToInsert = New List<DBLog_Summary__c>();
        List<CaseComment> caseCommentsToInert = New List<CaseComment>();
        List<Case> childCaseToUpdate = New List<Case>();
        List<case> parentCaseIdToUpdate = New List<Case>();
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BUpdatedSeatSeller'];
        if(!caseListToProcess.isEmpty()){
            for(Case csObj : caseListToProcess){
                string approvedBy = String.valueOf(csObj.Approved_By__c);
                    MMTExceptionalOperatorRefund eor=new MMTExceptionalOperatorRefund();
                    eor.type='exceptionalRefund';
                    eor.tin=csObj.PNR__c;
                    eor.description=csObj.description;
                    eor.amount=csObj.Refund_Amount__c;
                    if(csObj.Parent.Refund_Type__c =='Instant resolution - BO contest partially approved'){
                        eor.amount=csObj.parent.FC_Refunded_Amount__c;
                    }
                    eor.agentId=csObj.Approved_By__c;
                    eor.exceptionalRefundReason=csObj.Reason_For_Report__c;
                    if(('Instant refund - collectible from BO'.equalsIgnoreCase(csObj.Issue_Sub_Category__c) || 'Instant refund - customer delight'.equalsIgnoreCase(csObj.Issue_Sub_Category__c)) && string.isNotBlank(csObj.Service_Providerr_Id__c) && instantRefundBoIds.contains(csObj.Service_Providerr_Id__c)){
                        eor.refundUnderBolt=true;
                        if(csObj.Refund_Type__c!='' &&  csObj.Refund_Type__c !='Instant resolution - BO contest' && csObj.Issue_Type__c=='Exceptional Refund'){ //parent.Refund_Type__c !='Instant resolution - BO contest' &&
                            eor.recoveryFromBo=true;
                        }
                    }
                    String expOpJson=json.serialize(eor);
                    System.debug('expOpJson-->'+expOpJson);
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse response=new HttpResponse();
                    req.setEndpoint(APIMData.Endpoint__c);
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');  
                    req.setBody(expOpJson);               
                    string endPoint=APIMData.Endpoint__c;
                    req.setEndpoint(endPoint);
                    System.debug('endPoint-->'+endPoint);
                    DBLog_Summary__c expLogB2B= New DBLog_Summary__c();
                    expLogB2B.type__c='MMT-Exceptional Refund';
                    expLogB2B.Request_Data__c=String.valueOf(req)+'--Body-->'+expOpJson;
                    expLogB2B.EndPoint__c = String.valueOf(req.getEndpoint());
                    expLogB2B.Case_Number__c = String.valueOf(csObj.caseNumber);
                    System.debug('::RequestData '+String.valueOf(req)+'--Body-->'+expOpJson);
                    try{
                        response = http.send(req);
                        string responseValue = response.getBody();
                        system.debug('::: responseValue = '+responseValue);
                        expLogB2B.Response_Received__c=String.valueOf(responseValue+'..Body..'+response.getBody());
                        expLogB2B.CallOut_Status__c = string.valueOf(response.getStatus());
                        dbLogToInsert.add(expLogB2B);
                        
                        if(response.getStatusCode()==200 && !string.isBlank(response.getBody())){
                            CaseComment csCom = new CaseComment();
                            csCom.ParentId = csObj.Id;
                            csCom.commentBody = 'The case has been invoiced by the scheduler.';
                            caseCommentsToInert.add(csCom);
                            if(csObj.Refund_Type__c=='Instant resolution with refund' || csObj.Refund_Type__c=='Instant resolution - BO contest Rejected' || csObj.Parent.Refund_Type__c =='Instant resolution - BO contest partially approved'){
                                csObj.Refund_Type__c = 'Instant resolution - BO Accepted';
                            }
                            csObj.status = 'Closed';
                            csObj.Status_Processed__c = true;
                            childCaseToUpdate.add(csObj);
                            if(csObj.parent.Refund_Type__c=='Instant resolution with refund' || csObj.parent.Refund_Type__c=='Instant resolution - BO contest Rejected' || csObj.Parent.Refund_Type__c =='Instant resolution - BO contest partially approved'){
                                case parCase = New case();
                                parCase.Id= csObj.ParentId;
                                parCase.Refund_Type__c = 'Instant resolution - BO Accepted';
                                parentCaseIdToUpdate.add(parCase);
                            }
                        }
                    }catch(Exception e){
                        system.debug(':: Exception Occured :: ' +e.getMessage());
                        expLogB2B.Exception_Description__c=string.valueOf(e);
                        dbLogToInsert.add(expLogB2B);
                    }
            }
            if(!dbLogToInsert.isEmpty()){
                Database.insert(dbLogToInsert,false);
            }
            if(!caseCommentsToInert.isEmpty()){
                Database.insert(caseCommentsToInert,false);
            }
            if(!childCaseToUpdate.isEmpty()){
                Database.update(childCaseToUpdate,false);
            }

            if(!parentCaseIdToUpdate.isEmpty()){
                Database.update(parentCaseIdToUpdate,false);
            }
        }
    }

    public class MMTExceptionalOperatorRefund{
        public string tin;
        public decimal amount;
        public string description;
        public string agentId;
        public boolean partialRefund=true;
        public string type;
        public string exceptionalRefundReason;
        public boolean recoveryFromBo=false;
        public Boolean refundUnderBolt = false;
    }  

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com','nilika.haldar@redbus.com'});
        mail.setSubject('MMT Invocing procesing has been '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}