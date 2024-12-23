/**
 * (c) 2024 RedBus
 *
 * Name           : GIMMTServiceAgeingInvoicingBatch
 * Created Date   : 16 JUL 2024
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1820
 * Purpose        : Batch class to process the invocing for service ageing cases of MMT and GI
 * Test class     : GIMMTServiceAgeingInvoicingSchedulerTest
 *
 **/
global class GIMMTServiceAgeingInvoicingBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;

    public GIMMTServiceAgeingInvoicingBatch(string strQuery) {
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='GIMMTServiceAgeingInvoicing'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        List<case> caseListToProcess = New List<case>();
        List<DBLog_Summary__c> dbLogToInsert = New List<DBLog_Summary__c>();
        List<Case> parentCaseToUpdate = New List<Case>();
        List<CaseComment> caseCommentsToInert = New List<CaseComment>();
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BUpdatedSeatSeller'];
        if(!lstcases.isEmpty()){
            for(Case csObj : lstcases){
                    MMTExceptionalOperatorRefund eor=new MMTExceptionalOperatorRefund();
                    eor.type='exceptionalRefund';
                    eor.tin=csObj.PNR__c;
                    eor.description=csObj.description;
                    eor.amount=csObj.Refund_Amount__c;
                    eor.agentId='integration@redbus.com';
                    eor.exceptionalRefundReason='Refund by service ageing scheduler';
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
                    expLogB2B.type__c='GIMMT-Service Ageing Refund';
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
                            csObj.Status = 'Closed';
                            parentCaseToUpdate.add(csObj);
                        }
                        // DblogforQuickActionLwcCtrl.dblogCaptureMethod('MMT-Exceptional Refund',String.valueOf(req.getEndpoint()),String.valueOf(csObj.caseNumber),String.valueOf(req)+'--Body-->'+expOpJson,String.valueOf(responseValue+'..Body..'+response.getBody()),'','');
                    }catch(Exception e){
                        system.debug(':: Exception Occured :: ' +e.getMessage());
                        expLogB2B.Exception_Description__c=string.valueOf(e);
                        dbLogToInsert.add(expLogB2B);
                        // DblogforQuickActionLwcCtrl.dblogCaptureMethod('MMT-Exceptional Refund',String.valueOf(req.getEndpoint()),String.valueOf(csObj.caseNumber),String.valueOf(req)+'--Body-->'+expOpJson,'','',string.valueOf(e));
                    }
            }
            if(!dbLogToInsert.isEmpty()){
                Database.insert(dbLogToInsert,false);
            }
            if(!caseCommentsToInert.isEmpty()){
                Database.insert(caseCommentsToInert,false);
            }
            if(!parentCaseToUpdate.isEmpty()){
                Database.update(parentCaseToUpdate,false);
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
        mail.setSubject('GIMMT Service Ageing Invocing procesing has been '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}