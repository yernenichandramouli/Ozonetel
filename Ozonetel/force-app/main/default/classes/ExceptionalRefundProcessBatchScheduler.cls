global class ExceptionalRefundProcessBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ExceptionalRefundProcessScheduler busCan= new ExceptionalRefundProcessScheduler();
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}