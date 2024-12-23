@isTest
private class BusCPredictionSchedulerTest{
    public static testMethod void  testBusCPredSchedulerforCreate() 
    {
        Test.StartTest();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914  ';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        insert orIt;
        
        
        string json='[{"tin":"TM6686279816","route_id":9175940,"operator_id":3804,"doj":"2018-05-13 00:00:00"},{"tin":"TM6A48965878","route_id":8779969,"operator_id":8735,"doj":"2018-05-13 00:00:00"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        BusCPredictionScheduler bpSch= new BusCPredictionScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        Test.StopTest();
    }
    public static testMethod void testBusCPredSchedulerforUpdate() 
    {
        Test.StartTest();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914  ';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        insert orIt;
        
        Case cs = new Case();
        cs.Status = 'Initiated';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        cs.TIN_No__c=orIt.Order_Item_Reference_No__c;
        cs.Issue_Type__c='Bus Cancellation';
        insert cs;
        
        string json='[{"tin":"TM6686279816","route_id":9175940,"operator_id":3804,"doj":"2018-05-13 00:00:00"},{"tin":"TM6A48965878","route_id":8779969,"operator_id":8735,"doj":"2018-05-13 00:00:00"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        BusCPredictionScheduler bpSch= new BusCPredictionScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        
        Test.StopTest();
    }
    public static testMethod void testBusCPredSchedulerforFailure() 
    {
        Test.StartTest();
        BusCPredictionScheduler bpSch= new BusCPredictionScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        Test.StopTest();
        
    }
    
}