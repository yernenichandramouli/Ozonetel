@isTest
public class CzentrixSession_Test
{
    Static TestMethod void method()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        CZentrixSessionURL__c csu = new CZentrixSessionURL__c();
        csu.name = 'Bangalore';
        csu.API_EndPoint__c = 'test';
        insert csu;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ac.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ac);
        Test.setMock(HttpCalloutMock.class, new CzentrixSession_Test_CalloutMock());
        CzentrixSession tra = new CzentrixSession(con);
        CzentrixSession.SessionIdPing();
        Test.StopTest();
    }
}