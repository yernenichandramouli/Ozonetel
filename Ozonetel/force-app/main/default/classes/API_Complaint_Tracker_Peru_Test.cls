@isTest
public class API_Complaint_Tracker_Peru_Test
{
static testMethod void testDoPost(){
        
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Complaint Tracker - Peru').getRecordTypeId();
        Case cf = new Case( Status='open',RecordTypeId=(recordTypeId));
        insert cf;
        
        API_Complaint_Tracker_Peru.CaseInformation cwrp = new API_Complaint_Tracker_Peru.CaseInformation();
        cwrp.FullName = 'test';
        cwrp.Phone = 'test';
        cwrp.Email = 'test@gmail.com'; 
        cwrp.Document_number =  '1232';
        cwrp.Type = 'Test'; 
        cwrp.ID = 'Test321'; 
        cwrp.Date_Incident= '2016-09-13 15:30:00';
        cwrp.Registered_name = 'Test Registered_name'; 
        cwrp.Residence = 'Test Residence'; 
        cwrp.Department = 'Test Department'; 
        cwrp.Province = 'Test';
        cwrp.District = 'Test District'; 
        cwrp.IsMinor= 'Test'; 
        cwrp.Guardian_Fullname = 'Test Guardian_Fullname';
        cwrp.Guardian_ID= 'Test 11';
        cwrp.Guardian_Email= 'test11@gmail.com';
        cwrp.Claim_Type= 'Test Claim_Type';
        cwrp.ContractedGood= 'Test ContractedGood';
        cwrp.PricePaid= '6666';
        cwrp.Answer_Received= 'Test Answer_Received'; 
        cwrp.PricePaidCurrency  = 'Test PricePaidCurrency'; 
        cwrp.DetailOfService= 'Test DetailOfService'; 
        cwrp.DetailsOdComplaint= 'Test DetailsOdComplaint'; 
        
        
        
        String JsonMsg=JSON.serialize(cwrp);
    
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
        req.requestURI = '/services/apexrest/redBus/ComplaintTrackerPeru/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        
        API_Complaint_Tracker_Peru.doPost();
        Test.stopTest();
        

    }
}