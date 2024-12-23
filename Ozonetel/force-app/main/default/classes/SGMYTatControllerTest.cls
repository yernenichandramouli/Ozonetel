@isTest
public class SGMYTatControllerTest {
    @isTest static void fullRefundTestMethod(){
        Case cs = new Case();
        cs.Status='Closed';
        cs.Country__c='Malaysia';
        cs.Business_Type__c='L2 Support - SGMY';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SGMY HQBusdev').getRecordTypeId();
        cs.Origin='Email - hq_sgmy@redbus.my';
        cs.Issue_Type__c ='Seat layout configuration';
        cs.SuppliedEmail='test@mail.com';
        cs.Issue_Sub_Category__c ='New Seat layout configuration';
        insert cs;

        Test.startTest();
        string query='';
        SGMYTatController  busCan= new SGMYTatController(query);
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}