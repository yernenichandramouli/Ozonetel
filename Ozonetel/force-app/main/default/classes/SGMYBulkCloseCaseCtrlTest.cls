@isTest
public class SGMYBulkCloseCaseCtrlTest {
    @isTest static void getSGMYcaseListTest(){
        List<string> CaseIds = New List<string>();
        Case cs = new Case();
        cs.Country__c = 'Malaysia';
        cs.Business_Type__c ='L2 Support - SGMY';
        cs.Issue_Type__c = 'Cut Off time';
        cs.BO_Id__c='I felt unsafe during the journey';
        cs.Origin ='Email - hq_sgmy@redbus.my';
        Id RecordTypeIdContact = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SGMY HQBusdev').getRecordTypeId();
        cs.recordtypeId=RecordTypeIdContact;
        insert cs;
        CaseIds.add(string.valueOf(cs.Id));
        SGMYBulkCloseCaseCtrl.getSGMYcaseList();
        SGMYBulkCloseCaseCtrl.closeSelectedCases(CaseIds,'ghgjhkj','rdtfghkj');
    }
}