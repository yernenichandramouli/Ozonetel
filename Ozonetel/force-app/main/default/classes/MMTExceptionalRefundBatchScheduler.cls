/**
 * (c) 2023 RedBus
 *
 * Name           : MMTExceptionalRefundBatchScheduler
 * Created Date   : 10 OCT 2022
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1369
 * Purpose        : Schedular class to process all MMT cases for invoicing
 * Test class     : MMTExceptionalRefundBatchSchedulerTest
 *
 **/
global class MMTExceptionalRefundBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        MMTExceptionalRefundBatch mmt = New MMTExceptionalRefundBatch('');
        DataBase.executeBatch(mmt,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}