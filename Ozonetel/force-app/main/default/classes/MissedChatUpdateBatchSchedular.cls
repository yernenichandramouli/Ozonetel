global class MissedChatUpdateBatchSchedular implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        MissedChatUpdateBatch missedChatBatch= new MissedChatUpdateBatch('');
        DataBase.executeBatch(missedChatBatch,200);
    }
}