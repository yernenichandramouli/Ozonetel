/**
 * (c) 2023 RedBus
 *
 * Name           : MMTTransactionSyncBatchScheduler
 * Created Date   : 12 JUN 2023
 * Created By     : VR Sudarshan
 * Purpose        : Schedular class to process MMTTransactionSyncBatch.
 * Test class     : MMTTransactionSyncBatchSchedulerTest
 *
 **/
global class MMTTransactionSyncBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        MMTTransactionSyncBatch mmt = New MMTTransactionSyncBatch('');
        DataBase.executeBatch(mmt,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}