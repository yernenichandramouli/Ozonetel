/**
 * (c) 2016 RedBus
 *
 * Name           : SPOCBusCancellationExtnTest
 * Created Date   : 12 April 2018
 * Created By     : Veeramanikanta
 * Purpose        : Test class for SPOCBusCancellationExtn class
 *
 **/
 
@isTest
private class BusCancellationRefundedCasesTest{
     @isTest static void testCancellation() 
     {
        List<Order_Items__c> listOrIt = new List<Order_Items__c>();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.created_by__c = 'test';
        orIt.creation_time__c = system.now();
        orIt.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        orIt.amount_recieved_currency__c = 'INR';
        orIt.Order_Item_Reference_No__c= 'TM4N54341643';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';
        orIt.date_of_service__c = system.now();
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        listOrIt.add(orIt);
        
     /*   Order_Items__c  orIt2= new Order_Items__c();
        orIt2.Order_Item_Reference_No__c = 'TJCN77774445';
        orIt2.name = '9837321722';
        listOrIt.add(orIt2);
        
        Order_Items__c  orIt3= new Order_Items__c();
        orIt3.Order_Item_Reference_No__c = 'TM4N54341643';
        orIt3.name = '9837321733';
        listOrIt.add(orIt3);
      */  
        insert listOrIt;
              
        Case cs = new Case();
        cs.Status = 'Initiated';
        cs.isAgening_Refund_Processed__c=true;
        cs.isAgeing_Refund_Success__c=true;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
         cs.issue_type__c='Bus Cancellation';
        insert cs;
         cs.Status='Department Revert';
         cs.OwnerId=userinfo.getUserId();
         update cs;
         System.debug('test tin'+cs.TIN__c);
        
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(cs);
        BusCancellationRefundedCases spExtn = new BusCancellationRefundedCases(stdCntrl);
        spExtn.getboOptions();
       
        spExtn.doSearch();
        spExtn.selBO = 'Orange'; 
          spExtn.doi=System.today();
         spExtn.doj=System.today();
        spExtn.getmapServiceIdtoCase();
        ApexPages.currentPage().getParameters().put('selRouid','4353_'+String.valueOf(System.today())+'_Orange');
        spExtn.loadCaseData();
        
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
      
        spExtn.listWrapCase[0].isSelect = true;
        spExtn.updateAction='Approved';
        spExtn.tableIdtoRender = 'caseTableRB4353_'+String.valueOf(System.today())+'_Orange';
          // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi.redbus.com/api/User/v1/SendSmsOrMail?tin=123456&flag=2&email=mani.renus@gmail.com&mobile=9491322718';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        // string json='{"Status":"Ok","Code":"200"}';
         string json='[{"tin":"TM4N54341643","status":"Success"},{"tin":"SGM4U26589393","status":"Success"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));

                   spExtn.connectCall();
        
 spExtn.boPhoneNo='9491322718';
          spExtn.connectCall();
         Test.startTest();
         spExtn.performUpdate();
         Test.stopTest();
        
        //spExtn.updateAction='Refunded by redBus';
        //spExtn.performUpdate();
        
     }
  /*  @isTest static void testCancellation3() 
     {
        List<Order_Items__c> listOrIt = new List<Order_Items__c>();
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.created_by__c = 'test';
        orIt.creation_time__c = system.now();
        orIt.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        orIt.amount_recieved_currency__c = 'INR';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';
        orIt.date_of_service__c = system.now();
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        listOrIt.add(orIt);
        
      
        insert listOrIt;
              
        Case cs = new Case();
        cs.Status = 'Open';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        insert cs;
        
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(cs);
        BusCancellationRefundedCases spExtn = new BusCancellationRefundedCases(stdCntrl);
        spExtn.getboOptions();
        spExtn.doSearch();
        spExtn.selBO = 'Orange'; 
        spExtn.getmapServiceIdtoCase();
        ApexPages.currentPage().getParameters().put('selRouid','4353_'+String.valueOf(System.today())+'_Orange');
        spExtn.loadCaseData();
        
        
        spExtn.listWrapCase[0].isSelect = true;
       
        spExtn.tableIdtoRender = 'caseTableRB4353_'+String.valueOf(System.today())+'_Orange';
      
        spExtn.updateAction='Refunded by redBus';
        Test.startTest();
         // Set mock callout class 
        // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
          RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi-pp.redbus.com/api/Transaction/v1/call/cancellation';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","status":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
      
         spExtn.boPhoneNo='9491322718';
         spExtn.connectCall();
        Test.stopTest();
        
      
     }
  */  
     }