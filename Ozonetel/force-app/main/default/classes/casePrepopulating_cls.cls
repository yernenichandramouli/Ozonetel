public with sharing class casePrepopulating_cls
{
    
    public list<Order_Items__c> orilst{get;set;}
    public Case cs{get;set;}
    public Account acc{get;set;}
    public String tripId{get;set;}
    public Id csId;
    public string popupDescription{get;set;}
    public static Set<String> rtcBOIds = new Set<String>(System.Label.RTC_BO_IDS.split(','));
    
    public casePrepopulating_cls(ApexPages.StandardController controller)
    {       
        rtcBOIds.addAll(System.Label.RTC_BO_IDS.split(','));
        csId = ApexPages.CurrentPage().getParameters().get('tId');
        if(csId==null || string.isBlank(csId))
            csId=controller.getid();  
        system.debug('csId---->>'+csId);
        acc= new Account();
        cs = new Case();
        orilst = new list<Order_Items__c>();
        if(String.isNotBlank(csId)){
            orilst = [Select Id,Recordtypeid,Service_Provider_Id__c,Business_Unit__c,Order_Id__c,Customer_Name__c,Customer_Name__r.Phone_10_Digits__c,Customer_Name__r.PersonEmail,Date_of_Issue_New__c From Order_Items__c Where Id =:csId];
            if(!orilst.isEmpty()){
                tripId=orilst[0].Order_Id__c;
                cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('InBound Call').getRecordTypeId();
                cs.Phone_No_ct__c=orilst[0].Customer_Name__r.Phone_10_Digits__c;
                cs.Email_Id_ct__c=orilst[0].Customer_Name__r.PersonEmail;
                System.debug('tat notfi 3'+orilst[0].Customer_Name__r.PersonEmail);
                cs.TAT_Notifier_Email__c=orilst[0].Customer_Name__r.PersonEmail;
                System.debug('tat notfi'+cs.TAT_Notifier_Email__c);
                cs.Transaction_ID__c=orilst[0].Id;
                cs.Business_Unit_ct__c=orilst[0].Business_Unit__c;
                cs.OwnerId=UserInfo.getUserId();
                cs.Country__c = [SELECT id,name,Country from User WHERE Id=:UserInfo.getUserId()].Country;
                cs.Business_Type__c = [SELECT id,name,Business_Type__c from User WHERE Id=:UserInfo.getUserId()].Business_Type__c;
                if(String.isNotBlank(String.valueOf(orilst[0].Date_of_Issue_New__c))){
                    Datetime currentDateTime = System.now();
                    decimal decMinutes = ((currentDateTime.getTime())/1000/60) - ((orilst[0].Date_of_Issue_New__c.getTime())/1000/60);
                    if(decMinutes<30){
                        cs.is_ZQP__c = true;
                    }
                }
                if(orilst[0].recordtypeid==Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId()){
                    cs.Type='B2B';
                    cs.Partner__c='Amazon';
                }           
            }
        }
    }
    public pageReference saveMethod()
    {
        try
        {
            //RTC Restricted
            Set<String> setRestrictedRTCissue = new Set<String>(System.label.Restricted_issue_types_RTC.split('_'));
            Set<String> setRestrictedRTCsubissue = new Set<String>(System.label.Restricted_Subissue_types_RTC.split('_'));
            
            if(cs.Does_Customer_Require_CallBack__c)
                
                cs.CallBack_Requested_Time__c = cs.CallBack_Requested_Time__c!=null?System.now().addHours(Integer.valueOf(cs.Call_Back_Time__c)):null;
            
            
            
            System.debug('pop up des-->'+popupDescription);  
            if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && rtcBOIds.contains(orilst[0].Service_Provider_Id__c) && setRestrictedRTCissue.contains(cs.Issue_Type__c) && setRestrictedRTCsubissue.contains(cs.Issue_Sub_Category__c))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Case Insert Has Failed. We regret to inform you, as per the RTC policy, this subissue type is not accepted by RTC'));
                return null;
            }   
            
            System.debug('Customer Name-->'+cs.Customer_Name__c+'Issue_Type__c--'+cs.Issue_Type__c);
            if('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && 'B2B'.equalsIgnoreCase(cs.Type)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Create bus canellation case from Initiate Bus Cancellation button at Transcation Level'));
                return null;
            }else {
                Insert cs;
                System.debug('Customer Name after insert-->'+cs.Customer_Name__c);
                PageReference pRef = new PageReference('/'+cs.Id);
                return pRef;
            }
        }
        catch(exception e){ApexPages.addMessages(e); return null;}
        
    }
    
    public boolean displayPopup {get;set;}
    
    public pageReference showPopup()
    { 
        System.debug('calling showPopup');
        // displayPopup = true;
        
        system.debug('csId --->>'+csId);
        if(String.isNotBlank(csId)){
            list<case> clist=[select id,parentId,status,Transaction_ID__c from Case where Transaction_ID__c=:csId and status!='Closed'];
            System.debug('size here-->'+clist.size()); 
            if(clist.size()>=1){  
                System.debug('size here 2-->'+clist.size());   
                displayPopup = true;
            }
            else{
                saveMethod();
                System.debug('after savemethod');
                if(string.isNotBlank(cs.Id)){
                    PageReference pRef = new PageReference('/'+cs.Id);
                    return pRef;  
                }
            } 
        }
        return null;
    }
    public void closePopup() {
        displayPopup = false;       
    }
    
    public void boltNotification(){
        system.debug('>>>>>>calling>>>>104>>');
        string issue =cs.Issue_Type__c;
        string subIssue = cs.Issue_Sub_Category__c;
        system.debug('>>iis>>>'+issue+'>>>subIssue>>'+subIssue);
        set<Id> setMetaIssueIds = new set<Id>();
        Set<String> setBoltSubIssueTypes = new Set<String>();
        
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
        
        for(Meta_Issue_Type__mdt mdt : [select id,Issue_Type__c from Meta_Issue_Type__mdt where Issue_Type__c=:issue])
        {
            
            setMetaIssueIds.add(mdt.id);
        }
        
        for(Meta_Issue_Sub_Category__mdt subMdt :[select Issue_Sub_Category__c,Bolt_Applicable__c,Meta_Issue_Type__c from Meta_Issue_Sub_Category__mdt where Meta_Issue_Type__c in :setMetaIssueIds])
        {
            if(subMdt.Bolt_Applicable__c){
                setBoltSubIssueTypes.add(subMdt.Issue_Sub_Category__c);
            }
        }
        
        if(string.isNotBlank(orilst[0].Service_Provider_Id__c) && instantRefundBoIds.contains(orilst[0].Service_Provider_Id__c)&& setBoltSubIssueTypes.contains(subIssue))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, '<b>'+'IR(BOLT) : Please Follow BOLT Validation'+'</b>'));
            
        }
        
    }
    
}