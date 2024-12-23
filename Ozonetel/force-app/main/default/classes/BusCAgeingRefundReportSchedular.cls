/**
 * (c) 2017 RedBus
 *
 * Name           : BusCAgeingRefundReportSchedular
 * Created Date   : 25 Apr 2018
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to send bus cancellation ageing refund cases report daily
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
 
global class BusCAgeingRefundReportSchedular implements Schedulable 
{
   Boolean runRefundBreakup=false;
   Boolean runZeroDayBreakup=false;
   Boolean runClosedNotesBreakup=false;
   Boolean runMTDBreakup=false;
   
   public BusCAgeingRefundReportSchedular(Boolean isRefundBrkup,Boolean isZerodayBrkup,Boolean isClosedNotesBrkup,Boolean isMTDBrkup)
   {
       runRefundBreakup = isRefundBrkup;
       runZeroDayBreakup = isZerodayBrkup;
       runClosedNotesBreakup = isClosedNotesBrkup;
       runMTDBreakup = isMTDBrkup;
  }
   
   global void execute(SchedulableContext ctx) 
   {
        if(runRefundBreakup)
            Database.executeBatch(new ReportAsAttachmentBatch('BusCAgeingRefundBreackup'));
        
        if(runZeroDayBreakup)
            Database.executeBatch(new ReportAsAttachmentBatch('Zero_Day_BusC_Cases_Breakup'));
            
        if(runClosedNotesBreakup)
            Database.executeBatch(new ReportAsAttachmentBatch('AutoRefundedClosedCases_Breakup'));
        
        if(runMTDBreakup)
            Database.executeBatch(new ReportAsAttachmentBatch('BusC_MTD_Cases_And_Refund_Breakup'));
                     
   }
                      
}