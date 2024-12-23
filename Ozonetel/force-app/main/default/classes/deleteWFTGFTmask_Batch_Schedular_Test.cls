@isTest
public class deleteWFTGFTmask_Batch_Schedular_Test
{
    Static TestMethod void Method()
    {
        Test.StartTest();
        deleteWFTGFTmask_Batch_Schedular s = new deleteWFTGFTmask_Batch_Schedular();
        String sche ='0 00 1 3 * ?';
        system.schedule('Test', sche, s);
        Test.StopTest();
    }
}