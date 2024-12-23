@isTest
public class RoundRobinAssignmentSITBatchTest
{
    Static testMethod void testSITAssignment()
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
        usrDt.Team__c='SIT';
        insert usrDt;
        list<Case> Cslist = new list<Case>(); 
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='SIT_GUJ_Raj_Queue'].id;
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinAssignmentSITBatch rodR = new RoundRobinAssignmentSITBatch ('');
        rodR.ownerName='SIT - GUJ/Raj Queue';
        Database.QueryLocator ql = rodR.start(null);
        rodR.execute(null,Cslist);
        Test.stopTest();
        
    }
    Static testMethod void testSITAssignment2()
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
        usrDt.Team__c='SIT';
        insert usrDt;
        list<Case> Cslist = new list<Case>();
        set<id> cIds=new set<id>();
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='SIT_Kar_AP_Queue'].id;
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinAssignmentSITBatch rodR = new RoundRobinAssignmentSITBatch ('');
        rodR.ownerName='SIT - Kar/AP Queue';
        Database.QueryLocator ql = rodR.start(null);
        rodR.execute(null,Cslist);
        Test.stopTest();
    }
    Static testMethod void testSITAssignment3()
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
        usrDt.Team__c='SIT';
        insert usrDt;
        
        list<Case> Cslist = new list<Case>();
        set<id> cIds=new set<id>();
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='SIT_Cases_Queue'].id;
        csList.add(c);
        insert Cslist;
        System.debug('Cslist-->'+Cslist);
        Test.startTest();      
        RoundRobinAssignmentSITBatch r=new RoundRobinAssignmentSITBatch();
        String cronExp ='0 00 1 3 * ?';
        r.ownerName='SIT Cases Queue';
        System.schedule('RoundRobin', cronExp,r);
        r.execute(null,Cslist);
        Test.stopTest();
    }
    
}