@isTest
public class API_WhatsappNotificationTest
{
    static testMethod void WASendTest()
    {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string JsonMsg='{\"MessageDetails\":{\"TemplateName\":\"MTicketSMSMessage_WHATSAPP\",\"DataJsonStr\":\"{\\"WhatsAppNumber\\":\\"919491322718\\",\\"bpAddress\\":\\"TestbpAddress\\",\\"bpContactNo\\":\\"TestbpContactNo\\",\\"sourceLocation\\":\\"Pulai Chondong,Pulau Chondong,Kelantan\\",\\"destinationLocation\\":\\"__Sarikei,Sarikei Express Terminal\\",\\"orderItemReferenceNo\\":\\"MYQAD82361029\\",\\"doj\\":\\"23-Sep-2021 11:00\\",\\"dojIn12hrsFormat\\":\\"23-Sep-2021 11:00 AM\\",\\"ServiceProviderReferenceNo\\":\\"A6UT44ED\\",\\"TripId\\":\\"\\",\\"Connection\\":null,\\"passengerPNR\\":\\"\\",\\"Travels\\":\\"Test Malaysia\\",\\"Fare\\":\\"2.0\\",\\"Currency\\":\\"MYR\\",\\"BoardingPoint\\":\\"Pulau Chondong,Kelantan\\",\\"DroppingPoint\\":\\"Sarikei,Sarawak\\",\\"SupportContactNo\\":\\"+60-330992524\\",\\"Seats\\":\\"2\\",\\"SeatWisePNR\\":\\"2\\",\\"PnrList\\":\\"A6UT44ED\\",\\"TotalNoOfSeats\\":\\"1\\",\\"PassName\\":\\"Test\\",\\"serviceProviderName\\":\\"Test Malaysia\\",\\"busType\\":\\"Seater\\",\\"Old_TIN\\":\\"\\",\\"MticketURL\\":\\"yhzu2ct\\",\\"OperatorId\\":\\"18819\\",\\"TripIdForWhatsApp\\":\\"-\\",\\"QRCodeLink\\":\\"\\",\\"MetroTqPageLink\\":\\"s\\",\\"TerminalPNR\\":null,\\"isTerminalPNR\\":false,\\"isOTP\\":false}\"}}';
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_WhatsappNotification.doPost();
        Test.stopTest();
    }

    static testMethod void WASendTest2()
    {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string JsonMsg='{\"MessageDetails\":{\"TemplateName\":\"MTicketSMSMessage_WHATSAPP\",\"dataJsonStr\":\"{\\"WhatsAppNumber\\":\\"919491322718\\",\\"bpAddress\\":\\"TestbpAddress\\",\\"bpContactNo\\":\\"TestbpContactNo\\",\\"sourceLocation\\":\\"Pulai Chondong,Pulau Chondong,Kelantan\\",\\"destinationLocation\\":\\"__Sarikei,Sarikei Express Terminal\\",\\"orderItemReferenceNo\\":\\"MYQAD82361029\\",\\"doj\\":\\"23-Sep-2021 11:00\\",\\"dojIn12hrsFormat\\":\\"23-Sep-2021 11:00 AM\\",\\"ServiceProviderReferenceNo\\":\\"A6UT44ED\\",\\"TripId\\":\\"\\",\\"Connection\\":null,\\"passengerPNR\\":\\"\\",\\"Travels\\":\\"Test Malaysia\\",\\"Fare\\":\\"2.0\\",\\"Currency\\":\\"MYR\\",\\"BoardingPoint\\":\\"Pulau Chondong,Kelantan\\",\\"DroppingPoint\\":\\"Sarikei,Sarawak\\",\\"SupportContactNo\\":\\"+60-330992524\\",\\"Seats\\":\\"2\\",\\"SeatWisePNR\\":\\"2\\",\\"PnrList\\":\\"A6UT44ED\\",\\"TotalNoOfSeats\\":\\"1\\",\\"PassName\\":\\"Test\\",\\"serviceProviderName\\":\\"Test Malaysia\\",\\"busType\\":\\"Seater\\",\\"Old_TIN\\":\\"\\",\\"MticketURL\\":\\"yhzu2ct\\",\\"OperatorId\\":\\"18819\\",\\"TripIdForWhatsApp\\":\\"-\\",\\"QRCodeLink\\":\\"\\",\\"MetroTqPageLink\\":\\"s\\",\\"TerminalPNR\\":null,\\"isTerminalPNR\\":false,\\"isOTP\\":false}\"}}';
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_WhatsappNotification.doPost();
        Test.stopTest();
    }
    
    
    static testMethod void errorStatusTest()
    {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string JsonMsg='';
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_WhatsappNotification.doPost();
        Test.stopTest();
    }

    static testMethod void enhancedTemplateTest()
    {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string JsonMsg='{\"MessageDetails\":{\"TemplateName\":\"ttd_cart_abandonement\",\"DataJsonStr\":\"{\\"WhatsAppNumber\\":\\"919491322718\\",\\"bpAddress\\":\\"TestbpAddress\\",\\"bpContactNo\\":\\"TestbpContactNo\\",\\"sourceLocation\\":\\"Pulai Chondong,Pulau Chondong,Kelantan\\",\\"destinationLocation\\":\\"__Sarikei,Sarikei Express Terminal\\",\\"orderItemReferenceNo\\":\\"MYQAD82361029\\",\\"doj\\":\\"23-Sep-2021 11:00\\",\\"dojIn12hrsFormat\\":\\"23-Sep-2021 11:00 AM\\",\\"ServiceProviderReferenceNo\\":\\"A6UT44ED\\",\\"TripId\\":\\"\\",\\"Connection\\":null,\\"passengerPNR\\":\\"\\",\\"Travels\\":\\"Test Malaysia\\",\\"Fare\\":\\"2.0\\",\\"Currency\\":\\"MYR\\",\\"BoardingPoint\\":\\"Pulau Chondong,Kelantan\\",\\"DroppingPoint\\":\\"Sarikei,Sarawak\\",\\"SupportContactNo\\":\\"+60-330992524\\",\\"Seats\\":\\"2\\",\\"SeatWisePNR\\":\\"2\\",\\"PnrList\\":\\"A6UT44ED\\",\\"TotalNoOfSeats\\":\\"1\\",\\"PassName\\":\\"Test\\",\\"serviceProviderName\\":\\"Test Malaysia\\",\\"busType\\":\\"Seater\\",\\"Old_TIN\\":\\"\\",\\"MticketURL\\":\\"yhzu2ct\\",\\"OperatorId\\":\\"18819\\",\\"TripIdForWhatsApp\\":\\"-\\",\\"QRCodeLink\\":\\"\\",\\"MetroTqPageLink\\":\\"s\\",\\"TerminalPNR\\":null,\\"isTerminalPNR\\":false,\\"isOTP\\":false}\"}}';
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_WhatsappNotification.doPost();
        Test.stopTest();
    }
}