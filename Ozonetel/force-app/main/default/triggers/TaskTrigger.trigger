trigger TaskTrigger on Task (before insert,after insert,after update) {
    public set<string> caseIds=new set<string>();
    set<string> crtIds=new set<string>();
    set<string> ivrCalls=new set<string>();
    
    for(Task t:Trigger.new){
        if(string.isNotBlank(t.CrtObjectId__c) && string.isNotBlank(t.Description) && t.Description.isNumeric()){               
            caseIds.add(t.Description.trim());
        }        
        if(t.createdby.name!='CX User' && string.isNotBlank(t.CrtObjectId__c)){
            crtIds.add(t.CrtObjectId__c);
        } 
        
        if(string.isNotBlank(t.CrtObjectId__c)){
            ivrCalls.add(t.CrtObjectId__c);
        }
    } 
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        if(!ivrCalls.isEmpty() && System.Label.TaskTriggerPushCallDetails=='TRUE')
            TaskTriggerHandler.InboundCallsPush(Trigger.new);
        
    }
    if(Trigger.isBefore && Trigger.isInsert){
        
        if(!caseIds.isEmpty() && System.Label.TaskTriggerDetails=='TRUE')
            TaskTriggerHandler.CaseLink(caseIds,Trigger.new);
        
      /*  if(!crtIds.isEmpty() && System.Label.TaskTriggerDetails=='TRUE')
            TaskTriggerHandler.taskUpdate(Trigger.new,crtIds); */
        
    }    
    
}