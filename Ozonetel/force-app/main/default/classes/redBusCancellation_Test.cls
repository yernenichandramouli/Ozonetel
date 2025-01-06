@isTest
public class redBusCancellation_Test
{
    Static TestMethod void method1()
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='NormalCancelAPI';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='REDBUS_IN';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='http://cmapi-pp.redbus.com/api/Ticket/v1/Cancel/Normal';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Id__c = '123456';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'NormalCancelAPI';
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        cp.Full_Cancellation_Type__c='Partial Cancellation';
       
        insert cp;
               
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.normalCancelAPI();
        tra.fareAmount ='20';
        tra.refundAmount='10';
        
        tra.seatNo='12';
        Test.StopTest();
    }
    
    Static TestMethod void method2()
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='NormalCancelAPI';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='NormalCancelAPI';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='http://cmapi-pp.redbus.com/api/Ticket/v1/Cancel/Normal';
        insert Cs;
        
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        //orItem.Order_Id__c = '123456';
        orItem.Email__c = 'test@redbus.com    ';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'NormalCancelAPI';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        cp.Partial_Cancellation_Type__c='Full Cancellation';
        insert cp;


        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.normalCancelAPI();
        Test.StopTest();     
    }
    Static TestMethod void method3()    
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        RefundAPISettings__c Cs1=new RefundAPISettings__c();
        Cs1.Name='MaxRefundableAPI';
        Cs1.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs1.Business_Unit__c='MaxRefundableAPI';
        Cs1.Channel_Name__c='WEB_DIRECT';
        Cs1.Country_Name__c='IND';
        Cs1.Currency_Type__c='INR';
        Cs1.URL__c='http://cmapi-pp.redbus.com/api/Refund/v1/MaxRefundableAmount?tin=';
        insert Cs1;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        //orItem.Order_Id__c = '123456';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
        // orItem.Umbrella_TIN__c = 'TTAP80559073';
        // orItem.Connected_Items__c='{"a200c1cd22d7f006de86aae304020100":1,"a200cf9e22d7f006de86aae304020100":2}';
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.IsTicketCancellable();
        //tra.normalCancelAPI();      
        Test.StopTest();
    }
    Static TestMethod void method3_1()
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        RefundAPISettings__c Cs1=new RefundAPISettings__c();
        Cs1.Name='MaxRefundableAPI';
        Cs1.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs1.Business_Unit__c='MaxRefundableAPI';
        Cs1.Channel_Name__c='WEB_DIRECT';
        Cs1.Country_Name__c='IND';
        Cs1.Currency_Type__c='INR';
        Cs1.URL__c='http://cmapi-pp.redbus.com/api/Refund/v1/MaxRefundableAmount?tin=';
        insert Cs1;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
       
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        rs.ResponseMessage='itytty';
        tra.selCurrency=oritran.Auth_Key__c;
        tra.IsTicketCancellable();
       
        //tra.normalCancelAPI();
        Test.StopTest();
    }
    Static TestMethod void method4()
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='NormalCancelAPI';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='ForceCancelAPI';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='http://cmapi-pp.redbus.com/api/Ticket/v1/Cancel/Force';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        //orItem.Order_Id__c = '123456';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'ForceCancelAPI';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
       
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
       // tra.forceCancelAPI();
        Test.StopTest();
    }
    
    Static TestMethod void method4_1()
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='NormalCancelAPI';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='ForceCancelAPI';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='http://cmapi-pp.redbus.com/api/Ticket/v1/Cancel/Force';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        //orItem.Order_Id__c = '123456';
        //orItem.Email__c = 'test@redbus.com';
        orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'ForceCancelAPI';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        Test.StopTest();
    }
    
    Static TestMethod void method5()
    {
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Seat_No__c = '2E';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'ForceCancelAPI';
              
        insert orItem;
        
        Traveller_Info__c TI=new Traveller_Info__c();
        TI.Additional_Details__c='jjfn fnfdj fdjfdk';
        TI.Order_Item_Name__c=orItem.id;
       
        insert TI;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.seatSelection();
        Test.StopTest();
    }
    Static TestMethod void method6()
    {
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_COM';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_COM';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Seat_No__c = '2E';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_COM';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'ForceCancelAPI';
        orItem.Amount_Recieved_Currency__c='USD';
              
        insert orItem;
        
        Traveller_Info__c TI=new Traveller_Info__c();
        TI.Additional_Details__c='jjfn fnfdj fdjfdk';
        TI.Order_Item_Name__c=orItem.id;
       
        insert TI;
        /*case cs = new case();
        cs.Issue_Type__c='Physical Cancellation';
        cs.status='Closed';
        cs.TIN_No__c='"PEP9J82414444';
        insert cs;*/
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.seatSelection();
        tra.orIt.Business_Unit__c='REDBUS_IN';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.physCanclDeniedReason='false';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.cnrVale='a';
        tra.updateOpertPhysCancellationStatus();
        Test.StopTest();
    }
    Static TestMethod void method7()
    {
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_COM';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_COM';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Seat_No__c = '2E';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_COM';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'ForceCancelAPI';
        orItem.Amount_Recieved_Currency__c='USD';
        insert orItem;
        Traveller_Info__c TI=new Traveller_Info__c();
        TI.Additional_Details__c='jjfn fnfdj fdjfdk';
        TI.Order_Item_Name__c=orItem.id;
        insert TI;
        
        /*case cs = new case();
        cs.Issue_Type__c='Physical Cancellation';
        cs.status='Closed';
        cs.TIN_No__c='"PEP9J82414444';
        insert cs;*/
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock2());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.seatSelection();
        tra.orIt.Business_Unit__c='REDBUS_IN';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.physCanclDeniedReason='false';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.cnrVale='a';
        tra.updateOpertPhysCancellationStatus();
        Test.StopTest();
    }
    Static TestMethod void getRefundTest()    
    {
         
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        //tra.normalCancelAPI();
        tra.getRefundAmount();
        tra.updateOperCancellationStatus();
        tra.orIt.Email__c=null;
        tra.orIt.Email_Copy__c='test@redbus.com';
        tra.getRefundAmount();
        tra.updateOperCancellationStatus();
        tra.orIt.Email__c=null;
        tra.orIt.Email_Copy__c=null;
        tra.getRefundAmount();
        tra.updateOperCancellationStatus();
        tra.orIt.Mobile__c=null;
        tra.getRefundAmount();
        tra.updateOperCancellationStatus();
        tra.orIt.Item_Type__c='Coupon';
        tra.getRefundAmount();
        tra.updateOperCancellationStatus();
        Test.StopTest();
    }
    
     Static TestMethod void partialCancellationTest()    
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
        insert orItem;
        
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        cp.Code__c ='200';
        insert cp;
        Cancelled_Order_Items__c cancelorder=new Cancelled_Order_Items__c();
        cancelorder.Operator_Cancellation_Status__c='OPERATOR_CANCELLATION_INITIATED';
        cancelorder.Order_Item_Name__c=orItem.id;
       //insert cancelorder;
        
   
       
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.selStatus ='OPERATOR_CANCELLATION_SUCCESS';
        tra.refundDescription ='Testing comments';     
        tra.updateOperCancellationStatus();
        tra.selStatus ='Try Later';
        tra.updateOperCancellationStatus();
        tra.selStatus ='OPERATOR_CANCELLATION_SUCCESS';
        tra.forceCancelRefundAmnt=-1;
        tra.updateOperCancellationStatus();
        tra.selStatus='OPERATOR_CANCELLATION_FAILED';
        tra.updateOperCancellationStatus();
        
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        string json='{"toCityName":"Trikaripur","fromCityName":"Bangalore","dateOfJourney":"June 22 2017, Thursday","travelsName":"Kallada Travels (Suresh Kallada)","busType":"Premium Sleeper A/C (2+1)","boardingTime":"10:00 PM","arrivalTime":"7:30 AM","boardingPoint":"Kalasipalayam","duration":"9hrs 30min","paymentMode":null,"cardNumber":null,"cardType":"DC","totalAmountPaid":"1696.00","insuranceCharges":"0.00","serviceTax":"96.00","cashCouponValue":0.0,"baseFare":1600.0,"message":"","isPartialCancellation":true,"isTicketCancellable":true,"discount":"","refundTypeCSV":"","notes":null,"refundModes":[{"refundModeType":"WALLET_RECHARGE","refundDetails":"Get Instant Refund of Rs.1456 to your redBus Wallet!","totalRefundValue":1456.0,"refundVos":[{"refundObjectType":"WALLET_RECHARGE","refundValue":1456.0,"refundDetail":"Rs.1456 will be refunded to your Wallet"}]},{"refundModeType":"BACK_TO_PAYMENT","refundDetails":"Refund my Rs.1456 Back to Source. (This can take 5-7days)","totalRefundValue":1456.0,"refundVos":[{"refundObjectType":"OnlinePG","refundValue":53.5,"refundDetail":"Rs.53.5 will be refunded to your Card"},{"refundObjectType":"Wallet","refundValue":1402.5,"refundDetail":"Rs.1402.5 will be refunded to your Wallet"}]}],"lstPassengerInfo":[{"passengerName":"FATHIMATH ","sex":"female","age":"13","seat":"6ALB"},{"passengerName":"NASEEHA","sex":"female","age":"34","seat":"6BLB"}],"refundTypesList":["WALLET_RECHARGE","BACK_TO_PAYMENT"],"totalDiscount":0.0,"ticketFare":1696.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":{"fareWithSeat":[{"seatName":"6ALB,6BLB","fareresponse":{"fare":"1696.00","refAmount":"1456.00","canCharge":"240.00","serviceTax":"96","insuranceCharges":"0","nonRefAmount":"0.00","offerValue":"0.00"},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":[{"Key":"Fare","Value":{"value":1696.00,"refundableValue":1456.00}}]}],"TotalFare":"1696.00","RefundAmount":"1456.00","currency":null},"partialCancellationBreakUp":{"fareWithSeat":[{"seatName":"6ALB","fareresponse":{"fare":"800.00","refAmount":"680.00","canCharge":"120.00","serviceTax":"48.00","insuranceCharges":"0.00","nonRefAmount":null,"offerValue":null},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":null},{"seatName":"6BLB","fareresponse":{"fare":"800.00","refAmount":"680.00","canCharge":"120.00","serviceTax":"48.00","insuranceCharges":"0.00","nonRefAmount":null,"offerValue":null},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":null}],"TotalFare":null,"RefundAmount":null,"currency":null},"cancellationPolicy":[{"cancellationString":"After 07:00 PM on 21st Jun","cancellationCharge":"100%","cancellationPercentage":null},{"cancellationString":"Between 07:00 PM on 20th Jun - 07:00 PM on 21st Jun","cancellationCharge":"50%","cancellationPercentage":null},{"cancellationString":"Till 07:00 PM on 20th Jun","cancellationCharge":"15%","cancellationPercentage":null}],"currencytype":"INR","currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null}';
         Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        tra.getRefundAmount();
        tra.IsTicketCancellable();
       // redBusCancellation cls=new redBusCancellation();
       
        Test.StopTest();
    }
    
    Static TestMethod void exceptionalRefundCaseCreation()    
    {
          
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c='REDBUS_IN';
        orItem.Order_Id__c = '123';
        orItem.Service_Provider_Id__c='12344';
        insert orItem;
      
        Case cs = new Case();
        cs.Transaction_Id__c= orItem.id;
        cs.Issue_Type__c='test';
        cs.Issue_Sub_Category__c='testt';
        cs.Country__c='India';
        insert cs;

        case cs1 = New case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Refund_status__c='Exceptional Refund Approved';
        cs1.TIN_No__c='5676';
        insert cs1;
       

        case c = [Select Exceptional_Refund_Count__c From Case Where Id=:cs1.id];
        String csNumber = [Select CaseNumber From Case Where Id=:cs.id].CaseNumber;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        redBusCancellation tra = new redBusCancellation(con);
        tra.selCurrency=oritran.Auth_Key__c;
        Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
        
        //tra.selCurrency=oritran.Auth_Key__c;
        tra.refundDescription = '';
        tra.cp.FC_Refund_Amount__c = 90;
        tra.cp.Max_Refundable_Amount__c = 100;
        tra.submitForApproval();
        tra.refundDescription = 'testing';
        tra.parentCase=csNumber;
        tra.submitForApproval();
        tra.cp.FC_Refund_Amount__c = 0;
        tra.cp.Max_Refundable_Amount__c = 100;
        tra.selCurrency=oritran.Auth_Key__c;
        case cs2 = New case();
        cs2.Issue_Type__c = 'Exceptional Refund';
        cs2.Refund_status__c='Exceptional Refund Approved';
        cs2.TIN_No__c='5676';
        cs2.Exceptional_Refund_Count__c = 3;
        insert cs2;
        tra.submitForApproval();
        tra.getSuggestedRefundAmount();
        tra.selectRefundreason();
    }

    Static TestMethod void exceptionalRefundCaseCreation2()    
    {
          
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_COM';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_COM';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c='REDBUS_COM';
        orItem.Order_Id__c = '123';
        orItem.Service_Provider_Id__c='12344';
        insert orItem;
      
        Case cs = new Case();
        cs.Transaction_Id__c= orItem.id;
        cs.Issue_Type__c='test';
        cs.Issue_Sub_Category__c='testt';
        cs.Country__c='India';
        insert cs;

        case cs1 = New case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Refund_status__c='Exceptional Refund Approved';
        cs1.TIN_No__c='5676';
        insert cs1;

        case cs2 = New case();
        cs2.Issue_Type__c = 'Exceptional Refund';
        cs2.Refund_status__c='Exceptional Refund Approved';
        cs2.TIN_No__c='5676';
        cs2.Exceptional_Refund_Count__c = 3;
        insert cs2;
       

        case c = [Select Exceptional_Refund_Count__c From Case Where Id=:cs1.id];
        String csNumber = [Select CaseNumber From Case Where Id=:cs.id].CaseNumber;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        redBusCancellation tra = new redBusCancellation(con);
        tra.selCurrency=oritran.Auth_Key__c;
        Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
        
        //tra.selCurrency=oritran.Auth_Key__c;
        tra.refundDescription = '';
        tra.cp.FC_Refund_Amount__c = 90;
        tra.cp.Max_Refundable_Amount__c = 100;
        tra.submitForApproval();
        tra.refundDescription = 'testing';
        tra.parentCase=csNumber;
        tra.submitForApproval();
        tra.cp.FC_Refund_Amount__c = 0;
        tra.cp.Max_Refundable_Amount__c = 100;
        tra.selCurrency=oritran.Auth_Key__c;
        
        tra.submitForApproval();
    }

    Static TestMethod void updateOperCancellationStatusTest()    
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
        insert orItem;

        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        cp.Code__c ='200';
        insert cp;
        Cancelled_Order_Items__c cancelorder=new Cancelled_Order_Items__c();
        cancelorder.Operator_Cancellation_Status__c='OPERATOR_CANCELLATION_INITIATED';
        cancelorder.Order_Item_Name__c=orItem.id;
        insert cancelorder;

        Case c = New case();
        c.Issue_Type__c='Force Cancellation';
        c.Status='Open';
        c.Cancellation_ID__c = cancelorder.id;
        insert c;
        

        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        redBusCancellation tra = new redBusCancellation(con);
        redBusCancellation.APIResponse rs = new redBusCancellation.APIResponse();
        tra.selCurrency=oritran.Auth_Key__c;
        tra.selStatus ='OPERATOR_CANCELLATION_SUCCESS';
        tra.refundDescription ='Testing comments';     
        tra.updateOperCancellationStatus();
        
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        string json='{"toCityName":"Trikaripur","fromCityName":"Bangalore","dateOfJourney":"June 22 2017, Thursday","travelsName":"Kallada Travels (Suresh Kallada)","busType":"Premium Sleeper A/C (2+1)","boardingTime":"10:00 PM","arrivalTime":"7:30 AM","boardingPoint":"Kalasipalayam","duration":"9hrs 30min","paymentMode":null,"cardNumber":null,"cardType":"DC","totalAmountPaid":"1696.00","insuranceCharges":"0.00","serviceTax":"96.00","cashCouponValue":0.0,"baseFare":1600.0,"message":"","isPartialCancellation":true,"isTicketCancellable":true,"discount":"","refundTypeCSV":"","notes":null,"refundModes":[{"refundModeType":"WALLET_RECHARGE","refundDetails":"Get Instant Refund of Rs.1456 to your redBus Wallet!","totalRefundValue":1456.0,"refundVos":[{"refundObjectType":"WALLET_RECHARGE","refundValue":1456.0,"refundDetail":"Rs.1456 will be refunded to your Wallet"}]},{"refundModeType":"BACK_TO_PAYMENT","refundDetails":"Refund my Rs.1456 Back to Source. (This can take 5-7days)","totalRefundValue":1456.0,"refundVos":[{"refundObjectType":"OnlinePG","refundValue":53.5,"refundDetail":"Rs.53.5 will be refunded to your Card"},{"refundObjectType":"Wallet","refundValue":1402.5,"refundDetail":"Rs.1402.5 will be refunded to your Wallet"}]}],"lstPassengerInfo":[{"passengerName":"FATHIMATH ","sex":"female","age":"13","seat":"6ALB"},{"passengerName":"NASEEHA","sex":"female","age":"34","seat":"6BLB"}],"refundTypesList":["WALLET_RECHARGE","BACK_TO_PAYMENT"],"totalDiscount":0.0,"ticketFare":1696.0,"totalTax":0.0,"operatorDiscount":0.0,"fullCancellationBreakUp":{"fareWithSeat":[{"seatName":"6ALB,6BLB","fareresponse":{"fare":"1696.00","refAmount":"1456.00","canCharge":"240.00","serviceTax":"96","insuranceCharges":"0","nonRefAmount":"0.00","offerValue":"0.00"},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":[{"Key":"Fare","Value":{"value":1696.00,"refundableValue":1456.00}}]}],"TotalFare":"1696.00","RefundAmount":"1456.00","currency":null},"partialCancellationBreakUp":{"fareWithSeat":[{"seatName":"6ALB","fareresponse":{"fare":"800.00","refAmount":"680.00","canCharge":"120.00","serviceTax":"48.00","insuranceCharges":"0.00","nonRefAmount":null,"offerValue":null},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":null},{"seatName":"6BLB","fareresponse":{"fare":"800.00","refAmount":"680.00","canCharge":"120.00","serviceTax":"48.00","insuranceCharges":"0.00","nonRefAmount":null,"offerValue":null},"showFarebreakup":false,"fareSummarydict":null,"fareSummary":null}],"TotalFare":null,"RefundAmount":null,"currency":null},"cancellationPolicy":[{"cancellationString":"After 07:00 PM on 21st Jun","cancellationCharge":"100%","cancellationPercentage":null},{"cancellationString":"Between 07:00 PM on 20th Jun - 07:00 PM on 21st Jun","cancellationCharge":"50%","cancellationPercentage":null},{"cancellationString":"Till 07:00 PM on 20th Jun","cancellationCharge":"15%","cancellationPercentage":null}],"currencytype":"INR","currentCancellationPolicyIntl":null,"refundableAmount":0.0,"cancellationcharges":0.0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        tra.getRefundAmount();
        tra.IsTicketCancellable();
        Test.StopTest();
    }

    static testMethod void updateOpertPhysCancellationStatusTest1(){
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;

        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;

        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='PEP9J82414444';
        orItem.Email__c = 'test@redbus.com';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
        insert orItem;

        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        cp.Code__c ='200';
        insert cp;

        

        Case c = New Case();
        c.Issue_Type__c='Physical Cancellation';
        c.TIN_No__c='PEP9J82414444';
        insert c;

        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        redBusCancellation tra = new redBusCancellation(con);
        string json='{"status":"SUCCESS","errors":[],"data":{"zeroCancApplied":false,"status":"CANCELLATION_COMPLETED","serviceProviderId":"123456","refundAmount":{"currencyType":"PEN","amount":1100.0},"pnr":"TestPNR123","orderItemRefNumber":"PEP9J82414444","orderItemId":12783279536210433,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","cnr":"test12345678","clientIp":"","cancellationCharges":{"currencyType":"PEN","amount":0.0},"backToSource":true}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        tra.orIt.Business_Unit__c='REDBUS_IN';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_FAILED';
        tra.orIt.Business_Unit__c='REDBUS_COM';
        tra.physCanclDeniedReason='false';
        tra.updateOpertPhysCancellationStatus();
        tra.selOptrStatus='OPERATOR_CANCELLATION_SUCCESS';
        tra.cnrVale='a';
        tra.updateOpertPhysCancellationStatus();
        Test.StopTest();
    }

    Static TestMethod void partialCancellationTest23()    
    {
        RefundAPISettings__c Cs=new RefundAPISettings__c();
        Cs.Name='IsTicketCancellableURL';
        Cs.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs.Business_Unit__c='IsTicketCancellableURL';
        Cs.Channel_Name__c='WEB_DIRECT';
        Cs.Country_Name__c='IND';
        Cs.Currency_Type__c='INR';
        Cs.URL__c='https://capi.redbus.com/api/Ticket/v1/IsCancellable';
        insert Cs;
        
        RefundAPISettings__c Cs1=new RefundAPISettings__c();
        Cs1.Name='MaxRefundableAPI';
        Cs1.Auth_Key__c='fb26b9d6-28d5-4a43-a3f2-759839d7fdd7';
        Cs1.Business_Unit__c='MaxRefundableAPI';
        Cs1.Channel_Name__c='WEB_DIRECT';
        Cs1.Country_Name__c='IND';
        Cs1.Currency_Type__c='INR';
        Cs1.URL__c='http://cmapi-pp.redbus.com/api/Refund/v1/MaxRefundableAmount?tin=';
        insert Cs1;
        
        Orders__c order = new Orders__c();
        order.id__c = '123456';
        order.name = '123456';
        insert order;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Order_Items__c orItem = new Order_Items__c();
        orItem.name = '23456';
        orItem.id__c = '23456';
        orItem.Order_Item_Reference_No__c='5676';
        //orItem.Order_Id__c = '123456';
        orItem.Email__c = 'test@redbus.com';
        //orItem.Email_Copy__c = 'test@redbus.com    ';
        orItem.Mobile__c = '1234567891';
        orItem.Business_Unit__c = 'REDBUS_IN';
        orItem.Transaction_Source__c = 'MOBILEAPP';
        orItem.Item_Type__c = 'IsTicketCancellableURL';
              
        insert orItem;
        
        Cancellation_Process_DB_Log__c cp=new Cancellation_Process_DB_Log__c();
        cp.Transaction_Name__c=orItem.id;
        cp.FC_IsSuccess__c=true;
        insert cp;
        
        redBusCancellation.addOnWrapper adW = new redBusCancellation.addOnWrapper();
        adw.totalFare ='123';
        adw.refundableAmount ='123';
        adw.isAddOnCancellable ='123';
        adw.itemName ='123';
        adw.itemUuid ='123';
        adw.cancellationCharge =0.4;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',orItem.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(orItem);

        redBusCancellation tra = new redBusCancellation(con);
        tra.detailed_msg ='test';
        tra.primarySeatMsg='test1';
        tra.PhysCancellationStatus='test';
        tra.physCanclErrorMsg ='testt';
        
        string json=' {"Code":"400.24","Message":"Cancellation_Failed","DetailedMessage":"This ticket cannot be cancelled as Date of Journey expired. "}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        tra.selCurrency=oritran.Auth_Key__c;
        tra.IsTicketCancellable();

        Test.StopTest();
    }
}