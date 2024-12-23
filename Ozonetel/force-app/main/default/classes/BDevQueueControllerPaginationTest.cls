@isTest
public class BDevQueueControllerPaginationTest
{
    public static testMethod void TestBDCase()
    {
        Test.startTest(); 
        BDevQueueControllerPagination b=new BDevQueueControllerPagination();
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I need help to board my bus';
        //'General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();
        insert cs;
        b.caseid=cs.id;
        b.assignedById=cs.ownerid;
        
        Site_Users__c s=new Site_Users__c();
        s.name='Test BD Agent';
        s.Type__c='Agent';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        
        System.debug('Test Caseid'+b.caseId+'Test S.id'+s.id);
        System.debug('assignedBy Id'+b.assignedById+'assignedBy Owner '+s.ownerid);
        ApexPages.currentPage().getParameters().put('Id', s.Id);       
        ApexPages.currentPage().getParameters().put('session', s.Session_Id__c);
       
        b.BDCases();
        b.showComments();
        b.cancel();
        b.queueName='SIT/ HF Team';
        b.getCases();
        b.queueName='Others';
        b.getCases();
        b.save();
        b.Userlogout();
          b.sortCondPrepare();
        Test.stopTest(); 
        
    }
    public static testMethod void TestAttachment()
    {
         Test.startTest(); 
        BDevQueueControllerPagination b=new BDevQueueControllerPagination();
         Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();
        insert cs;
        b.caseid=cs.id;
        b.assignedById=cs.ownerid;
        Site_Users__c s=new Site_Users__c();
        s.name='Test BD Agent';
        s.Type__c='Manager';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        b.Copycheck='Test';
        b.Copyid = s.Id;
        b.description='Test Description';
        casecomment cc=new casecomment();
        cc.CommentBody=s.name +'-'+s.location__c+'->'+b.description;
        cc.ParentId=cs.id;
        insert cc;
         
        b.BDCases();
         b.queueName='SPOC';
        b.getCases();
        b.Userlogout();
        
        b.getobjAttachment();
        b.attachFile();
        b.queueName='Social Media / Escalated Care';
        b.getCases();
        b.queueName='Invalid BP number';
        b.getCases();
        b.queueName='BP Verification Primo';
        b.getCases();
        b.queueName='YourBus';
        b.getCases();
        b.sButton='SaveAndClose';
        b.save();
        b.buscanclPage();
        b.attFile='testFile';
        b.correctBPnumber='1234555';
        b.refreshPageSize();
        b.hide();
    }

    public static testMethod void TestServiceDetailsCall()
    {
        Test.startTest();
        BDevQueueControllerPagination.busCnclSource='testSource';
        BDevQueueControllerPagination.busCnclDestination='testDestination';
        BDevQueueControllerPagination.busCnclDojstart = Date.newInstance(2022, 06, 09);
        BDevQueueControllerPagination.busCnclDojend = Date.newInstance(2022, 06, 09);
        BDevQueueControllerPagination.cancellationType='testSource';
        BDevQueueControllerPagination.busCanclEmailId='test.te@redbus.com';
        string json ='{"status":{"type":"SUCCESS","description":"Operation successfully completed","code":"200"},"errors":[],"data":[{"ServiceID":"101","RouteID":161017,"JourneyDate":"2022-01-01","DateOfJourney":"2022-01-01 04:31:00","ConfirmTickets":15,"CancelTickets":1}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        BDevQueueControllerPagination.ServiceDetailsCall();
        BDevQueueControllerPagination.PassengerDetailsCall();
        Test.stopTest();
    }

    
    public static testMethod void TestUserLogout()
    {
        BDevQueueControllerPagination b=new BDevQueueControllerPagination();  
        ApexPages.currentPage().getParameters().put('Id', '1234');       
        ApexPages.currentPage().getParameters().put('session', 'test');
        Site_Users__c s=new Site_Users__c();
        s.name='Test BD Agent';
        s.Type__c='Agent';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        b.hideCommentsAction();
        b.getCaseDetails();
       //string st = b.sortExpression();
       
        b.BDCases();
        b.hide();
    }

}