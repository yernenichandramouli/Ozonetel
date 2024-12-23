trigger RollupToCase on Case_Feedback__c(after insert, after update, after delete) 
{
    set<string> caseIds = new set<string>();

    if(trigger.isInsert || trigger.isUpdate)
    {
        for(Case_Feedback__c c : trigger.new)
        {
            caseIds.add(c.Case_Name__c);
        }
    }
    
    if(trigger.isDelete)
    {
        for(Case_Feedback__c c : trigger.old)
        {
            caseIds.add(c.Case_Name__c);
        }
    }
    Map<id,case> cs=new Map<id,case>();
    for(string cid:caseIds)
    {
        cs.put(cid,new case(id=cid,Rollup_case_feedback__c=0));
    }
    for(Case_Feedback__c c : [SELECT id,name,Case_Name__c FROM Case_Feedback__c WHERE Case_Name__c=:caseIds])
    {
        if(cs.containskey(c.Case_Name__c))
        {
            cs.get(c.Case_Name__c).Rollup_case_feedback__c+=1;
        }
    }
    
    if(cs.values().size()>0)
    {
        update cs.values();
    }
}