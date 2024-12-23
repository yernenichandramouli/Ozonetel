/**
 * (c) 2018 RedBus
 *
 * Name           : BusCancellationInvoicingBatchSchedular
 * Created Date   : 14 JAN 2023
 * Created By     : Sreenivas M
 * Purpose        : Schedular class
 * Test class     : BusCancellationInvoicingSchedularTest
 *
 **/
 
global class BusCancellationInvoicingBatchSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        BusCancellationInvoicingBatch busCan= new BusCancellationInvoicingBatch('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}