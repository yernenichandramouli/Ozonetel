@isTest
private class MMTExceptionalRefundBatchSchedulerTest {
    @isTest
    static void testMethod1(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = 'C8ZYYRUV';
        orIt.ID__c = 'C8ZYYRUV';
        orIt.Order_Item_Reference_No__c= 'C8ZYYRUV';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '19776280';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        orIt.Inventory_Type__c = 'MMT';
        insert orIt;
        
        case cs1 = New case();
        cs1.Issue_Type__c = 'Safety Issues';
        cs1.Issue_Sub_Category__c ='Rude Staff Behaviour';
        cs1.Transaction_ID__c =orIt.Id;
        cs1.Status = 'Open';
        cs1.Channel_ct__c ='MMT';
        cs1.Inventory_Type__c ='MMT';
        cs1.TIN_No__c ='NU710161066069840';
        cs1.My_Desk_Id__c ='18383105010924672';
        cs1.PNR__c ='C8ZYYRUV';
        insert cs1;

        Case cs = new Case();
        cs.Issue_Type__c ='Exceptional Refund';
        cs.Issue_Sub_Category__c='Operator Refund';
        cs.Refund_Type__c='Instant resolution - BO Accepted';
        cs.Category__c = 'Other Issue';
        cs.transaction_id__c = orIt.Id;
        cs.PNR__c ='C8ZYYRUV';
        cs.My_Desk_Id__c ='18383105010924672';
        cs.TIN_No__c ='NU710161066069840';
        cs.Service_Providerr_Id__c ='159432426';
        cs.Refund_Amount__c = 30;
        cs.description ='testing flow';
        cs.Approved_By__c ='(redbustestuser@redbus.com)';
        cs.Approved_Rejected_Time__c = Datetime.now();
        cs.Reason_For_Report__c ='Service Issue';
        cs.status ='Approved For Exceptional Refund';
        cs.ParentId = cs1.Id;
        insert cs;

        Test.startTest();
        string json='{"type":"exceptionalRefund","tin":"88QUA7RV","refundUnderBolt":true,"recoveryFromBo":true,"partialRefund":true,"exceptionalRefundReason":"Service Issue","description":"MMT Bolt Approval Part.","amount":2.00,"agentId":"integration@redbus.com.operations"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        MMTExceptionalRefundBatchScheduler sh1 = new MMTExceptionalRefundBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}