/**
 * (c) 2017 RedBus
 *
 * Name           : DeletingDBLogSummarySchedule
 * Created Date   : 19 Apr 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to call DB Log Summary Details Batch
 * Test class     : DeletingDBLogSummaryTest
 *
 **/
 
global class DeletingDBLogSummarySchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        DeletingDBLogSummaryBatch delcls= new DeletingDBLogSummaryBatch();
        DataBase.executeBatch(delcls);
    }
}