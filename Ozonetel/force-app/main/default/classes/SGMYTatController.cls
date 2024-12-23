/**
 * (c) 2022 RedBus
 *
 * Name           : SGMYTatController
 * Created Date   : 04 NOV 2022
 * Created By     : VR Sudarshan
 * JiraId         : CRM -1233
 * Purpose        : Schedular class to update TAT values based on issue type for SGMY Community.
 * Test class     : SGMYTatControllerTest
 *
 **/
global class SGMYTatController implements DataBase.Batchable<sObject>,Schedulable{
    public string query;

    public SGMYTatController(String strQuery){

        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SGMY_Community_TAT_Query'].QueryDetails__c;
        }
    }

    public void execute(SchedulableContext scon){
        System.abortJob(scon.getTriggerId());
        System.schedule('SGMYTatController - '+String.valueOf(DateTime.now()), '0 0 22 * * ? *' , this);
        Integer batchSize = Integer.valueOf([SELECT Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SGMY_Community_TAT_Query'].Batch_Size__c);
        Database.executeBatch(new SGMYTatController(Query),batchSize);
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){

        List<Case> caseListToUpdate = New List<Case>();
        set<String> setIssueTypes = New Set<String>();
        Map<string,Issue_Based_TAT__mdt> mapIssueToTATRecord = New Map<string,Issue_Based_TAT__mdt>();

        if(!lstcases.isEmpty()){
            for(case c: lstcases){
                if(String.isNotBlank(c.Issue_Type__c)){
                    setIssueTypes.add(c.Issue_Type__c);
                }
            }
        }
        System.debug('::: setIssueTypes ::: '+setIssueTypes);
        for(Issue_Based_TAT__mdt issueTAT : [SELECT Issue_Type__c,Country__c,Version__c,TAT_Value__c from Issue_Based_TAT__mdt where Issue_Type__c IN :setIssueTypes AND TAT_Value__c!=null and Version__c='V4']){
            mapIssueToTATRecord.put(issueTAT.Issue_Type__c,issueTAT);
        }

        if(!lstcases.isEmpty()){
            for(case cs: lstcases){
                if(String.isNotBlank(cs.Issue_Type__c) && mapIssueToTATRecord.containsKey(cs.Issue_Type__c)){
                    System.debug(':: Tat Value :: '+mapIssueToTATRecord.get(cs.Issue_Type__c).TAT_Value__c);
                    cs.TAT_Value__c = mapIssueToTATRecord.get(cs.Issue_Type__c).TAT_Value__c;
                    caseListToUpdate.add(cs);
                }
            }
        }
        if(!caseListToUpdate.isEmpty()){
            DataBase.update(caseListToUpdate,false);
        }
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('SGMY Community TAT Scheduler'+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}