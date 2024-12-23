@isTest
public class createCaseControllerTest {
    static testMethod void testCaseTrigger()
    {
     
        Id rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
     Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        case cObj=new case();
        insert cObj;
        Account acc=new Account();
        acc.RecordTypeId=rectypeId;
        
        acc.lastname='Test Name';
        acc.PersonEmail='veeramanikanta.r@redbus.com';
        acc.PersonMobilePhone='9491322718';
        insert acc;
        System.currentPageReference().getParameters().put('id', acc.id);
         createCaseController c=new createCaseController();
     
        c.save();
    }
}