/**
 * (c) 2023 RedBus
 *
 * Name           : CreateExceptionalRefundCaseFuture
 * Created Date   : 12 MAY 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1381
 * Purpose        : To create Exceptional Refund Case in future contest.
 * Test class     : CreateExceptionalRefundCaseFutureTest
 *
 **/
global class CreateExceptionalRefundCaseFuture {
    @future
    public static void createSHExceptionCase(string caseNumber, String tinNumber) {
        if(String.isNotEmpty(caseNumber) && string.isNotEmpty(tinNumber)){
            API_Complaint_Tracker.CreateExceptionalRefundCase(caseNumber,tinNumber);
        }
    }
}