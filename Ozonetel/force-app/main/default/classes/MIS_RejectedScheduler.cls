global class MIS_RejectedScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('MIS_Rejected'));
   }
}