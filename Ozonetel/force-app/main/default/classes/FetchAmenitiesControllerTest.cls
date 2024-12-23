@isTest
private class FetchAmenitiesControllerTest {
    @isTest
    static void fetchAmenitesTestMethod(){
        Test.startTest();
        string json='[{"Id":1,"Name":"WIFI","Display_Name":"WIFI","Description":"WIFI","Active_CSS_Class":"","Category":"OTHER","AddedBy":"Mahendar"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        FetchAmenitiesScheduler busCan = New FetchAmenitiesScheduler();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
    @isTest
    static void fetchAmenitesExceptionTestMethod(){
        Test.startTest();
        string json='[{"Id":1,"Name":"WIFI","Display_Name":"WIFI","Description":"WIFI","Active_CSS_Class":"","Category":"OTHER","AddedOn":"\"Mar 8, 2013 4:34:54 PM\"","AddedBy":"Mahendar"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        FetchAmenitiesScheduler busCan = New FetchAmenitiesScheduler();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}