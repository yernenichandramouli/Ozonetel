@isTest
public with sharing class ShowAmenitiesCtrlTest {
    @isTest
    static void fullRefundTestMethod() {
        Order_Items__c orIt = new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c = '4353';
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c = '2551211';
        orIt.Order_Id__c = '15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Amenities__c = '1,2,3';
        insert orIt;

        ShowAmenitiesCtrl.fetchAmenities(String.valueOf(orIt.Id));
    }
}