@isTest
private class CaseIssuesControllerTest{
    
    static testMethod void caseIssueTest(){
        case c=new case();
        c.status='Open';
        c.Selected_Issues__c='11';
        c.issue_type__c='I have a problem with bus service';
        
        insert c;
        Test.startTest();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseIssuesController.fetchIssues(c.id); 
        Test.stopTest();
    }
    
    public static testMethod void GetPastTransactionDetailsTest(){
        case c=new case();
        c.status='Open';
        c.Selected_Issues__c='11';
        c.issue_type__c='I have a problem with bus service';
        
        insert c;
        Test.startTest();
        String json='{"rtc_bills":0,"last_route_travelled":"BANGALORE-MANGALURU","ftd":"2017-05-29","emailid":"veeramanikanta.renukunta@gmail.com","pvt_bills":1,"ltd":"2017-05-29","totalNoOfTrxns":1,"active_days":"1"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseIssuesController.GetPastTransactionDetails(c.id);
        Test.stopTest();
    }
    public static testMethod void GetPastCaseDetailsTest(){
        case c=new case();
        c.status='Open';
        c.Selected_Issues__c='11';
        c.issue_type__c='I have a problem with bus service';
        
        insert c;
        Test.startTest();
        string json='[ { "subIssueType": null, "issuetype": "Call Drop", "caseNumber": "15965189", "Notes": null, "tin": null, "tripId": null, "DateOfCreation": "2021-05-12T14:37:58.000Z", "open_date_and_time__c": "2021-05-12T14:37:58.000Z", "status": "Closed", "operatorId": null, "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16093357", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-23T08:44:01.000Z", "open_date_and_time__c": "2021-06-23T08:44:01.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false }, { "subIssueType": "I was charged extra fare for this booking", "issuetype": "Booking Issues", "caseNumber": "16097823", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-24T11:23:45.000Z", "open_date_and_time__c": "2021-06-24T11:23:45.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Help with availability of my preferred bus", "issuetype": "Need help to make a new bus tick", "caseNumber": "16119493", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-29T12:26:02.000Z", "open_date_and_time__c": "2021-06-29T12:26:02.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16417866", "Notes": null, "tin": "TQ9H58545248", "tripId": "13035761942647657", "DateOfCreation": "2021-08-25T12:12:52.000Z", "open_date_and_time__c": "2021-08-25T12:12:52.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "8516", "isRTC": false }, { "subIssueType": "Poor bus quality", "issuetype": "Bus Operator Service", "caseNumber": "16985138", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-12T11:00:20.000Z", "open_date_and_time__c": "2021-11-12T11:00:20.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Rude staff behavior", "issuetype": "I felt unsafe during the journey", "caseNumber": "17096945", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:33:52.000Z", "open_date_and_time__c": "2021-11-25T06:33:52.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Boarding / Dropping point changed", "issuetype": "Bus Operator Service", "caseNumber": "17096951", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:34:26.000Z", "open_date_and_time__c": "2021-11-25T06:34:26.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "My bus driver demanded additional fare", "issuetype": "Bus Operator Service", "caseNumber": "17099159", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T11:08:39.000Z", "open_date_and_time__c": "2021-11-25T11:08:39.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16677592", "Notes": null, "tin": "TQB432353858", "tripId": "13069547434287890", "DateOfCreation": "2021-10-08T14:28:39.000Z", "open_date_and_time__c": "2021-10-08T14:28:39.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false } ]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseIssuesController.GetPastCaseDetails(c.id);
        Test.stopTest();
    }
    
    public static testMethod void SaveIssuesTest(){
        case c=new case();
        c.status='Open';
        c.Selected_Issues__c='11';
        c.issue_type__c='I have a problem with bus service';
        
        insert c;
        string mockResp='[{"index":"0","isChecked":false,"issueName":"Driver is Rude","issueNo":"I_3"}]';
        CaseIssuesController.saveIssues(c.id,mockResp);
    }
    
     public static testMethod void UserTripsTest(){
        case c=new case();
        c.status='Open';
        c.Selected_Issues__c='11';
        c.issue_type__c='I have a problem with bus service';
        
        insert c;
         Test.startTest();
        string json='[ { "subIssueType": null, "issuetype": "Call Drop", "caseNumber": "15965189", "Notes": null, "tin": null, "tripId": null, "DateOfCreation": "2021-05-12T14:37:58.000Z", "open_date_and_time__c": "2021-05-12T14:37:58.000Z", "status": "Closed", "operatorId": null, "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16093357", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-23T08:44:01.000Z", "open_date_and_time__c": "2021-06-23T08:44:01.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false }, { "subIssueType": "I was charged extra fare for this booking", "issuetype": "Booking Issues", "caseNumber": "16097823", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-24T11:23:45.000Z", "open_date_and_time__c": "2021-06-24T11:23:45.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Help with availability of my preferred bus", "issuetype": "Need help to make a new bus tick", "caseNumber": "16119493", "Notes": null, "tin": "TQ7N25695119", "tripId": "12995429794578081", "DateOfCreation": "2021-06-29T12:26:02.000Z", "open_date_and_time__c": "2021-06-29T12:26:02.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16417866", "Notes": null, "tin": "TQ9H58545248", "tripId": "13035761942647657", "DateOfCreation": "2021-08-25T12:12:52.000Z", "open_date_and_time__c": "2021-08-25T12:12:52.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "8516", "isRTC": false }, { "subIssueType": "Poor bus quality", "issuetype": "Bus Operator Service", "caseNumber": "16985138", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-12T11:00:20.000Z", "open_date_and_time__c": "2021-11-12T11:00:20.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Rude staff behavior", "issuetype": "I felt unsafe during the journey", "caseNumber": "17096945", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:33:52.000Z", "open_date_and_time__c": "2021-11-25T06:33:52.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Boarding / Dropping point changed", "issuetype": "Bus Operator Service", "caseNumber": "17096951", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T06:34:26.000Z", "open_date_and_time__c": "2021-11-25T06:34:26.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "My bus driver demanded additional fare", "issuetype": "Bus Operator Service", "caseNumber": "17099159", "Notes": null, "tin": "TQBN74792499", "tripId": "13081139927724689", "DateOfCreation": "2021-11-25T11:08:39.000Z", "open_date_and_time__c": "2021-11-25T11:08:39.000Z", "status": "Closed", "operatorId": "15926", "isRTC": false }, { "subIssueType": "Initiate Bus Cancellation", "issuetype": "Bus Cancellation", "caseNumber": "16677592", "Notes": null, "tin": "TQB432353858", "tripId": "13069547434287890", "DateOfCreation": "2021-10-08T14:28:39.000Z", "open_date_and_time__c": "2021-10-08T14:28:39.000Z", "status": "Rejected For Bus Cancellation", "operatorId": "15926", "isRTC": false } ]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseIssuesController.userTrips(c.id,'Single');
        Test.stopTest();
    }
    
}