@isTest
public class RoundRobinAssignmentRefundQueueTest
{
    Static testMethod void testRefundMethod()
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
        usrDt.Team__c='Refund Escalation';
        insert usrDt;
        
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Refund Pending';
        cs.Country__c='India';
        Cslist.add(cs);
        insert Cslist;
        
        Test.startTest();
        RoundRobinAssignmentRefundQueue rodR = new RoundRobinAssignmentRefundQueue();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobinRefund', cronExp,rodR);
        // Database.QueryLocator ql = rodR.start(null);
        rodR.execute(null,Cslist);
        Test.stopTest();
    }
}