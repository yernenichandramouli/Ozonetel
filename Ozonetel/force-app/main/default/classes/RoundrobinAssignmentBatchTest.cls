@isTest
public class RoundrobinAssignmentBatchTest
{
    Static testMethod void testCasetoagents()
    {
     
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 20;
        usrDt.Assigned_Cases_Count__c=10;
        usrDt.User__c=uId;
        usrDt.Team__c='HF';
        insert usrDt;
        
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Open';
        cs.HF__c = true;
        cs.OwnerId =[Select id from Group where type='Queue' AND developername='HF_Queue'].id;
        Cslist.add(cs);
        insert Cslist;
        
        Test.startTest();
        RoundRobinAssignmentBatch rodR = new RoundRobinAssignmentBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
   
}