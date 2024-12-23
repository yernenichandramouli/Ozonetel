@isTest
public class API_Complaint_Tracker_Test
{
    static testMethod void Track1()
    {
        Account ac = new Account();
        ac.LastName='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        ac.PersonMobilePhone = 'test';
        ac.PersonEmail = 'test@gmail.com';
        Insert ac;
        
        Contact c = new Contact();
        c.LastName = 'Testcon';
        c.Email = 'test@gmail.com';
        insert c;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Flag__c = 0;
        ori.Order_Id__c = 'test';
        Insert ori;
        
        case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        cs.Account_Number__c='123'; 
        cs.Did_the_bus_arrived_on_time__c=true;
        insert cs;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
        cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'DBT';
        cwrp.category = 'test';
        cwrp.tripId = 'test';
        cwrp.tripDetails = 'test';
        cwrp.complaint = 'test';
        cwrp.dateSubmitted = '2016-09-13 15:30:00';
        cwrp.businessUnit= oritran.Case_Business_Type__c;
        cwrp.PNR=cs.PNR__c;
        cwrp.channel = 'ICICI';
        cwrp.country = 'India';
        cwrp.tin='';
        cwrp.tripId='';
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }
    static testMethod void Track2()
    {
        Account ac = new Account();
        ac.LastName='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        ac.PersonMobilePhone = 'test';
        ac.PersonEmail = 'test@gmail.com';
        Insert ac;
        
        Contact c = new Contact();
        c.LastName = 'Testcon';
        c.Email = 'test@gmail.com';
        insert c;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Flag__c = 0;
        ori.Order_Id__c = 'test1';
        Insert ori;
         
        case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        insert cs;
        
      
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        insert oritran;
        
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
        cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'Neft refund';
        cwrp.category = 'test';
        cwrp.tripId = 'test';
        cwrp.tripDetails = 'test';
        cwrp.complaint = '|';
        cwrp.dateSubmitted = '2016-09-13T15:30:00';
        cwrp.businessUnit= 'test';
        cwrp.channel = 'test';
        cwrp.country = 'test';
        cwrp.origin='Complaint Tracker';
        cwrp.currencyType ='INR';
        cwrp.refundAmount = 10.00;
        cwrp.paasOrderId = '727217';
        cwrp.amount='10.10';
        cwrp.bankName ='SBI';
        cwrp.businessType=cs.Business_Type__c;
        cwrp.tcode='1234';
                
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof('test');        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        
        API_Complaint_Tracker.doPost();
        
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }
    static testMethod void Track3()
    {
        Account ac = new Account();
        ac.LastName='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
     //  ac.PersonMobilePhone = 'test';
       // ac.PersonEmail = 'test@gmail.com';
        Insert ac;
        
        Contact c = new Contact();
        c.LastName = 'Testcon';
        c.Email = 'test@gmail.com';
        insert c;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Flag__c = 0;
        ori.Order_Id__c = 'test';
        Insert ori;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        insert oritran;
        
         
        case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        insert cs;
        
        
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
         cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'test';
        cwrp.category = 'test';
        cwrp.tripId = 'test';
        cwrp.tripDetails = 'test';
        cwrp.complaint = 'test';
        cwrp.dateSubmitted = '2016-09-13 15:30:00';
        cwrp.channel = 'test';
        cwrp.country = 'India';
        cwrp.businessType='Bushire';
        cwrp.tCode='123';
        
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }
     static testMethod void missingCodecoverage()
    {
         case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        cs.Account_Number__c='123'; 
        cs.Did_the_bus_arrived_on_time__c=true;
        insert cs;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        insert orIt;

        case parentcs = new case();
        parentcs.PNR__c='124';
        parentcs.Business_Type__c='BusHire';
        parentcs.Account_Number__c='123'; 
        parentcs.Did_the_bus_arrived_on_time__c=true;
        parentcs.Issue_Type__c='Bus Cancellation';
        parentcs.transaction_id__c = orIt.Id;
        parentcs.Status='Initiated';
        insert parentcs;
        
        List<API_Complaint_Tracker.Claim> claimwrpList = New List<API_Complaint_Tracker.Claim>();
        API_Complaint_Tracker.Claim claimwrapper = new API_Complaint_Tracker.Claim();
        claimwrapper.claimType='Test';
        claimwrapper.claimId='Test';
        claimwrpList.add(claimwrapper);

        

        API_Complaint_Tracker.ClaimDetails ClaimDetailswrapper = new API_Complaint_Tracker.ClaimDetails();
        ClaimDetailswrapper.policyId='test';
        ClaimDetailswrapper.claim=claimwrpList;
      
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
        cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'Bus Cancellation';
        cwrp.category = 'test';
        cwrp.tripId = '15425';
        cwrp.tripDetails = 'test';
        cwrp.complaint = '|';
        cwrp.dateSubmitted = '2016-09-13 15:30:00';
        cwrp.channel = 'Acko';
        cwrp.country = 'India';
        cwrp.businessType='Bushire';
        cwrp.tCode='123';
        cwrp.userHasTravelled=true;
        cwrp.bookingId='jhj';
        cwrp.myDeskId='test';
        cwrp.parentCasenumber = '123456';
        cwrp.origin='Acko';
        cwrp.arrivedOnTime=  cs.Did_the_bus_arrived_on_time__c;
        cwrp.claimDetails=ClaimDetailswrapper;
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }

