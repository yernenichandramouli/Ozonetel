/**
 * (c) 2022 RedBus
 *
 * Name           : YourBusNoReplyReportScheduler
 * Created Date   : 17 NOV 2022
 * Created By     : VR Sudarshan
 * JiraId         : CRM-1230
 * Purpose        : Schedular class to send YourBus esclated/No reply cases.
 * Test class     : YourBusNoReplyReportSchedulerTest
 *
 **/
global class YourBusNoReplyReportScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        Database.executeBatch(new ReportAsAttachmentBatch('YourBus_NoReply_Cases'));
    }
}