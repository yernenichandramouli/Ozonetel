@IsTest
public class TimeSlotBatchTest {
  
  @isTest
    static void timeSlotTest(){
        case cs= new case();
        cs.status ='open';
        insert cs;
         
        TimeSlot__c tm = new TimeSlot__c();
        tm.Status__c = 'Open';
        tm.CaseId__c=cs.id;
        tm.isSchedule__c=false;
        tm.isSecondary__c=true;
        tm.StartTime__c = system.now();
        tm.Phone__c='Domestic-Bus';
        tm.Description__c='1235';
        insert tm;

        test.startTest(); 
        SupervisorSecondCallbackScheduler obj = new SupervisorSecondCallbackScheduler();
        string json='[{"callbackProperties":null,"callbackTime":null,"campaignId":null,"id":null,"isSelfCallback":null,"userId":null,"crmIntegrated":null,"crmTypeString":null,"crmSuccess":null,"customerId":null,"isInserted":null,"resultTypeString":null,"message":"Unable to Upload Contacts and Add Callbacks due to you.are.not.authorized.to.invoke.this.api.invalid.token","inputCustomerRecord":null}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        String cronExp ='0 00 1 3 * ?';
        System.schedule('testBatch', cronExp,obj);
        Test.stopTest();
    }
}