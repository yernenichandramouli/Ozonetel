@isTest
public class EmailMessageTriggerTest{   
    public static testMethod void TestEmailMessage()
    {
        case c=new case();
        c.status='Open';
        c.issue_type__c='Bus Operator Service';
        insert c;
        
        EmailMessage e=new EmailMessage();
        e.FromAddress='test@t.com';
        e.ToAddress='test2@t.com';
        e.TextBody='Test body';
        e.Subject='Test subject';
        e.parentid=c.id;
        insert e;
    }  
}