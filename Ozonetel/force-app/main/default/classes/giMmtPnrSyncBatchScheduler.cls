/**
 * (c) 2023 RedBus
 *
 * Name           : giMmtPnrSyncBatchScheduler
 * Created Date   : 25 JUN 2024
 * Created By     : VR Sudarshan
 * Purpose        : Schedular class to schedule gi mmt pnr sync
 * Test class     : giMmtPnrSyncBatchSchedulerTest
 *
 **/

global class giMmtPnrSyncBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        giMmtPnrSyncBatch giMmt = New giMmtPnrSyncBatch('');
        DataBase.executeBatch(giMmt,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}