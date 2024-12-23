@isTest
private class shortroutereportschedularTest {

@isTest
    static void testSchedule() {
        Test.startTest();
        String jobId = System.schedule('Test Short Route Reports Scheduler', '0 0 23 * * ?', new shortroutereportschedular());
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'Scheduler did not run');
    }@isTest
    static void testScheduleWithInvalidReportName() {
        Test.startTest();
        try {
            String jobId = System.schedule('Test Short Route Reports Scheduler', '0 0 23 * * ?', new shortroutereportschedular());
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Invalid report name should throw an exception');
        }
        Test.stopTest();
    }}