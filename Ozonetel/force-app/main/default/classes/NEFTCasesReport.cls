/**
 *
 * Name           : NEFTCasesReport 
 * Created Date   : 8 Aug 2017
 * Created By     : Veeramanikanta R
 * Purpose        : Schedular class to send NEFT cases report daily
 * Test Class     : NEFTCasesReportTest
 *
 **/
 
global class NEFTCasesReport implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
       List<Case> caseList=new List<Case>();
       caseList=[select id from Case where status!='Closed' AND (Issue_Type__c='NEFT Refund' OR Issue_Type__c='NEFT Wallet Debit') AND Bank_Name__c!=''];
       if(!caseList.isEmpty()){
      /* List<Messaging.SingleEmailMessage> listSmail = new List<Messaging.SingleEmailMessage>();
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.addAll(Label.NEFT_Refund_Case_Recipients.Split(','));
       mail.setToAddresses(toAddresses);              
       mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName ='NEFT_Refund_Cases_Report'].id);
       mail.setTargetObjectId(UserInfo.getUserId());
       mail.setsaveAsActivity(false);
       listSmail.add(mail);          
       Messaging.sendEmail(listSmail);*/
       Database.executeBatch(new ReportAsAttachmentBatch('NEFT_Refund_Cases_Report'));
       }               
   }
                      
}