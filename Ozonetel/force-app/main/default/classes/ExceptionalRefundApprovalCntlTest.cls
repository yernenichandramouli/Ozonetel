/**
* (c) 2018 RedBus
*
* Name           : ExceptionalRefundApprovalCntlTest
* Created Date   : 03 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Test class for ExceptionalRefundApprovalCntl
*
**/

@isTest
Public class ExceptionalRefundApprovalCntlTest
{
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderItmList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderItmList.add(new Order_Items__c(name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID'));
        } 
        insert orderItmList ;
    }  
   static testMethod void initiateRefundTest()
    {
        
        List<Order_Items__c> listOrItems = new List<Order_Items__c>();
        Order_Items__c orIt = new Order_Items__c();
        orIt.Order_Item_Reference_No__c = 'TL12671237328';
        orIt.Business_Unit__c='ASSAMRTC_IN';
        orIt.Email__c = 'Test@redbus.com';
        orIt.Order_Id__c = '15653253265362';
        listOrItems.add(orIt);
        
        user currUser=[select id,user_level__c,Country from user where id=:UserInfo.getUserID()];


        Order_Items__c orIt2 = new Order_Items__c();
        orIt2.Order_Item_Reference_No__c = 'TL1267137328';
        orIt2.Email__c = 'Test2@redbus.com';
        orIt2.Business_Unit__c='redbus_IN';
        orIt2.Order_Id__c = '25653253265362';
        listOrItems.add(orIt2);
        insert listOrItems;
        
        Case cs = new Case();
        cs.Issue_Type__c = 'Exceptional Refund';
        cs.Issue_Sub_Category__c = 'Customer Delight';
        cs.Trip_Id_ct__c = orIt.Order_Id__c;
        cs.TIN_No__c = orIt.Order_Item_Reference_No__c;
        cs.Refund_Amount__c = 124;
        cs.Description ='unit test case' ;
        cs.Transaction_ID__c = orIt.id;
        cs.status= 'Open';
         cs.Country__c='India';
        cs.Booking_Email_ID__c = orIt.Email__c;
        cs.OwnerId = currUser.id;
        cs.Origin='InBound Call';
        cs.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
        cs.User_Level_Team__c = 'BoltPrimoRpw';
        insert cs;
        
        
        Case cs1 = new Case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Issue_Sub_Category__c = 'Technical Errort';
        cs1.Trip_Id_ct__c = orIt2.Order_Id__c;
        cs1.TIN_No__c = orIt2.Order_Item_Reference_No__c;
        cs1.Refund_Amount__c = 124;
        cs1.Description ='unit test case' ;
        cs1.Transaction_ID__c = orIt2.id;
        cs1.status= 'Open';
        cs1.Country__c='India';
        cs1.Booking_Email_ID__c = orIt2.Email__c;
        cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs1.Origin='InBound Call';
        cs1.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
        cs1.User_Level_Team__c = 'BoltPrimoRpw';
        insert cs1;
        case csObj=[select id,casenumber from case where id=:cs1.id];
        string reject='Rejected';
        string clmrjct='Claim Rejected Successfully';
        string clmreFail='Claim Reject Failed';
        ExceptionalRefundApprovalCntl exRef = new ExceptionalRefundApprovalCntl();
        exRef.selectedTeam = 'BoltPrimoRpw';
        exRef.refreshlist();
        exRef.seleStatus ='Deny';
        exRef.selCsId = cs.id;
        
        exRef.initiateRefund();
        
        
        exRef.seleStatus ='Approve';
        exRef.cId='1234567';
        exRef.selCsId = csObj.id;
        exRef.b2cCaseComments='Test Comments';
        OrderItemTransactionResource__c ot=new OrderItemTransactionResource__c();
        ot.Name='REDBUS_IN';
        ot.Auth_Key__c='1253Ratr';
        ot.Case_Country__c='India';
        ot.Default_Currency__c='INR';
        insert ot;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        exRef.initiateRefund();
        //exRef.ApproveorRejectstatus(reject,clmrjct,clmreFail);
        Test.stopTest();
        
    }
    static testMethod void initiateRefundTest1()
    {
        string reject='Rejected';
        string clmrjct='Claim Rejected Successfully';
        string clmreFail='Claim Reject Failed';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
        ExceptionalRefundApprovalCntl exRef = new ExceptionalRefundApprovalCntl();
        exRef.ApproveorRejectstatus(reject,clmrjct,clmreFail);
        ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput espRfnd = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
        espRfnd.isBusCancellation=true;
        espRfnd.isExceptionalBusCancellation=true;
        exRef.b2cCaseComments='Test Comments';
        espRfnd.cnr='123';
        espRfnd.operatorContribution=123;
        espRfnd.isZcafeApplied=false;
        Test.stopTest();
    }
    
    public static testMethod void B2BExceptionalRefundTest(){
        
        
        Test.startTest();
        list<Order_Items__c> ol=[select id,Order_Id__c,Order_Item_Reference_No__c,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        
        Case cs1 = new Case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Issue_Sub_Category__c = 'Technical Error';
        cs1.type='B2B';
        cs1.Trip_Id_ct__c = ol[0].Order_Id__c;
        cs1.TIN_No__c = ol[0].Order_Item_Reference_No__c;
        cs1.Refund_Amount__c = 124;
        cs1.Description ='unit test case' ;
        cs1.Transaction_ID__c = ol[0].id;
        cs1.status= 'Open';
        cs1.Country__c='India';
        cs1.Booking_Email_ID__c = ol[0].Email__c;
        cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs1.Origin='InBound Call';
        cs1.Subject = 'Exceptional Refund- '+cs1.Issue_Sub_Category__c;
        cs1.User_Level_Team__c = 'BoltPrimoRpw';
        insert cs1;
        case csObj=[select id,casenumber from case where id=:cs1.id];
        ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
        ea.sellerCentralId='124';
        ea.selCsId=csObj.id;
        ea.selectedTeam = 'BoltPrimoRpw';
        ea.refreshlist();
        ea.seleStatus='Approve';
        Continuation conti = (Continuation)ea.B2BExceptionalRefund();
        ea.refreshlist();
        HttpResponse response = new HttpResponse();
        string responseBody='{"cancellable":"true","cancellationCharges":{"entry":[{"key":"26U","value":"10.00"},{"key":"25U","value":"10.00"},{"key":"23U","value":"10.00"},{"key":"22U","value":"10.00"},{"key":"29U","value":"10.00"},{"key":"28U","value":"10.00"}]},"fares":{"entry":[{"key":"26U","value":"105.00"},{"key":"25U","value":"105.00"},{"key":"23U","value":"105.00"},{"key":"22U","value":"105.00"},{"key":"29U","value":"105.00"},{"key":"28U","value":"105.00"}]},"freeCancellationTime":"10.00","partiallyCancellable":"true","serviceCharge":"0"}';
        response.setBody(responseBody);
        Test.setContinuationResponse(ea.excepRefReq, response);
        Object result = Test.invokeContinuationMethod(ea, conti);
    }
     public static testMethod void B2BExceptionalRefundTest2(){
        
        
        Test.startTest();
        list<Order_Items__c> ol=[select id,Order_Id__c,Order_Item_Reference_No__c,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        
        Case cs1 = new Case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Issue_Sub_Category__c = 'Customer Delight';
        cs1.type='B2B';
        cs1.Trip_Id_ct__c = ol[0].Order_Id__c;
        cs1.TIN_No__c = ol[0].Order_Item_Reference_No__c;
        cs1.Refund_Amount__c = 124;
        cs1.Description ='unit test case' ;
        cs1.Transaction_ID__c = ol[0].id;
        cs1.status= 'Open';
        cs1.Country__c='India';
        cs1.User_Level_Team__c = 'BoltPrimoRpw';
        cs1.Booking_Email_ID__c = ol[0].Email__c;
        cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs1.Origin='InBound Call';
        cs1.Subject = 'Exceptional Refund- '+cs1.Issue_Sub_Category__c;
        insert cs1;
         
        case csObj=[select id,casenumber from case where id=:cs1.id];
        ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
        ea.sellerCentralId='124';
        ea.selCsId=csObj.id;
        ea.selectedTeam = 'BoltPrimoRpw';
        ea.refreshlist();
        ea.seleStatus='Approve';
        Continuation conti = (Continuation)ea.B2BExceptionalRefund();
        ea.refreshlist();
        HttpResponse response = new HttpResponse();
        string responseBody='{"cancellable":"true","cancellationCharges":{"entry":[{"key":"26U","value":"10.00"},{"key":"25U","value":"10.00"},{"key":"23U","value":"10.00"},{"key":"22U","value":"10.00"},{"key":"29U","value":"10.00"},{"key":"28U","value":"10.00"}]},"fares":{"entry":[{"key":"26U","value":"105.00"},{"key":"25U","value":"105.00"},{"key":"23U","value":"105.00"},{"key":"22U","value":"105.00"},{"key":"29U","value":"105.00"},{"key":"28U","value":"105.00"}]},"freeCancellationTime":"10.00","partiallyCancellable":"true","serviceCharge":"0"}';
        response.setBody(responseBody);
      //  Test.setContinuationResponse(ea.excepRefReq, response);
     //   Object result = Test.invokeContinuationMethod(ea, conti);
    }
    
    public static testMethod void methodToCheckDeny(){
        
        
        Test.startTest();
        list<Order_Items__c> ol=[select id,Order_Id__c,Order_Item_Reference_No__c,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        
        Case cs1 = new Case();
        cs1.Issue_Type__c = 'Exceptional Refund';
        cs1.Issue_Sub_Category__c = 'Customer Delight';
        cs1.type='B2B';
        cs1.Trip_Id_ct__c = ol[0].Order_Id__c;
        cs1.TIN_No__c = ol[0].Order_Item_Reference_No__c;
        cs1.Refund_Amount__c = 124;
        cs1.Description ='unit test case' ;
        cs1.Transaction_ID__c = ol[0].id;
        cs1.status= 'Open';
        cs1.Country__c='India';
        cs1.Booking_Email_ID__c = ol[0].Email__c;
        cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs1.Origin='InBound Call';
        cs1.Subject = 'Exceptional Refund- '+cs1.Issue_Sub_Category__c;
        cs1.User_Level_Team__c = 'BoltPrimoRpw';
        insert cs1;
                 String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='B2BExpOperatorRefund'].Endpoint__c;

        case csObj=[select id,casenumber from case where id=:cs1.id];
        ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
        ea.sellerCentralId='124';
        ea.selCsId=csObj.id;
        ea.selectedTeam = 'BoltPrimoRpw';
        ea.refreshlist();
        ea.seleStatus='Deny';
        Continuation conti = (Continuation)ea.B2BExceptionalRefund();
        ea.refreshlist();
        HttpResponse response = new HttpResponse();
        string responseBody='{"cancellable":"true","cancellationCharges":{"entry":[{"key":"26U","value":"10.00"},{"key":"25U","value":"10.00"},{"key":"23U","value":"10.00"},{"key":"22U","value":"10.00"},{"key":"29U","value":"10.00"},{"key":"28U","value":"10.00"}]},"fares":{"entry":[{"key":"26U","value":"105.00"},{"key":"25U","value":"105.00"},{"key":"23U","value":"105.00"},{"key":"22U","value":"105.00"},{"key":"29U","value":"105.00"},{"key":"28U","value":"105.00"}]},"freeCancellationTime":"10.00","partiallyCancellable":"true","serviceCharge":"0"}';
        response.setBody(responseBody);
      //  Test.setContinuationResponse(ea.excepRefReq, response);
     //   Object result = Test.invokeContinuationMethod(ea, conti);
    }

    public static testMethod void methodToCheckinitiateExceptionalRefund(){
        ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
        ea.teamWisecases();
    }

    @isTest
    static void closeShBotParentCaseTest(){
        Case cs = new Case();
        cs.Issue_Type__c ='NEFT Refund';
        cs.Account_Holder_Name__c = 'redBus Account';
        cs.Account_Number__c = '5525511881';
        cs.Country_ct__c = 'IND';
        cs.tin_no__c = 'TN828929192';
        cs.Priority = 'Low';
        insert cs;

        ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
        string caseId = String.valueOf(cs.Id);
        ea.closeShBotParentCase(caseId);
    }

    

        static testMethod void initiateRefundSGMYTest()
        {
            
            List<Activities__c> listOrItems = new List<Activities__c>();
            Activities__c orIt = new Activities__c();
            orIt.Purchase_Item_Currency__c = 'MYR';
            orIt.Activity_uuid__c = 'xcds32432432';
            orIt.OrderUuid__c = '6df4532506def0067bf1fe8602010200';
            orIt.Customer_Email_id__c = 'test@mail.com';
            listOrItems.add(orIt);
            
            user currUser=[select id,user_level__c,Country from user where id=:UserInfo.getUserID()];
    
    
            Activities__c orIt2 = new Activities__c();
            orIt2.Purchase_Item_Currency__c = 'MYR';
            orIt2.Activity_uuid__c = 'xcds32434542432';
            orIt2.Business_Unit__c='redbus_IN';
            orIt2.OrderUuid__c = '6df4532506def0dgrdfgfd067bf1fe8602010200';
            orIt2.Customer_Email_id__c = 'test@mail.com';
            listOrItems.add(orIt2);
            insert listOrItems;
            
            Case cs = new Case();
            cs.Issue_Type__c = 'Exceptional Refund';
            cs.Issue_Sub_Category__c = 'Customer Delight';
            cs.Trip_Id_ct__c = orIt.Activity_uuid__c;
            cs.TIN_No__c = orIt.OrderUuid__c;
            cs.Refund_Amount__c = 124;
            cs.Description ='unit test case' ;
            cs.Activity_Id__c = orIt.Id;
            cs.Business_Type__c='Activities';
            cs.Business_Unit_ct__c='SGMY Activites';
            cs.status= 'Open';
             cs.Country__c='India';
            cs.Booking_Email_ID__c = orIt.Customer_Email_id__c;
            cs.OwnerId = currUser.id;
            cs.Origin='InBound Call';
            cs.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
            cs.User_Level_Team__c = 'BoltPrimoRpw';
            cs.Refund_Amount__c =10;
            insert cs;
            
            
            Case cs1 = new Case();
            cs1.Issue_Type__c = 'Exceptional Refund';
            cs1.Issue_Sub_Category__c = 'Technical Errort';
            cs.Trip_Id_ct__c = orIt2.Activity_uuid__c;
            cs.TIN_No__c = orIt2.OrderUuid__c;
            cs1.Refund_Amount__c = 124;
            cs1.Description ='unit test case' ;
            cs1.Activity_Id__c = orIt2.id;
            cs1.status= 'Open';
            cs1.Country__c='India';
            cs1.Booking_Email_ID__c = orIt2.Customer_Email_id__c;
            cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs1.Origin='InBound Call';
            cs1.Business_Type__c='Activities';
            cs1.Business_Unit_ct__c='SGMY Activites';
            cs1.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
            cs1.User_Level_Team__c = 'BoltPrimoRpw';
            cs1.Refund_Amount__c = 12;
            insert cs1;
            case csObj=[select id,casenumber from case where id=:cs1.id];
            string reject='Rejected';
            string clmrjct='Claim Rejected Successfully';
            string clmreFail='Claim Reject Failed';
            ExceptionalRefundApprovalCntl exRef = new ExceptionalRefundApprovalCntl();
            exRef.selectedTeam = 'BoltPrimoRpw';
            exRef.refreshlist();
            exRef.seleStatus ='Deny';
            exRef.selCsId = cs.id;
            
            exRef.initiateRefund();
            
            
            exRef.seleStatus ='Approve';
            exRef.cId='1234567';
            exRef.selCsId = csObj.id;
            exRef.b2cCaseComments='Test Comments';
            OrderItemTransactionResource__c ot=new OrderItemTransactionResource__c();
            ot.Name='REDBUS_IN';
            ot.Auth_Key__c='1253Ratr';
            ot.Case_Country__c='India';
            ot.Default_Currency__c='INR';
            insert ot;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
            exRef.initiateRefund();
            //exRef.ApproveorRejectstatus(reject,clmrjct,clmreFail);
            Test.stopTest();
            
        }

        static testMethod void initiateRefundZQPTest()
        {
            
            List<Order_Items__c> listOrItems = new List<Order_Items__c>();
            Order_Items__c orIt = new Order_Items__c();
            orIt.Order_Item_Reference_No__c = 'TL12671237328';
            orIt.Business_Unit__c='ASSAMRTC_IN';
            orIt.Email__c = 'Test@redbus.com';
            orIt.Order_Id__c = '15653253265362';
            listOrItems.add(orIt);
            
            user currUser=[select id,user_level__c,Country from user where id=:UserInfo.getUserID()];
    
    
            Order_Items__c orIt2 = new Order_Items__c();
            orIt2.Order_Item_Reference_No__c = 'TL1267137328';
            orIt2.Email__c = 'Test2@redbus.com';
            orIt2.Business_Unit__c='redbus_IN';
            orIt2.Order_Id__c = '25653253265362';
            listOrItems.add(orIt2);
            insert listOrItems;
            
            Case cs = new Case();
            cs.Issue_Type__c = 'Exceptional Refund';
            cs.Issue_Sub_Category__c = 'ZQP Incorrect Booking';
            cs.Trip_Id_ct__c = orIt.Order_Id__c;
            cs.TIN_No__c = orIt.Order_Item_Reference_No__c;
            cs.Refund_Amount__c = 16000;
            cs.Description ='unit test case' ;
            cs.Transaction_ID__c = orIt.id;
            cs.status= 'Open';
             cs.Country__c='India';
            cs.Booking_Email_ID__c = orIt.Email__c;
            cs.OwnerId = currUser.id;
            cs.Origin='InBound Call';
            cs.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
            cs.User_Level_Team__c = 'BoltPrimoRpw';
            insert cs;
            
            
            Case cs1 = new Case();
            cs1.Issue_Type__c = 'Exceptional Refund';
            cs1.Issue_Sub_Category__c = 'ZQP Incorrect Booking';
            cs1.Trip_Id_ct__c = orIt2.Order_Id__c;
            cs1.TIN_No__c = orIt2.Order_Item_Reference_No__c;
            cs1.Refund_Amount__c = 16000;
            cs1.Description ='unit test case' ;
            cs1.Transaction_ID__c = orIt2.id;
            cs1.status= 'Open';
            cs1.Country__c='India';
            cs1.Booking_Email_ID__c = orIt2.Email__c;
            cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs1.Origin='InBound Call';
            cs1.Subject = 'Exceptional Refund- '+cs.Issue_Sub_Category__c;
            cs1.User_Level_Team__c = 'BoltPrimoRpw';
            insert cs1;
            case csObj=[select id,casenumber from case where id=:cs1.id];
            string reject='Rejected';
            string clmrjct='Claim Rejected Successfully';
            string clmreFail='Claim Reject Failed';
            ExceptionalRefundApprovalCntl exRef = new ExceptionalRefundApprovalCntl();
            exRef.selectedTeam = 'BoltPrimoRpw';
            exRef.refreshlist();
            exRef.seleStatus ='Deny';
            exRef.selCsId = cs.id;
            
            exRef.initiateRefund();
            
            
            exRef.seleStatus ='Approve';
            exRef.cId='1234567';
            exRef.selCsId = csObj.id;
            exRef.b2cCaseComments='Test Comments';
            OrderItemTransactionResource__c ot=new OrderItemTransactionResource__c();
            ot.Name='REDBUS_IN';
            ot.Auth_Key__c='1253Ratr';
            ot.Case_Country__c='India';
            ot.Default_Currency__c='INR';
            insert ot;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new redBusCancellationMock());
            exRef.initiateRefund();
            //exRef.ApproveorRejectstatus(reject,clmrjct,clmreFail);
            Test.stopTest();
            
        }
        
        public static testMethod void MMTB2BExceptionalRefundTest(){
        
        
            Test.startTest();
            list<Order_Items__c> ol=[select id,Order_Id__c,Order_Item_Reference_No__c,name,email__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
            
            case cs = New case();
            cs.Refund_status__c ='Instant Resolution with refund';
            cs.redCare_Status__c ='Test';
            cs.My_Desk_Id__c = '638264983498349023';
            insert cs;
            
            Case cs1 = new Case();
            cs1.Issue_Type__c = 'Exceptional Refund';
            cs1.Issue_Sub_Category__c = 'Technical Error';
            cs1.type='B2B';
            cs1.Trip_Id_ct__c = ol[0].Order_Id__c;
            cs1.TIN_No__c = ol[0].Order_Item_Reference_No__c;
            cs1.Refund_Amount__c = 124;
            cs1.Description ='unit test case' ;
            cs1.Transaction_ID__c = ol[0].id;
            cs1.status= 'Open';
            cs1.Country__c='India';
            cs1.Booking_Email_ID__c = ol[0].Email__c;
            cs1.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs1.Origin='InBound Call';
            cs1.My_Desk_Id__c = '638264983498349023';
            cs1.Subject = 'Exceptional Refund- '+cs1.Issue_Sub_Category__c;
            cs1.User_Level_Team__c = 'BoltPrimoRpw';
            cs1.ParentId = cs.Id;
            insert cs1;
            case csObj=[select id,casenumber from case where id=:cs1.id];
            ExceptionalRefundApprovalCntl ea=new ExceptionalRefundApprovalCntl();
            ea.sellerCentralId='124';
            ea.selCsId=csObj.id;
            ea.selectedTeam = 'BoltPrimoRpw';
            ea.refreshlist();
            ea.seleStatus='Approve';
            Continuation conti = (Continuation)ea.B2BExceptionalRefund();
            // ea.refreshlist();
            // HttpResponse response = new HttpResponse();
            // string responseBody='{"cancellable":"true","cancellationCharges":{"entry":[{"key":"26U","value":"10.00"},{"key":"25U","value":"10.00"},{"key":"23U","value":"10.00"},{"key":"22U","value":"10.00"},{"key":"29U","value":"10.00"},{"key":"28U","value":"10.00"}]},"fares":{"entry":[{"key":"26U","value":"105.00"},{"key":"25U","value":"105.00"},{"key":"23U","value":"105.00"},{"key":"22U","value":"105.00"},{"key":"29U","value":"105.00"},{"key":"28U","value":"105.00"}]},"freeCancellationTime":"10.00","partiallyCancellable":"true","serviceCharge":"0"}';
            // response.setBody(responseBody);
            // Test.setContinuationResponse(ea.excepRefReq, response);
            // Object result = Test.invokeContinuationMethod(ea, conti);
        }
}