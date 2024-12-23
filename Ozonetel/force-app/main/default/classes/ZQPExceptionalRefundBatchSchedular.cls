global class ZQPExceptionalRefundBatchSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ZQPExceptionalRefundBatch zqpBatch= new ZQPExceptionalRefundBatch('');
        DataBase.executeBatch(zqpBatch,25);
    }
}