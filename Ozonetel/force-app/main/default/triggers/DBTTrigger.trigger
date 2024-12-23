trigger DBTTrigger on DBT__c (after insert,after Update) {
   
    
     //After Insert--> DBT 
    if(Trigger.isAfter && Trigger.isInsert)
    {
       if(System.Label.DBTFuzzyCheck=='TRUE'){     
        System.debug('calling trigger');
        DBTTriggerHandler.dbtAfterInsert(Trigger.new);
        }
    }   
}