/**
 * (c) 2018 RedBus
 *
 * Name           : BusCancellationAgeingRefundSchedular
 * Created Date   : 12 Apr 2018
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to process all ageing bus cancellation cases
 * Test class     : BusCancellationAgeingRefundSchedularTest
 *
 **/
 
global class BusCancellationAgeingRefundSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        BusCancellationAgeingRefundBatch busCan= new BusCancellationAgeingRefundBatch('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}