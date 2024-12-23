@isTest
public class BDevQueueControllerTest
{
    public static testMethod void TestBDCase()
    {
        Test.startTest(); 
        BDevQueueController b=new BDevQueueController();
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
        Test.stopTest(); 
        
    }
    public static testMethod void TestAttachment()
    {
         Test.startTest(); 
        BDevQueueController b=new BDevQueueController();
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
    }
    public static testMethod void TestUserLogout()
    {
        BDevQueueController b=new BDevQueueController();  
        ApexPages.currentPage().getParameters().put('Id', '1234');       
        ApexPages.currentPage().getParameters().put('session', 'test');
        b.BDCases();
        b.hide();
    }
}