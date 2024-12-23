@isTest
private class rpwAutomationCasesCtrlTest {
    @isTest static void CreateExceptionalRefundCaseTestMethod(){

        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;


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
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.BO_Agreed_RB__c='agree';
        cs.Refund_Amount__c = 16;
        cs.Max_Refund_Amount__c = 10;
        cs.BO_Agreed_for_Refund__c = true;
        cs.Business_Type__c='REDBUS_IN';
        insert cs;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        rpwAutomationCasesCtrl.CreateExceptionalRefundCase(cs.Id);
        Test.stopTest();
    }

    @isTest static void CreateExceptionalRefundCaseTestMethod2(){

        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;


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
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.BO_Agreed_RB__c='agree';
        cs.Refund_Amount__c = 16;
        cs.Max_Refund_Amount__c = 10;
        cs.BO_Agreed_for_Refund__c = true;
        cs.Business_Type__c='REDBUS_IN';
        cs.My_Desk_Id__c = '13232321321';
        insert cs;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        rpwAutomationCasesCtrl.CreateExceptionalRefundCase(cs.Id);
        Test.stopTest();
    }

    @isTest static void rejectCaseTestMethod(){

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
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.BO_Agreed_RB__c='disagree';
        cs.Refund_Amount__c = 16;
        cs.Max_Refund_Amount__c = 10;
        cs.BO_Agreed_for_Refund__c = false;
        cs.Business_Type__c='REDBUS_IN';
        insert cs;
        case excase = New case();
        excase.Issue_Type__c='Exceptional Refund';
        cs.TIN_No__c = 'TIN6473553';
        excase.ParentId = cs.Id;
        insert excase;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        rpwAutomationCasesCtrl.CreateExceptionalRefundCase(cs.Id);
        Test.stopTest();
    }

    @isTest static void aplogyCaseTestMethod(){

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
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.BO_Agreed_RB__c='agree';
        cs.Max_Refund_Amount__c = 10;
        cs.BO_Agreed_for_Refund__c = false;
        cs.Business_Type__c='REDBUS_IN';
        insert cs;
        case excase = New case();
        excase.Issue_Type__c='Exceptional Refund';
        cs.TIN_No__c = 'TIN6473553';
        excase.ParentId = cs.Id;
        insert excase;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        rpwAutomationCasesCtrl.CreateExceptionalRefundCase(cs.Id);
        Test.stopTest();
    }
}