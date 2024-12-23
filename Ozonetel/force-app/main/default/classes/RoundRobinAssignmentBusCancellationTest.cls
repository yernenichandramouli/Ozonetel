@isTest
public class RoundRobinAssignmentBusCancellationTest
{
    Static testMethod void testBusCancellationAssignment()
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
        usrDt.Team__c='SPOC';
        insert usrDt;
        list<Case> Cslist = new list<Case>(); 
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='Bus_Cancellation_Auto_Refund_Queue'].id;
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinAssignmentBusCancellation rodR = new RoundRobinAssignmentBusCancellation('');
        rodR.ownerName='Bus Cancellation Auto Refund Queue';
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
        usrDt.Team__c='SPOC';
        insert usrDt;
        list<Case> Cslist = new list<Case>();
        set<id> cIds=new set<id>();
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='Bus_Cancellation_Queue'].id;
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinAssignmentBusCancellation rodR = new RoundRobinAssignmentBusCancellation('');
        rodR.ownerName='Bus Cancellation Queue';
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
        usrDt.Team__c='SPOC';
        insert usrDt;
        
        list<Case> Cslist = new list<Case>();
        set<id> cIds=new set<id>();
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='Domestic_OTRS_Bus_Cancellation_Cases'].id;
        csList.add(c);
        insert Cslist;
        System.debug('Cslist-->'+Cslist);
        Test.startTest();      
        RoundRobinAssignmentBusCancellation r=new RoundRobinAssignmentBusCancellation();
        String cronExp ='0 00 1 3 * ?';
        r.ownerName='Domestic OTRS Bus Cancellation Cases';
        System.schedule('RoundRobin', cronExp,r);
        r.execute(null,Cslist);
        Test.stopTest();
    }
    
}