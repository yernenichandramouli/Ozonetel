@isTest
public class NewUserBookingAssistanceBatchTest {

    @isTest
    static void testGetRandomRecord() {
        List<Object> testList = new List<Object>{'A', 'B', 'C'};
        RandomGeneric rg = new RandomGeneric(testList);
        Object randomRecord = rg.getRandomRecord();

        System.assert(testList.contains(randomRecord));
    }

    @isTest
    static void testGetNumberOfRandomRecords() {
        List<Object> testList = new List<Object>{1, 2, 3, 4, 5};
        RandomGeneric rg = new RandomGeneric(testList);
        List<Object> randomRecords = rg.getNumberOfRandomRecords(3);
        System.assertEquals(3, randomRecords.size());
        for (Object record : randomRecords) {
            System.assert(testList.contains(record));
        }
    }

    @isTest
    static void testGetNumberOfRandomRecordsWithinInterval() {
        List<Object> testList = new List<Object>{'X', 'Y', 'Z', 'P', 'Q', 'R'};
        RandomGeneric rg = new RandomGeneric(testList);
        List<Object> randomRecords = rg.getNumberOfRandomRecordsWithinInterval(2);
        System.assertEquals(2, randomRecords.size());
        for (Object record : randomRecords) {
            System.assert(testList.contains(record));
        }
    }

    Static testMethod void userTest()
    {
        list<Order_Items__c>  lstOrdrItm =new  list<Order_Items__c> ();
        Order_Items__c  ordrItm =new  Order_Items__c ();
        ordrItm.Business_Unit__c = 'REDBUS_IN';
        ordrItm.Mobile__c ='1234567890';
        lstOrdrItm.add(ordrItm);

        Order_Items__c  ordrItm1 =new  Order_Items__c ();
        ordrItm1 .Business_Unit__c = 'REDBUS_IN';
        ordrItm1 .Mobile__c ='123227890';
        ordrItm1 .Transaction_Status__c ='WFT';
        ordrItm1.status__c='TR_TENTATIVE_EXPIRED_PO_INITIATED';
        ordrItm1.IsNewUser__c=true;
        ordrItm1.Creation_Time__c=system.now().addMinutes(-20);
        lstOrdrItm.add(ordrItm1);
        
        insert lstOrdrItm;
        Test.startTest();
        string json='[{"callbackProperties":null,"callbackTime":null,"campaignId":null,"id":null,"isSelfCallback":null,"userId":null,"crmIntegrated":null,"crmTypeString":null,"crmSuccess":null,"customerId":null,"isInserted":null,"resultTypeString":null,"message":"Unable to Upload Contacts and Add Callbacks due to you.are.not.authorized.to.invoke.this.api.invalid.token","inputCustomerRecord":null}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        NewUserBookingAssistanceBatch userAss= new NewUserBookingAssistanceBatch ();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('newUserAss', cronExp,userAss);
        Test.stopTest();
    }
}