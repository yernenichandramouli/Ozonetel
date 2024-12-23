@isTest
public class CallbackSchedulerControllerTest {
    @TestSetup
    static void setupData() {
        // Create a test case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Open'
        );
        insert testCase;

        // Create a TimeSlot with blank Status__c
        TimeSlot__c timeSlotBlank = new TimeSlot__c(
            CaseId__c = testCase.Id,
            StartTime__c = DateTime.now(),
            EndTime__c = DateTime.now().addMinutes(30)
        );
        insert timeSlotBlank;

        // Create a TimeSlot with Status__c '-1'
        TimeSlot__c timeSlotRNR1 = new TimeSlot__c(
           CaseId__c = testCase.Id,
            StartTime__c = DateTime.now().addHours(-1),
            EndTime__c = DateTime.now().addMinutes(-45)
           
        );
        insert timeSlotRNR1;

        // Create a TimeSlot with Status__c '-2'
        TimeSlot__c timeSlotRNR2 = new TimeSlot__c(
           CaseId__c = testCase.Id,
            StartTime__c = DateTime.now().addHours(-2),
            EndTime__c = DateTime.now().addMinutes(-75)
            
            
        );
        insert timeSlotRNR2;
    }

    @IsTest
    static void testProcessTimeSlots_RNRStatus() {
        // Set the apiStatus to 'RNR'
        String apiStatus = 'RNR';

        //Query the time slots for the test case
        Case testCase = [SELECT Id,casenumber FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        List<TimeSlot__c> lstTmSlt = [
            SELECT Id, Status__c, EndTime__c, StartTime__c, CaseId__c
            FROM TimeSlot__c
            WHERE CaseId__c =:testCase.Id
            ORDER BY Status__c NULLS LAST, EndTime__c DESC
        ];

        Test.startTest();
        
        Integer rnrCount = 0;
        Boolean createNewSlot = false;
        Boolean rnr1Exists = false;
        
        // Simulate the logic
        for (TimeSlot__c tmSlt : lstTmSlt) {
            if (String.isBlank(tmSlt.Status__c)) {
                if (apiStatus == '') {
                    createNewSlot = false;
                    break;
                } else if (rnr1Exists) {
                    tmSlt.Status__c = apiStatus + '-2';
                    rnrCount = 2;
                    createNewSlot = false;
                } else {
                    tmSlt.Status__c = apiStatus + '-1';
                    rnrCount = 1;
                    rnr1Exists = true;
                    createNewSlot = true;
                }
            } else if (tmSlt.Status__c.endsWith('-1')) {
                rnr1Exists = true;
            } else if (tmSlt.Status__c.endsWith('-2')) {
                rnrCount = 2;
                createNewSlot = false;
            }

            update tmSlt;
            if (rnrCount == 2 || apiStatus == 'connected') {
                break;
            }
        }

        // If necessary, create a new time slot
        if (createNewSlot && rnrCount == 1) {
            TimeSlot__c newTimeSlot = new TimeSlot__c(
                CaseId__c = lstTmSlt[0].CaseId__c,
                StartTime__c = lstTmSlt[0].EndTime__c.addMinutes(15),
                Status__c = ''
            );
            insert newTimeSlot;
        }

        string json='[{"callbackProperties":null,"callbackTime":null,"campaignId":null,"id":null,"isSelfCallback":null,"userId":null,"crmIntegrated":null,"crmTypeString":null,"crmSuccess":null,"customerId":null,"isInserted":null,"resultTypeString":null,"message":"Unable to Upload Contacts and Add Callbacks due to you.are.not.authorized.to.invoke.this.api.invalid.token","inputCustomerRecord":null}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CallbackSchedulerController userAss= new CallbackSchedulerController ();
        List<TimeSlot__c> lst =CallbackSchedulerController.getAvailableSlots(system.today());
        CallbackSchedulerController.bookTimeSlot(system.now(),'1234567', '986543210',testCase.id,'test');
        CallbackSchedulerController.callBackAmeyoReqApi(system.now(),testCase.id, '986543210','test');
        CallbackSchedulerController.secondCallBackAmeyoReqApi(system.now(),testCase.id, '986543210','test');
      
        String jsonResponseTemplate='{"agentName":"callBackSup1","businessUnit":"BUS","callDateTime":"2024-09-04T07:20:16","callEndTime":"2024-09-04T07:19:11","caseId":"<caseId>","channel":"IVR","country":true,"dialedTime":"2024-09-04T07:18:39","menuLastValue":"","phoneNo":"9502105715","systemDisposition":"CONNECTED","talkTime":"0","uniqueId":"d909-6673568c-vce-623231"}';
        String jsonResponse = jsonResponseTemplate.replace('<caseId>', testCase.id);
       
 CallbackSchedulerController.callDispositionMethod(jsonResponse);
 
        Test.stopTest();

     
    }

    @IsTest
    static void testProcessTimeSlots_ConnectedStatus() {
        // Set the apiStatus to 'connected'
        String apiStatus = 'connected';

        // Query the time slots for the test case
        Case testCase = [SELECT Id,casenumber FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        List<TimeSlot__c> lstTmSlt = [
            SELECT Id, Status__c, EndTime__c, StartTime__c, CaseId__c
            FROM TimeSlot__c
            WHERE CaseId__c = :testCase.Id
            ORDER BY Status__c NULLS LAST, EndTime__c DESC
        ];

        Test.startTest();
        
        Integer rnrCount = 0;
        Boolean createNewSlot = false;
        Boolean rnr1Exists = false;
        
        // Simulate the logic
        for (TimeSlot__c tmSlt : lstTmSlt) {
            if (String.isBlank(tmSlt.Status__c)) {
                if (apiStatus == 'connected') {
                    createNewSlot = false;
                    break;
                }
            } else if (tmSlt.Status__c.endsWith('-1')) {
                rnr1Exists = true;
            } else if (tmSlt.Status__c.endsWith('-2')) {
                rnrCount = 2;
                createNewSlot = false;
            }

            update tmSlt;
            if (rnrCount == 2 || apiStatus == 'connected') {
                break;
            }
        }

        Test.stopTest();

        string json='[{"callbackProperties":null,"callbackTime":null,"campaignId":null,"id":null,"isSelfCallback":null,"userId":null,"crmIntegrated":null,"crmTypeString":null,"crmSuccess":null,"customerId":null,"isInserted":null,"resultTypeString":null,"message":"Unable to Upload Contacts and Add Callbacks due to you.are.not.authorized.to.invoke.this.api.invalid.token","inputCustomerRecord":null}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CallbackSchedulerController userAss= new CallbackSchedulerController ();
        List<TimeSlot__c> lst =CallbackSchedulerController.getAvailableSlots(system.today());
        CallbackSchedulerController.bookTimeSlot(null,'1234567', '986543210',testCase.id,'test');
        CallbackSchedulerController.callBackAmeyoReqApi(system.now(),testCase.id, '986543210','test');
              CallbackSchedulerController.secondCallBackAmeyoReqApi(system.now(),testCase.id, '986543210','test');

        String jsonResponseTemplate='{"agentName":"callBackSup1","businessUnit":"BUS","callDateTime":"2024-09-04T07:20:16","callEndTime":"2024-09-04T07:19:11","caseId":"<caseId>","channel":"IVR","country":true,"dialedTime":"2024-09-04T07:18:39","menuLastValue":"","phoneNo":"9502105715","systemDisposition":"CONNECTED","talkTime":"0","uniqueId":"d909-6673568c-vce-623231"}';
        String jsonResponse = jsonResponseTemplate.replace('<caseId>', testCase.id);
       
        CallbackSchedulerController.callDispositionMethod(jsonResponse);
 
      
    }
}