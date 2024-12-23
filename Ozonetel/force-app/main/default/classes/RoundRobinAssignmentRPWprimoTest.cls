@isTest
public class RoundRobinAssignmentRPWprimoTest
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
        usrDt.User__c=uId;
        usrDt.Team__c='RPW Primo';
        insert usrDt;
        
          Id rpwId = [Select id from Group where type='Queue' AND developername='RPW_Queue'].id;
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Open';
        cs.RPW_Case__c = true;
        cs.HFT__c='Primo';
         cs.ownerid=rpwId;
        cs.Origin='Inbound Call';
        cs.Issue_Type__c='I have a problem with bus service';
        //Cslist.add(cs);
        insert cs;
         Datetime yesterday = Datetime.now().addDays(-29);
        Test.setCreatedDate(cs.id, yesterday);
        
        Test.startTest();
        RoundRobinAssignmentRPWprimo rodR = new RoundRobinAssignmentRPWprimo();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
   
}