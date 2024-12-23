@isTest()
public without sharing class API_redBus_Booking_Test2
{
    static testMethod void Success1()
    {
        account ac =new account();
        ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '1122334455';
        ac.LastName = 'test';
        insert ac;
        
        ordersData ord = new ordersData();
        list<ordersData> listOrd = new list<ordersData>();
        ord.id = 99472429;
        ord.additional_details = '';
        ord.created_by = '';
        ord.creation_time = '2016-09-01 15:23:35';
        ord.transaction_source = 'WEBDIRECT';
        ord.updated_by = '';
        ord.updated_time ='';
        ord.version =1;
        ord.item_count =1;
        ord.business_unit='BUS';
        ord.creation_time_long =2016245;
        ord.cust_id = '3407679';
        ord.selected_payment_currency ='INR';
        ord.status_flag = true;
        ord.cust_details = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"1122334455\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord.guid ='';
        ord.operationType ='UPDATE';
        listOrd.add(ord);
        
         bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        bdata.orders = listOrd;
        
        
        String JsonMsg=JSON.serialize(bdata);
        
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
        
    }
    static testMethod void Success2()
    {
        account ac =new account();
        ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '112233';
        ac.LastName = 'test';
        ac.User_Id__c = '4261556';
        insert ac;
        
        ordersData ord = new ordersData();
        list<ordersData> listOrd = new list<ordersData>();
        ord.id = 99472429;
        ord.additional_details = '';
        ord.created_by = '';
        ord.creation_time = '2016-09-01 15:23:35';
        ord.transaction_source = 'WEBDIRECT';
        ord.updated_by = '';
        ord.updated_time ='';
        ord.version =1;
        ord.item_count =1;
        ord.business_unit='BUS';
        ord.creation_time_long =2016245;
        ord.cust_id = '3407679';
        ord.selected_payment_currency ='INR';
        ord.status_flag = true;
        ord.cust_details = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"1122334455\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord.guid ='';
        ord.operationType ='UPDATE';
        listOrd.add(ord);
        
         bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        bdata.orders = listOrd;
        
        
        String JsonMsg=JSON.serialize(bdata);
        
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void Success3()
    {
        account ac =new account();
        ac.PersonEmail = 'test@test.com';
        ac.PersonMobilePhone = '1122334455';
        ac.LastName = 'test';
        //ac.User_Id__c = '4261556';
        insert ac;
        
        contact cc = new contact();
        cc.lastname ='test';
        cc.email = 'vinolinga@gmail.com';
        cc.Account_name__c = ac.id;
        insert cc;
        
        ordersData ord = new ordersData();
        list<ordersData> listOrd = new list<ordersData>();
        ord.id = 99472429;
        ord.additional_details = '';
        ord.created_by = '';
        ord.creation_time = '2016-09-01 15:23:35';
        ord.transaction_source = 'WEBDIRECT';
        ord.updated_by = '';
        ord.updated_time ='';
        ord.version =1;
        ord.item_count =1;
        ord.business_unit='BUS';
        ord.creation_time_long =2016245;
        ord.cust_id = '3407679';
        ord.selected_payment_currency ='INR';
        ord.status_flag = true;
        ord.cust_details = '{\"UserId\":4261556,\"UMSUserId\":0,\"PEmail\":\"vinolinga@gmail.com\",\"PMobile\":\"1122334455\",\"Password\":null,\"Dob\":\"1987-11-01 00:00:00\",\"DisplayName\":\"Vinothkumar\",\"Gender\":0,\"IsEmailVerified\":false,\"IsMobileVerified\":false,\"PasswordExists\":false,\"IsWalletEnabled\":false,\"WalletId\":\"fI6YK6z921iyTZ-4FYmK1Q\",\"CountryCode\":\"IND\",\"PhoneCode\":91,\"PreferredCurrency\":null}';
        ord.guid ='';
        ord.operationType ='UPDATE';
        listOrd.add(ord);
        
         bookingData bdata = new bookingData();
        bdata.type = 'BOOKING';
        bdata.sentAt = '2016-09-01 10:20:01';
        bdata.orders = listOrd;
        
        
        String JsonMsg=JSON.serialize(bdata);
        
        Test.startTest();
        //System.runAs(intuser)
        {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
         
            req.requestURI = '/services/apexrest/services/apexrest/redBus/redBus_Booking';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(JsonMsg);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
            
            API_redBus_Booking.doPost();
            
        }
        Test.stopTest();
        
    }
    
    public class bookingData
    {
        string type;
        string sentAt;
        list<ordersData> orders;
        
        public bookingData()
        {
            
        }
    }
    
    public class ordersData
    {
        string operationType;
        integer id;
        string additional_details;
        string created_by;
        string creation_time;
        string transaction_source;
        string updated_by;
        string updated_time;
        integer version;
        integer item_count;
        string business_unit;
        integer creation_time_long;
        string cust_id;
        string selected_payment_currency;
        string guid;
        boolean status_flag;
        string cust_details;
        public ordersData()
        {
        
        }
    }
}