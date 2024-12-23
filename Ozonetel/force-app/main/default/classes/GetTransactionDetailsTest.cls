@isTest
public class GetTransactionDetailsTest {  
    @isTest
    public static void testgetFareBifurcation(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        oi.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert oi;
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        test.startTest();       
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        ApexPages.StandardController con = new ApexPages.StandardController(oi);
        getTransactionDetails cls = new getTransactionDetails(con);
        getTransactionDetails.getFareBifurcation(oi.id);  
        test.stopTest();
        GetTransactionDetails.getShowDetails(oi.id);
        Order_Items__c ord=new Order_Items__c();
        ord.name='Transaction-123';
        ord.Order_Item_Reference_No__c='12345';
        ord.Business_Unit__c = 'REDBUS_COM';
        ord.Transaction_Status__c ='Booked';
        ord.Primary_Boarding_Point_Time__c = DateTime.now();
		ord.Primary_Boarding_Point_Time__c = ord.Primary_Boarding_Point_Time__c.addHours(3);
        ord.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert ord;
        GetTransactionDetails.getShowDetails(ord.id);
        GetTransactionDetails.getBusAssignmentDetails(ord.id);
        GetTransactionDetails.yourBusTracking(ord.id);
        GetTransactionDetails.giMMtresponseWrapper gi = new GetTransactionDetails.giMMtresponseWrapper();
        gi.VendorId='TestCase';
        gi.VRouteId='TestCase';
        gi.TravelsName='TestCase';
        gi.SourceId=1;
        gi.RouteId='TestCase';
        gi.DestinationId=2;
        
    }
    @isTest
    public static void testgetFareBifurcation2(){
            Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'APSRTC_IN';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        oi.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert oi;
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'APSRTC_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        test.startTest();       
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        ApexPages.StandardController con = new ApexPages.StandardController(oi);
        getTransactionDetails cls = new getTransactionDetails(con);
        getTransactionDetails.getFareBifurcation(oi.id);  
    }
    @isTest
    public static void getBusAssignmentDetails(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'APSRTC_IN';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        oi.Service_Provider_Id__c='123';
        oi.ServiceID__c='4232';
        oi.Boarding_Time__c=system.now();
        oi.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert oi;
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'APSRTC_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        test.startTest();       
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        ApexPages.StandardController con = new ApexPages.StandardController(oi);
        getTransactionDetails cls = new getTransactionDetails(con);
        getTransactionDetails.getBusAssignmentDetails(oi.id);  
    }

    @isTest
    public static void mmtYourBusTrackingTest(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oI.Inventory_Type__c='MMT';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        oi.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert oi;
        test.startTest();       
        GetTransactionDetails.yourBusTracking(oi.id);
        test.stopTest();
    }

    @isTest
    public static void mmtYourBusTrackingTest2(){
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oI.Inventory_Type__c='MMT';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        oi.ServiceID__c='12322';
        oi.Route_Id__c = '3214';
        oi.Guid__c='a200c1cd22d7f006de86aae304020100';
        insert oi;
        test.startTest();  
        string json =' {"VendorId":"10256","VRouteId":"203-80-946-32006-77578-0","TravelsName":"M R Travels","SourceId":473,"ServiceId":"77578","RouteId":"18381318","DestinationId":70346}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        GetTransactionDetails.yourBusTracking(oi.id);
        test.stopTest();
    }
}