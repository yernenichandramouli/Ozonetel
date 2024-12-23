@isTest
public class deleteWFTCases_Batch_Test
{
    static testMethod void deleteWFTGFTmask_Batch_Batch()
    {
        String oid = String.Valueof(Label.WFT_Queue_Name);
        Case c = new Case();
        c.Ownerid = oid;
        c.Status = 'Open';
        insert c;
        deleteWFTCases_Batch cls = new deleteWFTCases_Batch();
        Id bid = Database.executeBatch(cls,1);
    }
}