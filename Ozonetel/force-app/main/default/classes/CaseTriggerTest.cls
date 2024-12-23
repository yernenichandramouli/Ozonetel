/**
* (c) 2017 RedBus
*
* Name           : CaseTriggerTest
* Created Date   : 04 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Test class for CaseTrigger and CaseTriggerHandler class
*
**/

@isTest
private class CaseTriggerTest {
    
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(name = 'testLName'+i,Flag__c=0,Business_Unit__c='REDBUS_IN',Transaction_Status__c='Booked',Order_Item_Reference_No__c='TN123456',Date_Of_Service__c =system.now(),Route_Id__c='2345876', Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='09491322718'));
        } 
        insert orderList ;
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Initiated';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.redCare_Amount__c=121;
        cs.redCare_Status__c='test';
        cs.First_Closure__c=system.now();
        cs.origin='Inbound call';
        cs.Issue_Sub_Category__c='Initiate Bus Cancellation';
        cs.Country__c='India';
        cs.Transaction_ID__c=orderList[0].id;
        cs.tin_no__c=orderList[0].Order_Item_Reference_No__c;
        cs.TAT_Value__c=678918;
        cs.Trip_Id_ct__c='123';
        insert cs;
        CaseTriggerHandler ch = new CaseTriggerHandler();        
    }
    
    
    static testMethod void afterInsertTest()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        List<Case> listCases = new List<Case>();
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();       
        cs.Status ='Open';
        cs.Origin = 'EmailSupport';
        cs.description='Test Description';              
        cs.Ownerid = UserInfo.getUserId();
        listCases.add(cs);
        Case cs1 = new Case();
        cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs1.Status ='Initiated';
        cs1.Origin = 'Inbound Call';
        cs1.Transaction_ID__c=ol[0].Id;
        cs1.Issue_Type__c ='NEFT Refund';
        cs1.Country__c='India';
        cs1.TAT_Value__c=67891;
        listCases.add(cs1);
        insert listCases;
        casecomment cc=new casecomment();
        cc.CommentBody='Test';
        cc.ParentId=cs.id;
        insert cc;
        Map<Id,case> caseMap=New Map<Id,Case>();
        list<id> caseIds=new list<id>();
        for(case c: listCases){
            caseMap.put(c.Id,c);
            caseIds.add(c.Id);
        }
        string json='{"status_code":200,"data":{"url":"https:www.redbus.idRefund?orderId=Op7Oao9gae2OIVF x81kbYrMXbkwh2U6nbQfko5RzuTXkn5a110xKLWrzxqm7y&Tin=nqRyUS2hsrHk3rIdQ9bo9WZWkWp45Kb5Lfso5erM4=&isEc=true&IsNewEncr=True,cD=2020-10-03 05:08:56","short":"jeqvxrl"}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        //Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        //List<case> caseList= new List<case>();
        //caseList = [select id,Issue_Type__c from case where id in :];
        CaseTriggerHandler.duplicateCheck(listCases,caseMap);
        Case c1 = new case();
        c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        c1.Issue_Type__c = 'Bus Cancellation';
        c1.Status = 'Initiated';
        c1.Transaction_Id__c =ol[1].Id;
        insert c1;
        listCases.add(c1);
        CaseTriggerHandler.duplicateCheck(listCases,caseMap);
        //listNEFTRefundCases
        Test.stopTest();
        
    }
    
    static testMethod void afterUpdateTest()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        Case cs = new Case();
        cs.status ='Open';
        cs.Transaction_ID__c=ol[0].Id;
        cs.TAT_Value__c=6789;
        insert cs;
        cs.TAT_Value__c=6789;
        cs.issue_type__c='Bus Operator Service';
        cs.status='Closed';
        Update cs;
        cs.issue_type__c='NEFT Refund';
        cs.Disbursal_Status__c='open';
        cs.Transaction_UUID__c='123';
        cs.status='Open';
        update cs;
        cs.Status= 'Escalated to BD';
        cs.Country__c= 'India';
        cs.All_Previous_Status_Dates__c = 'Escalated to BD';
        cs.BD_Location__c='Hyderabad';
        update cs;
        system.debug('<<cs id:'+ cs.id);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        
        Test.stopTest();
    }

    static testMethod void afterUpdateTest1()
    {
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        Case cs = new Case();
        cs.status ='Initiated';
        cs.Transaction_ID__c=ol[0].Id;
        cs.TAT_Value__c=6789;
        cs.Issue_Type__c='Wallet Credit';
        cs.Issue_Sub_Category__c ='ZQP';
        cs.Origin = 'Complaint Tracker';
        cs.Channel_ct__c = 'Chat';
        // cs.Business_Type__c = 'Bus';
        cs.Country__c = 'India';
        cs.Business_Type__c = 'BusHire'; 
        cs.Lead_TCode__c ='aqsa';
        insert cs;

        cs.Status= 'Escalated to BD';
        cs.Country__c= 'India';
        cs.All_Previous_Status_Dates__c = 'Escalated to BD';
        cs.BD_Location__c='Hyderabad';
        update cs;
        system.debug('<<cs id:'+ cs.id);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        
        Test.stopTest();
    }
    
    /*
Name: walletCreditTest
Descripton: Testing wallet Credit functionality
*/
    static testMethod void walletCreditTestSuccess()
    {
        Test.startTest(); 
        list<Order_Items__c> ol=[select id,name,email__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        Case cs = new Case();  
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Wallet Credit').getRecordTypeId();
        cs.Status ='Open';
        cs.Customer_Email_ID__c='Veeramanikanta.r@redbus.com';
        cs.Customer_Phone_Number__c='9491322718';
        cs.redCare_Amount__c=121;
        cs.redCare_Status__c='test';
        cs.First_Closure__c=system.now();
        cs.TAT_Value__c=122;
        cs.Transaction_ID__c=ol[0].Id;
        cs.redCare_Multiple__c=false;
        cs.Amount__c=12;
        cs.Price_Paid_Currency_ctp__c='INR';
        cs.Issue_Type__c='Wallet Credit';
        insert cs;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        insert cc;
        cs.status='Approved for Wallet Credit';
        List<id> caseIds = new List<id>();
        caseIds.add(cs.Id);
        CaseTriggerHandler.WalletCreditApprove(caseIds);
        string json='{"Data":[{"offerId":4619734,"offerType":"SPECIFIC","offerName":"Specific Offer","amount":1,"walletId":"xilLU2p4e7UntmldETkQEQ","isRefundable":true,"isUsed":false,"amountUsed":0,"expirationDate":"2017-10-01 18:18:46","creationDate":"2017-07-03 12:48:46","merchantId":1}],"IsWalletCreated":false,"NewToken":null,"WalletId":null,"Status":{"code":0,"statusCode":201,"error":"Amount credited sucessfully.","statusMessage":"SUCCESS","type":null},"ResponseMessage":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(201, 'OK', json));
        update cs;
        CaseTriggerHandler.WalletCreditApprove(caseIds);
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(404, 'Not Found', '{}'));
        update cs;
        cs.Price_Paid_Currency_ctp__c='SG';
        cs.Status='open';
        update cs;        
        cs.Price_Paid_Currency_ctp__c='MY';
        update cs;
        cs.Price_Paid_Currency_ctp__c='ID';
        update cs;
        cs.Price_Paid_Currency_ctp__c='PEN';
        update cs;
        cs.Price_Paid_Currency_ctp__c='COP';
        update cs;
        Test.stopTest();
    }
    static testMethod void InsuranceTestSuccess()
    {
         Test.startTest();
        Case cs = new Case();
        list<Order_Items__c> orderList=[select id,name,email__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Business_Unit_ct__c='REDBUS_IN';
        cs.Claim_id__c='9834567890';
        cs.Insurance_Provider_Name__c='Acko';
        cs.Status ='Initiated';
        cs.redCare_Amount__c=121;
        cs.redCare_Status__c='test';
        cs.First_Closure__c=system.now();
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Country__c='India';
        cs.Transaction_ID__c=orderList[0].id;
        cs.tin_no__c=orderList[0].Order_Item_Reference_No__c;
        cs.TAT_Value__c=678918;
        cs.Trip_Id_ct__c='123';
        cs.Notes__c='Alternative Arrangement by redBus';
        insert cs;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        insert cc;
        cs.Claim_Type_ctp__c='BOC';
        cs.Policy_Id__c='567890';
        cs.status='closed';
        
        update cs;
       
        string json='{"result":{"policy_id":"policy_fFAb9sGrXfFNBcd","claim_id":"claim_cqwdevXJpda50Gp","status":"Claim status updated successfully"},"success":true,"errorMessage":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.stopTest();
    }
    static testMethod void busCnclTest()
    {
        Test.startTest(); 
        Case cs = new Case();
        list<Order_Items__c> orderList=[select id,Route_Id__c,name,email__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Business_Unit_ct__c='REDBUS_IN';
        cs.Status ='Initiated';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Transaction_ID__c=orderList[0].id;
        cs.tin_no__c=orderList[0].Order_Item_Reference_No__c;
        cs.TAT_Value__c=678918;
        cs.Trip_Id_ct__c='123';
        insert cs;
        cs.status='Approved For Bus Cancellation';
        update cs;
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.stopTest();
    }
   /*static testMethod void markPayCmpltdTest()
    {
        Test.startTest();
        set<Id> caseIds = New Set<Id>();
        Case cs = new Case();
        list<Order_Items__c> orderList=[select id,Route_Id__c,name,email__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        cs.Business_Unit_ct__c='REDBUS_COM';
        cs.Status ='Open';
        cs.Issue_Sub_Category__c ='Mark Payment As Completed';
        cs.PG_Id__c='5645678789';
        cs.Order_UUId__c='854567876678';
        cs.PG_Ttransaction_Id__c='67891845678';
        cs.Approved_By__c=UserInfo.getUserId();
        insert cs;
        cs.status='Approved';
        update cs;
        caseIds.add(cs.id);
        string json='{"ISSuccess":true,"status":"SUCCESS","errors":[],"data":{"payments":[{"uuid":"18cd9958b025f0055722993402030100","savedCard":0,"requestedBy":"Naveen Kumar.V","preferred":0,"pgType":"Payment","pgName":"PaaS","paymentSystemRefNo":"1125557951","paymentSystem":"ONLINE","paymentStatus":"COMPLETED","paymentSessionId":12808386069013113,"paymentItemValue":{"currencyType":"INR","amount":284.0},"orderId":12808386069013113,"offerSelectionMode":0,"id":12808386079673026,"creationTime":"2020-09-25T15:37:39","businessUnitValue":{"currencyType":"INR","amount":284},"approvedBy":"Karthick S"}]}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.CompletePaymentApprove(caseIds);
        Test.stopTest();
    }*/
    
    static testMethod void failMarkPayCmpltdTest()
    {
        Test.startTest();
        set<Id> caseIds = New Set<Id>();
        Case cs = new Case();
        list<Order_Items__c> orderList=[select id,Route_Id__c,name,email__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        cs.Business_Unit_ct__c='REDBUS_COM';
        cs.Status ='Open';
        cs.Issue_Sub_Category__c ='Mark Payment As Completed';
        cs.PG_Id__c='5645678789';
        cs.Order_UUId__c='854567876678';
        cs.PG_Ttransaction_Id__c='67891845678';
        cs.Approved_By__c=UserInfo.getUserId();
        cs.origin='Email support queue Peru';
        insert cs;
        cs.status='Approved';
        update cs;
        caseIds.add(cs.id);
        string json='{"ISSuccess":true,"errors":[],"data":{"payments":[{"uuid":"18cd9958b025f0055722993402030100","savedCard":0,"requestedBy":"Naveen Kumar.V","preferred":0,"pgType":"Payment","pgName":"PaaS","paymentSystemRefNo":"1125557951","paymentSystem":"ONLINE","paymentStatus":"COMPLETED","paymentSessionId":12808386069013113,"paymentItemValue":{"currencyType":"INR","amount":284.0},"orderId":12808386069013113,"offerSelectionMode":0,"id":12808386079673026,"creationTime":"2020-09-25T15:37:39","businessUnitValue":{"currencyType":"INR","amount":284},"approvedBy":"Karthick S"}]}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.CompletePaymentApprove(caseIds);
        Test.stopTest();
    }
    
    
    static testMethod void markPayCmpltd_IndTest()
    {
        Test.startTest();
        Case cs = new Case();
        list<Order_Items__c> orderList=[select id,Route_Id__c,name,email__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        cs.Business_Unit_ct__c='REDBUS_IND';
        cs.Status ='Open';
        cs.Issue_Sub_Category__c ='Mark Payment As Completed';
        cs.PG_Id__c='5645678789';
        cs.Order_UUId__c='854567876678';
        cs.PG_Ttransaction_Id__c='67891845678';
        cs.Approved_By__c=UserInfo.getUserId();
        cs.country__c='India';
        insert cs;
        cs.status='Approved';
        update cs;
        string json='{ "Status": "SUCCESS", "Message": "SUCCESS", "TxnStatus": [{ "TxnId": 1151889577, "OrderId": "e71e54bac8a6f0055722993401030100", "IsSyncRequired": false, "Syncstatus": "SUCCESS" } ] }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.stopTest();
    }
    
    static testMethod void mmtBusCnclTest()
    {
        Test.startTest();
        Case cs = new Case();
        cs.status ='Initiated';
        cs.My_Desk_Id__c='34567890';
        cs.issue_type__c='Bus Cancellation';
        cs.Country__c='peru';
        insert cs;
        cs.status='Approved';
        update cs;
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        List<Case> BusCList = new List<Case>();
        Map<Id,Case> TriggerOldMap = new Map<Id,Case>();
        Case c = new Case();
        c.Issue_Type__c = 'Bus Cancellation';
        c.Status = 'Initiated';
        insert c;
        TriggerOldMap.put(c.Id, c);
        c.Status = 'Rejected For Bus Cancellation';
        update c;
        BusCList.add(c);
        //JSON.serialize(busCList)
        //JSON.serialize(Trigger.oldMap)
        caseTriggerHandler.createBusCCasesForCoPass(JSON.serialize(busCList),JSON.serialize(Trigger.oldMap));
        Test.stopTest();
    } 
    
    static testMethod void ackoPolicylTest()
    {
        Test.startTest();
        Case cs = new Case();
        cs.Status ='Initiated';
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Issue_Sub_Category__c='Initiate Bus Cancellation';
        cs.Country__c='India';
        cs.TIN_No__c='tn4567890';
        insert cs;
        string json='{"policyId":"policy_yf1PpXJg1znnMnB","redirect_url":"https://epartners.icicilombard.com/ePartners/api/redbus/policy/Document/policy_yf1PpXJg1znnMnB","vendor":"ICICI","success":true,"status":"1"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.stopTest();
    }
    
    static testMethod void neftIdsafterUpdateTest()
    {
        Test.startTest();
        Case cs = new Case();
        cs.status ='open';
        cs.Country__c='Colombia';
        cs.TAT_Value__c=6789;
        insert cs;
        case c = new case();    
        c.status ='open';
        c.TAT_Value__c=6789;
        c.ParentId = cs.id;
        insert c;
        cs.TAT_Value__c=6789;
        cs.issue_type__c='NEFT Refund';
        cs.status='New';
        Update cs;
        cs.status='Closed';
        cs.PG_Ttransaction_Id__c='123';    
        Update cs;
        CaseTriggerHandler ch = new CaseTriggerHandler();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.stopTest();
    }
    static testMethod void beforeUpdateTest()
    {
        Test.startTest();
        Case cs = new Case();
        cs.status ='Closed';
        insert cs;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        cs.Closed_By_Agent_Role__c='test';
        cs.status='Re-Open';
        Update cs;
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        Test.stopTest();
    }
    
    static testMethod void RredCareTest()
    {
        Test.startTest(); 
        
        account a=new account();
        a.PersonMobilePhone ='3453453453';
        a.LastName='test';
        insert a;
        
        
        list<Order_Items__c> ol=[select id,name,email__c,Mobile__c from Order_Items__c limit 1];
        ol[0].Business_Unit__c='REDBUS_IN';
        ol[0].Order_Item_Reference_No__c='123456';
        ol[0].Customer_Name__c =a.id;
        update ol;
        
        Case cs = new Case();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='Booking Issues';
        cs.Issue_Sub_Category__c='Need M ticket/ E ticket';  
        cs.Transaction_ID__c=ol[0].id;
        cs.Phone_No_ct__c='9989878789';
        cs.tin_no__c=ol[0].Order_Item_Reference_No__c;
        cs.redCare_Multiple__c=false;
        cs.redCare_Amount__c=3243;
        cs.redCare_Status__c='T_Amount is dedited';
        cs.Email_Id_ct__c='nilika.haldar@redbus.com';
        insert cs;
        
        cs.TAT_Value__c=-8;
        cs.redCare_Amount__c=2;
        cs.Status ='Closed';
        
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        insert cc;
        update cs;
        list<id> cIds=new list<id>();
        cIds.add(cs.id);
        list<string> caseTins=new list<string>();
        caseTins.add(cs.Tin_no__c);
        string json ='{"Data":[{"offerId":55604771,"offerType":"SPECIFIC","offerName":"Exceptional Refund","amount":150.0,"walletId":"40k0fRshnDYaQW-8j4852Q","isRefundable":false,"isUsed":false,"amountUsed":0,"expirationDate":"2023-12-05 15:03:42","creationDate":"2023-09-06 09:33:42","merchantId":1}],"IsWalletCreated":false,"NewToken":null,"WalletId":null,"Status":{"code":201,"statusCode":201,"error":"Amount credited sucessfully.","statusMessage":"SUCCESS","type":null},"ResponseMessage":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.redCare_WalletCredit(cIds,caseTins,json);
        Test.stopTest();
        
    }
    static testMethod void caseCommentbdRejIdsUpdateTest()
    {
        Test.startTest();
        List<Case> listCases = new List<Case>();
        case css = new case();
        css.status='open';
        listCases.add(css);
        Case cs = new Case();
        cs.status ='open';
        cs.origin='Inbound Call';
        listCases.add(cs);
        insert listCases;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        cs.Issue_Type__c='I felt unsafe during the journey';
        cs.BD_Location__c='Hyderabad';
        cs.status='Escalated to BD';
        Update cs;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stdTEST1919@testorg.com');
        insert u;    
        cs.OwnerId=u.id;
        Map<Id,case> caseMap=New Map<Id,Case>();
        set<id> caseIds=new set<id>();
        for(case c: listCases){
            caseMap.put(c.Id,c);
            caseIds.add(c.Id);
        }
        
        CaseTriggerHandler.ValidationCaseComment2(caseIds,caseMap);
        CaseTriggerHandler.ValidationCaseComment(caseIds,caseMap);
        Test.stopTest();
    }
    static testMethod void ClosedByAgentNameUpdateTest()
    {
        Test.startTest();
        List<Case> listCases = new List<Case>();
        Case cs = new Case();
        cs.status ='closed';
        cs.origin='Inbound Call';
        listCases.add(cs);
        insert listCases;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        cs.Closed_By_Agent__c='test@gmail.com';
        cs.Closed_By_Agent_Role__c='test';
        cs.status='Re-Open';
        Update cs;
        Map<Id,case> caseMap=New Map<Id,Case>();
        set<string> caseIds=new set<string>();
        List<id> idList = new List<id>();    
        for(case c: listCases){
            caseIds.add(c.Closed_By_Agent__c);
            idList.add(c.id);
        }  
        CaseTriggerHandler.assignToSameAgent(caseIds,listCases);
        list<case> neftCases = new List<case>();    
        for(case c: listCases){
            c.status='Error in NEFT';
            neftcases.add(c);
        }      
        system.debug('<<<idList'+idList);  
        string json='{"Status": "SUCCESS", "Message": "SUCCESS","Status":"DISBURSAL_SUCCESS","ReferenceID":"530996845","DisbursalID":"f97fbc5acf3e36689d049f4f90fa3ae2","DisbursalFailureReason":"","ConfirmationResonse":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.DisbursalNEFT(idList);
        Test.stopTest();
    }
    
     static testMethod void errorNeftTest()
    {
        Test.startTest();
        List<Case> listCases = new List<Case>();
        Case cs = new Case();
        cs.status ='closed';
        cs.origin='Inbound Call';
        cs.Business_Unit_ct__c='REDBUS_ID';
        listCases.add(cs);
        insert listCases;
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=cs.Id;
        cs.Closed_By_Agent__c='test@gmail.com';
        cs.Closed_By_Agent_Role__c='test';
        Update cs;
        Map<Id,case> caseMap=New Map<Id,Case>();
        set<string> caseIds=new set<string>();
        List<id> idList = new List<id>();    
        for(case c: listCases){
            caseIds.add(c.Closed_By_Agent__c);
            idList.add(c.id);
        }  
        CaseTriggerHandler.assignToSameAgent(caseIds,listCases);
        list<case> neftCases = new List<case>();    
        for(case c: listCases){
            c.status='Error in NEFT';
            neftcases.add(c);
        }      
        system.debug('<<<idList'+idList);  
        string json='{"Status": "SUCCESS", "Message": "SUCCESS","Status":"DISBURSAL_SUCCESS","ReferenceID":"530996845","DisbursalID":"f97fbc5acf3e36689d049f4f90fa3ae2","DisbursalFailureReason":"","ConfirmationResonse":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.DisbursalNEFT(idList);
        Test.stopTest();
    }
    
    static testMethod void CaseNEFTWrapperTest(){
       
        Test.startTest();
        List<Case> listCases = new List<Case>();
        Case cs = new Case();
        cs.status ='Closed';
        cs.origin='Inbound Call';
        
        Case cs1 = new Case();
        cs1.status ='Error in NEFT';
        cs1.origin='Inbound Call';
        listCases.add(cs1);
        
        insert listCases;
        
        CaseComment cc=new CaseComment();
        cc.CommentBody='Test Comment Body';
        cc.ParentId=listCases[0].Id;
        cs.Closed_By_Agent__c='test@gmail.com';
        cs.Closed_By_Agent_Role__c='test';
        cs.status='Re-Open';
        Update listCases[0];
        
        Map<Id,case> caseMap=New Map<Id,Case>();
        set<string> caseIds=new set<string>();
        List<id> idList = new List<id>();    
        for(case c: listCases){
            caseIds.add(c.Closed_By_Agent__c);
            idList.add(c.id);
        }  
        
        CaseTriggerHandler.assignToSameAgent(caseIds,listCases);
        list<case> neftCases = new List<case>();    
        for(case c: listCases){
            c.status='Error in NEFT';
            neftcases.add(c);
        }      
        system.debug('<<<idList'+idList);    
        string json='{"Status":"DISBURSAL_SUCCESS","ReferenceID":"530996845","DisbursalID":"f97fbc5acf3e36689d049f4f90fa3ae2","DisbursalFailureReason":"","ConfirmationResonse":""}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.DisbursalNEFT(idList);
        Test.stopTest();
    }
    
    static testMethod void CaseDefaultQueueTest(){
        Test.startTest();
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();
        cs.origin='Complaint Tracker';
        cs.status='Open';
        insert cs;
        set<id> csIds=new set<id>();
        csIds.add(cs.id);
        CaseTriggerHandler.DefaultQueToEmailsupporQue(csIds);
        Test.stopTest();

    } 
    
    static testMethod void closeChildCaseTest() {
        Test.startTest();
        Case c1 = new Case();
        c1.Status = 'Escalated to RTC Tech';
        c1.Origin = 'Complaint Tracker';
        c1.Country__c = 'India';
        insert c1;
        Case c2 = new Case();
        c2.Status = 'Open';
        c2.ParentId = c1.Id;
        c2.Business_Type__c = 'RTC Support';
        insert c2;
        c2.Status = 'Closed';
        update c2;
        c2.Status = 'Open';
        c2.Business_Type__c = '';
        update c2;
        Case c3 = new Case();
        c2.Status = 'Open';
        c2.ParentId = c1.Id;
        insert c3;
        Test.stopTest();
    }
    
    static testMethod void createRTCSupportCase() {
        set<Id> caseIds = New Set<Id>();
        Test.startTest();
        Case cs = new Case();
        cs.Origin = 'Complaint Tracker';
        cs.Status = 'Open';
        cs.Country__c = 'India';
        insert cs;
        Case c2 = [select id,status from Case where id=:cs.Id];
        c2.Status = 'Escalated to RTC Tech';
        update c2;
        caseIds.add(cs.Id);
        CaseTriggerHandler.CreateLtoSupportcases(caseIds,'RTC');
        Test.stopTest();
    }
    static testMethod void CreateLtoSupportcase(){
        set<Id> caseIds = New Set<Id>();
        Test.startTest();
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Open';
        cs.country__c='India';
        insert cs;
        casecomment cc=new casecomment();
        cc.CommentBody='To test the l2 child case creation';
        cc.ParentId=cs.id;
        Case c2 = [select id, CRM_Escalation__c,status from Case where id=:cs.Id];
        c2.CRM_Escalation__c = 'Invalid';
        c2.status='Escalated to Tech';
        update c2;
        caseIds.add(cs.Id);
        CaseTriggerHandler.CreateLtoSupportcases(caseIds,'L2');
        Test.stopTest();  
    }  
    static testMethod void UpdateEscMEteamcasesTest(){
        Test.startTest();
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Open';
        cs.country__c='India';
        insert cs;
        cs.status='Escalated to ME Team';
        update cs;
        
        Test.stopTest();
   
    }  
    
    static testMethod void UpdMobEmailCsIdsTest(){
       Test.startTest();
        list<Order_Items__c> orderList=[select id,name,email__c,Mobile__c from Order_Items__c limit 1];
        
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Open';
        cs.country__c='India';
        insert cs;
        cs.status='BO reply';
        cs.Transaction_ID__c=orderList[0].id;
        update cs;
        Test.stopTest();  
    }    
    
    static testMethod void mapYourBusDetailsTest(){
     Test.startTest();
        List<case> caseList = New List<case>();
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.Operator_Id__c='123456';
        insert sp;
        
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Escalated to BD';
        cs.country__c='India';
        cs.Issue_Type__c='New vehicle- GPS details needed';
        cs.Channel_ct__c='YourBus';
        cs.Service_Providerr_Id__c='123456';
        cs.Assigned_By__c=UserInfo.getUserId();
        insert cs;
        
        caseList.add(cs);
        //CaseTriggerHandler.mapYourBusDetails(caseList);
       Test.stopTest();

    }  
    
    static testMethod void UpdateBDmailIdTest(){
        Test.startTest();
        List<case> caseList = New List<case>();
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.BD_Email__c='test@mail.com';
        sp.Operator_Id__c='123456';
        insert sp;
        
        Order_Items__c orit = New Order_Items__c();
        orit.name = 'testLName';
        orit.Service_Provider_Id__c = '123456';
        orit.Mobile__c='9491322718';
        insert orit;
        
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Escalated to BD';
        cs.country__c='India';
        cs.Channel_ct__c='YourBus';
        cs.Assigned_By__c=UserInfo.getUserId();
        cs.Transaction_ID__c=orit.id;
        insert cs;
        
        caseList.add(cs);
        CaseTriggerHandler.UpdateBDmailId(caseList);
         Test.stopTest();

    } 
    
    static testMethod void SyncMethodTest(){
        Test.startTest();

        list<Order_Items__c> orderList=[select id,name,email__c,Mobile__c from Order_Items__c limit 1];
        set<Id> caseIds = New Set<Id>();
        
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='Open';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c='NEFT Refund';
        cs.Issue_Sub_Category__c='My bus didn\'t show up';
        cs.Transaction_UUID__c='40f15aa865a2f005e2483f9f01020100';
        insert cs;
        cs.Transaction_ID__c=orderList[0].id;
        caseIds.add(cs.Id);
        
        Case cs2 = new Case();
        cs2.origin='Complaint Tracker';
        cs2.status='Open';
        cs2.country__c='Indonesia';
        cs2.Business_Type__c='Domestic-Bus';
        cs2.Issue_Type__c='NEFT Refund';
        cs2.Issue_Sub_Category__c='My bus didn\'t show up';
        cs2.Transaction_UUID__c='40f15aa865a2f005e248f01020100';
        insert cs2;
        
        caseIds.add(cs2.Id);
        CaseTriggerHandler.SyncMethod(caseIds);
                Test.stopTest();

    } 
    
    static testMethod void sendNotificationTest(){
          Test.startTest();

        set<Id> caseIds = New Set<Id>();
        
        Case cs = new Case();
        cs.Booking_Mobile_No__c='1234567890';
        cs.origin='Complaint Tracker';
        cs.status='Escalated to BD';
        cs.country__c='India';
        cs.Email_Id_ct__c='contacto@redbus.pe';
        cs.Channel_ct__c='YourBus';
        cs.Service_Providerr_Id__c='123456';
        cs.Assigned_By__c=UserInfo.getUserId();
        cs.Send_Notification__c='Description Only';
        insert cs;
        
        caseIds.add(cs.Id);
        CaseTriggerHandler.sendNotification(caseIds);
        Test.stopTest(); 

    }  
    
    static testMethod void L2suppotTest(){
       
        Test.startTest();
        system.debug('inside the l2supporttest');
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        insert orIt;

      Order_Items__c  orItt= new Order_Items__c();
        orIt.name = '9837321';
        orIt.ID__c = '98373211';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        insert orItt;
        
        set<Id> caseIds = New Set<Id>();
        lead ld=new lead();
        ld.lastname='Test';
        ld.Status='New';
        insert ld;
        
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.status='closed';
        cs.country__c='India';
        cs.Trip_Id_ct__c='4567890';
        cs.Email_Id_ct__c='contacto@redbus.co';
        cs.BD_Location__c='Hyderabad';
        cs.Transaction_id__c=orIt.id;
        cs.Issue_Type__c='Exceptional Refund';
        cs.Lead__c=ld.id;
        cs.Assigned_By__c=UserInfo.getUserId();
        insert cs;
        cs.status='Escalated to BD';
        cs.Issue_Type__c='DBT';
        cs.Transaction_id__c=orItt.id;
        update cs;
        caseIds.add(cs.Id);
        CaseTriggerHandler.CreateLtoSupportcases(caseIds,'L2');
        CaseTriggerHandler.accountDetails Accdtls= new  CaseTriggerHandler.accountDetails(); //Accdtls
        CaseTriggerHandler.CaseNEFTWrapper csNEFTwrap = new CaseTriggerHandler.CaseNEFTWrapper(cs,Accdtls);
       Test.stopTest(); 
    }  
    
    static testMethod void B2bCopassengerTest(){
     Test.startTest();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        insert orIt;

        set<Id> b2bCsIds = New set<Id>();
        case c = New case();
        c.origin='Email support queue COLOMBIA';
        c.Issue_Type__c='Exceptional Refund';
        c.Transaction_ID__c=orIt.id;
        insert c;

        b2bCsIds.add(c.Id);
       
        string json='service id map null for vendor service id: 158028';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        CaseTriggerHandler.B2bCopassenger(b2bCsIds,'');
        CaseTriggerHandler.UpdateParentCaseHaveExpRefCheck(b2bCsIds);
        // Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();
        // CaseTriggerHandler.caseMapper(RecordTypeId);
        Test.stopTest();
    }
     
       static testMethod void IRDRTest1(){
        Test.startTest();
        list<Order_Items__c> ol=[select id,name,email__c,Service_Provider_Id__c,Business_Unit__c,Mobile__c from Order_Items__c]; 
        Case cs = new Case();
        cs.origin='Complaint Tracker';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c ='I have a problem with bus service';
        cs.Issue_Sub_Category__c='Need M ticket/ E ticket';
        cs.BO_Type__c = 'Non Callable';
        cs.status='Awaiting BO/BD Response';
        cs.BO_Email__c='testemail@gmail.com';
        cs.BD_Email__c ='test@gmail.com';
        cs.country__c='India';
        insert cs;
        cs.Transaction_ID__c=ol[0].Id;
        update cs;
        Test.stopTest();
     }  
    
     
}