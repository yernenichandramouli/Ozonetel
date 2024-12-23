@isTest
public class BusCancellationExtnIntlTest {
    @isTest
    public static void testCancellation(){
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
        cs.Country__c ='Indonesia';
        cs.Business_Unit_ct__c = 'REDBUS_ID';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        insert cs;
        
        Case cs1 = new Case();
        cs1.Status = 'Open';
        cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs1.Transaction_ID__c  = orIt.id;
        insert cs1;
        
              
       OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
        list<id> caseIds = new List<id>();
        caseIds.add(cs.id);
        caseIds.add(cs1.id);
        List<case> CasesList = [select caseNumber from case where id in:caseIds];
        string updateCases;
        for(case c:casesList){
            updateCases= updateCases+';'+ c.caseNumber ;
        }
        
        system.debug('<<updateCases'+updateCases);
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
        List<case> BoList = BusCancellationExtnIntl.getboListValues(); 
        BusCancellationExtnIntl.getboListValues(); 
        BusCancellationExtnIntl.getmapServiceIdtoCase('','',Null,NUll,'All');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        test.stopTest();
        BusCancellationExtnIntl.performUpdate('Approved','1234567890','test','test case comment',updateCases);
        
    }
   @isTest
    public static void testCancellation2(){
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
        
       OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Auth_Key__c = 'IND';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_IN';
        oritran.Default_Currency__c='IND';
        insert oritran;
        
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
        cs.Country__c ='Indonesia';
        cs.Business_Unit_ct__c = 'REDBUS_ID';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Transaction_ID__c  = orIt.id;
        insert cs;
        
        Case cs1 = new Case();
        cs1.Status = 'Open';
        cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs1.Transaction_ID__c  = orIt.id;
        insert cs1;
        
        list<id> caseIds = new List<id>();
        caseIds.add(cs.id);
        caseIds.add(cs1.id);
        set<id> caseIdset = new Set<id>();
        caseIdset.add(cs.id);
        caseIdset.add(cs1.id);
                
        List<case> CasesList = [select caseNumber from case where id in:caseIds];
        string updateCases;
        for(case c:casesList){
            updateCases= updateCases+';'+ c.caseNumber ;
        }
        
        system.debug('<<updateCases'+updateCases);
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        cm.commentBody = 'testing bus cacnellation';
        insert cm;  
        List<case> BoList = BusCancellationExtnIntl.getboListValues(); 
        BusCancellationExtnIntl.getboListValues(); 
        BusCancellationExtnIntl.getmapServiceIdtoCase('','',Null,NUll,'All');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        BusCancellationExtnIntl.performUpdate('Refunded by BO','1234567890','test','test case comment',updateCases);        
        CaseTriggerHandler.BusCanclProcessBuilder(caseIdset);
        buscancellationhandler.JsonBodyWrapper wrap = new buscancellationhandler.JsonBodyWrapper();
        buscancellationhandler.ViaRouteTinsResponse viwrap= new buscancellationhandler.ViaRouteTinsResponse();
        viwrap.tin='TIN12233';
        viwrap.status='Open';
        viwrap.isSuccess=true;
        viwrap.notes='Open';
        viwrap.routeId=1223;
        
        wrap.approvedBy='integeration user';
        wrap.boAgentContactBySPOC='user';
        wrap.boAgentNameBySPOC='integeration user';
        wrap.status='open';
        wrap.doj='date';
        wrap.tin='Tin1223334';
        wrap.notes='Approved';
        wrap.routeId=122233;
        wrap.initiatedBy='Test user';
        wrap.cancellationStatus='open';
        wrap.createdTime='date';
        wrap.updatedTime='datetime';
        wrap.boAgentNameByCSE='test user';
        wrap.boAgentContactByCSE='user';
        wrap.boAgentNameByCSE='test user';
        wrap.SPOCNameByCSE='integeration user';
        wrap.orderItemUuid='12334456666';
        wrap.localeName='test user';
        wrap.TransactionID='12233431234';
        test.stopTest();
      //BusCancellationHandler.insertCancelItems('');
       }
       
   
}