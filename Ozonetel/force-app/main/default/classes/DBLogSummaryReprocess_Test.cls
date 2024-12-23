@isTest()
public without sharing class DBLogSummaryReprocess_Test
{
    static testMethod void Success()
    {
        DBLog_Summary__c ds = new DBLog_Summary__c();
        ds.type__c = 'Booking';
        insert ds;
        
        attachment att = new attachment();
        att.body = blob.valueof('test');
        att.name = 'test';
        att.ParentId = ds.id;
        insert att;
     
        //System.runAs(intuser)
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',ds.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(ds);
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        DBLogSummaryReprocess tra = new DBLogSummaryReprocess(con);
        tra.SessionIdPing();
        tra.DBLogButtonEnable();
        Test.StopTest();
      
    }
}