global with sharing class PaasEscalatedBreakUpReportScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ReportAsAttachmentBatch('Refund_Pending_Report'));
    }
}