@isTest
private class ybTrackingCtrlTest {

    @isTest static void fetchBpDpDetailsTest() {
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        ordItem.Boarding_Time__c= System.now();
        string b2bRecType =  Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
        ordItem.recordTypeId = b2bRecType;
        insert ordItem;
        Test.startTest();
        string json='{"msg":"","data":{"vehicle_no":"","traveler_name":"Raj Travels Udaipur","route":"Udaipur-Jodhpur","doj":"2024-02-20","driver_details":"","bp_contact":"Udiapole - 8696971008","dp_conatct":"Barvi Road - 9414737477","tracking_type":"Full Tracking","redbus_tarcking_link":"","yourbus_tracking_link":"https://b.redbus.com/Uc7Ik4e6e","bp_name":"Udiapole","bp_sta":"22:30:00","bp_address":"Udiapole Shop no 2 Under Hotel City Express","bp_street_view_link":"Test","bp_address_link":"Test","dp_name":"Barvi Road","dp_sta":"05:30:00","dp_address":"Barvi Road","dp_street_view_link":"","dp_address_link":"Test","yb_enabled":1,"service_no":"RTUUDAIPUR-JODHPUR-1030PM","service_bps":{"1429339":"Udiapole, 22:30","1429340":"Town Hall, 22:35","1429341":"Fatehpura, 22:48","1446622":"Sardarpura Panchwati, 22:46","1741890":"Celebration Mall, 22:52","1741891":"Bhuwana Bypass, 22:55","17766362":"Paras Circle, 22:50","17824605":"PALI - NEW BUS STAND, 04:30","17832442":"Court Chourha, 22:40","18467804":"Ananta Hospital, 23:05","18492069":"Rajnagar Ramdev Circle, 23:50","18492070":"Opp Choudhary Petrol Pump, 23:40","18913791":"Amberi Puliya, 23:00","21738790":"Meera Girls College, 22:44","21738791":"Bansi Pan, 22:42","21738823":"Delhi Gate, 22:37","22918678":"Gomti Choraya, 01:00","22968580":"Ramdev Chouraha, 23:59","23689787":"Kelwa Chopati, 00:30"}}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ybTrackingCtrl.fetchBpDpDetails(ordItem.id);
        Test.stopTest();
    }

    @isTest static void fetchArrivalPatternTest() {
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        ordItem.Boarding_Time__c= System.now();
        ordItem.Service_Provider_Id__c = '11323';
        ordItem.ServiceID__c = '323';
        ordItem.Boarding_Point_Id__c = 'TESTTEST';
        string b2bRecType =  Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
        ordItem.recordTypeId = b2bRecType;
        insert ordItem;
        Test.startTest();
        string json='{"rbOperatorId": "16027", "serviceId": "55", "rbBpId": "1732964"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ybTrackingCtrl.Getarrivalpatterns(ordItem.id,'TESTTEST');
        Test.stopTest();
    }

