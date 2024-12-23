Global class deleteWFTCases_Batch_Schedular implements Schedulable
{
    Global void execute(SchedulableContext sc)
    {
        deleteWFTCases_Batch b= new deleteWFTCases_Batch();
        Database.executebatch(b);
    }
}