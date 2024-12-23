/**
*
* Name           : AccountTriggerHandler
* Created Date   : 15 June 2017
* Created By     : Veeramanikanta
* Purpose        : Trigger handler class for Account Object
* Test class     : AccountTriggerHandlerTest
*
**/
public class AccountTriggerHandler{    
    
    @future(callout=true)
    public static void HFData(Set<id> accIds){
        List<Account> accList=new List<Account>();
        accList=[select id,PersonEmail,email_copy__c,PersonMobilePhone,Phone_10_Digits__c from Account where id in : accIds];
        
        set<string> email=new set<string>();
        set<string> mobile=new set<string>();
        System.debug('accList-->'+accList);
        
        for(Account acc:accList){
            if(string.isnotblank(acc.PersonEmail))
                email.add(acc.PersonEmail);
            if(string.isnotblank(acc.email_copy__c))
                email.add(acc.email_copy__c);
            
            if(string.isnotblank(acc.PersonMobilePhone))
                mobile.add(acc.PersonMobilePhone);
            if(string.isnotblank(acc.Phone_10_Digits__c))
                mobile.add(acc.Phone_10_Digits__c);
        }
        
        System.debug('Email-->'+email+'<--Mobile-->'+mobile);    
        Set<string> hfEmailAndPhone=new Set<string>();
        
        for(High_Frequency_Data__c s:[select id,phone__c,Email__c from High_Frequency_Data__c where email__c in :email OR phone__c in:mobile]){
            hfEmailAndPhone.add(s.phone__c);
            hfEmailAndPhone.add(s.Email__c);        
        }
        System.debug('hfEmailAndPhone-->'+hfEmailAndPhone);
        List<Account> aUpdateList=new List<Account>();
        
        for(Account ac:accList){
            if( hfEmailAndPhone.contains(ac.PersonEmail) || hfEmailAndPhone.contains(ac.Phone_10_Digits__c))
                ac.hf__c=true;
            else
                ac.hf__c=false;
            
            aUpdateList.add(ac);
        } 
        
        if(!aUpdateList.isEmpty())
            update aUpdateList;
        
    }
}