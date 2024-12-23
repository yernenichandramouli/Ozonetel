/**
 * (c) 2017 RedBus
 *
 * Name           : CaseReportCSVSchedulerTest
 * Created Date   : 3 May 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for CaseReportCSVScheduler and GenerateCSVAttach
 *
 **/
 
@isTest
private class CaseReportCSVSchedulerTest
{
     @isTest static void CSVReportSchedulerTest() 
     {
      
      Case cs = new Case();
      cs.issue_Type__c ='Bus Cancellation';
      cs.isAgeing_Refund_Success__c =true;
      cs.isAgening_Refund_Processed__c =true;
      cs.Status='Initiated';
      cs.Ageing_Status__c ='Initiated';
      cs.Total_Fare_Value__c = 20.0;
      insert cs;
      Test.StartTest(); 
         
           CaseReportCSVScheduler sch = new CaseReportCSVScheduler();
           String sche ='0 0 22 * * ? *';
           system.schedule('Test', sche, sch);
           
           BusCancelCasesReportSchedular busC= new BusCancelCasesReportSchedular();          
           system.schedule('Test2', sche, busC);
           
           ForceCancelCasesReportSchedular fcs = new ForceCancelCasesReportSchedular();
           system.schedule('Test3', sche, fcs);
           
           BusCAgeingRefundReportSchedular busBrek = new BusCAgeingRefundReportSchedular(true,true,true,true);
           system.schedule('Test4', sche, busBrek);           
                   
        Test.StopTest();
     }
}