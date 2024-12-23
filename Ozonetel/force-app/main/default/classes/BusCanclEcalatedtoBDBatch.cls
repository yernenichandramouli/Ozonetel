/**
 * (c) 2022 RedBus
 *
 * Name           : BusCanclEcalatedtoBDBatch
 * Created Date   : 29 NOV 2022
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1252
 * Purpose        : Batch class to update status to Escalated to BD for BusCancellation Issue Types
 * Test class     : BusCanclEcalatedtoBDBatchTest
 *
 **/

global class BusCanclEcalatedtoBDBatch implements Database.Batchable<sObject>,Schedulable {
    public string query;

    public BusCanclEcalatedtoBDBatch(String strQuery) {

        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCanclEcalatedtoBD'].QueryDetails__c;
        }
    }

    public void execute(SchedulableContext scon){
        System.abortJob(scon.getTriggerId());
        System.schedule('BusCanclEcalatedtoBDBatch - '+String.valueOf(DateTime.now()), '0 0 23 * * ? *' , this);
        Integer batchSize = Integer.valueOf([SELECT Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCanclEcalatedtoBD'].Batch_Size__c);
        Database.executeBatch(new BusCanclEcalatedtoBDBatch(Query),batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('query..'+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, list<Case> listCase){
        if(!listCase.isEmpty()){
            DateTime currTime = System.Now();
            List<case> listCasesToUpdate = new List<Case>();
            list<casecomment> listCommToInsert = new List<casecomment>();
            Group BDQ=[select id from Group where type='Queue' AND developername='BD_Queue']; 

            for(Case cs : listCase){
                boolean isPreStatus=false;
                String allPreviousStatus=String.isNotBlank(cs.All_Previous_Status_Dates__c)?cs.All_Previous_Status_Dates__c:'';
                List<String> values = allPreviousStatus.split(';');
                for(String value:values){
                    if(value.Contains('Re-Open') || value.Contains('Department Revert')){  
                        isPreStatus=true;
                    }
                }
                datetime twentyFourHoursBD=cs.createddate.addhours(72);
                if(currTime > twentyFourHoursBD && isPreStatus == false){
                    casecomment cc=new casecomment();
                    cc.commentbody='Bus Cancellation Initiated, 72 hrs completed';
                    cc.parentid=cs.id;
                    cs.status='Escalated to BD';
                    cs.ownerid=BDQ.id;   
                    cs.Assigned_to_BD__c=System.now();
                    listCommToInsert.add(cc);
                    listCasesToUpdate.add(cs);
                }
            }

            if(!listCommToInsert.isEmpty()){
                database.insert(listCommToInsert);
            }

            if(!listCasesToUpdate.isEmpty()){
                database.update(listCasesToUpdate);
            }
        }
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('Bus Cancellation EcalatetoBDBatch'+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}