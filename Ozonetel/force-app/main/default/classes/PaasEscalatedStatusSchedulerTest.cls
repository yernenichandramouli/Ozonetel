@isTest
private class PaasEscalatedStatusSchedulerTest{
    public static testMethod void  testBusCPredSchedulerforCreate() 
    {
        Test.StartTest();
        Case cs = new Case();
        cs.Status = 'Escalated to Paas';
        cs.TIN_No__c='TN12345678';
        cs.Paas_Escalated_time__c=Date.newInstance(2020, 11 ,8);
        insert cs;
        
        
        //string json='[{"tin":"TM6686279816","route_id":9175940,"operator_id":3804,"doj":"2018-05-13 00:00:00"},{"tin":"TM6A48965878","route_id":8779969,"operator_id":8735,"doj":"2018-05-13 00:00:00"}]';
        //Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        PaasEscalatedStatusScheduler bpSch= new PaasEscalatedStatusScheduler();
        datetime currTimeee =cs.Paas_Escalated_time__c;
        datetime currTime=currTimeee+1.00008;
        
        PaasEscalatedStatusScheduler.SendEmailAlert();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        Test.StopTest();
    }
  }