/**
 * (c) 2016 RedBus
 *
 * Name           : SPOCBusCancellationExtnTest
 * Created Date   : 12 Dec 2016
 * Created By     : Sreenivas M
 * Purpose        : Test class for SPOCBusCancellationExtn class
 *
 **/
 
@isTest
private class SPOCBusCancellationExtnTest{
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
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';
        orIt.date_of_service__c = system.now();
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        listOrIt.add(orIt);
        
        Order_Items__c  orIt2= new Order_Items__c();
        orIt2.Order_Item_Reference_No__c = 'TJCN77774445';
        orIt2.name = '9837321722';
        listOrIt.add(orIt2);
        
        Order_Items__c  orIt3= new Order_Items__c();
        orIt3.Order_Item_Reference_No__c = 'TJCN4444446';
        orIt3.name = '9837321733';
        listOrIt.add(orIt3);
        
        insert listOrIt;
              
        Case cs = new Case();
        cs.Status = 'Open';
        cs.Country__c ='India';
        cs.Business_Unit_ct__c = 'REDBUS_IN';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        insert cs;
         System.debug('test tin'+cs.TIN__c);
        
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
         
          OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(cs);
        SPOCBusCancellationExtn spExtn = new SPOCBusCancellationExtn(stdCntrl);
        spExtn.getboOptions();
        spExtn.getstatusOptions();
        spExtn.doSearch();
        spExtn.selBO = 'Orange'; 
        spExtn.getmapServiceIdtoCase();
        ApexPages.currentPage().getParameters().put('selRouid','4353_'+String.valueOf(System.today())+'_Orange');
        spExtn.loadCaseData();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        spExtn.listWrapCase[0].isSelect = true;
        spExtn.updateAction='Approved';
        spExtn.tableIdtoRender = 'caseTableRB4353_'+String.valueOf(System.today())+'_Orange';
        spExtn.performUpdate();
        //spExtn.updateAction='Refunded by redBus';
        //spExtn.performUpdate();
        
      
     }
     
      @isTest static void testCancellation2() 
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
        cs.Country__c ='India';
        cs.Business_Unit_ct__c = 'REDBUS_IN';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        insert cs;
        
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
          OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(cs);
        SPOCBusCancellationExtn spExtn = new SPOCBusCancellationExtn(stdCntrl);
        spExtn.getboOptions();
        spExtn.getstatusOptions();
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
         Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
         spExtn.performUpdate();
        
        Test.stopTest();
        
      
     }
   /*  @isTest static void testConnectCall() 
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
         
          ApexPages.StandardController stdCntrl = new ApexPages.StandardController(cs);
        SPOCBusCancellationExtn spExtn = new SPOCBusCancellationExtn(stdCntrl);
         spExtn.tableIdtoRender = 'caseTableRB4353_'+String.valueOf(System.today())+'_Orange';
         spExtn.boPhoneNo='9491322718';
         spExtn.connectCall();
         // Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
         
          RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                
        req.requestURI = 'http://cmapi-pp.redbus.com/api/Transaction/v1/call/cancellation';  
        req.httpMethod = 'POST';//HTTP Request Type       
        RestContext.request = req;
        RestContext.response= res;        
        System.debug('test resp--->'+res);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
     }
     */
    @isTest static void testCancellation3() 
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
        SPOCBusCancellationExtn spExtn = new SPOCBusCancellationExtn(stdCntrl);
        spExtn.getboOptions();
        spExtn.getstatusOptions();
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
    
}