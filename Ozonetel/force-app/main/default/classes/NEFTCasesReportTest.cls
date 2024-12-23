@isTest
public class NEFTCasesReportTest {
    static testMethod void testNEFTCaseReport()
    {
        case c=new case();
        c.Issue_Type__c='NEFT Refund';
        c.Bank_Name__c='Test Bank';
        c.Status='Open';
        insert c;
        Test.StartTest();   
        NEFTCasesReport nef = new NEFTCasesReport();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, nef);
        Test.StopTest();
    }
    
}