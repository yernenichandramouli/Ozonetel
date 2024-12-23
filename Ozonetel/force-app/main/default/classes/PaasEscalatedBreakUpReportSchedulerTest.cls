// @isTest
// public class PaasEscalatedBreakUpReportSchedulerTest {
//     static testMethod void PaasEscalatedBreakUpReportSchedulerTest()
//     {
//         case c=new case();
//         c.Issue_Type__c='Exceptional Refund';
//         c.Bank_Name__c='Test Bank';
//         c.Status='Open';
//         insert c;
//         Test.StartTest();   
//         PaasEscalatedBreakUpReportScheduler nef = new PaasEscalatedBreakUpReportScheduler();
//         String sche ='0 0 22 * * ? *';
//         system.schedule('Refund_Pending_Report', sche, nef);
//         Test.StopTest();
//     }
    
// }

@isTest
public class PaasEscalatedBreakUpReportSchedulerTest {
    static testMethod void testPaasCaseReport()
    {
        // list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN');
        insert cs;
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN');
        insert cs2;
        Test.StartTest();   
        /*PaasEscalatedBreakUpReportScheduler nef = new PaasEscalatedBreakUpReportScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, nef);*/
        Test.StopTest();
    }
    
}