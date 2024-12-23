/**
 * (c) 2017 RedBus
 *
 * Name           : CaseReportCSVScheduler
 * Created Date   : 3 May 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to send cases report regulary as an attachment
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
 
global class CaseReportCSVScheduler implements Schedulable
{
   global void execute(SchedulableContext ctx) 
   {
  /* Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   List<String> toAddresses = new List<String>();
   toAddresses.addAll(Label.Daily_Case_Report_Recipient.Split(','));
   mail.setToAddresses(toAddresses);              
   mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName ='Report_Content_as_CSV'].id);
   mail.setTargetObjectId(UserInfo.getUserId());
   mail.setsaveAsActivity(false);
   Messaging.sendEmail(New Messaging.SingleEmailMessage[] {mail});*/
   Database.executeBatch(new ReportAsAttachmentBatch('Report_Content_as_CSV'));
                     
   }
                        
}