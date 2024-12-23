@isTest
public class IDNWhatsappMessagingDetailsTest {
   static testMethod void IDNWhatsappMessagingTest()
    {
        case c=new case();
        c.Issue_Type__c='Exceptional Refund';
        c.Bank_Name__c='Test Bank';
        c.Status='Open';
        insert c;
        Test.StartTest();   
        IDNWhatsappMessagingDetails nef = new IDNWhatsappMessagingDetails();
        String sche ='0 0 22 * * ? *';
        system.schedule('IDN_Whatsapp_Messaging_Details', sche, nef);
        Test.StopTest();
    }
}