global class DeletingDBLogs_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        DeletingDBLogs delcls= new DeletingDBLogs();
        DataBase.executeBatch(delcls);
    }
}