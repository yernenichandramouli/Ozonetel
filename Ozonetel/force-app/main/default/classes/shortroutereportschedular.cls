global class shortroutereportschedular implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
        Database.executeBatch(new ReportAsAttachmentBatch('short_route_case_report'));
        //Test changes to push to git
                     
   }
                      
}