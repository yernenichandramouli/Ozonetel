@isTest
public class MIS_InventorySchedulerTest
{
    static testMethod void MIS_InventoryTest()
    {
        Test.startTest();
        MIS_InventoryScheduler misSch= new MIS_InventoryScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, misSch);
        Test.stopTest();
    }
    static testMethod void MIS_RejectedTest()
    {
        Test.startTest();
        MIS_RejectedScheduler misSch= new MIS_RejectedScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, misSch);
        Test.stopTest();
    }
    static testMethod void MIS_ClosureTest()
    {
        Test.startTest();
        MIS_ClosureScheduler misSch= new MIS_ClosureScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, misSch);
        Test.stopTest();
    }
    static testMethod void MIS_CSATTest()
    {
        Test.startTest();
        MIS_CSATScheduler misSch= new MIS_CSATScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, misSch);
        Test.stopTest();
    }
     static testMethod void AmazonCustomerDelightTest()
    {
        Test.startTest();
        AmazonCustomerDelight misSch= new AmazonCustomerDelight();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, misSch);
        Test.stopTest();
    }
    
}