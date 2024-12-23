/**
 * (c) 2022 RedBus
 *
 * Name           : BusServiceAgeingRefundBatchScheduler
 * Created Date   : 10 OCT 2022
 * Created By     : VR Sudarshan
 * Purpose        : Schedular class to process all bus service ageing cases
 * Test class     : BusServiceAgeingRefundBatchSchedulerTest
 *
 **/
global class BusServiceAgeingRefundBatchScheduler implements Schedulable{
   global void execute(SchedulableContext sc)
    {
        BusServiceAgeingRefundBatch busCan= new BusServiceAgeingRefundBatch('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}