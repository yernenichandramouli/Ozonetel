/**
* (c) 2017 RedBus
*
* Name           : LeadTriggerTest
* Created Date   : 07 Nov 2017
* Created By     : Sreenivas M
* Purpose        : Test class for LeadTrigger
* Test class     : LeadTriggerTest
*
**/

@isTest
Public class LeadTriggerTest
{
    static testMethod void testLeadInsert()
    {
        list<Lead> lstled = new  list<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'MSR';
        ld.Phone='t12333';
        ld.NumberOfQuotes__c = 4;
        ld.status='New RnR';
        ld.NoOfEmailOpen__c = 5;
        ld.Distance__c = '832';
        ld.Call_back_requested__c  = true;
        ld.Call_back_done__c = false;
        
        ld.NextCallDate__c=system.today().addDays(1);
        ld.RnR_Call_Time__c=system.today();
        lstled.add(ld);
        insert lstled;
        
        ld.DOJStart__c=system.now();
        ld.TCode__c='123';
        ld.status='RnR';
        ld.NumberOfQuotes__c = 6;
        ld.NoOfEmailOpen__c = 8;
        ld.Distance__c = '872';
        ld.Call_back_requested__c  = true;
        ld.Call_back_done__c = true;
        ld.Call_back_request_time__c=system.now();
        ld.RnR_Unsuccessful_Attempts__c=2;
        Test.startTest();
        update ld;
         string json='{ "status": 200,"msg": "Success!"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.stopTest();
    }
    static testMethod void testLeadInsert2()
    {
        list<Lead> lstled = new  list<Lead>();
        Lead ld = new Lead();
        ld.LastName = 'MSR';
        ld.Phone='t12333';
        ld.NumberOfQuotes__c = 4;
        ld.status='New';
        ld.NoOfEmailOpen__c = 5;
        ld.Distance__c = '832';
        ld.Call_back_requested__c  = true;
        ld.Call_back_done__c = false;
        ld.TCode__c='123';
        ld.Call_back_request_time__c=System.now();
        
        ld.NextCallDate__c=system.today().addDays(1);
        ld.RnR_Call_Time__c=system.today();
        lstled.add(ld);
        insert lstled;
        ld.status='Converted';
        ld.Call_back_request_time__c=System.now().addMinutes(12);
        update lstled;
        case c=new case();
        c.Issue_Type__c='CallBack Requested';
        c.Status='Open';
        insert c;
        ld.Call_back_request_time__c=System.now().addMinutes(15);
        
        update ld;
       

    }
}