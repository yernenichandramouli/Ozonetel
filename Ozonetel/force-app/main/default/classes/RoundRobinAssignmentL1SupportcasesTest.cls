@isTest
public class RoundRobinAssignmentL1SupportcasesTest {
    @isTest static void testRoundRobinMethod(){
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 20;
        usrDt.Assigned_Cases_Count__c=10;
        usrDt.User__c=uId;
        usrDt.Team__c='L1 Support';
        insert usrDt;

        case cs = new case();
        cs.Status = 'Open';
        cs.RPW_Case__c=True;
        cs.Type='Bus';
        cs.Issue_Type__c='';
        cs.Origin='Inbound call';
        cs.OwnerId =[Select id from Group where type='Queue' AND developername='L1_Queue'].id;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('L1 Support').getRecordTypeId();
        insert cs;

        Datetime yesterday = Datetime.now().addDays(-29);
        Test.setCreatedDate(cs.id, yesterday);
        Test.startTest();
        RoundRobinAssignmentL1Supportcases rodR = new RoundRobinAssignmentL1Supportcases();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
}