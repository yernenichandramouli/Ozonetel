global class AmazonCustomerDelightMonthly implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('Amazon_Customer_Delight_Monthly'));
   }
}