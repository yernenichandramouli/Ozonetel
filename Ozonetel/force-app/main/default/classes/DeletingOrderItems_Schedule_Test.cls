@isTest
public class DeletingOrderItems_Schedule_Test
{
    Static TestMethod void method()
    {
        Test.StartTest();
        DeletingOrderItems_Schedule invsch = new DeletingOrderItems_Schedule();
        String sche ='0 00 1 3 * ?';
        system.schedule('Test', sche, invsch);
        Test.StopTest();
    }
}