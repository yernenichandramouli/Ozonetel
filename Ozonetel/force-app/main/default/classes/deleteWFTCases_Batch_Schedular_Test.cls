@isTest
public class deleteWFTCases_Batch_Schedular_Test
{
    Static TestMethod void Method()
    {
        Test.StartTest();
        deleteWFTCases_Batch_Schedular s = new deleteWFTCases_Batch_Schedular();
        String sche ='0 00 1 3 * ?';
        system.schedule('Test', sche, s);
        Test.StopTest();
    }
}