    @isTest static void fetchBpDpDetailsExceptionTest() {
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        ordItem.Boarding_Time__c= System.now();
        string b2bRecType =  Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
        ordItem.recordTypeId = b2bRecType;
        insert ordItem;
        Test.startTest();
        string json='{"msg":"","data":{"vehicle_no":"","traveler_name":"Raj Travels Udaipur","route":"Udaipur-Jodhpur","doj":"2024-02-20","driver_details":"","bp_contact":"Udiapole - 8696971008","dp_conatct":"Barvi Road - 9414737477","tracking_type":"Full Tracking","redbus_tarcking_link":"","yourbus_tracking_link":"https://b.redbus.com/Uc7Ik4e6e","bp_name":"Udiapole","bp_sta":"22:30:00","bp_address":"Udiapole Shop no 2 Under Hotel City Express","bp_street_view_link":"Test","bp_address_link":"Test","dp_name":"Barvi Road","dp_sta":"05:30:00","dp_address":"Barvi Road","dp_street_view_link":"","dp_address_link":"Test","yb_enabled":1,"service_no":"RTUUDAIPUR-JODHPUR-1030PM","service_bps":{"1429339":"Udiapole, 22:30","1429340":"Town Hall, 22:35","1429341":"Fatehpura, 22:48","1446622":"Sardarpura Panchwati, 22:46","1741890":"Celebration Mall, 22:52","1741891":"Bhuwana Bypass, 22:55","17766362":"Paras Circle, 22:50","17824605":"PALI - NEW BUS STAND, 04:30","17832442":"Court Chourha, 22:40","18467804":"Ananta Hospital, 23:05","18492069":"Rajnagar Ramdev Circle, 23:50","18492070":"Opp Choudhary Petrol Pump, 23:40","18913791":"Amberi Puliya, 23:00","21738790":"Meera Girls College, 22:44","21738791":"Bansi Pan, 22:42","21738823":"Delhi Gate, 22:37","22918678":"Gomti Choraya, 01:00","22968580":"Ramdev Chouraha, 23:59","23689787":"Kelwa Chopati, 00:30"}}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        ybTrackingCtrl.fetchBpDpDetails(ordItem.id);
        Test.stopTest();
    }

    @isTest static void fetchBpDpDetailsException2Test() {
        Order_Items__c ordItem = new Order_Items__c();
        ordItem.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        ordItem.Boarding_Time__c= System.now();
        string b2bRecType =  Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
        ordItem.recordTypeId = b2bRecType;
        insert ordItem;
        Test.startTest();
        string json='{"msg":"asadsadsadsdsad","data":{"vehicle_no":"","traveler_name":"Raj Travels Udaipur","route":"Udaipur-Jodhpur","doj":"2024-02-20","driver_details":"","bp_contact":"Udiapole - 8696971008","dp_conatct":"Barvi Road - 9414737477","tracking_type":"Full Tracking","redbus_tarcking_link":"","yourbus_tracking_link":"https://b.redbus.com/Uc7Ik4e6e","bp_name":"Udiapole","bp_sta":"22:30:00","bp_address":"Udiapole Shop no 2 Under Hotel City Express","bp_street_view_link":"Test","bp_address_link":"Test","dp_name":"Barvi Road","dp_sta":"05:30:00","dp_address":"Barvi Road","dp_street_view_link":"","dp_address_link":"Test","yb_enabled":1,"service_no":"RTUUDAIPUR-JODHPUR-1030PM","service_bps":null}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ybTrackingCtrl.fetchBpDpDetails(ordItem.Id);
        Test.stopTest();
    }

    @isTest static void wrapperTest(){
        ybTrackingCtrl.data wrapTestData = New  ybTrackingCtrl.data();
        wrapTestData.vehicle_no = 'TEST';
        wrapTestData.traveler_name = 'TEST';
        wrapTestData.route = 'TEST';
        wrapTestData.doj = 'TEST';
        wrapTestData.driver_details = 'TEST';
        wrapTestData.bp_contact = 'TEST';
        wrapTestData.dp_conatct = 'TEST';
        wrapTestData.tracking_type = 'TEST';
        wrapTestData.redbus_tarcking_link = 'TEST';
        wrapTestData.yourbus_tracking_link = 'TEST';
        wrapTestData.bp_name = 'TEST';
        wrapTestData.bp_sta = 'TEST';
        wrapTestData.bp_address = 'TEST';
        wrapTestData.bp_street_view_link = 'TEST';
        wrapTestData.bp_address_link = 'TEST';
        wrapTestData.dp_name = 'TEST';
        wrapTestData.dp_sta = 'TEST';
        wrapTestData.dp_address = 'TEST';
        wrapTestData.dp_street_view_link = 'TEST';
        wrapTestData.dp_address_link = 'TEST';
        wrapTestData.yb_enabled = 1;
        wrapTestData.service_no = 'TEST';
    }
}