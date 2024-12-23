@isTest(SeeAllData=true)
public class TaskTriggerTest
{
    public static testMethod void TestSuccess()
    {
        User usr = [SELECT Id FROM User WHERE UserName='it-admin@redbus.in'];
        //User usr = [SELECT Id FROM User WHERE UserName='ctiuserintl@redbus.com.ameyointl'];    
        System.runAs(usr) {
            case c=new case();
            c.status='Open';        
            insert c;
            task t=new task();
            t.CrtObjectId__c='12355';
            t.Description='12345';
            insert t;
        }
    }
    
    public static testMethod void TestSuccess1()
    {  
         User usr = [SELECT Id FROM User WHERE UserName='it-admin@redbus.in'];
        //User usr = [SELECT Id FROM User WHERE UserName='ctiuserintl@redbus.com.ameyointl'];       
        System.runAs(usr) {
            task t=new task();
            t.CrtObjectId__c='12355';
            insert t;
        }
        
        task ts=new task();
        ts.CrtObjectId__c='12355';

        insert ts;
    }      
}