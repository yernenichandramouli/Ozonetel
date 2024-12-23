/**
 * (c) 2017 RedBus
 *
 * Name           : ReportAsAttachmentBatch
 * Created Date   : 12 Mar 2018
 * Created By     : Sreenivas M
 * Purpose        : Generic Class to send Report as an Attachment
 *
 **/
 
 global class ReportAsAttachmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
 {   
     global final String reportName;
         
     global ReportAsAttachmentBatch(String q)
     {
         reportName = q;
         
     }
     
     global Database.QueryLocator start(Database.BatchableContext bc)
     {
        return Database.getQueryLocator('Select id from Account limit 1');
     } 
    
     global void execute(Database.BatchableContext BC, list<sObject> scope)
     {     
          try
          { 
           System.debug('scope..'+scope);
          }
           Catch(Exception e)
          {
           System.debug('excp..'+e);
          }
     }
     
     
     global void finish(Database.BatchableContext BC) 
     {                 
         Map<String,String> mapReportToDist = new Map<String,string>();
         mapReportToDist.put('Force_Cancellation_Report',System.Label.ForceCancellationReportReceipents);
         mapReportToDist.put('SGMY_Daily_Case_Report',System.Label.sgmyDailyCaseReportReceipents);
         mapReportToDist.put('Report_Content_as_CSV',System.Label.Daily_Case_Report_Recipient);
         mapReportToDist.put('NEFT_Refund_Cases_Report',System.Label.NEFT_Refund_Case_Recipients);
         mapReportToDist.put('BusC_Report_as_Attachment',System.Label.Bus_Cancellation_Cases_Receipents);
         mapReportToDist.put('YourBus_NoReply_Cases',System.Label.YourBus_NoReply_Cases_Recepients);
         mapReportToDist.put('BusCAgeingRefundBreackup',System.Label.BusCAgeingBreakupReport);
         mapReportToDist.put('Zero_Day_BusC_Cases_Breakup',System.Label.BusCAgeingBreakupReport);
         mapReportToDist.put('AutoRefundedClosedCases_Breakup',System.Label.BusCAgeingBreakupReport);
         mapReportToDist.put('BusC_MTD_Cases_And_Refund_Breakup',System.Label.BusCMTDBreakupReport);
         mapReportToDist.put('MIS_Inventory',System.Label.MISReports);
         mapReportToDist.put('MIS_Closure',System.Label.MISReports);
         mapReportToDist.put('MIS_Rejected',System.Label.MISReports);
         mapReportToDist.put('MIS_CSAT',System.Label.MISReports);
         mapReportToDist.put('Amazon_Customer_Delight',System.Label.Amazon_Customer_Delight);
         mapReportToDist.put('Amazon_Customer_Delight_Monthly',System.Label.Amazon_Customer_Delight_Monthly);
         mapReportToDist.put('Indonesia_NEFT_Refund_Report',System.Label.Indonesia_NEFT_Refund_Report);
         mapReportToDist.put('Amazon_Daily_Report',System.Label.Amazon_Daily_Report);
         mapReportToDist.put('IDN_Whatsapp_Messaging_Details',System.Label.IDN_Whatsapp_Messaging_Details);
         mapReportToDist.put('SGMY_Inavlid_Phone_Address',System.Label.SGMYInvalidEmailIds);
         mapReportToDist.put('Refund_Pending_Report',System.Label.PaasEscalatedBreakUpReport);
         mapReportToDist.put('NEFT_cases_Report',System.Label.NeftRepordRecipients);
         mapReportToDist.put('LATAM_NEFT_Refund_Report',System.Label.LATAM_NEFT_Refund_Report);
         mapReportToDist.put('short_route_case_report',System.Label.shortroutecasereport);
         System.debug('Report Name..'+reportName);
         
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         List<String> toAddresses = new List<String>();
 
         if('Bot_Metric_Last_N_Days'.equalsIgnoreCase(reportName))
         {
             toAddresses.addAll([SELECT DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Bot_Metric_Last_N_Days'].DistributionList__c.split(','));
         }
         else
         {
            System.debug('Dist list..'+mapReportToDist.get(reportName));
             toAddresses.addAll(mapReportToDist.get(reportName).Split(','));   
         }
       
         mail.setToAddresses(toAddresses);              
         mail.setTemplateId([SELECT Id FROM EmailTemplate where DeveloperName =:reportName].id);
         mail.setTargetObjectId(UserInfo.getUserId());
         mail.setsaveAsActivity(false);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                      
     }
    
 }