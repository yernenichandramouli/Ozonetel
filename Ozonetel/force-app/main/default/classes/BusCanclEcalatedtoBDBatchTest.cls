@isTest
private with sharing class BusCanclEcalatedtoBDBatchTest {
    @isTest static void fullRefundTestMethod(){
        Case cs = new Case();
        cs.Status ='Open';
        cs.Country__c='India';
        cs.issue_type__c='Bus Cancellation';
        cs.Issue_Sub_Category__c ='Initiate Bus Cancellation';
        cs.BD_Location__c='Andhra Pradesh';
        cs.Origin='Complaint Tracker';
        insert cs;
        Test.setCreatedDate(cs.Id, DateTime.newInstance(2022,10,10));

        Test.startTest();
        string query='';
        BusCanclEcalatedtoBDBatch  busCan= new BusCanclEcalatedtoBDBatch('');
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}