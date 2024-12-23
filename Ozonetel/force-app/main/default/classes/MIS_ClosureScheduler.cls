global class MIS_ClosureScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('MIS_Closure'));
   }
}