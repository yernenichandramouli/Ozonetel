global class ZQPCaseAutoClosureBatchSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ZQPCaseAutoClosureBatch zqpBatch= new ZQPCaseAutoClosureBatch('');
        DataBase.executeBatch(zqpBatch,200);
    }
}