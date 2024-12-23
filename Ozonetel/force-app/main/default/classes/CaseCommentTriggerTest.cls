/**
* (c) 2017 RedBus
*
* Name           : CaseCommentTriggerTest
* Created Date   : 04 Apr 2018
* Created By     : Veeramanikanta R
* Purpose        : Test class for CaseCommentTrigger and CaseCommentTriggerHandler class
*
**/

@isTest
private class CaseCommentTriggerTest{

static testMethod void testCaseCoomment()
    {
        Test.startTest(); 
        case c=new case();
        c.Email_Id_ct__c='test@redbus.com';
        c.status='Open';
        insert c;
        casecomment cc=new casecomment();
        cc.commentbody='(STC)Test body';
        cc.parentId=c.id;
            string json='{"type":["pushdata"], "pushdata": { "EmailId" :["'+c.Email_Id_ct__c+'"], "dataparams": { "message": "Your ticket has been booked successfully", "sid": "0"} } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        insert cc; 
        Test.stopTest();
    }
    
    static testMethod void FailtestCaseCoomment()
    {
        Test.startTest(); 
        case c=new case();
        c.Email_Id_ct__c='test@redbus.com';
        c.status='Open';
        insert c;
        casecomment cc=new casecomment();
        cc.commentbody='(CEV)Test body';
        cc.parentId=c.id;
            string json='{"type":["pushdata"], "pushdata": { "EmailId" :["'+c.Email_Id_ct__c+'"], "dataparams": { "message": "Your ticket has been booked successfully", "sid": "0"} } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        insert cc; 
        Test.stopTest();
    }
  
}