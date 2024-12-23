@isTest
private class SendRailsTicketControllerTest {

    @isTest static void testMethod1(){
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Item_Type__c = 'RAILS';
        ordItem.Transaction_Status__c ='Booked';
        ordItem.Guid__c='fbe5c256e331e005d4b52ab401020a00';
        ordItem.Service_Provider_Name__c='TEST';
        ordItem.Business_Unit__c='REDRAILS_IN';
        ordItem.Email__c='test@gmail.com';
        ordItem.Mobile__c='9198765432100';
        insert ordItem;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', ''));
        SendRailsTicketController.SendTicketDetails(ordItem.id,'1234567890',true,'test@gmail.com',true);
        Test.stopTest();  
    }
}