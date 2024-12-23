global class MIS_CSATScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('MIS_CSAT'));
   }
}