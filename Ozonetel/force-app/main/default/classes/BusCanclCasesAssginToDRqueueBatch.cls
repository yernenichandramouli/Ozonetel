/**
* (c) 2024 RedBus
*
* Name           : BusCanclCasesAssginToDRqueue
* Created Date   : 08 April 2024
* Created By     : Mahendra k
* Purpose        : Batch class to Assign to DR Queue from L1 agent 
**/

global class BusCanclCasesAssginToDRqueueBatch implements Database.Batchable<sObject>,Schedulable
{  
    
    global final String Query;
    
    public BusCanclCasesAssginToDRqueueBatch(){}
    
    public BusCanclCasesAssginToDRqueueBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCanclCasesAssginToDRquery'].QueryDetails__c;
        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCanclCasesAssginToDRquery'].Duration__c;
        System.schedule('BusCanclCasesAssginToDRqueueBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new BusCanclCasesAssginToDRqueueBatch(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
        System.debug('## ..'+listCase.size()+' records'+'..'+listCase);
        if(!listCase.isEmpty())
        {
            DateTime currTime = System.Now();
            
            List<case> listCasesToUpdate = new List<Case>();
            list<casecomment> listCommToInsert = new List<casecomment>();
            
            
            for(Case cs : listCase)
            {
                datetime tenMinutesCreation=cs.createddate.addMinutes(10);
                
                if(currTime > tenMinutesCreation){
                    casecomment cc=new casecomment();
                    cc.commentbody='Assgined L2-support Queue';
                    cc.parentid=cs.id;
                    cs.ownerId=System.Label.L2_Support_Queue_Id;
                    cs.Assigned_By__c ='Assigned By Bus Cancl Scheduler';
                    listCommToInsert.add(cc);
                    listCasesToUpdate.add(cs);
                }
            }
            
            if(!listCommToInsert.isEmpty()){
                insert listCommToInsert;
            }
            
            
            if(!listCasesToUpdate.isEmpty())
                update listCasesToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {                 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('Mahendrareddy.k@redbus.com.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('BusCanclCasesAssginToDRqueue'+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}