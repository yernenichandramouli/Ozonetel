/**
 * (c) 2023 RedBus
 *
 * Name           : LATAMNeftRefundReportScheduler
 * Created Date   : 25 AUG 2023
 * Created By     : Angela Tony
 * Jira Id        : CRM -1494
 * Purpose        : Scheduler to send LATAM_NEFT_Refund_Report report on daily basis.
 * Test class     : LATAMNeftRefundReportSchedulerTest
 *
 **/

global class LATAMNeftRefundReportScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ReportAsAttachmentBatch('LATAM_NEFT_Refund_Report'));
    }

}