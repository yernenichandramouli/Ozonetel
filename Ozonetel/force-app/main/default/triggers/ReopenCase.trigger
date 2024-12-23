trigger ReopenCase on Case_Feedback__c (after insert) 
{
     set<string> caseIds = new set<string>();
     list<case> cs=new list<case>();
     
     for(Case_Feedback__c c : trigger.new)
     {
         if(c.Re_open__c==true)
         {
             caseIds.add(c.Case_Name__c);
         }
     }
     if(caseIds.size()>0)
     {
         for(case c:[SELECT id,AccountId,Status FROM case WHERE id=:caseIds])
         {
             c.Status='New';
             cs.add(c);
         }
     }
     
     if(cs.size()>0)
     {
         update cs;
     }
}