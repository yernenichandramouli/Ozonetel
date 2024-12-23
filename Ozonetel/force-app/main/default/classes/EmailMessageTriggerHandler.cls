public class EmailMessageTriggerHandler{
    
    public static void captureEmailMessages(list<EmailMessage> emList){
        
        List<Email_Messages__c> emcList=new List<Email_Messages__c>();
        for(EmailMessage em:emList){
            Email_Messages__c e=new Email_Messages__c();
            e.name=em.id;
            e.BccAddress__c=em.BccAddress;
            e.CcAddress__c=em.CcAddress;
            e.FirstOpenedDate__c=em.FirstOpenedDate;
            e.FromAddress__c=em.FromAddress;
            e.FromName__c=em.FromName;
            e.HasAttachment__c=em.HasAttachment;
            if(String.isNotBlank(em.Headers)){
                if(em.Headers.length() <255){
                    e.Headers__c=em.Headers;
                }
                else{
                    e.Headers__c=em.Headers.substring(0,254);  
                }                
            }
            if(String.isNotBlank(em.HtmlBody)){
                if(em.HtmlBody.length() <100000){
                    e.HtmlBody__c=em.HtmlBody;
                }
                else{
                    e.HtmlBody__c=em.HtmlBody.substring(0,99999);  
                }                
            }
            e.MessageDate__c=em.MessageDate;
            e.MessageIdentifier__c=em.MessageIdentifier;
            e.ParentId__c=em.Parentid;
            e.case__c=em.parentid;
            e.Status__c=em.Status;
            e.Subject__c=em.Subject;
            e.TextBody__c=em.TextBody;
            e.ThreadIdentifier__c=em.ThreadIdentifier;
            e.ToAddress__c=em.ToAddress;
            e.CreatedBy__c=string.valueOf(em.CreatedBy);
            e.CreatedDate__c=em.CreatedDate;
            e.FirstOpenedDate__c=em.FirstOpenedDate;
            e.ValidatedFromAddress__c=em.ValidatedFromAddress;
            e.IsExternallyVisible__c=em.IsExternallyVisible;
            e.Incoming__c=em.Incoming;
            e.LastModifiedBy__c=string.valueOf(em.LastModifiedBy);
            e.LastModifiedDate__c=em.LastModifiedDate;
            // e.MessageSize__c=em.MessageSize;
            emcList.add(e);
        }
        
        if(!emcList.isEmpty())
            insert emcList;
        
    }    
}