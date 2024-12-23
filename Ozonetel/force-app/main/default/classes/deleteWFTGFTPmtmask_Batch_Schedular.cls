Global class deleteWFTGFTPmtmask_Batch_Schedular implements Schedulable
{
    Global void execute(SchedulableContext sc)
    {
        deleteWFTGFTPmtmask_Batch b= new deleteWFTGFTPmtmask_Batch();
        Database.executebatch(b);
    }
}