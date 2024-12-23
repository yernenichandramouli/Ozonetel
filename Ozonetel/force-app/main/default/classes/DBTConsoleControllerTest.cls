@isTest
private class DBTConsoleControllerTest{
    
    @isTest
    static void testMethod1(){

        Orders__c ord = new Orders__c();
        ord.name='12211663367073522';
        ord.Guid__c = '5E786D6F5405F0055BE4CE5801010100';
        insert ord;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Name__c = ord.id;
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        orIt.Bank_Account_Number__c='12345';
        orIt.Date_Of_Purchase__c=System.today();
        insert orIt;

        case c = New case();
        c.issue_type__c='DBT';
        c.Bank_Name__c='BRI';
        c.amountd__c='54.321';
        c.transaction_id__c = orIt.Id;
        c.Trip_Id_ct__c='12211663367073522';
        c.Country__c ='Indonesia';
        c.Business_Unit_ct__c='REDBUS_ID';
        insert c;

        Payment_Items__c p = new Payment_Items__c();
        p.Order_Item_Name__c = orIt.id;
        p.Order_ID__c='12211663367073522';
        p.Payment_Gateway_Type__c='BRI';
        p.Payment_System__c='ONLINE';
        p.Account_Holder_Name__c='TESTACC';
        p.Guid__c='5e8477ad5405f0055be4ce5801020100';
        p.Creation_Time__c = Datetime.now().addDays(-1);
        insert p;


        DBT__c dt=new DBT__c();
        //dt.status__c='Ticket Generated';
        dt.status__c='No Case Found';
        dt.amount__c='54321';
        dt.formatted_amount__c='54321';
        dt.bank_name__c='BRI';
        insert dt;

        Test.startTest();
        string json='{"isTicketGenrated":true,"isGFT":false,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDSA995400712\u0026emailId=beprettylashstudio@gmail.com\u0026ChannelName=MOBILE_APP"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        DBTConsoleController dbtt = New DBTConsoleController();
        dbtt.amount='54321';
        dbtt.bankName = 'BRI';
        dbtt.DBTSearchAndConfirm();
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){

        Orders__c ord = new Orders__c();
        ord.name='12211663367073522';
        ord.Guid__c = '5E786D6F5405F0055BE4CE5801010100';
        insert ord;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Order_Name__c = ord.id;
        orIt.Order_Item_Reference_No__c = 'TM6686279816';
        orIt.name = '12211663367079914';
        orIt.Order_Id__c = '12211663367073522';
        orIt.status__c ='Created';
        orIt.Service_Provider_Name__c = 'RedBus';
        orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
        orIt.Bank_Account_Number__c='12345';
        orIt.Date_Of_Purchase__c=System.today();
        insert orIt;

        case c = New case();
        c.issue_type__c='DBT';
        c.Bank_Name__c='BRI';
        c.amountd__c='54321';
        c.transaction_id__c = orIt.Id;
        c.Trip_Id_ct__c='12211663367073522';
        c.Country__c ='Indonesia';
        c.Business_Unit_ct__c='REDBUS_ID';
        insert c;

        Payment_Items__c p = new Payment_Items__c();
        p.Order_Item_Name__c = orIt.id;
        p.Order_ID__c='12211663367073522';
        p.Payment_Gateway_Type__c='BRI';
        p.Payment_System__c='ONLINE';
        p.Account_Holder_Name__c='TESTACC';
        p.Guid__c='5e8477ad5405f0055be4ce5801020100';
        p.Creation_Time__c = Datetime.now().addDays(-1);
        insert p;


        DBT__c dt=new DBT__c();
        //dt.status__c='Ticket Generated';
        dt.status__c='No Case Found';
        dt.amount__c='54321';
        dt.formatted_amount__c='54321';
        dt.bank_name__c='BRI';
        insert dt;

        Test.startTest();
        string json='{"isTicketGenrated":true,"isGFT":false,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDSA995400712\u0026emailId=beprettylashstudio@gmail.com\u0026ChannelName=MOBILE_APP"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        DBTConsoleController dbtt = New DBTConsoleController();
        dbtt.amount='54321';
        dbtt.bankName = 'BRI';
        dbtt.DBTSearchAndConfirm();
        Test.stopTest();
    }
}