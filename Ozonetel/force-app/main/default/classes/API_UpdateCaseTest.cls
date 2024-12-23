@isTest 
private class API_UpdateCaseTest{
    static testmethod void testCaseUpdate() {
        // Load the test data from the static resource
     //   List<sObject> ls = Test.loadData(Update_Mapper__mdt.sObjectType, 'MappingData');
        Case cs = new Case();
        cs.Issue_Type__c ='NEFT Refund';
        cs.Account_Holder_Name__c = 'redBus Account';
        cs.Account_Number__c = '5525511881';
        cs.Country_ct__c = 'IND';
        cs.tin_no__c = 'TN828929192';
        cs.Priority = 'Low';
        insert cs;
        
      //  API_UpdateCase.customMetadata = (List<Update_Mapper__mdt>) JSON.deserialize('{"All_Needed_Custom_Fields__c ":"dummyValue"}', List<Update_Mapper__mdt>.class);    
        
        String caseNum = [Select CaseNumber from Case where Id=:cs.id].CaseNumber;
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonStr ='{"caseNumber":"'+caseNum+'","accountNumber":"3773727277222","bankName":"sbi","ifscCode":"SBIN00300565","accHolderName":"Testing","tripId":"10215554333","tin":"TK939939399393","businessUnit":"REDBUS_IN/REDBUS_SG","country":"IND/MYS","currencyType":"INR/SGD","paasOrderId":"125555555","refundAmount":"13.0","priority":"High"}';
        
        req.requestURI = '/services/apexrest/redBus/updateCase/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
                Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        

        req.requestBody = Blob.valueof('test'); 
        RestContext.request = req;
        RestContext.response= res;
        
        API_UpdateCase.doPost();
        
        req.requestBody = Blob.valueof(jsonStr);        
          
        RestContext.request = req;
        RestContext.response= res;
        
        API_UpdateCase.doPost();
       
    }
    
    static testmethod void testCaseUpdate1() {
        // Load the test data from the static resource
     //   List<sObject> ls = Test.loadData(Update_Mapper__mdt.sObjectType, 'MappingData');
        Case cs = new Case();
        cs.Channel_ct__c = 'Simplify360';
        cs.Country_ct__c = 'IND';
        cs.tin_no__c = 'TN828929192';
        cs.status = 'open';
        insert cs;
         String caseNum = [Select CaseNumber from Case where Id=:cs.id].CaseNumber;
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonStr ='{"caseNumber":"'+caseNum+'","accountNumber":"3773727277222","bankName":"sbi","ifscCode":"SBIN00300565","accHolderName":"Testing","tripId":"10215554333","tin":"TK939939399393","businessUnit":"REDBUS_IN/REDBUS_SG","country":"IND/MYS","currencyType":"INR/SGD","paasOrderId":"125555555","refundAmount":"13.0","priority":"High"}';
        
        req.requestURI = '/services/apexrest/redBus/updateCase/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
                Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());        

        req.requestBody = Blob.valueof('test'); 
        RestContext.request = req;
        RestContext.response= res;
        
        API_UpdateCase.doPost();
        
        req.requestBody = Blob.valueof(jsonStr);        
          
        RestContext.request = req;
        RestContext.response= res;
         API_UpdateCase.doPost();
        }
}