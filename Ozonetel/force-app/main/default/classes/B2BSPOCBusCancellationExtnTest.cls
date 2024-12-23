/*
 * Name:B2BSPOCBusCancellationExtnTest
 * Description: Testing search and callout functionalities for 
 *      B2BSPOCBusCancellationExtnTest controller
 *
 */

@isTest
public class B2BSPOCBusCancellationExtnTest
{ 
   public static testMethod void NotesUpdateTest()
    {   
        Test.startTest();
        List<Order_Items__c> listOrIt = new List<Order_Items__c>();
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Route_Id__c='12345';
        
        oi.Date_Of_Service__c=system.now();
        listOrIt.add(oi);
        
        insert listOrIt;
        String userId = UserInfo.getUserID();
        case c=new case();
        c.status = 'Refunded By Ageing Scheduler';
        c.type='B2B';
        c.Transaction_ID__c  = listOrIt[0].id;
        c.TIN_No__c='D4UZ22Ymk5';
        c.isAgening_Refund_Processed__c=true;
        c.isAgeing_Refund_Success__c=true;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        
        c.OwnerId=userId;
        insert c;
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(c);
        
        B2BSPOCBusCancellationExtn bObj = new B2BSPOCBusCancellationExtn(stdCntrl);
        bObj.getsearchStatusOptions();
        bObj.selSearchStatus='Pending Auto Refunded';
        bObj.caseComments='test'; 
        bObj.selectedupdstatus='Approved for Bus Cancellation';
        bObj.doSearch();
        bObj.dojt=system.today();
        bObj.selBO='1234';
        bObj.selRId='3456';
        bObj.selectedNotes='testt';
        bObj.doj=system.today();
        bObj.listWrapCase[0].isSelect = true;
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        bObj.updateFinalStatus();
        Test.stopTest();
        
    }
    
    public static testMethod void casecommentsTest()
    {
      case c=new case();
        c.status = 'Refunded By Ageing Scheduler';
        c.type='B2B';
        c.TIN_No__c='D4UZ22Ymk5';
        c.isAgening_Refund_Processed__c=true;
        c.isAgeing_Refund_Success__c=true;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        c.OwnerId=UserInfo.getUserID();
        insert c;
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(c);
        B2BSPOCBusCancellationExtn bObj = new B2BSPOCBusCancellationExtn(stdCntrl);
        bObj.caseComments=''; 
        bObj.updateFinalStatus();
    }
    
   public static testMethod void NotesUpdateTest1()
    {   
        
        List<Order_Items__c> listOrIt = new List<Order_Items__c>();
        Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Route_Id__c='12345';
        oi.Date_Of_Service__c=system.now();
        oi.Order_Item_Reference_No__c='D4UZ22Ymk5';
        listOrIt.add(oi);
        
        insert listOrIt;
        String userId = UserInfo.getUserID();
        case c=new case();
        c.status = 'Refunded By Ageing Scheduler';
        c.type='B2B';
        c.Transaction_ID__c  = listOrIt[0].id;
        c.TIN_No__c='D4UZ22Ymk5';
        c.isAgening_Refund_Processed__c=true;
        c.isAgeing_Refund_Success__c=true;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        
        c.OwnerId=userId;
        insert c;
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(c);
        
        B2BSPOCBusCancellationExtn bObj = new B2BSPOCBusCancellationExtn(stdCntrl);
        bObj.getsearchStatusOptions();
        bObj.selSearchStatus='Pending Auto Refunded';
        bObj.caseComments='test'; 
        bObj.selectedupdstatus='Refunded by BO';
        bObj.doSearch();
        bObj.listWrapCase[0].isSelect = true;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        string json='[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        bObj.updateFinalStatus();
        Test.stopTest();
        
    } 
    
    static testMethod void B2BBusCancellationInitiationTest(){
        string b2bRecType = Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();     
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.recordTypeId= b2bRecType;
        orIt.Transaction_Status__c = 'Booked';
        orIt.Seat_No__c='3';
        orIt.Cancellation_Policy__c = 'TESTTEST';
        orIt.Order_Id__c = 'TesTTest';
        orIt.status__c = 'Confirmed';
        orIt.Service_Provider_Reference_No__c='Long';
        insert orIt;

        case tempCase = New CASE();
        tempCase.SS_Route_Id__c='TesTTest';
        tempCase.Partner__c='TESTTEST';
        tempCase.Origin = 'OTRS EMail';
        insert tempCase;

        set<string> b2bCsIds = New set<string>();
        case c = New case();
        c.Transaction_ID__c=orIt.id;
        c.Origin = 'Email - support@redbus.in';
        c.SS_Route_Id__c='4353';
        c.Partner__c='TESTTEST';
        c.parentid = tempCase.Id;
       // c.Issue_Type__c='Bus Cancellation';
        insert c;

        b2bCsIds.add(string.valueOf(c.Id));
        Test.startTest();
        string json='{"processedBySfa":"false","status":"Initiated","tin":"28V6422H"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        B2BSPOCBusCancellationExtn.B2BBusCancellationInitiation(b2bCsIds,'B2B');
        Test.stopTest();
    }
}