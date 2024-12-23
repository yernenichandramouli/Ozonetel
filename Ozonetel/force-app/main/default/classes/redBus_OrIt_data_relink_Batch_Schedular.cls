global class redBus_OrIt_data_relink_Batch_Schedular implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        redBus_OrderIteam_data_relink_Batch  batchJob = new redBus_OrderIteam_data_relink_Batch();
        Database.executeBatch(batchJob,50);
    }
}