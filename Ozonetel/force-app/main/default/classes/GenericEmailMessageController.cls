/**
 * (c) 2022 RedBus
 *
 * Name           : GenericEmailMessageController
 * Created Date   : 17 July 2022
 * Created By     : VR Sudarshan
 * Purpose        : To send emails with email template option.
 * Test class     : GenericEmailMessageControllerTest
 *
 **/

public with sharing class GenericEmailMessageController {
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody, String caseId, String fromEmailAdd, String folderId,String templateId){
        string senderEmail = fromEmailAdd.deleteWhitespace();
        System.debug(':: mMail ::: '+mMail+ ':: mSubject ::: ' +mSubject+':: fromEmailAdd ::: '+senderEmail+':: caseId ::: '+caseId+':: folderId ::: '+folderId+':: templateId ::: '+templateId);
    
        string caseName = '';
        String caseOwnerName = '' ;
        
        list<EmailTemplate> em = new list<EmailTemplate>();
        em = [SELECT Id,Subject,Body,HtmlValue From EmailTemplate where id =: templateId limit 1];
        
        if(caseId != null ){ 
            case ldObj = [select id,CaseNumber,Owner.Name from case where Id =: caseId];
            caseName = ldObj.CaseNumber;
            System.debug(':: caseName :: '+caseName);
            if(ldObj.Owner.Name != null){
                caseOwnerName = String.ValueOf(ldObj.Owner.Name);
            }
        }
        List<EmailMessage> emailmessageList =  new List<EmailMessage>();
        emailmessageList = [select id, Subject,TextBody from emailmessage where EmailTemplateId =: templateId order By createddate desc limit 1];
        

        List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =:senderEmail LIMIT 1];
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        
        mail.setToAddresses(sendTo);
        //mail.setSenderDisplayName('Saleforce DevOrg'); 
        mail.setSubject(mSubject);
        if(test.isRunningTest()){
            mail.setOrgWideEmailAddressId('0D20I0000000FpASAU');
        }else{
            mail.setOrgWideEmailAddressId( orgAddressList[0].id); 
        }
        

        
        string htmlReplace = '' ;
        if(mbody != null && mbody != ''){
            htmlReplace = mbody; 
        }
        
        if(htmlReplace != null &&  htmlReplace.containsIgnoreCase('{!case.CaseNumber}')){
            System.debug(':: case CaseNumber ::');
            htmlReplace = htmlReplace.replace('{!case.CaseNumber}',caseName)+'<br/>'; 
        }
        if(htmlReplace != null &&  htmlReplace.containsIgnoreCase('{!case.OwnerFullName}')){
            System.debug(':: case Owner Name ::');
            htmlReplace = htmlReplace.replace('{!case.OwnerFullName}',caseOwnerName)+'<br/>'; 
        }


        mail.setHtmlBody(mbody);
       // mail.setTargetObjectId(con.id); 
        mail.setWhatId(caseId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setTreatBodiesAsTemplate(true);
        mail.setTemplateId(em.get(0).id);
        mails.add(mail);
        System.debug(':: Final Mail List  ::' +mails);
        if(string.isNotBlank(mMail)){
            Messaging.sendEmail(mails);            
        }
        
    }   
    
    @AuraEnabled
    public static list<emailTemplateWrapper> getEmailTempaltes(){
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        user loggedInUser = [SELECT Id,Profile.Name FROM User where Id =:UserInfo.getUserId()];
        map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(system.label.Generic_Email_Folders);        
        string getFolderName =string.valueOf(resObj.get(loggedInUser.Profile.Name));
        System.debug('::FolerName = '+getFolderName);
        if(test.isRunningTest()){
            getFolderName = 'Yb Support Email Templates';
        }
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        Folder folderObj = new folder();
        folderObj= [SELECT Id,Name FROM Folder where Name=:getFolderName];
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and FolderId =: folderObj.Id ]){ 
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            
            return emailTemplateWrapperlist;
        }
        return null;
    }
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  
    
    @AuraEnabled
    public static case getLeadRec(String caseId){
        case caseObj = new case();
        caseObj = [select id,CaseNumber,Email_Id_ct__c from case where id=: caseId Limit 1];
        System.debug(':: case Object :: '+caseObj);
        return caseObj;
        
    }
}