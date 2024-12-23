@isTest
private class CoPassengerDetailsCtrlTest {
    @isTest
    static void GetCoPassengerDetailsTestMethod() {
        Order_Items__c ot=new Order_Items__c ();
        ot.Order_Item_Reference_No__c='TP2V93248582';
        ot.Business_Unit__c='REDBUS_IN';
        ot.Boarding_Time__c=System.now();
        ot.Primary_Boarding_Point_Time__c=System.now();
        insert ot;
        OrderItemTransactionResource__c ott=new OrderItemTransactionResource__c();
        ott.name='REDBUS_IN';
        ott.Auth_Key__c='2334';
        ott.Default_Currency__c='INR';
        insert ott;
        Country_Codes__c cc=new Country_Codes__c();
        cc.name='REDBUS_IN';
        cc.ou__c='1';
        insert cc;
        Test.startTest();
        string json='{"status":"SUCCESS","errors":[],"data":[{"tin":"TS4Y20972251","status":"CONFIRMED","phone":"919711199699","orderItemId":"13442602896176586","orderId":"13441372740459577","name":"cksharma","email":"omgoldenlight@gmail.com","droppingPoint":"Nepali Farm","boardingPoint":"Dilshad Garden (MarutiSuzuki)"},{"tin":"TS5674636566","status":"CONFIRMED","phone":"919873738212","orderItemId":"13446719657130745","orderId":"13446719657115609","name":"papendra","email":"papychauhan@gmail.com","droppingPoint":"Rispana Bridge, Dehradun","boardingPoint":"Anand Vihar (ITC Travels)"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CoPassengerDetailsCtrl.GetCoPassengerDetails(ot.id);
        Test.stopTest();
    }
    
    @isTest
    static void GetB2BCoPassengerDetailsTestMethod() {
        Order_Items__c ot=new Order_Items__c ();
        ot.Order_Item_Reference_No__c='TP2V93248582';
        ot.Business_Unit__c='REDBUS_IN';
        ot.Date_Of_Service__c=System.now();
        ot.Primary_Boarding_Point_Time__c=System.now();
        ot.Route_Id__c = '123456';
        insert ot;
        OrderItemTransactionResource__c ott=new OrderItemTransactionResource__c();
        ott.name='REDBUS_IN';
        ott.Auth_Key__c='2334';
        ott.Default_Currency__c='INR';
        insert ott;
        Country_Codes__c cc=new Country_Codes__c();
        cc.name='REDBUS_IN';
        cc.ou__c='1';
        insert cc;
        Test.startTest();
        string responseBody = '{"passengerTickets":[{"iSServiceIdIGDoj":2122502247580075491,"tin":"D8QKCPFP","pnr":"D8QKCPFP","source":"Kolar","destination":"Hisar","seats":["1"],"boardingPoint":"Kolar","boardingPointId":188606,"boardingTime":1110,"fare":55.50,"bookedByAccount":20820329,"bookedBy":"whatsapp feature testing","account":20820329,"accountName":"whatsapp feature testing","passengerName":"test_automation_passenger_name","mobile":"8909876543","bookingType":"STANDARD","bookingTime":"2023-12-27T15:19:30.000+0530","bookingAgent":"whatsapp feature testing","altArranged":false,"altInformed":false,"salesChannel":"api","travels":"Virtual_travels","dropLocation":"Hyderabad","dropLocationId":189153,"dropLocationTime":930,"agentServiceCharge":0.00,"ticketId":40510202,"itineraryLegId":40538746,"operator":10011111,"doj":"2024-01-11T00:00:00.000+0530","phoneReservation":false,"postPonedTicket":false},{"iSServiceIdIGDoj":2122502247580075491,"tin":"D896B4S5","pnr":"D896B4S5","source":"Kolar","destination":"Hisar","seats":["2"],"boardingPoint":"Kolar","boardingPointId":188606,"boardingTime":1110,"fare":55.50,"bookedByAccount":20820329,"bookedBy":"whatsapp feature testing","account":20820329,"accountName":"whatsapp feature testing","passengerName":"test_automation_passenger_name","mobile":"8909876543","bookingType":"STANDARD","bookingTime":"2023-12-27T15:44:48.000+0530","bookingAgent":"whatsapp feature testing","altArranged":false,"altInformed":false,"salesChannel":"api","travels":"Virtual_travels","dropLocation":"Hisar Bus Stop","dropLocationId":189153,"dropLocationTime":930,"agentServiceCharge":0.00,"ticketId":40510214,"itineraryLegId":40538759,"operator":10011111,"doj":"2024-01-11T00:00:00.000+0530","phoneReservation":false,"postPonedTicket":false}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', responseBody));
        CoPassengerDetailsCtrl.GetB2BCoPassengerDetails(ot.id);
        Test.stopTest();
    }
    // @isTest
    // static void wrapperTestMethod(){
    //     CoPassengerDetailsCtrl = New CoPassengerDetailsCtrl();
        
        
    // }
}