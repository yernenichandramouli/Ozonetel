@isTest
public class DeletingDBLogs_Schedule_Test
{
    Static TestMethod void method()
    {
        Test.StartTest();
        DeletingDBLogs_Schedule invsch = new DeletingDBLogs_Schedule();
        String sche ='0 00 1 3 * ?';
        system.schedule('Test', sche, invsch);
        Test.StopTest();
    }
}