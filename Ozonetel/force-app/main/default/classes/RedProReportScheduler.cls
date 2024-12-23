global class RedProReportScheduler implements Schedulable 
{
    global void execute(SchedulableContext ctx) {    
       RedProReport.CaseDetails();
       RedProReportRegionWise.CaseDetails();
      // RedProReportRegionWise.CaseDetails('last30days');
       //RedProReportRegionWise.CaseDetails('MTD');
    }
}