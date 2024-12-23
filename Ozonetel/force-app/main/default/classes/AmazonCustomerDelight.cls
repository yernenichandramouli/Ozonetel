global class AmazonCustomerDelight implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('Amazon_Customer_Delight'));
        Database.executeBatch(new ReportAsAttachmentBatch('Amazon_Daily_Report'));
   }

}