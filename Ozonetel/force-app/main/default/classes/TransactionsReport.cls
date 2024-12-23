/**
 *
 * Name           : TransactionsReport 
 * Created Date   : 26 Aug 2017
 * Created By     : Veeramanikanta R
 * Purpose        : Schedular class to send booked transactions report daily
 * Test Class     : TransactionsReportTest
 *
 **/
 
global class TransactionsReport implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
      List<Messaging.SingleEmailMessage> listSmail = new List<Messaging.SingleEmailMessage>();
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.Transaction_Report_Recipients.Split(','));
       mail.setToAddresses(toAddresses);              
       mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName ='Yesterday_Transactions'].id);
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.setsaveAsActivity(false);
       listSmail.add(mail);          
       Messaging.sendEmail(listSmail);    
                      
   }
                      
}