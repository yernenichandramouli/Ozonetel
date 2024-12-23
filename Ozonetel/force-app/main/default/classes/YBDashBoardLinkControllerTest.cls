@isTest
private class YBDashBoardLinkControllerTest {
    @isTest static void testMethod1(){
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Service_Provider_Id__c = '16728';
        ordItem.ServiceID__c ='1146';
        ordItem.Business_Unit__c ='REDBUS_IN';
        ordItem.Boarding_Time__c = System.now();
        insert ordItem;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', ''));
        YBDashBoardLinkController.GetAllBps(ordItem.Id);
        YBDashBoardLinkController.GetTrackingDetails(ordItem.Id);
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Service_Provider_Id__c = '16728';
        ordItem.ServiceID__c ='1146';
        insert ordItem;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', ''));
        YBDashBoardLinkController.Getarrivalpatterns(ordItem.Id, '12345');
        Test.stopTest();
    }
}