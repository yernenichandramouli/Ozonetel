@isTest
public class AmazonCustomerDelightMonthlyTest{
    static testMethod void AmazonCustomerDelightTest()
    {
        case c=new case();
        c.Issue_Type__c='Exceptional Refund';
        c.Bank_Name__c='Test Bank';
        c.Status='Open';
        insert c;
        Test.StartTest();   
        AmazonCustomerDelightMonthly nef = new AmazonCustomerDelightMonthly();
        String sche = '0 0 0 ? * * *';
        system.schedule('Amazon_Customer_Delight_Monthly', sche, nef);
        Test.StopTest();
    }
    
}