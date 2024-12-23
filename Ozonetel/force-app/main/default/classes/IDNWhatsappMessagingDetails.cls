global class IDNWhatsappMessagingDetails implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('IDN_Whatsapp_Messaging_Details'));
   }
}