    static testMethod void yourbusTestMethods()
    {
         case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        cs.Account_Number__c='123'; 
        cs.Did_the_bus_arrived_on_time__c=true;
        cs.Channel_ct__c='YourBus';
        cs.Vehicle_No__c='TS12346';
        insert cs;
        
        List<API_Complaint_Tracker.Claim> claimwrpList = New List<API_Complaint_Tracker.Claim>();
        API_Complaint_Tracker.Claim claimwrapper = new API_Complaint_Tracker.Claim();
        claimwrapper.claimType='Test';
        claimwrapper.claimId='Test';
        claimwrpList.add(claimwrapper);

        

        API_Complaint_Tracker.ClaimDetails ClaimDetailswrapper = new API_Complaint_Tracker.ClaimDetails();
        ClaimDetailswrapper.policyId='test';
        ClaimDetailswrapper.claim=claimwrpList;
      
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
        cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'New vehicle- GPS details needed';
        cwrp.category = 'test';
        cwrp.tripId = '15425';
        cwrp.tripDetails = 'test';
        cwrp.complaint = '|';
        cwrp.dateSubmitted = '2016-09-13 15:30:00';
        cwrp.channel = 'YourBus';
        cwrp.country = 'India';
        cwrp.businessType='Bushire';
        cwrp.tCode='123';
        cwrp.userHasTravelled=true;
        cwrp.bookingId='jhj';
        cwrp.myDeskId='test';
        cwrp.busNumber='TS12346';
        cwrp.parentCasenumber = '123456';
        cwrp.arrivedOnTime=  cs.Did_the_bus_arrived_on_time__c;
        cwrp.claimDetails=ClaimDetailswrapper;
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }

    static testMethod void SHBoltAutomationTestMethod()
    {
        Account ac = new Account();
        ac.LastName='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        ac.PersonMobilePhone = 'test';
        ac.PersonEmail = 'test@gmail.com';
        Insert ac;
        
        Contact c = new Contact();
        c.LastName = 'Testcon';
        c.Email = 'test@gmail.com';
        insert c;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Flag__c = 0;
        ori.Order_Id__c = 'test';
        Insert ori;
        
        case cs = new case();
        cs.PNR__c='124';
        cs.Business_Type__c='BusHire';
        cs.Account_Number__c='123'; 
        cs.Did_the_bus_arrived_on_time__c=true;
        // cs.SH_Dropping_Time__c = Datetime.now().addDays(-2);
        insert cs;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        API_Complaint_Tracker.CaseInformation cwrp = new API_Complaint_Tracker.CaseInformation();
        cwrp.name = 'test';
        cwrp.phoneNo = 'test';
        cwrp.emailId = 'test@gmail.com';
        cwrp.issue = 'DBT';
        cwrp.category = 'test';
        cwrp.tripId = 'test';
        cwrp.tripDetails = 'test';
        cwrp.complaint = 'test';
        cwrp.dateSubmitted = '2016-09-13 15:30:00';
        cwrp.businessUnit= oritran.Case_Business_Type__c;
        cwrp.PNR=cs.PNR__c;
        cwrp.channel = 'ICICI';
        cwrp.country = 'India';
        cwrp.tin='';
        cwrp.tripId='';
        cwrp.shBoltInstantRefund = true;
        cwrp.droppingTime = '2023-05-03T15:26:08.744Z';
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTracker/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        API_Complaint_Tracker.doPost();
        Test.stopTest();
    }
    
}