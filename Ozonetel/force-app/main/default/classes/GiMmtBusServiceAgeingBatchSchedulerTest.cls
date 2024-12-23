@isTest
private class GiMmtBusServiceAgeingBatchSchedulerTest {
    @isTest static void fullRefundTestMethod(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        insert orIt;
        
        list<case> caselist=new list<Case>();
        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2B';
        cs.Business_Unit_ct__c ='REDBUS_IN';
        cs.Booking_Email_ID__c ='test@mail.com';
        cs.Total_Fare_Value__c=50.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.Max_Refund_Amount__c = 100.00;
        insert cs;
        Test.setCreatedDate(cs.Id, DateTime.newInstance(2024,09,01));
        caselist.add(cs);

        Test.startTest();
        string query='';
        GiMmtBusServiceAgeingScheduler  busCan= new GiMmtBusServiceAgeingScheduler ();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }

    @isTest static void fullRefundTestMethod2(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        insert orIt;

        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2B';
        cs.Business_Unit_ct__c ='REDBUS_IN';
        cs.Booking_Email_ID__c ='test@mail.com';
        cs.Total_Fare_Value__c=50.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.Max_Refund_Amount__c = 100.00;
        insert cs;
        
        list<case> caselist=new list<Case>();
        Case cs1 = new Case();
        cs1.transaction_id__c = orIt.Id;
        cs1.Status ='Approved For Exceptional Refund';
        cs1.Issue_Type__c='Exceptional Refund';
        cs1.Type='B2B';
        cs1.Business_Unit_ct__c ='REDBUS_IN';
        cs1.Booking_Email_ID__c ='test@mail.com';
        cs1.Total_Fare_Value__c=50.00;
        cs1.Price_Paid_Currency_ctp__c='INR';
        cs1.All_Previous_Status_Dates__c = 'Approved For Exceptional Refund';
        cs1.Max_Refund_Amount__c = 100.00;
        insert cs1;
        Test.setCreatedDate(cs.Id, DateTime.newInstance(2024,09,01));
        caselist.add(cs);

        Test.startTest();
        string query='';
        GiMmtBusServiceAgeingScheduler  busCan= new GiMmtBusServiceAgeingScheduler ();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}