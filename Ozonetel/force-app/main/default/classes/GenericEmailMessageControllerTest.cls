@isTest
public class GenericEmailMessageControllerTest {
    @isTest static void testMethod1(){

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
        insert u1;
        EmailTemplate tempEmailTemplate = new EmailTemplate();
        tempEmailTemplate.isActive = true;
        tempEmailTemplate.Name = 'name';
        tempEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        tempEmailTemplate.TemplateType = 'text';
        tempEmailTemplate.FolderId = UserInfo.getUserId();
        tempEmailTemplate.Subject = 'Your Subject Here';
        insert tempEmailTemplate;

        Case cs = new Case();
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Price_Paid_Currency_ctp__c='INR';
        System.RunAs(u1){
            test.startTest();
            insert cs;
            test.stopTest();
        }
        
        String mMail =''; String mSubject='Test' ; String mbody='Test'; String templateId='Test';
        string fromEmailAdd = 'test@mail.com';
        
        GenericEmailMessageController.sendMailMethod(mMail , mSubject , mbody,  cs.Id, fromEmailAdd, tempEmailTemplate.folderId, tempEmailTemplate.Id );
    }

    @isTest static void testMethod2(){

        GenericEmailMessageController.emailTemplates emailWrapper = new GenericEmailMessageController.emailTemplates();
        emailWrapper.emailTemplateId='YBSupport Profile';
        emailWrapper.emailbody='YBSupport Profile';
        emailWrapper.emailSubject='YBSupport Profile';
        emailWrapper.emailTemplatename='YBSupport Profile';

        GenericEmailMessageController.emailTemplateWrapper emailTempWrapper = new GenericEmailMessageController.emailTemplateWrapper();
        emailTempWrapper.folderName='Yb Support Email Templates';
        emailTempWrapper.folderId='Yb Support Email Templates';
        list<GenericEmailMessageController.emailTemplates> tempList = new list<GenericEmailMessageController.emailTemplates>();
        tempList.add(emailWrapper);
        emailTempWrapper.emailtemplatelist=tempList;

        Case cs = new Case();
        cs.Status ='Escalated to BD';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c ='My bus met with an accident';
        cs.Type='B2C';
        cs.Total_Fare_Value__c=250.00;
        cs.Email_Id_ct__c='INR@mail.com';
        insert cs;

        GenericEmailMessageController.getLeadRec(cs.Id);
        GenericEmailMessageController.getEmailTempaltes();

    }
}