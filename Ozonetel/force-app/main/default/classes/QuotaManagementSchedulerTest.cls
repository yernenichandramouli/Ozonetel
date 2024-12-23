@isTest
private class QuotaManagementSchedulerTest{
    public static testMethod void  test1() 
    {
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Service_Provider_Id__c='12410791449275457';
        insert ordtm;
        
        case cs = new case ();
        cs.issue_type__c='Quota Management';
        cs.Transaction_ID__c=ordtm.id;
        cs.BO_Mobile_Number__c='99898987876';
        //cs.parentid=ordtm.id;
        insert cs;
        
        
        Test.StartTest();
        //Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        QuotaManagementScheduler bpSch= new QuotaManagementScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        Test.StopTest();
        }
   
   }