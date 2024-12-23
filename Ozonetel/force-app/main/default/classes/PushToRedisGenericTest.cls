@isTest
private class PushToRedisGenericTest {

    @isTest static void testMethod1(){
        TempProcessing__c tempData = new TempProcessing__c();
        tempData.Name = '8887f6e7e286e005bcc008bf01010b00';
        tempData.processed__c =false;
        insert tempData;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        PushToRedisGeneric batchCls = New PushToRedisGeneric('11','IND');
        Id jobid= Database.executeBatch(batchCls,5);
        //string query='';
        //TempTransactionSyncBatch  busCan= new TempTransactionSyncBatch(query);
        //String sch = '0 0 8 13 2 ?';
        //system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();  
    }
}