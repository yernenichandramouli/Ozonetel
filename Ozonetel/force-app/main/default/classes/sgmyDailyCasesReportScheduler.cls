/**
 * (c) 2023 RedBus
 *
 * Name           : sgmyDailyCasesReportScheduler
 * Created Date   : 24 JUL 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM - 1455
 * Purpose        : Scheduler to send SGMY closed report.
 * Test class     : sgmyDailyCasesReportSchedulerTest
 *
 **/
global class sgmyDailyCasesReportScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ReportAsAttachmentBatch('SGMY_Daily_Case_Report'));
    }
}