/**
 * (c) 2017 RedBus
 *
 * Name           : DeletingDBLogSummaryTest
 * Created Date   : 18 Apr 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for DeletingDBLogSummary class
 *
 **/
 
@isTest
private class DeletingDBLogSummaryTest
{
     @isTest static void testDBLogSummary()
     {
      
           DBLog_Summary__c dbl = new DBLog_Summary__c();
           dbl.type__c = 'New User GFT';
           insert dbl;
           Test.setCreatedDate(dbl.Id, DateTime.newInstance(2012,12,12));   
                  
         Test.StartTest();   
           DeletingDBLogSummarySchedule dblog = new DeletingDBLogSummarySchedule();
           String sche ='0 0 22 * * ? *';
           system.schedule('Test', sche, dblog);
        Test.StopTest();
      
      }
}