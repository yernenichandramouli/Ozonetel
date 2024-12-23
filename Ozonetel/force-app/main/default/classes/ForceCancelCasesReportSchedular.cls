/**
 * (c) 2017 RedBus
 *
 * Name           : ForceCancelCasesReportSchedular
 * Created Date   : 21 Nov 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to send Force Cancellation cases report daily
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
 
global class ForceCancelCasesReportSchedular implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
       /*List<Messaging.SingleEmailMessage> listSmail = new List<Messaging.SingleEmailMessage>();
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.ForceCancellationReportReceipents.Split(','));
       mail.setToAddresses(toAddresses);              
       mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName ='Force_Cancellation_Report'].id);
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.setsaveAsActivity(false);
       listSmail.add(mail);
       Messaging.sendEmail(listSmail);*/
       
        Database.executeBatch(new ReportAsAttachmentBatch('Force_Cancellation_Report'));
                     
   }
                      
}