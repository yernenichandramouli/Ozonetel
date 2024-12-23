global class MIS_InventoryScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('MIS_Inventory'));
   }
}