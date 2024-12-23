global class SupervisorSecondCallbackScheduler implements Database.Batchable<sObject>,Schedulable
{    
    global final String Query;    
    public SupervisorSecondCallbackScheduler(){}    
    public SupervisorSecondCallbackScheduler(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='TimeSlotQuery'].QueryDetails__c;    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='TimeSlotQuery'].Duration__c;
        System.schedule('SupervisorSecondCallbackScheduler -- '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new SupervisorSecondCallbackScheduler(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<TimeSlot__c> listTimeSlot)
    {     
        System.debug('## RoundRobin Records Size..'+listTimeSlot.size()+' records'+'..'+listTimeSlot);
        List<Id> timeSlotIds = new List<Id>();
        if(!listTimeSlot.isEmpty())
        {            
            for (TimeSlot__c ts : listTimeSlot) {
                timeSlotIds.add(ts.Id);
            }
        }   
        
         if (!timeSlotIds.isEmpty()) {
            System.enqueueJob(new TimeSlotQueueable(timeSlotIds));
        }
    }
    
    
    
    global void finish(Database.BatchableContext BC) 
    {                 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addall(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('SupervisorSecondCallbackScheduler Has Finished '+a.Status);
        mail.setPlainTextBody
            ('SupervisorSecondCallbackScheduler job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}