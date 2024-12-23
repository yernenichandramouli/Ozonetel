global with sharing class NEFTcasesAgeingReportScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ReportAsAttachmentBatch('NEFT_cases_Report'));
    }
}