Global class deleteWFTGFTmask_Batch_Schedular implements Schedulable
{
    Global void execute(SchedulableContext sc)
    {
        deleteWFTGFTmask_Batch b= new deleteWFTGFTmask_Batch();
        Database.executebatch(b);
    }
}