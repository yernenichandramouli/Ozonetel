@isTest
public class BDIntldevQueueControllerTest
{
    public static testMethod void TestBDIntlCase()
    {
      
        BDIntldevQueueController b=new BDIntldevQueueController();
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
        
        BDIntldevQueueController.busCnclSource='Klang';
        BDIntldevQueueController.busCnclDestination='Penang';
        BDIntldevQueueController.busCnclDojstart=system.today();
        BDIntldevQueueController.busCnclDojend=system.today();
        BDIntldevQueueController.busCanclEmailId='test@gmail.com';
        BDIntldevQueueController.cancellationType='ALL';
        BDIntldevQueueController.buttonValue='test';
        BDIntldevQueueController.errorMessage='test';
          
        PageReference pageRef = Page.BDIntldevQueuePage;
        
        
        BDIntldevQueueController.ResponseDataWarpper rsepw=new  BDIntldevQueueController.ResponseDataWarpper();
        rsepw.RouteID=23456;
        rsepw.ConfirmTickets=1;
        rsepw.CancelTickets=1;
        
        BDIntldevQueueController.caseCommentstruct comm = new BDIntldevQueueController.caseCommentstruct();
        comm.createDate='testDate';
        
        list<case> css=b.getCaseDetails();
        b.buscanclPage();
       
       Test.startTest(); 
       b.refreshPageSize();
       string json ='{"status":{"type":"SUCCESS","description":"Operation successfully completed","code":"200"},"errors":[],"data":[{"ServiceID":"101","RouteID":161017,"JourneyDate":"2022-01-01","DateOfJourney":"2022-01-01 04:31:00","ConfirmTickets":15,"CancelTickets":1}]}';
       Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
       BDIntldevQueueController.PassengerDetailsCall();
       Test.stopTest(); 
        
    }
    public static testMethod void TestAttachment()
    {
         Test.startTest(); 
        BDIntldevQueueController b=new BDIntldevQueueController();
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
        s.Type__c='Agent';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        b.description='Test Description';
        casecomment cc=new casecomment();
        cc.CommentBody=s.name +'-'+s.location__c+'->'+b.description;
        cc.ParentId=cs.id;
        insert cc;
         
        b.BDCases();
         b.queueName='SPOC';
        b.getCases();
        b.Userlogout();
        b.save();
        b.getobjAttachment();
        b.attachFile();
        b.queueName='Social Media / Escalated Care';
        b.getCases();
        b.queueName='Invalid BP number';
        b.getCases();
        b.attFile='testFile';
        b.correctBPnumber='1234555';
        b.getCases();
        b.queueName='Invalid Address';        

    }
    public static testMethod void TestUserLogout()
    {
        BDIntldevQueueController b=new BDIntldevQueueController();  
        ApexPages.currentPage().getParameters().put('Id', '1234');       
        ApexPages.currentPage().getParameters().put('session', 'test');
        b.hide();
        b.hideBPAddress();
        b.isExistingBPnumber=true;
        b.isExistingBPAddress=true;
        b.BDCases();
        b.hide();
        b.hideBPAddress();
        b.hideCommentsAction();
        b.sortCondPrepare();
    }
        public static testMethod void testinvalidaddress()
    {
         Test.startTest(); 
        BDIntldevQueueController b=new BDIntldevQueueController();
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
        b.description='Test Description';
        casecomment cc=new casecomment();
        cc.CommentBody=s.name +'-'+s.location__c+'->'+b.description;
        cc.ParentId=cs.id;
        insert cc;
         
        b.BDCases();
        b.queueName='SPOC';
        b.getCases();
        b.Userlogout();
        b.sButton='SaveAndClose';   
        b.save();
        b.getobjAttachment();
        b.attachFile();
        b.queueName='Social Media / Escalated Care';
        b.getCases();
        b.queueName='Invalid BP number';
        b.getCases();
        b.queueName='Invalid Address';        
        b.getCases();
        b.attFile='testFile';
        b.correctBPnumber='1234555';
    }
}