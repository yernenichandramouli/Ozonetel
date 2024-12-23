@isTest
Public class TestReopenCase
{
    static testMethod void TestRollup()
    {
       
             
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Email';
        c.Rollup_case_feedback__c = 1;
        insert c;
        
        Case_Feedback__c cs = new Case_Feedback__c();
        cs.Case_Name__c= c.id;
        cs.Re_open__c = true;
        insert cs;
    
    }
}