/**
 * (c) 2023 RedBus
 *
 * Name           : IDNNeftRefundReportScheduler
 * Created Date   : 02 JUN 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM -1432
 * Purpose        : Scheduler to send Indonesia_NEFT_Refund_Report report on daily basis.
 * Test class     : IDNNeftRefundReportSchedulerTest
 *
 **/
global class IDNNeftRefundReportScheduler implements Schedulable {
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new ReportAsAttachmentBatch('Indonesia_NEFT_Refund_Report'));
    }
}