@isTest
public class deleteWFTGFTPmtmask_Batch_Schedular_Test
{
    Static TestMethod void Method()
    {
        Test.StartTest();
        deleteWFTGFTPmtmask_Batch_Schedular s = new deleteWFTGFTPmtmask_Batch_Schedular();
        String sche ='0 00 1 3 * ?';
        system.schedule('Test', sche, s);
        Test.StopTest();
    }
}