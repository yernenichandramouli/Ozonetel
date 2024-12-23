@isTest
private class API_ondcCaseUpdateTest {
    @isTest static void doPostValidCaseTestMethod(){

        case cs = New case();
        cs.Issue_Type__c='Ticket not working - due to To & fro mismatch';
        cs.Issue_Sub_Category__c='Origin & Destination mismatch';
        cs.Status='Open';
        insert cs;
        cs = [select id, casenumber from case where id = : cs.id];

        String JsonMsg='{"message":{"issue":{"resolution_provider":{"respondent_info":{"type":"TRANSACTION-COUNTERPARTY-NP","organization":{"org":{"name":"Triffy"},"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"person":{"name":"Vam C"}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"sample short description","long_desc":"sample long description","action_triggered":"CANCEL","refund_amount":""},"selected_odrs_info":null,"description":{"name":"","code":"","symbol":"","short_desc":"","long_desc":"","images":null,"audio":"","3d_render":""},"id":"'+cs.CaseNumber+'","issue_actions":{"respondent_actions":[{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:27:00.050228Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:28:07.189749Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:30:01.749529Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:30:51.325558Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0}],"resolution_provider":{"respondent_info":{"type":"","organization":{"org":{"name":""},"contact":{"email":"","phone":""},"person":{"name":""}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"","long_desc":"","action_triggered":"CANCEL","refund_amount":""}},"created_at":"0001-01-01T00:00:00Z","updated_at":"0001-01-01T00:00:00Z"}},"error":{"type":"","code":"","path":"","message":""}}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/v1/ondcCaseUpdate/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_ondcCaseUpdate.doPost();
        Test.stopTest();
    }

    @isTest static void doPostInValidCaseTestMethod(){

        case cs = New case();
        cs.Issue_Type__c='Ticket not working - due to To & fro mismatch';
        cs.Issue_Sub_Category__c='Origin & Destination mismatch';
        cs.Status='Open';
        insert cs;

        String JsonMsg='{"message":{"issue":{"resolution_provider":{"respondent_info":{"type":"TRANSACTION-COUNTERPARTY-NP","organization":{"org":{"name":"Triffy"},"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"person":{"name":"Vam C"}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"sample short description","long_desc":"sample long description","action_triggered":"CANCEL","refund_amount":""},"selected_odrs_info":null,"description":{"name":"","code":"","symbol":"","short_desc":"","long_desc":"","images":null,"audio":"","3d_render":""},"id":"'+cs.CaseNumber+'","issue_actions":{"respondent_actions":[{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:27:00.050228Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:28:07.189749Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:30:01.749529Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:30:51.325558Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0}],"resolution_provider":{"respondent_info":{"type":"","organization":{"org":{"name":""},"contact":{"email":"","phone":""},"person":{"name":""}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"","long_desc":"","action_triggered":"","refund_amount":""}},"created_at":"0001-01-01T00:00:00Z","updated_at":"0001-01-01T00:00:00Z"}},"error":{"type":"","code":"","path":"","message":""}}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/v1/ondcCaseUpdate/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_ondcCaseUpdate.doPost();
        Test.stopTest();
    }

    @isTest static void doPostBlankCaseTestMethod(){

        String JsonMsg='{"message":{"issue":{"resolution_provider":{"respondent_info":{"type":"TRANSACTION-COUNTERPARTY-NP","organization":{"org":{"name":"Triffy"},"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"person":{"name":"Vam C"}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"sample short description","long_desc":"sample long description","action_triggered":"REFUND","refund_amount":""},"selected_odrs_info":null,"description":{"name":"","code":"","symbol":"","short_desc":"","long_desc":"","images":null,"audio":"","3d_render":""},"id":"","issue_actions":{"respondent_actions":[{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:27:00.050228Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:28:07.189749Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"PROCESSING","short_desc":"Complaint is being processed","updated_at":"2024-07-12T13:30:01.749529Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0},{"respondent_action":"RESOLVED","short_desc":"Sample Short Description","updated_at":"2024-07-12T13:30:51.325558Z","updated_by":{"contact":{"email":"metro-support@triffy.co","phone":"0000000000"},"org":{"name":"Triffy"},"person":{"name":"Vam C"}},"cascaded_level":0}],"resolution_provider":{"respondent_info":{"type":"","organization":{"org":{"name":""},"contact":{"email":"","phone":""},"person":{"name":""}},"resolution_support":{"chat_link":"","contact":{"email":"","phone":""},"gros":null}}},"resolution":{"short_desc":"","long_desc":"","action_triggered":"","refund_amount":""}},"created_at":"0001-01-01T00:00:00Z","updated_at":"0001-01-01T00:00:00Z"}},"error":{"type":"","code":"","path":"","message":""}}';
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/redBus/v1/ondcCaseUpdate/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_ondcCaseUpdate.doPost();
        Test.stopTest();
    }

}