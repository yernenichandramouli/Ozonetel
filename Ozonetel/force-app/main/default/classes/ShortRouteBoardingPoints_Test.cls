@isTest
public class ShortRouteBoardingPoints_Test {
    
    @testsetup
    static void insertData(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Route_Id__c='12345';
        oi.Source_City_Id__c='462';
        oi.Destination_City_Id__c='130';
        insert oi;
    }
    
    @istest static void methodToCheckBoardingPoints(){
        Order_Items__c oi=[select id,name,Route_Id__c,Source_City_Id__c,Destination_City_Id__c from Order_Items__c];
        test.startTest();
        ApexPages.StandardController con = new ApexPages.StandardController(oi);
        ShortRouteBoardingPoints tra=new ShortRouteBoardingPoints(con); 
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        ShortRouteBoardingPoints.getBoardingPoints(oi.Source_City_Id__c,oi.Destination_City_Id__c,'06-07-2019');
        test.stopTest();
    }
    
    @istest static void methodToCheckBusDetails(){
        Order_Items__c oi=[select id,name,Route_Id__c,Source_City_Id__c,Destination_City_Id__c from Order_Items__c];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        ApexPages.StandardController con = new ApexPages.StandardController(oi);
        ShortRouteBoardingPoints tra=new ShortRouteBoardingPoints(con); 
        ShortRouteBoardingPoints.getBusesDetails(oi.Source_City_Id__c,oi.Destination_City_Id__c,'5675','06-07-2019');
        test.stopTest();
        // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
    }
}