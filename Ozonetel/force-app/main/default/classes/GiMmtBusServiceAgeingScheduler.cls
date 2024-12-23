/**
 * (c) 2022 RedBus
 *
 * Name           : GiMmtBusServiceAgeingScheduler
 * Created Date   : 08 JUL 2024
 * Created By     : VR Sudarshan
 * Purpose        : scheduler to process Batch class .
 * Test class     : GiMmtBusServiceAgeingBatchSchedulerTest
 *
 **/
global class GiMmtBusServiceAgeingScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        GiMmtBusServiceAgeingRefundBatch busCan= new GiMmtBusServiceAgeingRefundBatch('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));

        // GiMmtBusCancellationAgeingRefund busCance= new GiMmtBusCancellationAgeingRefund('');
        // DataBase.executeBatch(busCance,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}