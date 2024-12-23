@isTest
public class deleteRestriction_Test
{
    static testMethod void deleteRestriction()
    {
        Email_Message_Deletion_Profiles__c st = new Email_Message_Deletion_Profiles__c();
         st.Name = 'ST Prfoile Test';
        insert st;
        
        Case c = new Case();
         c.Status = 'New';
        insert c;
        
        EmailMessage em = new EmailMessage();
         em.ParentId = c.Id;
        insert em;  
        
        try{
            delete em;
        }catch(exception e){}
    }
}