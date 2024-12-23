/**
 * (c) 2017 RedBus
 *
 * Name           : BusCancelCasesReportSchedular
 * Created Date   : 30 May 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to send Bus Cancellation cases report daily
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
 
global class BusCancelCasesReportSchedular implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
       /*List<Messaging.SingleEmailMessage> listSmail = new List<Messaging.SingleEmailMessage>();
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.Bus_Cancellation_Cases_Receipents.Split(','));
       mail.setToAddresses(toAddresses);              
       mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName ='BusC_Report_as_Attachment'].id);
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.setsaveAsActivity(false);
       listSmail.add(mail);
       Messaging.sendEmail(listSmail);*/
       
       Database.executeBatch(new ReportAsAttachmentBatch('BusC_Report_as_Attachment'));
                     
   }
                      
}