@isTest
public class IR_CasesRoundrobinAssignmentTest
{
    Static testMethod void testRPWcases()
    {
     
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 20;
        usrDt.Assigned_Cases_Count__c=10;
        usrDt.Total_Cases_Assigned_Count__c=3;
        usrDt.Daily_Assignment_Limit__c=5;
        usrDt.User__c=uId;
        usrDt.Team__c='IRteam';
        insert usrDt;
        
        Id rpwId = [Select id from Group where type='Queue' AND developername='IR_Queue'].id;
 
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Open';
        cs.priority='Low';
        cs.Origin='Inbound Call';
        cs.Flow_Type__c='IR_Queue';
        cs.Issue_Type__c='I have a problem with bus service';
        cs.Case_Category__c='Instant resolution-BOLT';
        cs.OwnerId=rpwId;
        Cslist.add(cs);
        insert Cslist;
        
         
        Test.startTest();
        IR_CasesRoundrobinAssignment rodR = new IR_CasesRoundrobinAssignment();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('IrRoundRobin', cronExp,rodR);
        Test.stopTest();
    }
   
}