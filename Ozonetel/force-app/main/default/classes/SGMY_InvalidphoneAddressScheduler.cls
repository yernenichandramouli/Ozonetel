global class SGMY_InvalidphoneAddressScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('SGMY_Inavlid_Phone_Address'));
   }
}