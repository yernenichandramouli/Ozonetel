@isTest
private class sgmyDailyCaseReportTest {
    @isTest
    static void testMethod1() {
        Case cs = new Case();
        cs.Status = 'Open';
        cs.origin='Email - hq_sgmy@redbus.my';
        cs.Issue_Type__c = 'I felt unsafe during the journey';
        cs.Issue_Sub_Category__c = 'My bus met with an accident';
        insert cs;
        sgmyDailyCaseReport s = New sgmyDailyCaseReport();
        s.getStatusWiseClosedCases();
    }
}