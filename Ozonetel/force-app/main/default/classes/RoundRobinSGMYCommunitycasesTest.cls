@isTest
public class RoundRobinSGMYCommunitycasesTest
{
    Static testMethod void testMethod1()
    {
        BusinessHours bh = [SELECT Id FROM BusinessHours Where IsActive=True AND Name='SGMYSupportCommunityLoginHours'];
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 20;
        usrDt.Assigned_Cases_Count__c=10;
        usrDt.User__c=uId;
        usrDt.Team__c='SGMY Support';
        insert usrDt;
        list<Case> Cslist = new list<Case>(); 
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='SGMY_HQBusdev_Queue'].id;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SGMY HQBusdev').getRecordTypeId();
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinSGMYCommunitycases rodR = new RoundRobinSGMYCommunitycases ('');
        Database.QueryLocator ql = rodR.start(null);
        rodR.execute(null,Cslist);
        Test.stopTest();
        
    }

    Static testMethod void testMethod2()
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
        usrDt.Team__c='SGMY Support';
        insert usrDt;
        list<Case> Cslist = new list<Case>(); 
        case c=new case();
        c.Status = 'Open'; 
        c.OwnerId =[Select id,name from Group where developername='SGMY_HQBusdev_Queue'].id;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SGMY HQBusdev').getRecordTypeId();
        csList.add(c);
        insert Cslist;
        Test.startTest();
        RoundRobinSGMYCommunitycases rodR = new RoundRobinSGMYCommunitycases('');
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
        
    }
    
}