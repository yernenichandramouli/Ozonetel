@isTest
Private class BoltFlagUpdateBatchClassTest {

    @isTest
    static void boltFlagTest(){
        case cs = new case();
        cs.Status = 'Open';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c='I have a problem with bus service';
        cs.Issue_Sub_Category__c='My boarding or dropping point was changed by the bus operator';
        cs.Service_Providerr_Id__c='15625';
        insert cs;

        test.startTest(); 
        BoltFlagUpdateBatchClass obj = new BoltFlagUpdateBatchClass();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('BoltFlagUpdateBatchClass', cronExp,obj);
        Test.stopTest();
    }
}