/**
* (c) 2017 RedBus
*
* Name           : CaseTriggerHandler
* Created Date   : 04 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Handler class for CaseTrigger
* Test class     : CaseTriggerTest
*
**/

public class CaseTriggerHandler
{
    public static boolean stopDuplicateCheck = false;
    public static boolean stopBeforeInsertDuplicateTATCheck = false;
    public static boolean stopBeforeUpdateDuplicateTATCheck = false;
    public static boolean stopCaseStatus = true;
    public static boolean stopWalletCredit=true;
    public static boolean stopBusCaseCreation = true;
    public static boolean stopOpenCaseCount = true;
    public static boolean stopStatusUpdate=true;
    public static boolean stopRedCare=true;
    public static boolean stopPushNotify=true;
    public static boolean stopSendNotification=true;
    public static boolean stopEsclateToUGC = false;
    public static boolean enableUGCcase= false;
    public static boolean stopvalidateCaseComment=false;
    public static boolean stopEsclateToBD = false;
    public static boolean stopEsclateToFulfillment = false;
    public static boolean stopAssignToSameAgent = false;
    public static boolean stopValidateSendNotif = false;
    public static boolean stopEsclateToTech = false;
    public static boolean stopEscalateToRTCTech = false;
    public static boolean stopPolicyInitiation= false;
    public static boolean stopNEFTUpdate= false;
    public static boolean stopAckoApprClaimUpdate= false;
    public static boolean stopAckoRejctClaimUpdate= false;
    public static boolean stopWhatsAppNotification= false;
    public static boolean stopCompltPaymnt=true;
    public static boolean stopMMTBusCApprove=true;
    public static boolean stopDisbursalUpdate= false;
    public static boolean defaultQueue= false;
    public static boolean enableRPWcase= false;
    public static boolean enableSupportcase= false;
    public static boolean enableRTCSupportcase= false;
    public static boolean enableLtoSuprtcase= false;
    public static boolean stopafterUpdaeEmailMble=true;
    public static boolean enableMEteamcase= false;
    public static boolean  commentsL2Support = false;
    public static Set<String> setTATEnabledGeos = new Set<String>{'INDIA','SINGAPORE','MALAYSIA','India','Singapore','Malaysia'};
        public static Set<String> setTotalRTCcoPas = new Set<String>(System.label.TotalRTCids.split('__'));   
    public static Set<String> rtcBOIds = new Set<String>(System.Label.RTC_BO_IDS.split(','));
    public Order_Items__c orIt{get;set;} 
     
    static Id gftRectId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
    
    public CaseTriggerHandler()
    {
        rtcBOIds.addAll(System.Label.RTC_BO_IDS.split(','));
        setTATEnabledGeos = new Set<String>{'INDIA','SINGAPORE','MALAYSIA','India','Singapore','Malaysia'};

            
            }
    
    // Restrict the user to create only one BusCancellation case for one Transaction
    public static void duplicateCheck(List<Case> TriggerNew,Map<Id,Case> TriggerOldMap)
    {
        if(!CaseTriggerHandler.stopDuplicateCheck)
        {
            CaseTriggerHandler.stopDuplicateCheck = true;
            Map<String, Case> CaseMap = new Map<String, Case>();
            for (Case cs : TriggerNew) 
            {
                system.debug('<<<<cs.Issue_Type__c'+cs.Issue_Type__c+'<<<'+cs.Transaction_Id__c+'<<<'+System.Trigger.isInsert+'<<<'+cs.Transaction_Id__c+'<<<'+TriggerOldMap.get(cs.Id).Transaction_Id__c );
                if (('Bus Cancellation'.EqualsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(cs.Transaction_Id__c)) && (System.Trigger.isInsert || (cs.Transaction_Id__c !=TriggerOldMap.get(cs.Id).Transaction_Id__c ))) 
                {
                    if (CaseMap.containsKey(cs.Transaction_Id__c)) {
                        system.debug('****26****');
                        cs.addError('You can\'t create multiple Bus Cancellation cases for single transation');
                    } 
                    
                    else {
                        CaseMap.put(cs.Transaction_Id__c, cs);
                    }
                }
                
                
            }
            
            system.debug('****37****'+CaseMap);
            
            if(!CaseMap.isEmpty())
            {
                for (Case cs: [SELECT Transaction_Id__c FROM Case WHERE Transaction_Id__c IN :CaseMap.KeySet() AND Issue_Type__c='Bus Cancellation']) 
                {
                    Case newCase = CaseMap.get(cs.Transaction_Id__c);
                    system.debug('****44****'+newCase);
                    newCase.addError('You can\'t create multiple Bus Cancellation cases for single transation');
                }
            }
        }
    }
    
    // Populate TAT Value and CallBack Functionality  
    public static void updateTATValue(List<Case> TriggerNew,Map<Id,Case> TriggerOldMap,Map<Id,Case> TriggerNewMap)
    {
        setTATEnabledGeos = new Set<String>{'INDIA','SINGAPORE','MALAYSIA','India','Singapore','Malaysia'};
            Set<String> setIssueTypes = new Set<String>();
        Set<String> SkipInternalIssueTypes = new Set<String>(System.label.Internal_IssueTypes.split(','));
        Set<String> setSubIssueTypes = new Set<String>();
        Set<String> setBoltSubIssueTypes = new Set<String>();
        Map<String,Issue_Based_TAT__mdt> mapIssueToTATRecord = new Map<string,Issue_Based_TAT__mdt>();
        Map<String,Issue_Based_TAT__mdt> mapBustypeToTATRecord = new Map<string,Issue_Based_TAT__mdt>();
        Map<String,Date> mapIssueToDate = new Map<String,Date>();
        Map<String,Date> mapRedCareToDate = new Map<String,Date>();
        map<id,lead> leadmap = new map<id,Lead>();
        set<Id> caseClosedIds=new set<Id>();
        set<Id> bdRejIds=new set<Id>();
        set<Id> bdIds=new set<id>();
        set<Id> snfIds=new set<Id>();
        set<Id> busHireFulfillmentIds =new set<Id>();
        set<Id> leadIds=new set<Id>();
        set<Id> setMetaIssueIds = new set<Id>();
        Set<String> setClosedByAgentName = new Set<String>();
        set<Id> transIds=new set<Id>();
        list<order_items__c> orItLs=new list<order_items__c>();
        list<lead> leadlst = new list<lead>();
        list<case> cseLst = new list<case>();
        map<string,order_items__c> ortMap=new map<string,order_items__c>();
        
        Id railsSupportQueueId = [Select id from Group where type='Queue' AND developername='redrailsupport'].id;
        Id rydeffId=[select id from Group where type='Queue' AND developername='ryde_eff'].id;
        Id busHireSupQueueId = [Select id from Group where type='Queue' AND developername='BusHire_Support'].id;
        Group g=[Select Id from Group where name='BD Queue' limit 1];
        Id quotaCSQueueId = [Select id from Group where type='Queue' AND developername='Quota_CS_Queue'].id;
        Id paasEscqueueId = [Select id from Group where type='Queue' AND developername='Paas_Escalation_Queue'].id;
        Id IDNPayBusId = [Select id from Group where type='Queue' AND developername='IDN_Pay_Bus'].id;
        Map<String,String> mapTcode = new Map<String,String>();
        Map<String,String> mapTridId = new Map<String,String>();
        Map<String,String> mapOrderItemUuid = new Map<String,String>();
        Map<String,String> mapIssType = new Map<String,String>();
        Map<String,String> mapSubIssType = new Map<String,String>();
        Set<String> setSkipChannels = new Set<String>(System.label.Channel.split(','));
        Set<String> setSkipCommIssues = new Set<String>(System.label.SkipCommentIssueTypes.split(','));
        Set<String> setRPWissuTypes = new Set<String>(System.label.RPW_Issuetypes.split(','));
        Set<String> setTatOrigin = new Set<String>(System.label.TAT_Origin.split(','));
        Set<String> setIsueChangeTatOrigin = new Set<String>(System.label.IssueTypeChangedTATOrigin.split(','));
        Set<String> setRPWboids = new Set<String>();
        Set<id> setLtoSupportids = new Set<id>();
        Set<id> setRTCSupportids = new Set<id>();
        Set<id> setUGCSupportIds = new Set<id>();
        List<User> usr=new List<user>();
        
        //IR&DR 
        Set<String> setStatusExculd = new Set<String>(System.label.Status_Excluding_in_IRDR_Flow.split(','));
        Set<String> setChannelExculd = new Set<String>(System.label.Channel_Excluding_in_IRDR_Flow.split(','));
        Set<String> setOriginsExculd = new Set<String>(System.label.Origins_Excluding_in_IRDR_Flow.split(','));
        //Map<String,Issue_Based_TAT__mdt> mapIssueIrDrBolt = new Map<string,Issue_Based_TAT__mdt>();
        //Map<String,Issue_Based_TAT__mdt> mapIssueIrDrNonBolt = new Map<string,Issue_Based_TAT__mdt>();
        Map<String,Issue_Based_TAT__mdt> mapIssueIrDr = new Map<string,Issue_Based_TAT__mdt>();
        Set<String> setChannels = new Set<String>(System.label.ChannelCheck.split(';'));
        Set<String> setOrigins = new Set<String>(System.label.OriginCheck.split(';'));
        //RTC Restricted
        Set<String> setRestrictedRTCissue = new Set<String>(System.label.Restricted_issue_types_RTC.split('_'));
        Set<String> setRestrictedRTCsubissue = new Set<String>(System.label.Restricted_Subissue_types_RTC.split('_'));
        Set<String> setIRDRissueTypes = new Set<String>();
        Set<String> setIRDRsubIssueTypes = new Set<String>();
        Set<String> setCountry = new Set<String>();
        Set<String> setBusinessType = new Set<String>();
        Map<String,Case_Default_Values_Mapper__mdt> mapDefvalMaprMdt= new Map<string,Case_Default_Values_Mapper__mdt>();
        Map<String,user> mapUserNameId = new Map<String,user>();
        Set<String> setSystemAdminUsers = new Set<String>(System.label.AdminUsersIds.split(','));
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        Set<Id> parentIds = new Set<Id>();
        List<Id> disbursalIds=new list<Id>();
        set<string> transUUId = new set<string>();
        map<string,Order_Items__c> transCsMap = new map<string,Order_Items__c>();      
        for(User u:[Select id,name,Agent_Type__c from User Where IsActive=True]){
            mapUserNameId.put(u.name,u);
        }
        
        string loginProfileName='';
        if(string.isNotBlank(UserInfo.getProfileId())){
              list<Profile> currentProfile = new list<Profile>();
              currentProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
            if (!currentProfile.isEmpty()) {
            
                   loginProfileName = currentProfile[0].Name;
              }
       }
        Id socialMediaQid= [Select id from Group where type='Queue' AND developername='Social_Media_Queue'].id;

        for(Case cs : TriggerNew)
        {
            String tripId = String.isNotBlank(cs.Trip_Id_ct__c)?cs.Trip_Id_ct__c:String.isNotBlank(cs.Trip_ID__c)?cs.Trip_ID__c:'';
            string OrderItemUuid=String.isNotBlank(cs.OrderItem_Uuid__c)?cs.OrderItem_Uuid__c:'';
            if(String.isNotBlank(cs.origin) && (cs.origin.contains('Email') || 'MobileAppReview'.equalsIgnorecase(cs.Origin)) && String.isNotBlank(cs.SuppliedEmail)){
                cs.TAT_Notifier_Email__c=cs.SuppliedEmail;
            }else if((cs.origin=='Complaint Tracker' || 'IVR-Ameyo'.equalsIgnorecase(cs.Origin)) && String.isNotBlank(cs.Email_Id_ct__c)){
                cs.TAT_Notifier_Email__c=cs.Email_Id_ct__c;
            }else if(cs.origin=='InBound Call' && String.isBlank(cs.Booking_Email_ID__c)){
                cs.TAT_Notifier_Email__c=cs.Email_Id_ct__c;
            }else{
                cs.TAT_Notifier_Email__c=cs.Booking_Email_ID__c;
            }  
            
            if(String.isNotBlank(cs.Issue_Type__c)  && SkipInternalIssueTypes.contains(cs.Issue_Type__c)){
                cs.is_Internal_IssueType__c = true;
            }
            
            if('Pay at Bus'.equalsIgnoreCase(cs.Issue_Type__c) && 'I have generated Pay at Bus voucher'.equalsIgnoreCase(cs.Issue_Type__c) && 'Indonesia'.equalsIgnoreCase(cs.country__c))
                cs.OwnerId = IDNPayBusId;
            
            if(Trigger.isInsert)
            {
                cs.Prior_Issue_Type__c=cs.issue_type__c;
                
                if (String.isNotBlank(cs.ParentId) && 'Open'.equalsIgnoreCase(cs.Status)) {
                    parentIds.add(cs.ParentId);
                }
                if(string.isNotBlank(cs.Business_Unit_ct__c) && cs.status=='Open' && (cs.Business_Unit_ct__c =='REDBUS_RAILS_IN' || cs.Business_Unit_ct__c =='REDRAILS_IN'))
                {
                    cs.ownerId =railsSupportQueueId;
                }
                
                if('Twitter'.equalsIgnoreCase(cs.origin) || 'Facebook'.equalsIgnoreCase(cs.origin)){
                 cs.ownerId=socialMediaQid;
                }
                
                //TAT Issue type before insert
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c))
                {
                    setIssueTypes.add(cs.Issue_Type__c);
                    setSubIssueTypes.add(cs.Issue_Sub_Category__c);
                }
                
                //IR&DR
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && (setOrigins.contains(cs.Origin) || setChannels.contains(cs.Channel_ct__c)) && String.isNotBlank(cs.Business_Type__c) && String.isNotBlank(cs.Country__c)){
                    setIRDRissueTypes.add(cs.Issue_Type__c);
                    setIRDRsubIssueTypes.add(cs.Issue_Sub_Category__c);
                    setCountry.add(cs.Country__c);
                    setBusinessType.add(cs.Business_Type__c);
                }
                
                if(string.isNotBlank(cs.Lead__c)){
                    leadIds.add(cs.Lead__c);
                }
                
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && 'BP Verification'.equalsIgnoreCase(cs.Issue_Type__c))
                {
                    mapIssType.put(cs.Issue_Type__c,cs.Issue_Type__c);                 
                    mapSubIssType.put(cs.Issue_Sub_Category__c,cs.Issue_Sub_Category__c);
                }
                
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && !setSkipChannels.contains(cs.Channel_ct__c))
                {
                    if('Bus Cancellation'.equalsIgnorecase(cs.Issue_Type__c))
                    {
                        if(String.isNotBlank(tripId)){
                            mapTridId.put(tripId,tripId);
                        }
                        
                        if(String.isNotBlank(OrderItemUuid)){
                            mapOrderItemUuid.put(OrderItemUuid,OrderItemUuid);
                        }
                    }
                    else
                    {
                        if(String.isNotBlank(tripId)){
                            mapTridId.put(tripId,tripId);
                        }
                        mapIssType.put(cs.Issue_Type__c,cs.Issue_Type__c);                 
                        mapSubIssType.put(cs.Issue_Sub_Category__c,cs.Issue_Sub_Category__c);
                    }
                }
                
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && cs.Business_Type__c=='BusHire' && String.isNotBlank(cs.Lead_TCode__c)){
                    mapTcode.put(cs.Lead_TCode__c,cs.Lead_TCode__c);
                    mapIssType.put(cs.Issue_Type__c,cs.Issue_Type__c);                 
                    mapSubIssType.put(cs.Issue_Sub_Category__c,cs.Issue_Sub_Category__c);
                } 
                
                if(cs.Transaction_ID__c !=null){
                    cs.BD_Location__c=cs.BD_Location2__c;
                    cs.SH_Dropping_Time__c=cs.Dropping_Time__c;
                    if(string.isBlank(cs.Bus_Operator_Namee__c)){
                        cs.Bus_Operator_Namee__c=cs.Service_Provider_Name__c;
                    }
                    transIds.add(cs.transaction_id__c);
                }
                
                if('contacto@redbus.co'.equalsIgnorecase(cs.TAT_Notifier_Email__c)  && (string.isBlank(cs.Country__c) || string.isBlank(cs.Business_Unit_ct__c) || string.isBlank(cs.Business_Type__c))){
                    cs.Country__c='Colombia';
                    cs.Business_Unit_ct__c='REDBUS_CO';
                    cs.origin ='Email support queue COLOMBIA';
                    cs.Business_Type__c='Colombia-Bus';
                }else if('contacto@redbus.pe'.equalsIgnorecase(cs.TAT_Notifier_Email__c) && (string.isBlank(cs.Country__c) || string.isBlank(cs.Business_Unit_ct__c) || string.isBlank(cs.Business_Type__c))){
                    cs.Country__c='Peru';
                    cs.Business_Unit_ct__c='REDBUS_PE';
                    cs.origin ='Email support queue Peru';
                    cs.Business_Type__c='Peru-Bus';
                }else if(('Email support queue COLOMBIA'.equalsIgnorecase(cs.Origin) || 'Email Precio Garantizado CO'.equalsIgnorecase(cs.Origin)) && string.isBlank(cs.Country__c)){
                    cs.Country__c='Colombia';
                    cs.Business_Unit_ct__c='REDBUS_CO';
                    cs.Business_Type__c='Colombia-Bus';
                }else if(('Email support queue Peru'.equalsIgnorecase(cs.Origin) || 'Email Precio Garantizado PE'.equalsIgnorecase(cs.Origin)) && string.isBlank(cs.Country__c)){
                    cs.Country__c='Peru';
                    cs.Business_Unit_ct__c='REDBUS_PE';
                    cs.Business_Type__c='Peru-Bus';
                }
                
                if('Peru'.equalsIgnorecase(cs.Country__c) && string.isBlank(cs.Business_Unit_ct__c)){
                    cs.Business_Unit_ct__c='REDBUS_PE';
                    cs.Business_Type__c='Peru-Bus';
                }else if('Colombia'.equalsIgnorecase(cs.Country__c) && string.isBlank(cs.Business_Unit_ct__c)){
                    cs.Business_Unit_ct__c='REDBUS_CO';
                    cs.Business_Type__c='Colombia-Bus';
                }
                
                system.debug('==rpwp=='+!setTotalRTCcoPas.contains(cs.Service_Providerr_Id__c)+'=rpw='+cs.RPW_Case__c+'--'+cs.Service_Providerr_Id__c );
                if(!cs.RPW_Case__c && (cs.Service_Provider_Id__c!=null || cs.Service_Providerr_Id__c !=null) && string.isNotBlank(cs.Issue_Type__c) && setRPWissuTypes.contains(cs.Issue_Type__c) && !setTotalRTCcoPas.contains(cs.Service_Provider_Id__c) && !setTotalRTCcoPas.contains(cs.Service_Providerr_Id__c))
                {
                    cs.RPW_Case__c =True;
                } 
                
                for(Case_Default_Values_Mapper__mdt defaultValmapMdt : [select id,Business_Type__c,Business_Unit__c,Country__c,Email_Id__c,Issue_Sub_Category__c,Issue_Type__c from Case_Default_Values_Mapper__mdt])
                {
                    mapDefvalMaprMdt.put(defaultValmapMdt.Email_Id__c,defaultValmapMdt);
                }
                if(string.isBlank(cs.Country__c) && string.isNotBlank(cs.origin)){
                    string csEmail='';
                    if(cs.origin.contains('Email -') || cs.origin.contains('Email - ')){
                        csEmail =cs.origin.SubStringAfter('-').trim();
                        system.debug('--282-csEmail--'+csEmail);
                    }
                    
                    if(string.isBlank(csEmail) && !cs.origin.contains('Email -') && cs.origin.contains('@redbus')){
                        csEmail =cs.origin.trim();
                        system.debug('--287-csEmail--'+csEmail);
                    }
                    
                    if(string.isNotBlank(csEmail) && mapDefvalMaprMdt.containskey(csEmail)){
                        cs.Country__c=mapDefvalMaprMdt.get(csEmail).Country__c;
                        cs.Business_Type__c=mapDefvalMaprMdt.get(csEmail).Business_Type__c;
                        cs.Business_Unit_ct__c=mapDefvalMaprMdt.get(csEmail).Business_Unit__c;
                    }
                    
                    
                }
                
            }
            
            
            if(Trigger.isUpdate)
            {
                Case oldCase = TriggerOldMap.get(cs.ID);
                cs.Prior_Issue_Type__c=oldCase.issue_type__c;
                String oldTripId = String.isNotBlank(oldCase.Trip_ID__c)?oldCase.Trip_ID__c:String.isNotBlank(cs.Trip_Id_ct__c)?cs.Trip_Id_ct__c:'';
                string oldItemUuuid =String.isNotBlank(oldCase.OrderItem_Uuid__c)?oldCase.OrderItem_Uuid__c:'';
                
                if(string.isBlank(cs.transaction_id__c) && string.isNotBlank(cs.Transaction_UUID__c)){
                   transUUId.add(cs.Transaction_UUID__c);
                }
                
               if(string.isNotBlank(cs.Disbursal_Id__c) && cs.status=='Closed' && !'MANUAL_NEFT'.equalsIgnoreCase(cs.Disbursal_Mode__c) && (!'Disbursal_Success'.equalsIgnoreCase(cs.Disbursal_Status__c) || !'DISBURSAL_COMPLETED'.equalsIgnoreCase(cs.Disbursal_Status__c)) && !'Action Took By Finance'.equalsIgnoreCase(cs.status) && 'NEFT Refund'.equalsIgnoreCase(cs.Issue_Type__c) && (oldCase.status!=cs.status) )
                {
                        
                  if(string.isNotBlank(cs.Account_Number__c) && string.isNotBlank(cs.Bank_Name__c) && string.isNotBlank(loginProfileName) && loginProfileName!='Finance Profile' && loginProfileName!='Integration User' && loginProfileName!='System Administrator'){
                       cs.addError('Bank Details submitted by customer for NEFT refund, not eligible to receive voucher');
                  }
                  else if((string.isBlank(cs.Voucher_Ref_Id__c) || cs.Voucher_Validity__c==null) && loginProfileName!='Finance Profile' && loginProfileName!='Integration User' && loginProfileName!='System Administrator'){
                     cs.addError('Please add Voucher Ref Id & Voucher validity');
                    
                  }else{
                    disbursalIds.add(cs.id);
                  }
                }
                if (String.isNotBlank(cs.ParentId) && ((String.isNotBlank(cs.Issue_Type__c) && cs.Issue_Type__c!=oldCase.Issue_Type__c) || (String.isNotBlank(cs.Issue_Sub_Category__c) && cs.Issue_Sub_Category__c!=oldCase.Issue_Sub_Category__c) )) {
                    parentIds.add(cs.ParentId);
                }
                
                if(cs.Does_Customer_Require_CallBack__c && (cs.Does_Customer_Require_CallBack__c!=oldCase.Does_Customer_Require_CallBack__c) && String.isNotBlank(cs.Call_Back_Time__c))
                    cs.CallBack_Requested_Time__c = System.now().addHours(Integer.valueOf(cs.Call_Back_Time__c));
                
                if(cs.transaction_id__c!=oldCase.transaction_id__c)
                    transIds.add(cs.transaction_id__c);
                
                
                System.debug('curr is->'+cs.Issue_Type__c+'--old is->'+oldCase.Issue_Type__c);
                System.debug('curr is->'+cs.Issue_Sub_Category__c+'--old is->'+oldCase.Issue_Sub_Category__c);
                System.debug('origin->'+cs.Origin+'--country-->'+cs.country__c);
                
                if(((String.isNotBlank(cs.Issue_Type__c) && cs.Issue_Type__c!=oldCase.Issue_Type__c) || (String.isNotBlank(cs.Issue_Sub_Category__c) && cs.Issue_Sub_Category__c!=oldCase.Issue_Sub_Category__c) )|| (cs.Channel_ct__c =='MMT' || cs.Channel_ct__c=='GI') || cs.Case_Category__c==null)
                {
                    setIssueTypes.add(cs.Issue_Type__c);
                    setSubIssueTypes.add(cs.Issue_Sub_Category__c);
                }
                
                // IRDR
                if(oldCase.transaction_id__c==null && cs.transaction_id__c!=null && (setOrigins.contains(cs.Origin) || setChannels.contains(cs.Channel_ct__c)) && String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && String.isNotBlank(cs.Country__c) && String.isNotBlank(cs.Business_Type__c))
                {
                    setIRDRissueTypes.add(cs.Issue_Type__c);
                    setIRDRsubIssueTypes.add(cs.Issue_Sub_Category__c);
                    setCountry.add(cs.Country__c);
                    setBusinessType.add(cs.Business_Type__c);
                }
                
                
                if(cs.Origin != 'Failed Transaction' && !setSkipCommIssues.contains(cs.issue_Type__c) && 'Closed'.equalsIgnoreCase(cs.status) && !'Closed By BO'.equalsIgnoreCase(cs.Closed_By__c) && !'Customer from SH'.equalsIgnoreCase(cs.Closed_By__c) && oldCase.Status!='Closed')
                    caseClosedIds.add(cs.id);        
                
                if(cs.Origin != 'Failed Transaction' && 'Escalated to BD'.equalsIgnoreCase(cs.status) && oldCase.Status!='Escalated to BD')    bdRejIds.add(cs.id); 
                
                if(cs.send_notification__c!=''){
                    snfIds.add(cs.id);
                }
                
                if(string.isNotBlank(cs.Issue_Type__c) && string.isNotBlank(cs.Issue_Sub_Category__c) &&  cs.status!=oldCase.status && cs.Business_Type__c=='BusHire' && cs.status=='Escalated to fulfillment'){ 
                    busHireFulfillmentIds.add(cs.id);
                }
                
                
                if(string.isNotBlank(cs.Issue_Type__c) && string.isNotBlank(cs.Issue_Sub_Category__c) &&  cs.status!=oldCase.status && cs.Business_Type__c=='BusHire' && cs.status=='Fulfillment revert'){ 
                    busHireFulfillmentIds.add(cs.id);
                }
                
                // if('Re-Open'.equalsIgnoreCase(cs.status) && cs.status!=oldCase.status && 'Closed'.equalsIgnoreCase(oldCase.status) && String.isNotBlank(cs.Closed_By_Agent__c) && (( String.isNotBlank(cs.Closed_By_Agent_Role__c) && !cs.Closed_By_Agent_Role__c.startsWithIgnoreCase('Inbound')) ||  cs.Customer_Revert_Delay__c!=null ))
                //     setClosedByAgentName.add(cs.Closed_By_Agent__c);
                
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && 'BP Verification'.equalsIgnoreCase(cs.Issue_Type__c) &&  String.isNotBlank(oldCase.caseNumber) && ((cs.Issue_Type__c != oldCase.Issue_Type__c )||(cs.Issue_Sub_Category__c != oldCase.Issue_Sub_Category__c)))
                {
                    mapIssType.put(cs.Issue_Type__c,cs.Issue_Type__c);
                    mapSubIssType.put(cs.Issue_Sub_Category__c,cs.Issue_Sub_Category__c);
                }
                
                if(String.isNotBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && !'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(tripId) && String.isNotBlank(oldCase.caseNumber) && ((tripId != oldTripId ) || (cs.Issue_Type__c != oldCase.Issue_Type__c )||(cs.Issue_Sub_Category__c != oldCase.Issue_Sub_Category__c)) && !setSkipChannels.contains(cs.Channel_ct__c))
                {
                    mapTridId.put(tripId,tripId);
                    mapIssType.put(cs.Issue_Type__c,cs.Issue_Type__c);
                    mapSubIssType.put(cs.Issue_Sub_Category__c,cs.Issue_Sub_Category__c);
                    
                }
                if(String.isNotBlank(cs.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(tripId) && String.isNotBlank(oldCase.caseNumber) && (tripId != oldTripId || cs.Issue_Type__c != oldCase.Issue_Type__c) && !setSkipChannels.contains(cs.Channel_ct__c))
                {
                    mapTridId.put(tripId,tripId);
                }
                
                if(String.isNotBlank(cs.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(OrderItemUuid) && String.isNotBlank(oldCase.caseNumber) && (OrderItemUuid != oldItemUuuid || cs.Issue_Type__c != oldCase.Issue_Type__c) && !setSkipChannels.contains(cs.Channel_ct__c))
                {
                    mapOrderItemUuid.put(OrderItemUuid,OrderItemUuid);
                }
                
                if('Escalated to Tech'.equalsIgnoreCase(cs.status) && cs.status!=oldCase.status && !'Closed'.equalsIgnoreCase(oldCase.status)){
                    setLtoSupportids.add(cs.id);
                }
                
                if('Escalated to UGC'.equalsIgnoreCase(cs.status) && cs.status!=TriggerOldMap.get(cs.id).status && !'Closed'.equalsIgnoreCase(TriggerOldMap.get(cs.id).status)){
                    setUGCSupportIds.add(cs.id);
                }
                
                if('Escalated to RTC Tech'.equalsIgnoreCase(cs.status) && cs.status!=oldCase.status && !('Closed'.equalsIgnoreCase(oldCase.status))) {
                    setRTCSupportids.add(cs.id);
                }
            }
            
        }
        // Query parent cases based on ParentId
        if (!parentIds.isEmpty()) {
            parentCaseMap = new Map<Id, Case>([SELECT Id, Issue_Type__c, Issue_Sub_Category__c FROM Case WHERE Id IN :parentIds]);
        }
        
        leadlst =[select id,TCode__c,SrcCityName__c,DestCityName__c,Operator_Name__c,Email,Region__c,DOJStart__c,Phone from lead where id in:leadIds];  
        for(Lead ld:leadlst){
            leadmap.put(ld.id,ld);
        }
        
        
        orItLs=[select id,name,hft__c,OrderUuid__c,RecordType.Name,Source_Destination__c,Source_Destination_id__c,Service_Provider_Info__r.Operator_Id__c,Service_Provider_Info__r.Name,Inventory_Type__c,Service_Provider_Id__c,Total_Fare__c  from order_items__c where id in:transIds ];
        for(order_items__c ot:orItLs){
            ortMap.put(ot.id,ot);
        }
        
        
         orItLs=[select id,Guid__c  from order_items__c where  Guid__c!=null and Guid__c in:transUUId ];
        for(order_items__c ot:orItLs){
            transCsMap.put(ot.Guid__c,ot);
           }
        
        //Instant Bolt
        for(Meta_Issue_Type__mdt mdt : [select id,Issue_Type__c from Meta_Issue_Type__mdt where Issue_Type__c in :setIssueTypes])
        {
            setMetaIssueIds.add(mdt.id);
        }
        
        for(Meta_Issue_Sub_Category__mdt subMdt :[select Issue_Sub_Category__c,Bolt_Applicable__c,Meta_Issue_Type__c from Meta_Issue_Sub_Category__mdt where Meta_Issue_Type__c in :setMetaIssueIds])
        {
            if(subMdt.Bolt_Applicable__c){
                setBoltSubIssueTypes.add(subMdt.Issue_Sub_Category__c);
            }
        }
        
        
        
        //IRDR 
        for(Issue_Based_TAT__mdt issueTAT : [SELECT id,Issue_Type__c,QueueId__c,Queue__c,Business_Type__c,Country__c,Bolt_Enable__c,Priority__c,Issue_Sub_Category__c,Applicable_Date_From__c,Amount__c,redCare__c,Version__c,redCare_Applicable_from__c,TAT_Value__c,Enable_IRDR__c,Amber_Zone__c,Green_Zone__c,Red_Zone__c from Issue_Based_TAT__mdt where Issue_Type__c IN :setIRDRissueTypes AND Issue_Sub_Category__c IN :setIRDRsubIssueTypes and Business_Type__c IN :setBusinessType and Country__c IN :setCountry and Version__c='V3' and Enable_IRDR__c=True])
        {
            
            /*if(issueTAT.Bolt_Enable__c){
mapIssueIrDrBolt.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
}else{
mapIssueIrDrNonBolt.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
}*/
            
            mapIssueIrDr.put(issueTAT.Issue_Type__c+issueTAT.Issue_Sub_Category__c,issueTAT);
            
            if(issueTAT.Applicable_Date_From__c!=null)
                mapIssueToDate.put(issueTAT.Issue_Type__c,issueTAT.Applicable_Date_From__c);
            
            if(issueTAT.redCare_Applicable_from__c!=null)            
                mapRedCareToDate.put(issueTAT.Issue_Type__c,issueTAT.redCare_Applicable_from__c);  
            
            /*if(issueTAT.Business_Type__c!=null)    
mapBustypeToTATRecord.put(issueTAT.Business_Type__c,issueTAT); */
        }
        
        Map<String,String> mapTcodeIssSubToCase = new Map<String,String>();
        Map<String,String> mapTripIssSubToCase = new Map<String,String>();
        Map<String,String> mapOrdrItemIsueCase = new Map<String,String>();
        Map<String,String> mapTripIssuCase = new Map<String,String>();
        Map<String,String> mapBPVissuCase = new Map<String,String>();
        
        if(!mapIssType.keySet().isEmpty()){
            for(Case c:[select id,casenumber,BP_Contact_Number__c,Issue_Type__c,Issue_Sub_Category__c from case where Issue_Type__c='BP Verification' and BP_Contact_Number__c!=null AND Issue_Type__c IN :mapIssType.keySet() AND Issue_Sub_Category__c IN :mapSubIssType.keySet()])
            {
                mapBPVissuCase.put(c.BP_Contact_Number__c+c.Issue_Type__c+c.Issue_Sub_Category__c,c.CaseNumber);      
            }
        }
        
        if(!mapTridId.keySet().isEmpty()){
            for(Case c:[select Trip_Id_ct__c,casenumber,Issue_Type__c,Issue_Sub_Category__c from case WHERE Trip_Id_ct__c IN :mapTridId.keySet()])
            {
                if(String.isNotBlank(c.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c))
                    mapTripIssuCase.put(c.Trip_Id_ct__c+c.Issue_Type__c,c.CaseNumber);
                else if(String.isNotBlank(c.Issue_Type__c)&& String.isNotBlank(c.Issue_Sub_Category__c))
                    mapTripIssSubToCase.put(c.Trip_Id_ct__c+c.Issue_Type__c+c.Issue_Sub_Category__c,c.CaseNumber);      
            }
        }
        
        if(!mapOrderItemUuid.keySet().isEmpty()){
            for(Case c:[select id,Transaction_Id__c,OrderItem_Uuid__c,Trip_ID__c,Trip_Id_ct__c,TIN_No__c,casenumber,Issue_Type__c,Issue_Sub_Category__c from case where Issue_Type__c ='Bus Cancellation' AND  OrderItem_Uuid__c IN :mapOrderItemUuid.keySet()])
            {
                mapOrdrItemIsueCase.put(c.OrderItem_Uuid__c+c.Issue_Type__c,c.CaseNumber);      
            }
        }
        
        if(!mapTcode.keySet().isEmpty()){
            for(Case c:[select id,Lead_TCode__c,casenumber,Issue_Type__c,Issue_Sub_Category__c from case where Lead_TCode__c!=null AND Business_Type__c='BusHire'and Lead_TCode__c IN :mapTcode.keySet() AND Issue_Type__c IN :mapIssType.keySet() AND Issue_Sub_Category__c IN :mapSubIssType.keySet()])
            {
                mapTcodeIssSubToCase.put(c.Lead_TCode__c+c.Issue_Type__c+c.Issue_Sub_Category__c,c.CaseNumber);      
            }
        }
        
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
        Id quotaInvQueueId = [Select id from Group where type='Queue' AND developername='Quota_Inv_Ops_Queue'].id;
        for(Case c : TriggerNew)
        {
            
            Case oldCaseIn=null;
            if(Trigger.isUpdate)
                oldCaseIn = TriggerOldMap.get(c.ID);    
            
            System.debug('Createddate...'+c.createddate+'..'+rtcBOIds);
            String strIssueSubIssue = c.Issue_Type__c+c.Issue_Sub_Category__c;
            String strOnlyIssSubIssue = c.Issue_Type__c+c.Issue_Sub_Category__c;
            string strIssu=c.Issue_Type__c;
            String newTripId = String.isNotBlank(c.Trip_Id_ct__c)?c.Trip_Id_ct__c:String.isNotBlank(c.Trip_ID__c)?c.Trip_ID__c:'';
            String newBPcontact = String.isNotBlank(c.BP_Contact_Number__c)?c.BP_Contact_Number__c:'';
            String newOrderItem = String.isNotBlank(c.OrderItem_Uuid__c)?c.OrderItem_Uuid__c:'';
            string serviceProvId =  String.isNotBlank(c.Service_Provider_Id__c)?c.Service_Provider_Id__c:String.isNotBlank(c.Service_Providerr_Id__c)?c.Service_Providerr_Id__c:'';
            
            System.debug('strIssueSubIssue -->'+strIssueSubIssue );
            
            if(Trigger.isInsert)
            {
                c.All_Previous_Status_Dates__c=c.status+','+String.valueOf(System.now());
                
                if (c.ParentId != null && parentCaseMap.containsKey(c.ParentId)) {
                    Case parentCase = parentCaseMap.get(c.ParentId);
                    if (parentCase != null) {
                        c.Parent_IssueType__c = parentCase.Issue_Type__c;
                        c.Parent_Issue_SubCategory__c = parentCase.Issue_Sub_Category__c;
                    }
                }
                
                if(String.isNotBlank(c.Issue_Type__c) && String.isNotBlank(c.Issue_Sub_Category__c) && rtcBOIds.contains(serviceProvId) && setRestrictedRTCissue.contains(c.Issue_Type__c) && setRestrictedRTCsubissue.contains(c.Issue_Sub_Category__c))
                {
                    c.addError('Case Insert Has Failed. We regret to inform you, as per the RTC policy, this subissue type is not accepted by RTC');  
                }
                
                if( 'Closed'.equalsIgnoreCase(c.status) && c.First_Closure__c==null)
                    c.First_Closure__c=System.now();
                
                if('Indonesia'.equalsIgnoreCase(c.country__c) && 'Open'.equalsIgnoreCase(c.status) && 'Quota Management'.equalsIgnoreCase(c.issue_Type__c))
                    c.ownerid = quotaInvQueueId;
                
                if(String.isNotBlank(c.Issue_Type__c) && 'BP Verification'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newBPcontact) && String.isNotBlank(c.Issue_Sub_Category__c) && mapBPVissuCase.containsKey(newBPcontact+strOnlyIssSubIssue) && !c.origin.contains('Email'))
                    c.addError('Case Insert Has Failed.Becuase Case is already exists with same details.Existing Case Number is -'+mapBPVissuCase.get(newBPcontact+strOnlyIssSubIssue));  
                
                if(String.isNotBlank(c.Issue_Type__c) && !'NEFT Refund'.equalsIgnoreCase(c.Issue_Type__c) && !'Exceptional Refund'.equalsIgnoreCase(c.Issue_Type__c) && !'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newTripId) && String.isNotBlank(c.Issue_Sub_Category__c) && mapTripIssSubToCase.containsKey(newTripId+strOnlyIssSubIssue) && !c.origin.contains('Email'))
                    c.addError('Case Insert Has Failed.Becuase Case is already exists with same details.Existing Case Number is -'+mapTripIssSubToCase.get(newTripId+strOnlyIssSubIssue));  
                
                if(String.isNotBlank(c.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newTripId) && mapTripIssuCase.containsKey(newTripId+strIssu) && !c.origin.contains('Email')){
                    c.addError('Bus Cancellation Case Insert Has Failed.Becuase Case is already exists with same details.Existing Case Number is -'+mapTripIssuCase.get(newTripId+strIssu)); 
                }
                
                if(String.isNotBlank(c.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newOrderItem) && mapOrdrItemIsueCase.containsKey(newOrderItem+strIssu) && !c.origin.contains('Email')){
                    c.addError('Bus Cancellation Case Insert Has Failed.Becuase Case is already exists with same details.Existing Case Number is -'+mapOrdrItemIsueCase.get(newOrderItem+strIssu)); 
                }
                
                if(String.isNotBlank(c.Issue_Type__c) &&  c.Business_Type__c=='BusHire' && String.isNotBlank(c.Lead_TCode__c) && mapTcodeIssSubToCase.containsKey(c.Lead_TCode__c+strIssueSubIssue))
                    c.addError('Case Insert Has Failed.Becuase Case is already exists with same details.Existing Case Number is -'+mapTcodeIssSubToCase.get(c.Lead_TCode__c+strIssueSubIssue));    
                
                
                if(leadmap.containsKey(c.Lead__c)){
                    
                    c.Lead_TCode__c=leadmap.get(c.Lead__c).TCode__c;
                    c.SourceT__c=leadmap.get(c.Lead__c).SrcCityName__c;
                    c.Business_Type__c='BusHire';
                    c.DestinationT__c=leadmap.get(c.Lead__c).DestCityName__c;
                    c.Bus_Operator_Namee__c=leadmap.get(c.Lead__c).Operator_Name__c;
                    c.Email_Id_ct__c=leadmap.get(c.Lead__c).Email;
                    c.Region__c=leadmap.get(c.Lead__c).Region__c;
                    c.SS_DOJ__c=leadmap.get(c.Lead__c).DOJStart__c;
                    c.Phone_No_ct__c =leadmap.get(c.Lead__c).Phone;
                }
                
                String b2bOprtrId='';
                List<shortrouteids__mdt> shortRoutes = [SELECT MasterLabel, source__c, destination__c,source_and_destination_id__c FROM shortrouteids__mdt];
                set<string> shrtSrcDest = New set<string>();
                for(shortrouteids__mdt m:shortRoutes){
                    shrtSrcDest.add(m.source_and_destination_id__c);
                }
                if(ortMap.containsKey(c.transaction_id__c)){
                    c.HFT__c= ortMap.get(c.transaction_id__c).hft__c;
                    c.Order_UUId__c=ortMap.get(c.transaction_id__c).OrderUuid__c;
                    c.Inventory_Type__c=ortMap.get(c.transaction_id__c).Inventory_Type__c;
                    c.Source_And_Destination__c = ortMap.get(c.transaction_id__c).Source_Destination__c;
                    c.Source_Destination_id__c = ortMap.get(c.transaction_id__c).Source_Destination_id__c;
                
                    if(string.isNotBlank(c.Source_Destination_id__c) && shrtSrcDest.contains(string.valueOf(c.Source_Destination_id__c))){
                        c.IsShortRoute__c = true;
                    }
                    if(string.isBlank(c.Service_Providerr_Id__c)){
                        c.Service_Providerr_Id__c=ortMap.get(c.transaction_id__c).Service_Provider_Id__c;
                    }
                    
                    if(c.Issue_Type__c!='DBT'){
                        c.amountT__c= ortMap.get(c.transaction_id__c).Total_Fare__c;
                    }
                    
                    if(ortMap.get(c.transaction_id__c).RecordType.Name=='B2B Bus Booking'){
                        b2bOprtrId = (ortMap.get(c.transaction_id__c).Service_Provider_Info__r!=null && ortMap.get(c.transaction_id__c).Service_Provider_Info__r.Operator_Id__c!= null) ? ortMap.get(c.transaction_id__c).Service_Provider_Info__r.Operator_Id__c:'';
                    }
                }
                
                // B2b bolt flag insert
                if(string.isNotBlank(b2bOprtrId) && instantRefundBoIds.contains(b2bOprtrId)&& setBoltSubIssueTypes.contains(c.Issue_Sub_Category__c))
                {
                    c.Case_Category__c='Instant resolution-BOLT';
                }
                
                
                // bolt flag insert
                if(string.isNotBlank(serviceProvId) && instantRefundBoIds.contains(serviceProvId)&& setBoltSubIssueTypes.contains(c.Issue_Sub_Category__c))
                {
                    c.Case_Category__c='Instant resolution-BOLT';
                }
                
                //IRand DR
                if( !'Initiate Bus Cancellation'.equalsIgnoreCase(c.Issue_Sub_Category__c) && String.isNotBlank(c.Issue_Type__c) && String.isNotBlank(c.Issue_Sub_Category__c) && !setStatusExculd.contains(c.status) && !setChannelExculd.contains(c.Channel_ct__c) && !setOriginsExculd.contains(c.origin) && c.Type!='B2B' && string.isNotBlank(c.Business_Type__c) && string.isNotBlank(c.country__c) && c.country__c=='India' && mapIssueIrDr.containsKey(strIssueSubIssue))
                {
                    Issue_Based_TAT__mdt boltmdt=mapIssueIrDr.get(strIssueSubIssue) ;
                    c.Flow_Type__c='L2 Support Queue';
                    c.ownerId=System.Label.L2_Support_Queue_Id;
                    c.Priority = boltmdt.Priority__c;
                    c.TAT_Value__c = boltmdt.TAT_Value__c;
                    c.Green_Zone__c = boltmdt.Green_Zone__c;
                    c.Amber_Zone__c = boltmdt.Amber_Zone__c;
                }
                
            }
            
            if(Trigger.isUpdate)
            {
                String oldStatus=TriggerOldMap.get(c.Id).Status;
                Case oldCase = TriggerOldMap.get(c.ID);
                string oldTransaction=TriggerOldMap.get(c.Id).Transaction_id__c; 
                string oldIssueType = TriggerOldMap.get(c.Id).Issue_Type__c;
                string oldSubIssueType = TriggerOldMap.get(c.Id).Issue_Sub_Category__c;
                
                if(string.isBlank(c.Transaction_id__c) && transCsMap.containsKey(c.Transaction_UUID__c)){
                    c.Transaction_ID__c = transCsMap.get(c.Transaction_UUID__c).id; 
                }
                
                // bolt flag updat
                if((c.Issue_Type__c!=oldIssueType || c.Issue_Sub_Category__c!=oldSubIssueType) || (c.Channel_ct__c =='MMT' || c.Channel_ct__c=='GI') || c.Case_Category__c==null){  
                    if(string.isNotBlank(serviceProvId) && instantRefundBoIds.contains(serviceProvId) && setBoltSubIssueTypes.contains(c.Issue_Sub_Category__c))
                    {
                        c.Case_Category__c='Instant resolution-BOLT';
                    }else{
                        c.Case_Category__c='';
                    }
                    
                }
                if (c.ParentId != null && parentCaseMap.containsKey(c.ParentId) && (c.Issue_Type__c!=oldIssueType || c.Issue_Sub_Category__c!=oldSubIssueType)) {
                    Case parentCase = parentCaseMap.get(c.ParentId);
                    if (parentCase != null) {
                        c.Parent_IssueType__c = parentCase.Issue_Type__c;
                        c.Parent_Issue_SubCategory__c = parentCase.Issue_Sub_Category__c;
                    }
                }
                
                if(c.Transaction_id__c!=null && c.Transaction_id__c!=oldTransaction){
                    
                    if(ortMap.containsKey(c.transaction_id__c)){
                        c.HFT__c= ortMap.get(c.transaction_id__c).hft__c;  
                        c.Order_UUId__c=ortMap.get(c.transaction_id__c).OrderUuid__c;
                        c.Inventory_Type__c=ortMap.get(c.transaction_id__c).Inventory_Type__c;
                        
                    }
                    c.BD_Location__c=c.BD_Location2__c;
                    c.SH_Dropping_Time__c=c.Dropping_Time__c;
                }
                
                if(c.status!=oldStatus)
                {
                    if(c.status=='Escalated to BD' || c.status=='Re-escalated to BD'){
                        
                        c.Assigned_to_BD__c=System.now();
                        c.Assigned_By__c= UserInfo.getUserID();
                        c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();         
                        c.ownerid=g.id;
                        
                        if(c.Country__c=='India'){
                            string previousStatusValues = string.valueOf(c.All_Previous_Status_Dates__c);
                            String[] parts = previousStatusValues.split(';');
                            Integer count = 0;
                            for (String part : parts) {
                                if (part.startsWith('Escalated to BD')) {
                                    count++;
                                }
                            }
                            if(count>=2){
                                c.status='Re-escalated to BD';
                            }
                        }
                    }
                    
                    if(CaseTriggerHandler.stopStatusUpdate)
                    {
                        CaseTriggerHandler.stopStatusUpdate=false;
                        c.Previous_Status__c=oldStatus;
                        String prevValues;
                        
                        if(c.All_Previous_Status_Dates__c!=null){
                            prevValues=c.status+','+String.valueOf(System.now())+';'+c.All_Previous_Status_Dates__c;
                            if(prevValues.length()<50000)
                                c.All_Previous_Status_Dates__c=prevValues;
                            else
                                c.All_Previous_Status_Dates__c=prevValues.right(50000);                      
                        }else{
                            c.All_Previous_Status_Dates__c=c.status+','+String.valueof(System.now());
                        }
                        
                    }
                    
                    if('Indonesia'.equalsIgnoreCase(c.country__c) && 'Escalated to CSE'.equalsIgnoreCase(c.status))
                        c.ownerid = quotaCSQueueId;
                    
                    // if( c.status=='Escalated to BD'){
                    //     c.Assigned_to_BD__c=System.now();
                    //     c.Assigned_By__c= UserInfo.getUserID();
                    //     c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();         
                    //     c.ownerid=g.id;
                    // }
                    
                    //busHire Fulfillment
                    if(string.isNotBlank(c.Issue_Type__c) && string.isNotBlank(c.Issue_Sub_Category__c) && string.isNotBlank(c.Lead_TCode__c) && c.Business_Type__c=='BusHire' && c.status=='Escalated to fulfillment'){  
                        c.Assigned_to_BD__c=System.now();
                        c.Assigned_By__c=UserInfo.getUserid();
                        c.status='Escalated to fulfillment';
                        c.ownerid=rydeffId;
                        c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();
                    }
                    
                    if(c.Business_Type__c=='BusHire' && string.isNotBlank(c.Lead_TCode__c) && 'Escalated to fulfillment'.equalsIgnoreCase(c.Previous_Status__c) && c.status=='Fulfillment revert'){
                        if(string.isNotBlank(c.Assigned_By__c)){
                            c.ownerid=c.Assigned_By__c;
                        }else{
                            c.ownerid=busHireSupQueueId;
                        }
                        c.Department_Revert_Time__c=System.now();
                        c.Revert_By_Agent__c=UserInfo.getUsername();
                    }
                    
                    //ryde Partner rYde Community Profile
                    if( c.status=='Escalated to Partner' && string.isNotBlank(c.rYde_Parnter_Users__c)){
                        String rYdeuser=c.rYde_Parnter_Users__c;
                        c.ownerid= c.rYde_Parnter_Users__c;
                        
                    }
                    
                    
                    if( 'Closed'.equalsIgnoreCase(c.status) && c.First_Closure__c==null){
                        c.First_Closure__c=System.now();
                    }
                    
                    if( 'Escalated to Paas'.equalsIgnoreCase(c.status)){
                        c.ownerid = paasEscqueueId;
                        c.Paas_Escalated_time__c=System.now();
                    }
                    
                    if('Re-Open'.equalsIgnoreCase(c.status) && 'Closed'.equalsIgnoreCase(c.Previous_Status__c))
                    {  
                        c.redCare_Amount__c=null;
                        
                        if(String.isBlank(c.Re_Opened_By__c))
                            c.Re_Opened_By__c = 'Re-Opened By System';
                        
                    }
                    if(('BO Replied'.equalsIgnoreCase(c.status) || 'Department Revert'.equalsIgnoreCase(c.status)))
                    {  
                        if(setSystemAdminUsers.contains(c.ownerid) || string.isBlank(c.Assigned_By__c) || 'Non callble scheduler'.equalsIgnoreCase(c.Assigned_By__c)){
                            c.ownerId=System.Label.L2_Support_Queue_Id;
                            c.Flow_Type__c='L2 Support Queue';
                        }else if(string.isNotBlank(c.Assigned_By__c)){
                            c.ownerId=c.Assigned_By__c;
                        }
                    }
                    
                    if('Approved'.equalsIgnoreCase(c.status) && 'Mark Payment As Completed'.equalsIgnoreCase(c.Issue_Sub_Category__c)){
                        
                        if(String.isBlank(c.Order_UUId__c) || String.isBlank(c.PG_Ttransaction_Id__c))
                            c.addError('OrderUuid or PO No is Missing For This Transaction.So,you can not approve');
                        else
                            c.Approved_By__c=userinfo.getName();
                        
                    }
                    
                    //Re-open casses assign to closed by (agent) or L2 queue based on flow type
                    if('Re-Open'.equalsIgnoreCase(c.status) && (c.ownerid==System.Label.Closed_Cases_Queue_Id || setSystemAdminUsers.contains(c.ownerid)))
                    {
                        if(string.isNotBlank(c.Closed_By__c)){
                            string strClosedByAgenName = c.Closed_By__c;
                            if(mapUserNameId.containsKey(strClosedByAgenName) && !setSystemAdminUsers.contains(mapUserNameId.get(strClosedByAgenName).id) && mapUserNameId.get(strClosedByAgenName).Agent_Type__c!='L1'){
                                c.ownerId=mapUserNameId.get(strClosedByAgenName).id;
                            }else{
                                c.ownerId =System.Label.L2_Support_Queue_Id;  
                            }
                            
                        }else{
                            c.ownerId =System.Label.L2_Support_Queue_Id;
                        }
                        
                    }   
                    
                    if(c.Type!='B2B' && 'Instant resolution-BOLT'.equalsIgnoreCase(c.Case_Category__c) && string.isBlank(c.Refund_Type__c) && 'Closed'.equalsIgnoreCase(c.status))
                    {
                        c.addError('Please Add Refund Type - Mandatory');
                    }
                }
                
                if(c.Does_Customer_Require_CallBack__c && (c.Does_Customer_Require_CallBack__c!=oldCase.Does_Customer_Require_CallBack__c) && String.isNotBlank(c.Call_Back_Time__c))
                    c.CallBack_Requested_Time__c = System.now().addHours(Integer.valueOf(c.Call_Back_Time__c));
                
                if(String.isNotBlank(oldCase.caseNumber) && String.isNotBlank(c.Issue_Type__c) && !'Exceptional Refund'.equalsIgnoreCase(c.Issue_Type__c) && !'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && !setSkipChannels.contains(c.Channel_ct__c) && String.isNotBlank(newTripId) && String.isNotBlank(c.Issue_Sub_Category__c) && mapTripIssSubToCase.containsKey(newTripId+strOnlyIssSubIssue) && ((newTripId != oldCase.Trip_Id_ct__c) || (newTripId != oldCase.Trip_ID__c) || (c.Issue_Type__c != oldCase.Issue_Type__c ) || (c.Issue_Sub_Category__c != oldCase.Issue_Sub_Category__c)) && !c.origin.contains('Email'))
                    c.addError('Case Update Has Failed Becuase Case is already exists with same details.Existing Case Number is -'+mapTripIssSubToCase.get(newTripId+strOnlyIssSubIssue));
                
                if(String.isNotBlank(oldCase.caseNumber) && String.isNotBlank(c.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newTripId) && mapTripIssuCase.containsKey(newTripId+strIssu) && ((newTripId != oldCase.Trip_Id_ct__c) || (newTripId != oldCase.Trip_ID__c) || (c.Issue_Type__c != oldCase.Issue_Type__c )) && !c.origin.contains('Email')){
                    c.addError('Bus Cancellation Case Update Has Failed Becuase Case is already exists with same details.Existing Case Number is -'+mapTripIssuCase.get(newTripId+strIssu));    
                }
                
                if(String.isNotBlank(oldCase.caseNumber) && String.isNotBlank(c.Issue_Type__c) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(newOrderItem) && mapOrdrItemIsueCase.containsKey(newOrderItem+strIssu) && ((newOrderItem != oldCase.OrderItem_Uuid__c) || (c.Issue_Type__c != oldCase.Issue_Type__c )) && !c.origin.contains('Email')){
                    c.addError('Bus Cancellation Case Update Has Failed Becuase Case is already exists with same details.Existing Case Number is -'+mapOrdrItemIsueCase.get(newOrderItem+strIssu));    
                }
            }
        }
        
        if(Trigger.isUpdate)
        {
           if(!stopDisbursalUpdate && !disbursalIds.isEmpty() && !System.isFuture() && !System.isBatch())
            {
               stopDisbursalUpdate = true;
               DisbursalNEFT(disbursalIds);
            }
            
            //Validtion - Case Comment is mandatory whenever closing the close
            if(!caseClosedIds.isEmpty() && !stopvalidateCaseComment && !'sreenivas.m@redbus.com'.equalsIgnoreCase(UserInfo.getUserName()))
            {
                stopvalidateCaseComment = true;
                ValidationCaseComment(caseClosedIds,TriggerNewMap);   
            }
            if(!bdRejIds.isEmpty() && !stopEsclateToBD)
            {
                stopEsclateToBD = true;
                ValidationCaseComment2(bdRejIds,TriggerNewMap);
            }
            
            if(!snfIds.isEmpty() && !stopValidateSendNotif)
            {
                stopValidateSendNotif = true;
                ValidationSendNotification(snfIds,TriggerNewMap);    
            }
            
            if(!busHireFulfillmentIds.isEmpty() && !stopEsclateToFulfillment)
            {
                stopEsclateToFulfillment = true;
                ValidationCaseComment2(busHireFulfillmentIds,TriggerNewMap);    
            }
            
            //CRM - 1365
            if(!setLtoSupportids.isEmpty() && !stopEsclateToTech)
            {
                stopEsclateToTech = true;
                ValidationCaseComment2(setLtoSupportids,TriggerNewMap);    
            }
            
            if(!setUGCSupportIds.isEmpty() && !stopEsclateToUGC)
            {
                stopEsclateToUGC = true;
                ValidationCaseComment2(setUGCSupportIds,TriggerNewMap);    
            }
            
            if(!setRTCSupportids.isEmpty() && !stopEscalateToRTCTech)
            {
                stopEscalateToRTCTech = true;
                ValidationCaseComment2(setRTCSupportids,TriggerNewMap);  
            }
            
            if(!setClosedByAgentName.isEmpty() && !stopAssignToSameAgent)
            {
                stopAssignToSameAgent=true;
                assignToSameAgent(setClosedByAgentName,TriggerNew);
            }
            
            if(!setLtoSupportids.isEmpty() && !enableSupportcase)
            {
                enableSupportcase=true;
                CreateLtoSupportcases(setLtoSupportids,'L2');
            }
            
            if(!setUGCSupportIds.isEmpty() && !enableUGCcase)
            {
                enableUGCcase=true;
                CreateLtoSupportcases(setUGCSupportIds,'UGC');
            }
            
            if(!setRTCSupportids.isEmpty() && !enableRTCSupportcase) {
                enableRTCSupportcase = true;
                CreateLtoSupportcases(setRTCSupportids,'RTC');
            }
        }
    } 
    
    //Case After Insert Logic
    public static void caseAfterInsert(List<Case> TriggerNew,Map<Id,Case> TriggerOldMap)
    {
        List<Case> gftCaseList = new List<Case>();
        List<Case> listNEFTRefundCases = new List<Case>();
        set<id> listbusCancellationCasesid = new set<id>();
        List<Case> listCompTrackCases = new List<Case>();
        List<Case> listEmailCases = new List<Case>();
        Set<String> setEmailOrigions = new Set<String>();
        List<Case> listNLPCases = new List<Case>();
        Set<String> setNLPOrigions = new Set<String>();
        set<id> setparentIds = new set<id>();
        Set<String> setNLPTypes = new Set<String>();
        set<Id> noOpenCases=new set<id>();
        set<Id> setHFCases=new set<id>();
        set<id> dbtCsIds=new set<id>();
        set<string> dbtTpIds=new set<string>();
        set<id> mmtBusCIds=new set<id>();
        set<id> b2bCopassTins=new set<id>();
        setEmailOrigions.addAll(System.Label.TextClassification.split(','));
        setNLPOrigions.addAll(System.Label.Restricted_NLP_Origins.split(','));      
        setNLPTypes.addAll(System.Label.Restricted_NLP_Types.split(','));
        set<id> CxUserCsIds=new set<id>();
        set<id> setMobEmailCsIds=new set<id>();
        set<id> b2cCopassTins=new set<id>();
        Set<String> setDefaulIssueTypes = new Set<String>(System.label.Default_Queue_to_EmailSupportQueue.split(','));
        Set<String> setDefaulSubIssueTypes = new Set<String>(System.label.Default_Queue_SubIssue.split('__'));
        Set<String> setDefaulChannels = new Set<String>(System.label.Default_Channel.split('__'));
        Id ComplaintTracRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Tracker').getRecordTypeId();
        Id SITrecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('External - SIT Case').getRecordTypeId(); 
        set<id> setNonCallableCsIds=new set<id>();
        set<id> setParentExpRefCsIds= new set<id>();
        Map<id,String> whatsAppToTrigger = new Map<id,String>();
        Set<String> SkipInternalIssueTypes = new Set<String>(System.label.Internal_IssueTypes.split(','));
        Set<String> gameChangerIssueTypesToSkip = new Set<String>(System.label.gameChangerIssueTypesToSkip.split(','));
        
        for (Case cs : TriggerNew) 
        {
            System.debug('***cs.owner.name***'+cs);
            
            /* if('NEFT Refund'.equalsIgnoreCase(cs.Issue_Type__c) && String.isBlank(cs.Account_Number__c) && (String.isNotBlank(cs.Transaction_ID__c) || String.isnotblank(cs.TIN_No__c) || String.isNotBlank(cs.Trip_Id_ct__c))){
listNEFTRefundCases.add(cs);
}*/ 
            if('Exceptional Refund'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(cs.ParentId) && 'Open'.equalsIgnoreCase(cs.Status) && cs.Type != 'B2B'){
                setParentExpRefCsIds.add(cs.parentid);
                
            }
            
            //Non Callable Sent notification on case creation
            if(cs.type!='B2B' && 'Awaiting BO/BD Response'.equalsIgnoreCase(cs.status) && 'Non Callable'.equalsIgnoreCase(cs.BO_Type__c)){
                setNonCallableCsIds.add(cs.id);
            }
            
            if(!'IAS'.equalsIgnoreCase(cs.Channel_ct__c) && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && ('Initiated'.equalsIgnoreCase(cs.Status) || 'Open'.equalsIgnoreCase(cs.Status))&& cs.Type != 'B2B' && 'India'.equalsIgnorecase(cs.Country__c)){
                listbusCancellationCasesid.add(cs.id);
                
            }
            if(cs.type=='B2B' && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) ){
                b2bCopassTins.add(cs.id);
            }            
            
            if((cs.status=='Initiated' || cs.status=='Open') && cs.Origin != 'Failed Transaction')
                setHFCases.add(cs.id);
            
            if('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && Boolean.valueOf(System.Label.Enable_Acko_Flows) && 'India'.equalsIgnorecase(cs.Country__c))
            {
                setparentIds.add(cs.id);
            }
            else if(Boolean.valueOf(System.Label.Enable_Acko_Flows) && 'Exceptional Refund'.equalsIgnoreCase(cs.Issue_Type__c) && String.isNotBlank(cs.ParentId) && 'India'.equalsIgnorecase(cs.Country__c))
            {
                setparentIds.add(cs.parentid);
            }
            
            
            if(cs.Transaction_ID__c !=null)
                noOpenCases.add(cs.Transaction_ID__c);
            
            if(cs.issue_type__c=='DBT' && cs.DBTScheduler__c==true){
                dbtCsIds.add(cs.id);
                dbtTpIds.add(cs.trip_id_ct__c);
            } 
            
            string ownername= userinfo.getName();                  
            if('CX User'.equalsIgnorecase(ownername) && cs.TAT_Value__c==Null && cs.recordtypeid==ComplaintTracRecTypeId && !setDefaulChannels.contains(cs.Channel_ct__c) && cs.HFT__c!='Primo'){
                defaultQueue=true;
            }   
            
            if(defaultQueue && cs.recordtypeid!=SITrecTypeId && cs.Origin=='Complaint Tracker' && cs.status=='Open' && 'REDBUS_IN'.equalsIgnoreCase(cs.Business_Unit_ct__c) && setDefaulIssueTypes.contains(cs.issue_type__c)){ 
                CxUserCsIds.add(cs.id);
            }
            
            if(defaultQueue && cs.recordtypeid!=SITrecTypeId && cs.Origin=='Complaint Tracker' && cs.status=='Open' && 'REDBUS_IN'.equalsIgnoreCase(cs.Business_Unit_ct__c) && setDefaulSubIssueTypes.contains(cs.Issue_Sub_Category__c)){ 
                CxUserCsIds.add(cs.id);
            }
            
            // for mapping values from signed_in_user_mobile__c,booking_user_mobile__c into booking_mobile_no__c and booking_email_copy__c,signed_in_user_email__c,booking_user_email__c into booking_email_id__c
            if(String.isNotBlank(cs.signed_in_user_mobile__c) || String.isNotBlank(cs.booking_user_mobile__c) || String.isNotBlank(cs.booking_email_copy__c) || String.isNotBlank(cs.signed_in_user_email__c) || String.isNotBlank(cs.booking_user_email__c) || String.isNotBlank(cs.Complaint_Mobile_No__c)){
                setMobEmailCsIds.add(cs.id);
            }
            
            // To trigger whatsApp message for Open and initiated status
            if('India'.equalsIgnoreCase(cs.country__c) && 'Domestic-Bus'.equalsIgnoreCase(cs.Business_Type__c) && !SkipInternalIssueTypes.contains(cs.Issue_Type__c) && !gameChangerIssueTypesToSkip.contains(cs.Issue_Type__c) && 'Open'.equalsIgnoreCase(cs.Status) || ('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && 'Initiated'.equalsIgnoreCase(cs.Status))){
                Case_WhatsApp_Notification__c notificationSetting = Case_WhatsApp_Notification__c.getInstance(cs.Status);
                if (notificationSetting != null) {
                    String templateName = notificationSetting.Template_Name__c;
                    whatsAppToTrigger.put(cs.Id, templateName);
                }
            }
            /*if('Complaint Tracker'.equalsIgnorecase(cs.Origin))
listCompTrackCases.add(cs);

if (cs.RecordTypeId == gftRectId || 'Payment debited but ticket not issued - Need ticket'.equalsIgnorecase(cs.Issue_Sub_Category__c))    
{
gftCaseList.add(cs);
}

if(String.isBlank(cs.Issue_Type__c) && String.isNotBlank(cs.Origin) && setEmailOrigions.contains(cs.Origin))
{
System.debug('add to list..'+cs);
listEmailCases.add(cs);
}

if((String.isBlank(cs.Origin) || (String.isNotBlank(cs.Origin) && !setNLPOrigions.contains(cs.Origin))) && (String.isBlank(cs.Issue_Type__c) || (String.isNotBlank(cs.Issue_Type__c) && !setNLPTypes.contains(cs.Issue_Type__c))))
{       
System.debug('NLP Case..'+cs);      
listNLPCases.add(cs);       
}
*/
        }  
        
        if(!system.isFuture() && !whatsAppToTrigger.isEmpty() && !System.isBatch()){
            sendWhatAppCapiFutureCtrl.asyncSendWhatsAppMessage(whatsAppToTrigger);
        }
        if(!system.isFuture() && !setParentExpRefCsIds.isEmpty() && !System.isBatch())
        {
            UpdateParentCaseHaveExpRefCheck(setParentExpRefCsIds);
        }
        if(!system.isFuture() && !setMobEmailCsIds.isEmpty() && !System.isBatch())
        {
            MapEmailMobileValues(setMobEmailCsIds);
        }
        
        if(!system.isFuture() && !CxUserCsIds.isEmpty() && !System.isBatch())
        {
            DefaultQueToEmailsupporQue(CxUserCsIds);
        }
        
        if(!dbtCsIds.isEmpty() && !dbtTpIds.isEmpty())
        {
            DBTConfirmHandler.dbtConfirm(dbtCsIds,dbtTpIds);
        }
        
        if(!system.isFuture() && !setHFCases.isEmpty() && !System.isBatch())
        {
            HFData(setHFCases);
        }
        
        if(!system.isFuture() && !System.isBatch() &&!b2bCopassTins.isEmpty()){
            B2BCopassenger(b2bCopassTins,'B2B');
        }
        
        if(!system.isFuture() && !System.isBatch() &&!b2cCopassTins.isEmpty()){
            B2BCopassenger(b2cCopassTins,'B2C');
        }
        /*if(!listNEFTRefundCases.isEmpty() && !System.isFuture() && !System.isBatch())
{
sendNEFTRefundNotification(JSON.serializePretty(listNEFTRefundCases));
}*/
        
        if(!listbusCancellationCasesid.isEmpty() && !System.isFuture() && !System.isBatch())
        {
            //buscancelSendnotification(listbusCancellationCasesid);
            BusCanclProcessBuilder(listbusCancellationCasesid);
        }
        
        
        
        if(!CaseTriggerHandler.stopPolicyInitiation && !setparentIds.isEmpty() && !System.isFuture() && !System.isBatch())
        {
            CaseTriggerHandler.stopPolicyInitiation = true;
            system.debug('policyInitiate-->>'+setparentIds);
            policyInitiate(setparentIds);
        }
        
        
        
        if(!noOpenCases.isEmpty() && CaseTriggerHandler.stopOpenCaseCount)
        {
            CaseTriggerHandler.stopOpenCaseCount = false;
            CaseTriggerHandler.numberOfOpenCases(noOpenCases);         
        }
        
        if(!setNonCallableCsIds.isEmpty() && !System.isFuture() && !System.isBatch())
        {
            sendEmailAlertToNonCallableBOs(setNonCallableCsIds);
        }
        
        /*  if(!gftCaseList.isEmpty() && !NewUserGFT.flag && !System.isFuture() && !System.isBatch())
{
NewUserGFT.isNewUser(JSON.serializePretty(gftCaseList));
}
if(!listEmailCases.isEmpty() && !System.isFuture() && !System.isBatch())
{
System.debug('Inside...listEmailCases..'+listEmailCases);
textClassification(JSON.serializePretty(listEmailCases));
}

if(!listNLPCases.isEmpty())     
{           
if(!System.isFuture() && !System.isBatch()){        
System.debug('asynccasePrioritizationScore..if..'+listNLPCases);             
asynccasePrioritizationScore(JSON.serializePretty(listNLPCases));       
}        
else        
{  System.debug('casePrioritizationScore..else..'+listNLPCases);        
casePrioritizationScore(JSON.serializePretty(listNLPCases));        
}       
}

if(!listCompTrackCases.isEmpty())
CheckCaseSentiment.CaseSentiment(JSON.serializePretty(listCompTrackCases)); 

*/    
    }  
    
    //Case After Update Logic
    public static void caseAfterUpdate(List<Case> TriggerNew,Map<Id,Case> TriggerOldMap)
    {
        List<Case> listCases=new List<Case>();
        List<Id> neftIds=new list<Id>();
        List<Id> disbursalIds=new list<Id>();
        List<id> walletCreditIds=new list<Id>();  
        set<id> sendNotificationIds=new set<id>();
        set<id> pushNotificationIds=new set<id>();
        list<string> issueTypes=new list<string>();
        list<id> redCareIds=new list<id>();
        set<Id> noOpenCases=new set<id>();
        set<Id> setRejctBusCIds=new set<id>();
        Set<id> setApprvdBusCIds = new Set<id>();
        list<string> caseTrips=new list<string>();
        set<id> setTransUUid = new set<id>();
        issueTypes=Label.CaseNotifications.split(',');
        Id walletCreditRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Wallet Credit').getRecordTypeId(); 
        list<case> busCList=new list<case>(); 
        set<string> busCB2CIds=new set<string>(); 
        Boolean isAckoEnabled = Boolean.valueOf(System.Label.Enable_Acko_Flows);
        Boolean isIcIciEnabled = Boolean.valueOf(System.Label.EnableIciciUpdateFlow);  
        set<Id> excepRefIds=new set<Id>(); 
        set<id> markpaymntCmpltIds = new set<id>();
        set<id> markpaymntCmpltIds_Ind = new set<id>(); 
        set<id> mmtBusCIds=new set<id>();      
        set<id> setRPWids=new set<id>();
        Set<String> setRPWissuTypes = new Set<String>(System.label.RPW_Issuetypes.split(','));
        Set<String> setRPWboids = new Set<String>();
        set<id> setaftrUpdMobEmailCsIds=new set<id>();
        set<id> setMEteamIds = new set<id>();
        set<id> b2cCopassTins=new set<id>();
        set<id> setParentExpRefCsIds= new set<id>();
        Map<id,String> whatsAppToTrigger = new Map<id,String>();
        Set<String> SkipInternalIssueTypes = new Set<String>(System.label.Internal_IssueTypes.split(','));
        Set<String> gameChangerIssueTypesToSkip = new Set<String>(System.label.gameChangerIssueTypesToSkip.split(','));
        
        
        for(Case c:TriggerNew)
        {
            if(c.Transaction_ID__c !=null && !rtcBOIds.contains(c.Service_Provider_Id__c) && c.Trip_Id_ct__c!=null && 'Closed'.equalsIgnoreCase(c.status) && c.status!=TriggerOldMap.get(c.Id).status && c.TAT_Value__c!=null) {            
                redCareIds.add(c.id);
                caseTrips.add(c.Trip_Id_ct__c);
            }
            
            /*
if('Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && 'B2B'.equalsIgnoreCase(c.type) && ('Closed'.equalsIgnoreCase(c.status) || 'Rejected For Bus Cancellation'.equalsIgnoreCase(c.status)))
{ 
listCases.add(c);
}
*/
            if('Exceptional Refund'.equalsIgnoreCase(c.Issue_Type__c) && String.isNotBlank(c.ParentId) && 'Open'.equalsIgnoreCase(c.Status) && c.Type != 'B2B'){
                setParentExpRefCsIds.add(c.parentid);
            }
            if(!c.RPW_Case__c && setRPWissuTypes.contains(c.Issue_Type__c) && (c.Service_Provider_Id__c!=null || c.Service_Providerr_Id__c !=null))
            {
                setRPWids.add(c.id);
            } 
            
           /* if( 'XENDIT_DISBURSMENT'.equalsIgnoreCase(c.Disbursal_Mode__c) && ('XENDIT_DISBURSMENT'.equalsIgnoreCase(c.Disbursal_Mode__c) && !'Disbursal_Success'.equalsIgnoreCase(c.Disbursal_Status__c)) && ('XENDIT_DISBURSMENT'.equalsIgnoreCase(c.Disbursal_Mode__c) && !'DISBURSAL_COMPLETED'.equalsIgnoreCase(c.Disbursal_Status__c)) && string.isNotBlank(c.Disbursal_Id__c) && !'Action Took By Finance'.equalsIgnoreCase(c.status) && 'NEFT Refund'.equalsIgnoreCase(c.Issue_Type__c) && (TriggerOldMap.get(c.id).status!=c.status ))
            {
                disbursalIds.add(c.id);
            }*/
            
            if('MANUAL_NEFT'.equalsIgnoreCase(c.Disbursal_Mode__c) && string.isNotBlank(c.Disbursal_Id__c) && !'Action Took By Finance'.equalsIgnoreCase(c.status) && 'NEFT Refund'.equalsIgnoreCase(c.Issue_Type__c) && (TriggerOldMap.get(c.id).status!=c.status ))
            {
                disbursalIds.add(c.id);
            }
            if('NEFT Refund'.equalsIgnoreCase(c.Issue_Type__c) && string.isNotblank(c.Disbursal_Status__c) && string.isNotblank(c.Transaction_UUID__c) && TriggerOldMap.get(c.id).Disbursal_Status__c!=c.Disbursal_Status__c){
                setTransUUid.add(c.id);
                SyncMethod(setTransUUid);
                
            }
            
            /* if((!'Integration User'.equalsIgnoreCase(userinfo.getName())) && !'Action Took By Finance'.equalsIgnoreCase(c.status) && 'NEFT Refund'.equalsIgnoreCase(c.Issue_Type__c) && (TriggerOldMap.get(c.id).status!=c.status || TriggerOldMap.get(c.id).Account_Number__c!=c.Account_Number__c || TriggerOldMap.get(c.id).IFSC_Code__c!=c.IFSC_Code__c || TriggerOldMap.get(c.id).Bank_Name__c!=c.Bank_Name__c))
{
neftIds.add(c.id);
}*/
            
            if(c.recordtypeid==walletCreditRecTypeId && 'Approved for Wallet Credit'.equalsIgnoreCase(c.status) && TriggerOldMap.get(c.Id).status !='Approved for Wallet Credit' &&  'Wallet Credit'.equalsIgnoreCase(c.Issue_Type__c))
            {
                walletCreditIds.add(c.id);
                
            }
            
            if(c.Transaction_ID__c !=null && ((('Closed'.equalsIgnoreCase(c.status) || 'Rejected For Bus Cancellation'.equalsIgnoreCase(c.status) || 'Re-Open'.equalsIgnoreCase(c.status)) && c.status!=TriggerOldMap.get(c.Id).status) || (c.Transaction_ID__c!=TriggerOldMap.get(c.Id).Transaction_ID__c))){
                noOpenCases.add(c.Transaction_ID__c);
            }
            
            if('Closed'.equalsIgnoreCase(c.status) && c.status!=TriggerOldMap.get(c.id).status && c.issue_type__c!=null &&  issueTypes.contains(c.issue_type__c) )
            {
                sendNotificationIds.add(c.id);
                // pushNotificationIds.add(c.id);
            }
            else if( c.status !='Closed' && c.issue_type__c!=null &&  issueTypes.contains(c.issue_type__c) && c.send_notification__c!=null && c.send_notification__c!=TriggerOldMap.get(c.Id).send_notification__c)
            {
                sendNotificationIds.add(c.id);
            }
            
            if('REDBUS_IN'.equalsIgnoreCase(c.Business_Unit_ct__c) && !'B2B'.equalsIgnoreCase(c.type) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && ('Rejected For Bus Cancellation'.equalsIgnoreCase(c.status) ||('Closed'.equalsIgnoreCase(c.status) && 'Alternative Arrangement by BO'.equalsIgnoreCase(c.Notes__c)))&& c.status!=TriggerOldMap.get(c.id).status && String.isNotBlank(c.Claim_id__c) && (('Acko'.equalsIgnoreCase(c.Insurance_Provider_Name__c) && isAckoEnabled)|| ('ICICI'.equalsIgnoreCase(c.Insurance_Provider_Name__c) && isIcIciEnabled)))
            {
                setRejctBusCIds.add(c.id);
            }
            
            else if('REDBUS_IN'.equalsIgnoreCase(c.Business_Unit_ct__c) && !'B2B'.equalsIgnoreCase(c.type) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && (('Closed'.equalsIgnoreCase(c.status) && 'Refund by BO'.equalsIgnoreCase(c.Notes__c)) || 'Alternative Arrangement by redBus'.equalsIgnoreCase(c.Notes__c)) && c.status!=TriggerOldMap.get(c.id).status && String.isNotBlank(c.Claim_id__c) && (('Acko'.equalsIgnoreCase(c.Insurance_Provider_Name__c) && isAckoEnabled)|| ('ICICI'.equalsIgnoreCase(c.Insurance_Provider_Name__c) && isIcIciEnabled)))
            {
                setApprvdBusCIds.add(c.id);
            }
            
            if(!setTotalRTCcoPas.contains(c.Service_Provider_Id__c) && !'BD-Autocase'.equalsIgnoreCase(c.origin) && !'GDS BusCancellation'.equalsIgnoreCase(c.origin) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && 'Approved For Bus Cancellation'.equalsIgnoreCase(c.Status) && c.status!=TriggerOldMap.get(c.id).status && ('Rejected For Bus Cancellation'.equalsIgnoreCase(TriggerOldMap.get(c.id).status) || 'Initiated'.equalsIgnoreCase(TriggerOldMap.get(c.id).status)))
            {
                
                if(c.Type != 'B2B'){
                    busCList.add(c);
                }
                
                
                busCB2CIds.add(c.id);
                
                System.debug('busCB2CIds-->'+busCB2CIds);
            }
            if(TriggerOldMap.get(c.id).BO_Agreed_for_Refund__c==false && c.BO_Agreed_for_Refund__c==true && c.status=='Approved For Exceptional Refund' && c.status!=TriggerOldMap.get(c.id).status && c.Refund_Amount__c!=null)
            {
                excepRefIds.add(c.id);
            }             
            
            if(c.country__c!='India' && c.PG_Ttransaction_Id__c!=null && 'Mark Payment As Completed'.equalsIgnoreCase(c.Issue_Sub_Category__c) && 'Approved'.equalsIgnoreCase(c.status) && 'Open'.equalsIgnoreCase(TriggerOldMap.get(c.id).status))
            {
                markpaymntCmpltIds.add(c.id); 
            }
            
            if(c.type!='B2B' && !'BD-Autocase'.equalsIgnoreCase(c.origin) && !'GDS BusCancellation'.equalsIgnoreCase(c.origin) && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && (String.isNotBlank(c.Route_Id__c) || String.isNotBlank(c.SS_Route_Id__c)) && (c.Date_Of_Journey_New__c!=null) && c.Service_Id__c!=null)
            {
                b2cCopassTins.add(c.id);
            }
            
            if(c.country__c=='India' && c.PG_Ttransaction_Id__c!=null && 'Mark Payment As Completed'.equalsIgnoreCase(c.Issue_Sub_Category__c) && 'Approved'.equalsIgnoreCase(c.status) && 'Open'.equalsIgnoreCase(TriggerOldMap.get(c.id).status)) 
            {   
                markpaymntCmpltIds_Ind.add(c.id);    
            }
            
            if(c.My_Desk_Id__c!=null && 'Bus Cancellation'.equalsIgnoreCase(c.Issue_Type__c) && c.status=='Approved' && c.status!=TriggerOldMap.get(c.id).status){
                mmtBusCIds.add(c.id);
            }  
            
            if('Escalated to ME Team'.equalsIgnoreCase(c.status) && c.status!='closed' && c.status!=TriggerOldMap.get(c.id).status){
                setMEteamIds.add(c.id);
            }
            
            //mapping email and mobile 
            if(c.Transaction_ID__c!=TriggerOldMap.get(c.Id).Transaction_ID__c)
            {
                setaftrUpdMobEmailCsIds.add(c.id);
            }
            if(c.country__c=='India' && 'Domestic-Bus'.equalsIgnoreCase(c.Business_Type__c) && !gameChangerIssueTypesToSkip.contains(c.Issue_Type__c) && !SkipInternalIssueTypes.contains(c.Issue_Type__c) && c.status!=TriggerOldMap.get(c.id).status){
                Case_WhatsApp_Notification__c notificationSetting = Case_WhatsApp_Notification__c.getInstance(c.Status);
                if (notificationSetting != null) {
                    String templateName = notificationSetting.Template_Name__c;
                    whatsAppToTrigger.put(c.Id, templateName);
                }
            }
        }
        /* if(!excepRefIds.isEmpty()){
CaseTriggerHandler.ProcessExceptionalRefund(excepRefIds);
}*/
        if(!system.isFuture() && !setParentExpRefCsIds.isEmpty() && !System.isBatch())
        {
            UpdateParentCaseHaveExpRefCheck(setParentExpRefCsIds);
        }
        if(!CaseTriggerHandler.stopWhatsAppNotification && !system.isFuture() && !whatsAppToTrigger.isEmpty() && !System.isBatch())
        {
            CaseTriggerHandler.stopWhatsAppNotification = true;
            sendWhatAppCapiFutureCtrl.asyncSendWhatsAppMessage(whatsAppToTrigger);
        }
        if(!CaseTriggerHandler.stopAckoRejctClaimUpdate && !setRejctBusCIds.isEmpty() && !System.isFuture() && !System.isBatch())
        {
            CaseTriggerHandler.stopAckoRejctClaimUpdate = true;
            ApproveorRejectedstatus(setRejctBusCIds,'Rejected','Claim Rejected Successfully','Claim Reject Failed');
        }
        
        if(!CaseTriggerHandler.stopAckoApprClaimUpdate && !setApprvdBusCIds.isEmpty() && !System.isFuture() && !System.isBatch())
        {
            CaseTriggerHandler.stopAckoApprClaimUpdate = true;
            ApproveorRejectedstatus(setApprvdBusCIds,'Approved','Claim Approved Successfully','Claim Approval Failed');
        }
        
        
        if(!redCareIds.isEmpty() && stopRedCare && !System.isFuture() && !System.isBatch()){
            stopRedCare=false;
            redCare_WalletCredit(redCareIds,caseTrips,'T_');
        }
        
        if(!noOpenCases.isEmpty() && stopOpenCaseCount){
            stopOpenCaseCount = false;
            numberOfOpenCases(noOpenCases);         
        }
        
        if(!setaftrUpdMobEmailCsIds.isEmpty() && stopafterUpdaeEmailMble && !System.isFuture() && !System.isBatch()){
            stopafterUpdaeEmailMble=false;
            MapEmailMobileValues(setaftrUpdMobEmailCsIds);
        }
        
        if(!system.isFuture() && !System.isBatch() &&!b2cCopassTins.isEmpty())
        {
            B2BCopassenger(b2cCopassTins,'B2C');
        }
        
        /* if(stopCaseStatus && !listCases.isEmpty() && !System.isFuture() && !System.isBatch())
{
stopCaseStatus = false;
CaseStatus(JSON.serialize(listCases));
}*/
        
        /* if(!stopNEFTUpdate && !neftIds.isEmpty() && !System.isFuture() && !System.isBatch())
{
stopNEFTUpdate = true;
CaseNEFT(neftIds);
}*/
        if(!stopDisbursalUpdate && !disbursalIds.isEmpty() && !System.isFuture() && !System.isBatch())
        {
           stopDisbursalUpdate = true;
           DisbursalNEFT(disbursalIds);
        }
        
        
        if(!sendNotificationIds.isEmpty() && stopSendNotification && !system.isFuture() && !System.isBatch()){
            stopSendNotification=false;
            sendNotification(sendNotificationIds);
        }
        
        /* if(!pushNotificationIds.isEmpty() && stopPushNotify && !system.isFuture() && !System.isBatch())
{
stopPushNotify=false;
CaseCommentTriggerHandler.pushNotification(pushNotificationIds,'caseClosure');            
}*/
        
        if(!walletCreditIds.isEmpty()  && stopWalletCredit && !system.isFuture() && !System.isBatch()){
            stopWalletCredit= false;
            WalletCreditApprove(walletCreditIds);
        }
        
        if([SELECT EnableLog__c FROM API_EndPoints__mdt where DeveloperName='BusCancellationSwitch'].EnableLog__c && !System.isFuture() && !System.isBatch() && stopBusCaseCreation )
        {
            stopBusCaseCreation= false;
            
            if(!busCList.isEmpty())
                createBusCCasesForCoPass(JSON.serialize(busCList),JSON.serialize(Trigger.oldMap));
            
            if(busCB2CIds.size()>0)
                B2BSPOCBusCancellationExtn.B2BBusCancellationInitiation(busCB2CIds,'B2C');
            
            
        }
        
        if(!markpaymntCmpltIds.isEmpty()  && stopCompltPaymnt && !system.isFuture() && !System.isBatch()){
            stopCompltPaymnt= false;
            CompletePaymentApprove(markpaymntCmpltIds);
        }
        
        if(!markpaymntCmpltIds_Ind.isEmpty()  && stopCompltPaymnt && !system.isFuture() && !System.isBatch()){  
            stopCompltPaymnt= false;    
            CompletePaymentApproveIndia(markpaymntCmpltIds_Ind);    
        }
        
        if(!mmtBusCIds.isEmpty() && !System.isFuture() && !System.isBatch() && stopMMTBusCApprove){
            stopMMTBusCApprove=false;
            MMTApproveBusCancellation(mmtBusCIds);
        }
        
        if(!setRPWids.isEmpty() && !enableRPWcase)
        {
            enableRPWcase=true;
            EnableRPWcases(setRPWids);
        }
        
        if(!setMEteamIds.isEmpty() && !enableMEteamcase)
        {
            enableMEteamcase=true;
            UpdateEscMEteamcases(setMEteamIds);
        }
        
    }
    
    /*
Name: CaseStatus
Description: On Case update sending status,tin values to seatseller
*/
    /* @future(callout=true)
public static void CaseStatus(string jsonCases){


List<Case> caseList=new List<Case>();
caselist= (List<Case>)JSON.deserializeStrict(jsonCases,List<Case>.class);
List<CaseRequestWrapper> cReqList=new list<CaseRequestWrapper>();
System.debug('serialized json-->'+JSON.serializePretty(caseList));

for(Case c:caseList)
{         
String statusValue;        
if(c.status=='Rejected For Bus Cancellation')
statusValue='DisApproved';

else if(c.status=='Closed' && c.Notes__c=='Refund by redBus')
statusValue='Cancel Ticket';
else
statusValue='Alternative Arrangement by BO';

cReqList.add(new CaseRequestWrapper(c.TIN_No__c,statusValue));                                
}

if(!cReqList.isEmpty())
{
API_EndPoints__mdt endPointData = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SSBusCancellation'];   
System.debug('Request Wrapper-->'+cReqList);
String jsonBody=json.serialize(cReqList);  
System.debug('Request Json-->'+jsonBody);         
Http h= new Http();
HttpRequest req = new HttpRequest();
HttpResponse res = new HttpResponse();
req.setHeader('Accept', 'application/json');
req.setHeader('Content-Type', 'application/json');
req.setEndpoint(endPointData.Endpoint__c);
req.setMethod('POST');
req.setBody(jsonBody);
DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.Type__c = 'SS Notification';
dbl.SentAt__c = system.now();
dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'..'+String.valueOf(jsonBody);

try
{
res=h.send(req);
System.debug('Response-->'+res.getBody());          
dbl.Payment_Request_Response_Time__c = System.now();
dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody()+stopCaseStatus);                
}

Catch(Exception e)
{
dbl.Payment_Request_Response_Time__c = System.now();
dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());                
}

if(endPointData.EnableLog__c)
insert dbl;


}

}

public class CaseRequestWrapper{
public string tin;
public string status;
public CaseRequestWrapper(string tin,string status){
this.tin=tin;
this.status=status;
}
}*/
    
    /*
Name: CaseNEFT
Description: On Case close, sending case details to NEFT Refund API
*/
    /* @future(callout=true)
public static void CaseNEFT(List<id> caseNEFTIds){
List<Case> caseNEFTList=new List<Case>();
caseNEFTList=[select id,status,type,notes__c,TIN_No__c,PG_Ttransaction_Id__c,Paas_OrderId__c,Refund_Amount__c,CaseNumber,LastModifiedByid,LastModifiedBy.Name,Description,Trip_Id_ct__c,Email_Id_ct__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Account_Holder_Name__c from case where id in:caseNEFTIds];
list<CaseNEFTWrapper> neftWrapperList=new list<CaseNEFTWrapper>();              
AccountDetails accountDetails=new AccountDetails ();      

for(case c:caseNEFTList){
neftWrapperList.add(new CaseNEFTWrapper(c,accountDetails));
}         

if(!neftWrapperList.isEmpty()){
String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='NEFT_Refund'].Endpoint__c;             
String neftJson=json.serialize(neftWrapperList); 
System.debug('neftJson----->'+neftJson);
DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.type__c = 'NEFT Refund Paas Update';

Http h= new Http();
HttpRequest req = new HttpRequest();
HttpResponse res = new HttpResponse();
req = HttpRequestUtil.populateHeaders(req);
req.setHeader('Accept', 'application/json');
req.setHeader('Content-Type', 'application/json');
req.setEndpoint(endPoint);
req.setMethod('POST');
req.setBody(neftJson);
dbl.Request_Data__c = req+'..Body..'+neftJson;
res=h.send(req);
dbl.Response_Received__c = res+'..Resp Body..'+res.getBody();
System.debug('Response-->'+res.getBody());
insert dbl;

}  
}*/
    
    public class CaseNEFTWrapper{ 
        public String orderid; //PaasOrderId
        public String amount;  //RefundAMount
        public String custRefundsId;
        public AccountDetails accountDetails;
        public String salesForceCaseId;
        public String updatedBy;
        public String comments;
        public String pgtransactionid;
        public String tripId;
        public String emailId;
        public String tin;
        
        public CaseNEFTWrapper(Case cs,AccountDetails accountDetails){
            this.salesForceCaseId=cs.caseNumber;
            this.updatedBy=cs.LastModifiedBy.Name;
            this.comments= 'Closed'.equalsIgnoreCase(cs.status)?'NEFT Successful':cs.status;
            this.pgtransactionid=cs.PG_Ttransaction_Id__c;          
            this.emailId=cs.Email_Id_ct__c;
            this.tin=cs.TIN_No__c;
            this.orderid = cs.Paas_OrderId__c;
            this.amount = String.valueOf(cs.Refund_Amount__c);
            this.accountDetails=accountDetails; 
            this.accountDetails.accountNumber=cs.Account_Number__c;
            this.accountDetails.neftCode=cs.IFSC_Code__c;
            this.accountDetails.bankName=cs.Bank_Name__c;
            this.accountDetails.accountHolderName=cs.Account_Holder_Name__c;   
            
        }
    }
    
    public class accountDetails{
        public String accountNumber;
        public String neftCode;
        public String bankName;
        public String accountHolderName;        
    }
    
    
    
    // Validation - case comments are mandatory on case closure
    public static void ValidationCaseComment(set<Id> caseIds,Map<Id,Case> TriggerNewMap){
        
        List <Case> casesL= [SELECT Id, (SELECT id,createddate FROM CaseComments ORDER BY CreatedDate DESC LIMIT 1) FROM Case where id in:caseIds];
        for(Case c: casesL)
        {
            Case actualRecord = TriggerNewMap.get(c.Id);
            System.debug('caseL--->'+c);
            decimal decMinutes;
            if(c.CaseComments.size() > 0){
                DateTime ccLatest= c.CaseComments[0].createddate;
                decMinutes = ((System.now().getTime())/1000/60)-((ccLatest.getTime())/1000/60);
                System.debug('decMinutes 2--->'+decMinutes );
            }
            if(!Test.isRunningTest() && ( c.CaseComments.isEmpty() || decMinutes>=10)){
                actualRecord.addError('Please Create Case Comment before Closing the Case');
            }    
        }
        
    }
    
    // Validation - case comments are mandatory on case status changes to 'Rejected to BD team'
    public static void ValidationCaseComment2(set<Id> caseIds,Map<Id,Case> TriggerNewMap){
        
        List <Case> casesL= [SELECT Id,Business_Type__c,lastmodifiedbyid,ownerid, (SELECT id,lastmodifiedbyid,createddate,createdbyid FROM CaseComments ORDER BY CreatedDate DESC LIMIT 1) FROM Case where id in:caseIds];
        for(Case c: casesL)
        {
            Case actualRecord = TriggerNewMap.get(c.Id);
            
            if(!Test.isRunningTest() && c.CaseComments.isEmpty()){
                actualRecord.addError('Please Create Case Comment before changing the status');
            } 
            for(caseComment ccm:c.casecomments){
                if(!Test.isRunningTest() && c.lastmodifiedbyid!=ccm.lastmodifiedbyid){
                    if(c.Business_Type__c=='BusHire'){
                        actualRecord.addError('Please Create Case Comment before changing status Fulfillment');
                    }else{
                        actualRecord.addError('Please Create Case Comment');
                    }
                }
            }              
        }       
    }
    
    //Crediting amount to wallet 
    @future(callout=true)
    public static void WalletCreditApprove(List<id> walletCreditIds){
        List<Case> walletCreditList=new List<Case>();
        walletCreditList=[select id,Signed_In_UserId__c,Customer_Phone_Number__c,Customer_Email_ID__c,amount__c,Price_Paid_Currency_ctp__c from Case where id in:walletCreditIds limit 1];
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        for(case c:walletCreditList){
            gen.writeStartObject();
            string walletamount=string.valueof(c.amount__c);
            
            if(String.isNotBlank(c.Signed_In_UserId__c))     
                gen.writeStringField('userid',c.Signed_In_UserId__c);
            else
                gen.writeStringField('userid','');
            
            if(String.isNotBlank(c.Customer_Email_ID__c))     
                gen.writeStringField('emailId',c.Customer_Email_ID__c);
            else
                gen.writeStringField('emailId', '');
            if(String.isNotBlank(c.Customer_Phone_Number__c))     
                gen.writeStringField('phone',c.Customer_Phone_Number__c);
            else
                gen.writeStringField('phone', '');
            gen.writeStringField('amount', walletamount);
            gen.writeEndObject();
        }
        string countryHeader;
        String paidCurrency = walletCreditList[0].Price_Paid_Currency_ctp__c;
        if(paidCurrency.equalsIgnoreCase('INR')){
            countryHeader='IND';
        }else if(paidCurrency.contains('SG')){
            countryHeader='SGP';
        }else if(paidCurrency.contains('MY')){
            countryHeader='MYS';
        }
        else if(paidCurrency.contains('ID')){
            countryHeader='IDN';
        }
        else if(paidCurrency.contains('PEN')){
            countryHeader='PER';
        }
        else if(paidCurrency.contains('COP')){
            countryHeader='COL';
        }
        String walletJson= gen.getAsString();
        System.debug('walletJson-->'+walletJson);
        
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Wallet_Credit'].Endpoint__c;      
        string json45='{ "userId":"","amount": 1,"emailId" :"kadamba.t@gmail.com","phone": "7760471596"}';       
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        Http h= new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Country_Name', countryHeader);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(walletJson);
        CaseComment cc=new CaseComment();
        cc.parentid=walletCreditList[0].id;
        try{
            res=h.send(req);
            System.debug('Response-->'+res.getBody());
            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
            map<String,Object> statusMap= (map<string,object>)resMap.get('Status');
            
            
            if(string.valueof(statusMap.get('statusCode'))=='201'){
                
                cc.CommentBody='System Update- Case has been approved for wallet credit';
                walletCreditList[0].status='Closed';
            }else{
                walletCreditList[0].status='Open';
                cc.CommentBody='System Update- Wallet Credit has failed.Reason-'+resMap.get('ResponseMessage');
            }
            
            
            dbl.Type__c = 'Wallet Credit';
            // dbl.Payment_Request_Sent_Data__c=walletJson;
            // dbl.Payment_Request_Response_Data__c=res.getBody(); 
            dbl.Request_Data__c = walletJson;
            dbl.Response_Received__c = res.getBody(); 
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            insert cc;
            update walletCreditList;      
            insert dbl;
        }
        catch(Exception e){
            dbl.Type__c = 'Wallet Credit';
            walletCreditList[0].status='Open';
            // dbl.Payment_Request_Sent_Data__c=walletJson;
            // dbl.Payment_Request_Response_Data__c=res.getBody()+'<--Exception-->'+e;
            dbl.Request_Data__c = walletJson;
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.Response_Received__c = res.getBody()+'<--Exception-->'+e;
            cc.CommentBody='System Update- Exception In Wallet Credit.Exception-'+String.valueOf(e);
            if(cc.id!=null)
                update cc;
            else
                insert cc;
            update walletCreditList;        
            insert dbl;
        }
    }
    
    /* Count number of open cases and updates in Transaction level */
    public static void numberOfOpenCases(set<id> tIds){
        
        System.debug('Opne Cases Entered');
        List<order_items__c> oList=[select id, (select id from Cases__r where status NOT IN ('Closed','Rejected For Bus Cancellation') AND origin!='Failed Transaction') FROM order_items__c where id in: tIds FOR UPDATE];
        
        if(oList.size() > 0){
            for(order_items__c o: oList){
                o.no_of_open_cases__c = o.Cases__r.size();
            }
            
            update oList;     
        }
    }
    
    /*Mark whether Cases belogs to HF data or not */
    @future(callout=true)
    public static void HFData(set<id> cIds){
        
        List<case> caseList=new List<case>();
        caseList=[select id,Customer_Email_ID__c ,Customer_Phone_Number__c,Email_Id_ct__c,Phone_No_ct__c,Booking_Email_ID__c,Booking_Mobile_No__c from case where id in: cIds ];
        
        list<string> emails=new list<string>();
        list<string> mobile=new list<string>();
        
        for(case c:caseList){           
            
            if(string.isnotblank(c.Email_Id_ct__c))
                emails.add(c.Email_Id_ct__c);
            
            if(string.isnotblank(c.Phone_No_ct__c))
                mobile.add(c.Phone_No_ct__c);
            
            if(string.isnotblank(c.Booking_Email_ID__c))
                emails.add(c.Booking_Email_ID__c);
            
            if(string.isnotblank(c.Booking_Mobile_No__c))
                mobile.add(c.Booking_Mobile_No__c);
            
        }
        
        System.debug('emails-->'+emails+'<--Mobile-->'+mobile);        
        Set<string> hfEmailAndPhone=new Set<string>();          
        for(High_Frequency_Data__c s:[select id,phone__c,Email__c from High_Frequency_Data__c where email__c in :emails OR phone__c in:mobile]){
            hfEmailAndPhone.add(s.phone__c);
            hfEmailAndPhone.add(s.Email__c);        
        }
        
        List<case> caseUpdateList=new List<case>();
        for(case c2:caseList){
            if( hfEmailAndPhone.contains(c2.Email_Id_ct__c) || hfEmailAndPhone.contains(c2.Phone_No_ct__c) ||hfEmailAndPhone.contains(c2.Booking_Email_ID__c) || hfEmailAndPhone.contains(c2.Booking_Mobile_No__c))
                c2.hf__c=true;
            else
                c2.hf__c=false;
            
            caseUpdateList.add(c2);
        } 
        
        if(!caseUpdateList.isEmpty())
            update caseUpdateList;
        
    }
    
    
    //Create a Bus Cancellation Case for Co-Passsengers
    @future
    public static void createBusCCasesForCoPass(String jsonCase,String oldCaseJson)
    {
        Set<String> setRouteIds = new Set<String>();
        Set<DateTime> setDateTime = new Set<DateTime>();
        Set<String> setRouteDOJLong = new Set<String>();
        Set<Id> setCaseIds = new Set<Id>();
        
        List<Case> caseList=new List<Case>();
        Map<id,case> TriggerOld = new Map<id,case>();
        caselist= (List<Case>)JSON.deserializeStrict(jsonCase,List<Case>.class);
        TriggerOld = (Map<id,Case>)JSON.deserializeStrict(oldCaseJson,Map<id,Case>.class);
        System.debug('Trigger New.caselist.'+caselist);
        Map<string,string> orMap=new Map<string,string>();
        Map<string,Id> orCaseMap=new Map<string,Id>();
        
        for(Case cs : caselist)
        {
            System.debug('cs.Date_Of_Journey_New__c..'+cs.Date_Of_Journey_New__c);
            System.debug('..1...'+TriggerOld);
            
            if(cs.Type!='B2B' && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && ('Approved For Bus Cancellation'.equalsIgnoreCase(cs.Status)) && ( 'Rejected For Bus Cancellation'.equalsIgnoreCase(((Map<Id,Case>)TriggerOld).get(cs.Id).Status) || 'Initiated'.equalsIgnoreCase(((Map<Id,Case>)TriggerOld).get(cs.Id).Status) ) && (String.isNotBlank(cs.Route_Id__c) || String.isNotBlank(cs.SS_Route_Id__c)) && (cs.Date_Of_Journey_New__c!=null))
            { 
                String rId = String.isNotBlank(cs.Route_Id__c)?cs.Route_Id__c:cs.SS_Route_Id__c;
                setRouteIds.add(rId);
                setDateTime.add(cs.Date_Of_Journey_New__c);
                setRouteDOJLong.add(rId+String.valueOf(cs.Date_Of_Journey_New__c.getTime()));
                setCaseIds.add(cs.id);
                orMap.put(rId+String.valueOf(cs.Date_Of_Journey_New__c.getTime()),cs.origin);
                orCaseMap.put(rId+String.valueOf(cs.Date_Of_Journey_New__c.getTime()),cs.parentId);
            }
        }
        
        List<Case> listCasesToUpsert = new List<Case>();
        Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        System.debug('RecTypeId ...'+RecTypeId);
        String origin;
        case parentCase=new case();
        Id parentCaseId;
        
        for(Order_Items__c orItem :[SELECT Id, Route_Id__c, Date_Of_Service__c,Business_Unit__c,Order_Item_Reference_No__c,(SELECT id,origin,status from cases__r where Issue_Type__c='Bus Cancellation') FROM Order_Items__c where Route_Id__c IN :setRouteIds AND Transaction_Status__c='Booked' AND Flag__c=0 and Date_Of_Service__c IN :setDateTime])
        {
            String rIdDoj = orItem.Route_Id__c + String.valueOf(orItem.Date_Of_Service__c.getTime());
            if(orCaseMap.containsKey(rIdDoj) && orCaseMap.get(rIdDoj)!=null)
                parentCaseId=orCaseMap.get(rIdDoj);
            if(orMap.containsKey(rIdDoj) && orMap!=null)
                origin=orMap.get(rIdDoj);                         
            
            System.debug('rIdDoj....'+rIdDoj+'..'+orItem.cases__r.size()+'..'+orItem.id+'--Parent Id-->'+parentCase);          
            if(setRouteDOJLong.contains(rIdDoj) && orItem.cases__r.size()<=0)
            {
                Case cs = new Case();
                cs = caseMapper(RecTypeId);               
                cs.TIN_No__c = orItem.Order_Item_Reference_No__c;               
                cs.Transaction_ID__c = orItem.id;
                cs.country__c = OrderItemTransactionResource__c.getValues(orItem.Business_Unit__c).Case_Country__c;
                cs.origin=origin;
                if(parentCaseId!=null)
                    cs.ParentId=parentCaseId;
                
                cs.ownerid=UserInfo.getUserid();
                listCasesToUpsert.add(cs);
            }
            
            else if(setRouteDOJLong.contains(rIdDoj) && orItem.cases__r.size()>0)
            {
                for(Case c :orItem.cases__r)
                {
                    if(!setCaseIds.contains(c.id) && c.status!='Closed' && c.status!='Escalated to BD')
                    {
                        Case cs = new Case();
                        cs = caseMapper(RecTypeId); 
                        cs.id=c.id;
                        cs.Origin =c.origin;
                        cs.TIN_No__c = orItem.Order_Item_Reference_No__c;
                        if(parentCaseId!=null)
                            cs.ParentId=parentCaseId;
                        
                        listCasesToUpsert.add(cs);
                    }
                }
            }
            
        }
        
        System.debug('listCasesToUpsert...'+listCasesToUpsert);
        if(!listCasesToUpsert.isEmpty())
        {
            try
            {
                upsert listCasesToUpsert;
            }
            Catch(Exception e)
            {
                System.debug('Error in updateing Bus cancellation Co pass..'+e);
            }
        }   
    }
    
    Private Static Case caseMapper(Id recTpeId)
    {
        Case cs = new Case();
        cs.Status = 'Approved For Bus Cancellation';
        cs.RecordTypeId = recTpeId;
        cs.Issue_Type__c ='Bus Cancellation';
        cs.Origin ='InBound Call';
        cs.Approved_By__c = UserInfo.getName()+'('+UserInfo.getUserName()+')';
        cs.Approved_Rejected_Time__c = System.now();
        cs.Is_Secondary_SourceInfo__c = true;
        return cs;
    }
    
    //Text classification API invocation and Status Update
    /* @future(callout=true)
private static void textClassification(String jsonCase)
{
System.debug('textClassification..'+jsonCase);
List<Case> caselist= (List<Case>)JSON.deserializeStrict(jsonCase,List<Case>.class);
List<case> listUpdateCases = new List<Case>();
Http ht = new Http();
HttpRequest req = new HttpRequest();
req.setHeader('Content-Type','application/json');
req.setMethod('POST');
API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='TextClassifier'];
req.setEndpoint(APIMData.Endpoint__c);

if(APIMData.EnableLog__c)
{
for(Case c:caselist)
{
HttpResponse resp = new HttpResponse();
String jsonbody = c.Description;
jsonbody = jsonbody.replaceAll('\n', '\\\\n');
String finalJsonBody = '{"docID":'+c.CaseNumber+',"txtForClassfication":'+JSON.serialize(jsonbody)+'}';
req.setBody(finalJsonBody);

try
{
resp = ht.send(req);
if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null)
{
Case cs = new Case(Id=c.id);
String resBody = resp.getBody();
System.debug('resBody..'+resBody);
map<string,object> tickDetails = (map<string,object>)JSON.deserializeUntyped(resBody);
String issType = (String)tickDetails.get('predicted_class'); 
cs.Issue_Type__c = 'Unclassified'.equalsIgnoreCase(issType)?'':issType;
cs.Is_ML_Processed__c = True;
listUpdateCases.add(cs);
}

else
System.debug('Invalid Respone..'+resp+'Body..'+resp.getBody());

}

Catch(Exception e){ 
System.debug('Error while making an Api call'+e);
}
}

try
{
if(!listUpdateCases.isEmpty())
DataBase.update(listUpdateCases,false);
}

Catch(Exception e)
{
System.debug('Error while updating the cases Isssue Type'+e);
}
}

}

public static void updatedBDIds(List<case> TriggerNew){
//case cObj=[select id,description,Send_Notification__c from case where id in:sIds];
Group smg=[Select Id from Group where name='Social Media Queue' limit 1]; 
Group hg=[Select Id from Group where name='HF Queue' limit 1];   
Group bg=[Select Id from Group where name='Bus Cancellation Queue' limit 1];
Group sig=[Select Id from Group where name='SIT Cases Queue' limit 1];  
for(case c:TriggerNew){
if(c.Issue_Type__c=='Bus Cancellation')
c.First_Assigned_Owner_Id__c=string.valueOf(bg.id);
else if(c.Origin=='Facebook' || c.Origin=='Twitter')
c.First_Assigned_Owner_Id__c=string.valueOf(smg.id);
else if(c.hf__c==true)
c.First_Assigned_Owner_Id__c=string.valueOf(hg.id);
else
c.First_Assigned_Owner_Id__c=string.valueOf(sig.id);      

}    
} 
*/
    
    public static void assignToSameAgent(Set<String> setAgentsName,List<Case> TriggerNew)
    {
        Map<String,Id> mapUserNameToId = new Map<String,Id>();
        
        for(User u:[Select id,name from User Where Name IN:setAgentsName And IsActive=True])
            mapUserNameToId.put(u.name,u.id);
        
        Id inactiveAgentsQueueId = [Select Id from Group where developername='Re_Opened_In_Active_Agents_Cases'].id; 
        for(Case cs:TriggerNew)
        {
            if(mapUserNameToId.containsKey(cs.Closed_By_Agent__c))
                cs.OwnerId = mapUserNameToId.get(cs.Closed_By_Agent__c);
            else
                cs.OwnerId = inactiveAgentsQueueId;
            
        }
    }
    
    public static void EnableRPWcases(Set<id> rpwId)
    {
        List <Case> caseLst=[select id,Service_Providerr_Id__c,Service_Provider_Id__c,RPW_Case__c from case where id=:rpwId];
        List <Case> updatecaseLst = new List <Case> ();
        for(Case cs:caseLst)
        {
            cs.RPW_Case__c=false;
            updatecaseLst.add(cs); 
            
        }
        if(!updatecaseLst.isEmpty()){
            update updatecaseLst;
        }
    }
    
    // Validation - case comments are mandatory on case closure
    public static void ValidationSendNotification(set<Id> caseIds,Map<Id,Case> TriggerNewMap){
        
        List <Case> casesL= [SELECT Id,description,Send_Notification__c, (SELECT id,createddate FROM CaseComments ORDER BY CreatedDate DESC LIMIT 1) FROM Case where id in:caseIds];
        for(Case c: casesL)
        {
            Case actualRecord = TriggerNewMap.get(c.Id);
            System.debug('descript sen-->'+actualRecord.description);
            
            if(!Test.isRunningTest() && actualRecord.send_notification__c=='Description Only' && actualRecord.Description==null){
                actualRecord.addError('Please enter the description to send notification');
            }            
            if(!Test.isRunningTest() &&  c.CaseComments.size() <= 0 && actualRecord.send_notification__c=='CaseComment Only'){
                actualRecord.addError('Please enter the case comment to send notification');
            } 
            if(!Test.isRunningTest() && ( c.CaseComments.size() <= 0 || actualRecord.Description==null) && actualRecord.send_notification__c=='Both (Description&CaseComment)'){
                actualRecord.addError('Please enter the Case comment/Description to send notification');
            }               
        }
        
    }
    
    //Send SMS & Whatsapp notification to customer on case update and closure (API doesn't support for bulk notifications hence taking single case at a time)
    @future(callout=true)
    public static void sendNotification(set<id> sIds)
    {
        case cObj=[select Account.Name,casenumber,id,status,description,Issue_Type__c,Send_Notification__c,Booking_Mobile_No__c,Phone_No_ct__c,(select id,commentbody from casecomments ORDER BY CreatedDate DESC LIMIT 1) from case where id in: sIds limit 1];
        try{
            if(cObj!=null ){
                string description;
                string mobile;
                System.debug('bookingMob-->'+cObj.Booking_Mobile_No__c);
                if(cObj.Booking_Mobile_No__c!=null){
                    mobile=cObj.Booking_Mobile_No__c;
                    mobile=mobile.replace('(','');
                    mobile=mobile.replace(')','');
                    mobile=mobile.replace('-','');
                    mobile=mobile.replace(' ','');
                }
                else{
                    mobile=cObj.Phone_No_ct__c;
                }
                If (mobile!=null){
                    
                    if(mobile.length()==10){
                        mobile='91'+mobile;
                    }
                    
                    if(cObj.Send_Notification__c=='Description Only')
                        description=cObj.description;
                    else if(cObj.Send_Notification__c=='CaseComment Only' && cObj.casecomments.size()>0)
                        description=cObj.casecomments[0].commentbody;
                    else if(cObj.Send_Notification__c=='Both (Description&CaseComment)' && cObj.casecomments.size()>0)
                        description=cObj.description +'-'+cObj.casecomments[0].commentbody;
                    
                    // string fromatedDescription='{\"Description\":\"'+description+'\",\"Amount\":\"424.0\"}';
                    //  string fromatedDescription='{"Description":"'+description+'","Amount":"424.0"}';
                    
                    string customerName;
                    if(cObj.Account.Name==null){
                        customerName='';
                    }else{
                        customerName=cObj.Account.Name;
                    }                    
                    
                    Map<String, String> headers = new Map<String, String>();
                    headers.put('Content-Type','application/json');
                    headers.put('Channel_Name','MOBILE_WEB');
                    headers.put('Country_Name','IND');
                    headers.put('BusinessUnit','BUS');
                    headers.put('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
                    list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                    for(string o:headers.keyset()){
                        //maxKey = counts.get(s1)>counts.get(maxKey)?s1:maxKey;
                        System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                        hlist.add(new HeadersWrapper(o,headers.get(o))); 
                    }
                    String headerJson=json.serialize(hlist); 
                    String headerJson2=json.serialize(headerJson);           
                    
                    DBLog_Summary__c dbl = new DBLog_Summary__c();
                    DBLog_Summary__c dbl2 = new DBLog_Summary__c();
                    API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                    //Send notification on Case update
                    if(cObj.status!='Closed'){
                        string fromatedDescription='{"customerName":"'+customerName+'","caseNumber":"'+cObj.casenumber+'","description":"'+description+'"}';
                        SendNotificationWrapper sn=new SendNotificationWrapper(fromatedDescription,mobile,'CaseUpdate_WHATSAPP');            
                        System.debug('jsonBody-->'+JSON.serialize(sn));
                        String jsonBody=JSON.serialize(sn);
                        String feds=JSON.serialize(jsonBody);
                        
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification'];
                        string jsonCM='{"action":"Post","body":'+feds+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
                        Http ht = new Http();
                        HttpRequest req = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        req.setHeader('Channel_Name','WEB_DIRECT');
                        req.setHeader('Content-Type','application/json');
                        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                        req.setHeader('Country_Name', 'IND'); 
                        req.setHeader('BusinessUnit', 'BUS');  
                        req.setHeader('Language', 'en');             
                        req.setMethod('POST');
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
                        req.setEndpoint(APIMData.Endpoint__c);
                        req.setBody(jsonCM);
                        resp = ht.send(req);
                        System.debug('wp resp-->'+resp.getBody());
                        dbl.Request_Data__c=req.getbody();
                        dbl.Type__c='Whatsapp Notification - Update';
                        if(resp!=null){
                            dbl.Response_Received__c=resp.getbody();
                        }
                        
                        RequestWrapper.SendNotificationWrapper smsJ=new RequestWrapper.SendNotificationWrapper(mobile,fromatedDescription,'CaseUpdate_SMS','',true);
                        String smsJsonBody=JSON.serialize(smsJ);
                        System.debug('smsJsonBody-->'+smsJsonBody);
                        Http ht2 = new Http();
                        HttpRequest req2 = new HttpRequest();
                        HttpResponse resp2 = new HttpResponse();
                        req2.setHeader('Channel_Name','WEB_DIRECT');
                        req2.setHeader('Content-Type','application/json');
                        req2.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                        req2.setHeader('Country_Name', 'IND'); 
                        req2.setHeader('BusinessUnit', 'BUS');  
                        req2.setHeader('Language', 'en');             
                        req2.setMethod('POST');
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'];
                        req2.setEndpoint(APIMData.Endpoint__c);
                        req2.setBody(smsJsonBody);
                        resp2 = ht2.send(req2);
                        System.debug('sms resp-->'+resp2.getBody());
                        dbl2.Request_Data__c=req2.getbody();
                        dbl2.Type__c='SMS Notification - Update';
                        if(resp2!=null){
                            dbl2.Response_Received__c=resp2.getbody();
                        }
                        insert dbl;
                        insert dbl2;
                    }
                    //Send notification on Case closure - Sending SMS on closure(Can be enable in future if required)
                    /*  else{
APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CaseFeedback'];
string urlBody='url='+APIMData.Endpoint__c+cObj.id+',cD='+System.now();
string feedbackLink;
string fromatedDescription='{"customerName":"'+customerName+'","caseNumber":"'+cObj.casenumber+'","issueType":"'+cObj.Issue_Type__c+'","feedbackLink":"'+feedbackLink+'"}';

APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Shorten'];
Http ht1 = new Http();
HttpRequest req1 = new HttpRequest();
HttpResponse resp1 = new HttpResponse();                                   
req1.setMethod('POST');                  
req1.setBody(urlBody);
req1.setendpoint(APIMData.Endpoint__c);
resp1=ht1.send(req1);
map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(resp1.getbody());
map<string,object> resObj1=(map<string,object>)resObj.get('data');
string feedbackLink='https://s.redbus.com/'+resObj1.get('short');    

string fromatedDescription='{"customerName":"'+customerName+'","caseNumber":"'+cObj.casenumber+'","issueType":"'+cObj.Issue_Type__c+'","feedbackLink":"'+feedbackLink+'"}';
SendNotificationWrapper sn=new SendNotificationWrapper(fromatedDescription,mobile,'CaseClosed_WHATSAPP');            
System.debug('jsonBody-->'+JSON.serialize(sn));
String jsonBody=JSON.serialize(sn);
String feds=JSON.serialize(jsonBody);

APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification'];
string jsonCM='{"action":"Post","body":'+feds+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
System.debug('jsonCM-->'+jsonCM);
Http ht = new Http();
HttpRequest req = new HttpRequest();
HttpResponse resp = new HttpResponse();
req.setHeader('Channel_Name','WEB_DIRECT');
req.setHeader('Content-Type','application/json');
req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
req.setHeader('Country_Name', 'IND'); 
req.setHeader('BusinessUnit', 'BUS');  
req.setHeader('Language', 'en');             
req.setMethod('POST');
APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
req.setEndpoint(APIMData.Endpoint__c);
req.setBody(jsonCM);
resp = ht.send(req);
System.debug('wp resp-->'+resp.getBody());
dbl.Request_Data__c=req.getbody();
dbl.Type__c='Whatsapp Notification - Closure';
if(resp!=null){
dbl.Response_Received__c=resp.getbody();
}

RequestWrapper.SendNotificationWrapper smsJ=new RequestWrapper.SendNotificationWrapper(mobile,fromatedDescription,'CaseClosed_SMS');
String smsJsonBody=JSON.serialize(smsJ);
System.debug('smsJsonBody-->'+smsJsonBody);
Http ht2 = new Http();
HttpRequest req2 = new HttpRequest();
HttpResponse resp2 = new HttpResponse();
req2.setHeader('Channel_Name','WEB_DIRECT');
req2.setHeader('Content-Type','application/json');
req2.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
req2.setHeader('Country_Name', 'IND'); 
req2.setHeader('BusinessUnit', 'BUS');  
req2.setHeader('Language', 'en');             
req2.setMethod('POST');
APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'];
req2.setEndpoint(APIMData.Endpoint__c);
req2.setBody(smsJsonBody);
resp2 = ht2.send(req2);
System.debug('sms resp-->'+resp2.getBody());
dbl2.Request_Data__c=req2.getbody();
dbl2.Type__c='SMS Notification - Closure';
if(resp2!=null){
dbl2.Response_Received__c=resp2.getbody();
}
//insert dbl;
insert dbl2;
}*/
                }   
            }
        }catch(Exception e){
            DBLog_Summary__c dbl3 = new DBLog_Summary__c();
            dbl3.Exception_Description__c=string.valueof(e);
            dbl3.Type__c='Closure Notification';
            insert dbl3;
            
        }
    }
    
    public class SendNotificationWrapper{
        public string data_params;
        public List<string> channels=new List<string>{'whatsapp'};
            public string name;
        public AttachmentDetails AttachmentDetails=new AttachmentDetails();
        public address address=new address();
        public MessageDetails MessageDetails=new MessageDetails();
        public SendNotificationWrapper(string description,string mobileNo,string templateName ){
            this.address.whatsapp_number=mobileNo;
            this.MessageDetails.DataJsonStr=description;
            this.MessageDetails.TemplateName=templateName;
            
        }
    }
    public class AttachmentDetails{}
    public class address{
        public string whatsapp_number;
        public string links;
    }
    public class MessageDetails{
        public string TemplateName;
        public string DataJsonStr;
        public integer DataComplexity=2;
        public string Language='en';
        public string tin;
        
    }
    public class HeadersWrapper{       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    /*
@future(callout=true)
private static void asynccasePrioritizationScore(String jsonCase)
{
System.debug('inside.asynccasePrioritizationScore.'+jsonCase);
casePrioritizationScore(jsonCase);
}*/
    /*
private static void casePrioritizationScore(String jsonCase)
{
System.debug('Case Priority Logic..'+jsonCase);
List<Case> caselist= (List<Case>)JSON.deserializeStrict(jsonCase,List<Case>.class);
List<case> listUpdateCases = new List<Case>();
API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Ether'];

if(APIMData.EnableLog__c)
{
API_EndPoints__mdt genericAPI=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
List<DBLog_Summary__c> listdbl = new List<DBLog_Summary__c>();
for(Case c:caselist)
{
DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.Type__c = 'Ether NLP';

HttpResponse resp = new HttpResponse();
string mobileNum = String.isBlank(c.Booking_Mobile_No__c)?String.isBlank(c.Phone_No_ct__c)?'':c.Phone_No_ct__c:c.Booking_Mobile_No__c;
String jsonbody = String.isNotBlank(c.Description)?c.Description:'';
if(String.isNotBlank(jsonbody))
jsonbody = jsonbody.replaceAll('\n', '\\\\n').normalizeSpace().replaceAll('[().,-/&\'\"]','');
String subject =String.isNotBlank(c.Subject)?c.Subject.normalizeSpace().replaceAll('[().,-/&\'\"]',''):'';
String subType = String.isNotBlank(c.Issue_Sub_Category__c)?c.Issue_Sub_Category__c.replaceAll('[().,-/&\'\"]',''):'';
String finalJsonBody = '{"SFData":{"Case.Number":"'+c.CaseNumber+'","Booking.Mobile.No":"'+mobileNum+'","Case.Origin":"'+c.Origin+'","Subject":"'+subject+'","Description":'+JSON.serialize(jsonbody)+',"TIN":"'+c.TIN_No__c+'","Issue.Type":"'+c.Issue_Type__c+'","Issue.Sub.Category":"'+subType+'","Punctuality":"","BusQuality":"","Staffbehavior":"","Score":""}}';
System.debug('Priority Json...'+finalJsonBody+'..seria..');                
String finBody = finalJsonBody.replaceAll('null','');
System.debug('finBody ...'+finBody);

// string jsonCM='{"action":"Post","body":'+finBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":{\"Content-Type\":\"application/json\"}}';
string jsonCM='{"action":"Post","body":'+JSON.serialize(finBody)+',"endPoint":"'+APIMData.Endpoint__c+'","headers":"[{\\"value\\":\\"application/json\\",\\"key\\":\\"Content-Type\\"}]"}';

try
{

HttpRequest req = new HttpRequest();
req = HttpRequestUtil.populateHeaders(req);
Http ht = new Http();
req.setMethod('POST');
req.setTimeout(120000);                     
req.setEndpoint(genericAPI.Endpoint__c);
System.debug('jsonCM..'+jsonCM);
req.setBody(jsonCM);
dbl.Payment_Request_Sent_Time__c = system.now();
dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'Request Body.'+jsonCM;
dbl.SentAt__c = system.now();
dbl.Order_Items_Data_Received_Ids__c = String.valueOf(c.CaseNumber);

resp = ht.send(req);
dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'..Body..'+resp.getBody());
dbl.Payment_Request_Response_Time__c = System.now();


if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null)
{
dbl.Payment_Ping_Status__c = 'Ether NLP Ping Success';
Case cs = new Case(Id=c.id);
cs.Is_ML_Processed__c = True;                       
String resBody = resp.getBody();
System.debug('resBody..'+resBody);
map<string,object> tickDetails = (map<string,object>)JSON.deserializeUntyped(resBody);
String score = (String)tickDetails.get('Score');
System.debug('Score value..'+score);
if(String.isNotBlank(score))
cs.Priority_Score__c = score;
listUpdateCases.add(cs);
}

else
{
System.debug('Invalid Respone..'+resp+'Body..'+resp.getBody());
dbl.Payment_Ping_Status__c = 'Ether NLP Ping Failed';
}

}

Catch(Exception e){ 
System.debug('Error while making an Api call'+e);
dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());
dbl.Payment_Ping_Status__c = 'Ether NLP Ping Error';           
}
listdbl.add(dbl);
}


try
{

if(!listUpdateCases.isEmpty())                
DataBase.update(listUpdateCases,false);
insert listdbl;
}

Catch(Exception e)
{
System.debug('Error while updating the cases Isssue Type'+e);
}

}
}*/
    
    /* @future(callout=true)
private static void sendNEFTRefundNotification(String neftRefundCases)
{
List<DBLog_Summary__c> listDblog = new List<DBLog_Summary__c>();
Map<String,String> mapBUToSenEMail= new Map<String,String>();
for(OrderItemTransactionResource__c res :OrderItemTransactionResource__c.getall().values())
{
if(res.Name.contains('REDBUS_'))
mapBUToSenEMail.put(res.Name.right(3),res.SenderEmail__c);
}
List<Case> caselist= (List<Case>)JSON.deserializeStrict(neftRefundCases,List<Case>.class);

for(Case c:caselist)
{
DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.type__c ='Send NEFT Link For Skip Case';
String tin =String.isNotBlank(c.TIN__c)?c.TIN__c:String.isBlank(c.TIN_No__c)?'':c.TIN_No__c;

String tripId = String.isBlank(c.Trip_ID__c)?c.Trip_Id_ct__c:c.Trip_ID__c;
String emailId = String.isBlank(c.Booking_EMail_Copy__c)?c.Email_Id_ct__c:c.Booking_EMail_Copy__c;
String busiUnit = String.isBlank(c.Transaction_Business_Type__c)?c.Business_Unit_ct__c:c.Transaction_Business_Type__c;
Http ht = new http();
HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
HttpResponse resp = new HttpResponse();
req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Encryption'].Endpoint__c+tin+'&tripId='+tripId+'&pullFromNeon=false&orderItemUUID=&businessUnit='+busiUnit);
req.setMethod('GET');

try
{
dbl.Request_Data__c = String.valueOf(req);
resp=ht.send(req);

if(resp.getStatus() =='OK' && resp.getStatusCode() ==200 && String.isNotBlank(resp.getBody()))
{
string neftUrl = String.valueOf(resp.getBody());
neftUrl= neftUrl.removeStart('"').removeEnd('"');
Set<String> setNonWhiteLabelBUs = new Set<String>(System.label.NonWhiteLabelBUs.split(','));
if(!setNonWhiteLabelBUs.contains(busiUnit)){
String repUrl= neftUrl.replace('Refund/Refund','neftskip/Refund');
neftUrl = repUrl+'&BU='+busiUnit;
}

dbl.Response_Received__c = resp+'--Neft URL--'+resp.getBody();
String encodedUrl = EncodingUtil.urlEncode(neftUrl,'UTF-8');
string urlBody='url='+encodedUrl+',cD='+System.now();

Http shrtHt = new Http();
HttpRequest shrtReq = new HttpRequest();
HttpResponse shrtResp = new HttpResponse();                                   
shrtReq.setMethod('POST');                  
shrtReq.setBody(urlBody);
shrtReq.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Shorten'].Endpoint__c);
shrtResp=shrtHt.send(shrtReq);
dbl.Complaint_Tracker_Body_Received__c= 'Request..'+shrtReq+'..'+urlBody+'..Response..'+shrtResp.getbody();
map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(shrtResp.getbody());
map<string,object> resObj1=(map<string,object>)resObj.get('data');
string shortenURL='https://s.redbus.com/'+resObj1.get('short');    

HttpRequestWrappersUtil.SendSMSEMailReqWrapper emailReq = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
emailReq.type= new List<String>{'emaildata','smsdata'};
String refundAmount = String.isBlank(c.Price_Paid_Currency_ctp__c)?c.Total_Ticket_Amount__c.replace('INR','RS'):c.Price_Paid_Currency_ctp__c.replace('INR','RS')+' '+c.Refund_Amount__c;
string bodyText = '{"refundAmount":"'+refundAmount+'","refundLink":"'+shortenURL+'"}';                    
emailReq.emaildata = HttpRequestUtil.prepareEmailReqData('NEFT_Email',bodyText,'',refundAmount+' Refund Pending from Redbus',mapBUToSenEMail.get(busiUnit.right(3)),emailId,'','RedBus Support','en','en',true);
System.debug('emailReq..'+emailReq);

Http htEmail = new http();
HttpRequest emReq = HttpRequestUtil.populateCAPIHeaders(new HttpRequest());
HttpResponse emresp = new HttpResponse();
emReq.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'].Endpoint__c);
emReq.setBody(Json.serialize(emailReq));
emReq.setMethod('POST');
dbl.Payment_Request_Sent_Data__c =String.valueOf(emReq)+'..ReqBody'+String.valueOf(emailReq);
emresp = htEmail.send(emReq);
dbl.Payment_Request_Response_Data__c = String.valueOf(emresp);
dbl.Payment_Request_Response_Data__c = dbl.Payment_Request_Response_Data__c+'.Email Body..'+emresp.getBody();

}
}
catch(Exception e)
{
system.debug('Error in sending neft link..'+e);
dbl.Exception_Description__c = String.valueOf(e);
}
listDblog.add(dbl);
}
insert listDblog;
}*/
    
    /*---Used for crediting amount to the customer wallet if case is not resolved with in TAT. Program Name: redCare
--> Refer DB Log Summary Object to get logs 
-> Check UserId/WalletId exist or not, Refer follow fields 
1. Request_Data__c
2. Response_Received__c
3. Exception_Description__c (For any exception)

-> Check Amount is credited or not, Refer follow fields
1. Payment_Request_Sent_Data__c
2. Payment_Request_Response_Data__c
3. Complaint_Tracker_Error__c (For any exception)
*/     
    @future(callout=true)
    public static void redCare_WalletCredit(List<id> caseIds,List<string> caseTins,string callout){
        System.debug('Calling redC');
        List<Case> caseList=new List<Case>();
        List<case> caseUpList=new List<case>();
        List<DBLog_Summary__c> dbsList = new list<DBLog_Summary__c>();
        if(System.Label.redCare=='TRUE'){       
            caseList=[select id,TIN_No__c,Service_Provider_Id__c,Trip_Id_ct__c,Transaction_ID__r.Mobile__c,Transaction_ID__r.Customer_Name__r.PersonMobilePhone,casenumber,redCare_Status__c,Phone_No_ct__c,Closure_Delay__c,redCare_Amount__c,redCare_Amount_Credited__c,Transaction_ID__c,Signed_In_UserId__c,Customer_Phone_Number__c,Customer_Email_ID__c,amount__c,Price_Paid_Currency_ctp__c,First_Closure__c,Expected_Closure_Time__c from Case where id in:caseIds and redCare_Multiple__c=false and redCare_Amount__c!=null and redCare_Status__c!='T_Amount is Credited' AND redCare_Status__c!='S_Amount is Credited' AND Transaction_ID__r.Business_Unit__c='REDBUS_IN' AND redCare_Status__c!='Wallet/User Id does not exist' AND redCare_Status__c!='Wallet is not Active' AND redCare_Status__c!='S_Wallet/User Id does not exist' AND redCare_Status__c!='S_Wallet is not Active' AND Email_Id_ct__c='nilika.haldar@redbus.com' limit 48];       
        }else{
            caseList=[select id,TIN_No__c,Service_Provider_Id__c,Trip_Id_ct__c,Transaction_ID__r.Mobile__c,Transaction_ID__r.Customer_Name__r.PersonMobilePhone,casenumber,redCare_Status__c,Phone_No_ct__c,Closure_Delay__c,redCare_Amount__c,redCare_Amount_Credited__c,Transaction_ID__c,Signed_In_UserId__c,Customer_Phone_Number__c,Customer_Email_ID__c,amount__c,Price_Paid_Currency_ctp__c,First_Closure__c,Expected_Closure_Time__c from Case where id in:caseIds and redCare_Multiple__c=false and redCare_Amount__c!=null and redCare_Status__c!='T_Amount is Credited' AND redCare_Status__c!='S_Amount is Credited' AND redCare_Status__c!='T_Wallet/User Id does not exist' AND redCare_Status__c!='T_Wallet is not Active' AND redCare_Status__c!='S_Wallet/User Id does not exist' AND redCare_Status__c!='S_Wallet is not Active' AND Transaction_ID__r.Business_Unit__c='REDBUS_IN' AND Service_Provider_Id__c NOT IN:rtcBOIds order by Closure_Delay__c asc limit 48];       
        }
        
        List<case> cLst=new List<case>();
        cLst=[select id,Tin_No__c,Trip_Id_ct__c from case where Trip_Id_ct__c in:caseTins and (redcare_status__c='T_Amount is Credited' or redcare_status__c='S_Amount is Credited')];
        Map<string,case> caseMap=new Map<string,case>();
        for(case c:cLst){
            if(c.Trip_Id_ct__c!=null)
                caseMap.put(c.Trip_Id_ct__c,c);
        }
        
        System.debug('case Map-->'+caseMap);
        String WalletStatusCheckEndpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='WalletStatusCheck'].Endpoint__c;
        String walletCreditEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Wallet_Credit'].Endpoint__c;      
        System.debug('caseList-->'+caseList);        
        set<string> credTrans=new set<string>();        
        
        string mobile; 
        
        DBLog_Summary__c dbforExp=new DBLog_Summary__c();
        try{
            for(case caseObj:caseList){            
                System.debug('caseMap-->'+caseMap.get(caseObj.Trip_Id_ct__c));                       
                mobile=caseObj.Transaction_ID__r.Customer_Name__r.PersonMobilePhone;
                System.debug('mobile C-->'+mobile);           
                
                if(mobile==null || mobile=='')
                    mobile=caseObj.Phone_No_ct__c;
                
                if(mobile==null || mobile=='')
                    mobile=caseObj.Transaction_ID__r.Mobile__c;
                
                if(mobile!='' && mobile!=null){
                    //removing mobile number format
                    mobile = mobile.replaceAll('\\D','');
                }
                system.debug('<<<phone'+mobile);
                if(mobile!='' && mobile!=null && mobile.length()>9 && caseMap.get(caseObj.Trip_Id_ct__c)==null && (caseObj.Closure_Delay__c>0 || callout=='S_') && !credTrans.contains(caseObj.Trip_Id_ct__c) && !rtcBOIds.contains(caseObj.Service_Provider_Id__c)){
                    credTrans.add(caseObj.Trip_Id_ct__c);               
                    
                    DBLog_Summary__c dbl = new DBLog_Summary__c();
                    dbl.Type__c = 'redCare';
                    dbl.Case_Number__c=caseObj.casenumber;
                    dbl.Phone_no__c=mobile;
                    dbl.Payment_Transaction_Name__c  =caseObj.Transaction_ID__c;
                    
                    string jsonbody = '{"phone":"'+mobile+'"}';
                    string loggedInUserId;
                    boolean walletActive=true;
                    if (Test.isRunningTest())
                        loggedInUserId='12345';
                    
                    Http http = new Http();
                    HttpResponse res = new HttpResponse();       
                    HttpRequest req = new HttpRequest();
                    req = HttpRequestUtil.populateHeaders(req);
                    req.setBody(jsonbody);
                    req.setMethod('POST');        
                    req.setEndpoint(WalletStatusCheckEndpoint);
                    DB_Log__c dbLog=new DB_Log__c();
                    dbl.Request_Data__c=string.valueof(req.getbody());
                    try{
                        res = http.send(req);
                        if(res!=null && res.getStatusCode()==200 && String.isNotBlank(res.getBody()))
                        {
                            dbl.Response_Received__c=string.valueof(res.getbody());
                            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                            map<String,Object> statusMap= (map<string,object>)resMap.get('Status');
                            string data= (string)resMap.get('Data');
                            String statusCode=string.valueof(statusMap.get('code'));
                            
                            
                            if(String.isNotBlank(data))
                            {
                                map<String,Object> dataMap= (map<string,object>)JSON.deserializeUntyped(data);
                                if(dataMap.containsKey('UserId') && dataMap.get('UserId')!=null)
                                {
                                    loggedInUserId=string.valueof(dataMap.get('UserId'));
                                    caseObj.Signed_In_UserId__c=loggedInUserId;
                                    dbl.user_id__c=loggedInUserId;
                                }                 
                            }
                            if(statusCode =='200'){
                                caseObj.redCare_Status__c='User id Exist';
                            }               
                            else if(statusCode =='201'){
                                caseObj.redCare_Status__c='Wallet is not Active';
                                walletActive=false;                   
                            }
                            else if(statusCode=='400')
                            {
                                caseObj.redCare_Status__c='Wallet/User Id does not exist';                    
                            }   
                        }else{
                            if(string.valueof(res).length()>25000)
                                dbl.Response_Received__c=string.valueof(res).substring(0,24999);
                            else
                                dbl.Response_Received__c=string.valueof(res);
                            caseObj.redCare_Status__c='WS API NULL';
                        }
                    }catch(Exception e){
                        caseObj.redCare_Status__c='WS API Failed';
                        dbl.Exception_Description__c=string.valueof(e);
                    }
                    DB_Log__c dbLog2=new DB_Log__c();
                    if(loggedInUserId!=null && walletActive && System.Label.redCare_Credit_Check=='TRUE'){
                        string s= string.valueOf(caseObj.Closure_Delay__c).SubStringBefore('.');
                        integer cdelay=integer.valueof(s)+1;              
                        
                        System.debug('Closure D T-->'+cdelay);
                        //Calculating amount - Delay of case closure * redCare amount of corresponding issue type
                        decimal amount=cdelay*caseObj.redCare_Amount__c;
                        if(amount>decimal.valueof(System.Label.redCare_Amount_Limit))
                            amount=decimal.valueof(System.Label.redCare_Amount_Limit);
                        
                        
                        JSONGenerator gen = JSON.createGenerator(true);                
                        gen.writeStartObject();             
                        gen.writeStringField('userid',loggedInUserId);
                        gen.writeNumberField('amount', amount);
                        gen.writeEndObject();
                        
                        string countryHeader='IND';
                        String walletJson= gen.getAsString();
                        Http h= new Http();
                        HttpRequest reqs = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        reqs = HttpRequestUtil.populateHeaders(req);
                        reqs.setHeader('Accept', 'application/json');
                        reqs.setHeader('Country_Name', countryHeader);
                        reqs.setEndpoint(walletCreditEndPoint );
                        reqs.setMethod('POST');
                        reqs.setBody(walletJson);  
                        dbl.Request_Data__c=string.valueof(reqs.getbody());
                        dbl.EndPoint__c = String.valueOf(reqs.getEndpoint());
                        try{
                            resp=h.send(reqs);
                            dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
                            if(resp!=null && resp.getStatusCode()==200 && String.isNotBlank(resp.getBody())){
                                dbl.Response_Received__c=string.valueof(resp.getbody());
                                System.debug('Response-->'+resp.getBody());
                                map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
                                map<String,Object> statusMap= (map<string,object>)resMap.get('Status');
                                
                                if(string.valueof(statusMap.get('statusCode'))=='201'){               
                                    caseObj.redCare_Status__c='Amount is Credited';
                                    caseObj.redCare_Amount_Credited_Date_Time__c=system.now();
                                    caseObj.redCare_Amount_Credited__c=amount;
                                }else{
                                    caseObj.redCare_Status__c='User Id exist but Amount is not credited';
                                }
                                
                            }else{
                                if(string.valueof(resp).length()>10000)
                                    dbl.Response_Received__c=string.valueof(resp).substring(0,9999);
                                else
                                    dbl.Response_Received__c=string.valueof(resp);
                                caseObj.redCare_Status__c='WC API NULL';
                            }
                        }
                        catch(Exception e){
                            caseObj.redCare_Status__c='WC API Failed';
                            dbl.Complaint_Tracker_Error__c=string.valueof(e); 
                        }
                    }
                    caseObj.redCare_Status__c=callout+caseObj.redCare_Status__c;           
                    
                    caseUpList.add(caseObj);
                    dbsList.add(dbl);                          
                }else if(caseMap.get(caseObj.Trip_Id_ct__c)!=null || credTrans.contains(caseObj.Trip_Id_ct__c)){
                    caseObj.redCare_Multiple__c=true;
                    caseUpList.add(caseObj);                    
                }
            }
        }catch(Exception e){
            dbforExp.type__c='redCare For failed';
            dbforExp.Exception_Description__c=string.valueof(e);
            database.insert(dbforExp);
        }
        
        
        if(!caseUpList.isEmpty())
        {            
            list<DBLog_Summary__c> lsDbSuc=new list<DBLog_Summary__c>();
            list<DBLog_Summary__c> lsDbExp=new list<DBLog_Summary__c>();
            
            try
            {            
                Database.SaveResult[] srList = Database.update(caseUpList, false);
                
                for (Database.SaveResult sr : srList) {
                    
                    if (sr.isSuccess()) {
                        DBLog_Summary__c dbSucc=new DBLog_Summary__c();
                        dbSucc.Case_Number__c=sr.getId();
                        dbSucc.type__c='redCare Case Update Success';
                        dbSucc.Order_Items_Success__c = String.valueOf(dbSucc.Order_Items_Success__c+','+ sr.getId()).left(9999);
                        lsDbSuc.add(dbSucc);
                    }
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            DBLog_Summary__c dbexp=new DBLog_Summary__c();
                            dbexp.Case_Number__c=sr.getId();
                            dbexp.type__c='redCare Case Update Failed';                                                                            
                            dbexp.Order_Items_Failed__c = err.getStatusCode() + '-' + err.getMessage()+'--'+err.getFields();
                            lsDbExp.add(dbexp);
                        }
                    }   
                }
                if(!lsDbSuc.isEmpty())
                    database.insert(lsDbSuc);
                
                if(!lsDbExp.isEmpty())     
                    database.insert(lsDbExp);   
            }
            Catch(Exception e)
            {
                DBLog_Summary__c dbexp22=new DBLog_Summary__c();
                dbexp22.type__c='redCare Case Update Catch Failed';
                dbexp22.Complaint_Tracker_Error__c=string.valueof(e);
                insert dbexp22;               
            }            
        }
        
        if(!dbsList.isEmpty())
            Database.SaveResult[] dblList = Database.update(dbsList, false);                           
    }
    
    //Send SMS AND Watsup Notifications for the buscancelation
    
    /* @future(callout=true)
public static void buscancelSendnotification(set<id> stIds)
{
List<Case> caseList=new List<Case>();

caseList=[select Account.Name,Source__c,Destination__c,casenumber,id,status,description,Tin_no__c,TIN__c,SourceT__c,DestinationT__c,SS_DOJ__c,Issue_Type__c,Send_Notification__c,Date_Of_Journey_New__c,Booking_Mobile_No__c,Phone_No_ct__c from case where id in: stIds ];

HttpRequestWrappersUtil.SendSMSEMailReqWrapper smsReqJson = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
smsReqJson.type= new List<String>{'smsdata'};
List<HttpRequestWrappersUtil.SMSRequest> listSMSReq = new List<HttpRequestWrappersUtil.SMSRequest>();
DBLog_Summary__c dbl = new DBLog_Summary__c();
for(case c :caseList)
{
String tinn=String.isBlank(c.TIN__c)?c.TIN_No__c:c.TIN__c;
string mobileNum = String.isBlank(c.Booking_Mobile_No__c)?String.isBlank(c.Phone_No_ct__c)?'':c.Phone_No_ct__c:c.Booking_Mobile_No__c;
String srcCity = String.isNotBlank(c.Source__c)?c.Source__c:String.isNotBlank(c.SourceT__c)?c.SourceT__c:'';
String desCity = String.isNotBlank(c.Destination__c)?c.Destination__c:String.isNotBlank(c.DestinationT__c)?c.DestinationT__c:'';
String strDoj = c.SS_DOJ__c!=null?String.valueOf(c.SS_DOJ__c):c.Date_Of_Journey_New__c!=null?String.valueOf(c.Date_Of_Journey_New__c):'';
if(String.isNotBlank(tinn) && String.isNotBlank(mobileNum) && String.isNotBlank(srcCity) && String.isNotBlank(desCity) && String.isNotBlank(strDoj))
{
string bodyText = '{"tinno":"'+tinn+'","source":"'+srcCity+'","destination":"'+desCity+'","doj":"'+strDoj+'"}';
listSMSReq.add(HttpRequestUtil.prepareSMSRequest('Bus_Cancellation_SMS',bodyText,'','',mobileNum,'',false));
}

}

if(!listSMSReq.isEmpty())
{
Http ht2 = new http();
HttpRequest req =  HttpRequestUtil.populateCAPIHeaders(new HttpRequest());
HttpRequestWrappersUtil.Smsdata smsdataReq = new HttpRequestWrappersUtil.Smsdata();
System.debug('listSMSReq...'+listSMSReq);
smsdataReq.SMSRequest = new List<HttpRequestWrappersUtil.SMSRequest>();
smsdataReq.SMSRequest=listSMSReq;
smsdataReq.NotificationType  ='SMS';
smsdataReq.Language  ='en';
smsdataReq.IsTemplateUsedForMessage  =true;

smsReqJson.smsdata = smsdataReq;
System.debug('smsReqJson...'+JSON.serialize(smsReqJson));
System.debug('smsdataReq...'+smsdataReq);

HttpResponse resp = new HttpResponse();
req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'].Endpoint__c);
req.setBody(JSON.serialize(smsReqJson));
req.setMethod('POST');
resp = ht2.send(req);
system.debug('resp===>>>'+resp.getbody());
}

// Watsup Notification


Map<String, String> whatsappheaders = new Map<String, String>();
whatsappheaders.put('Content-Type','application/json');
whatsappheaders.put('Channel_Name','MOBILE_WEB');
whatsappheaders.put('Country_Name','IND');
whatsappheaders.put('BusinessUnit','BUS');
whatsappheaders.put('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
for(case c: caseList){

String tinn=String.isBlank(c.TIN__c)?c.TIN_No__c:c.TIN__c;
String srcCity = String.isNotBlank(c.Source__c)?c.Source__c:String.isNotBlank(c.SourceT__c)?c.SourceT__c:'';
String desCity = String.isNotBlank(c.Destination__c)?c.Destination__c:String.isNotBlank(c.DestinationT__c)?c.DestinationT__c:'';
String strDoj = c.SS_DOJ__c!=null?String.valueOf(c.SS_DOJ__c):c.Date_Of_Journey_New__c!=null?String.valueOf(c.Date_Of_Journey_New__c):'';


if(String.isNotBlank(tinn) && String.isNotBlank(c.Booking_Mobile_No__c) && String.isNotBlank(srcCity) && String.isNotBlank(desCity) && String.isNotBlank(strDoj))
{
HttpResponse wappHt = new HttpResponse();
string bodyText = '{"tinno":"'+tinn+'","source":"'+srcCity+'","destination":"'+desCity+'","doj":"'+strDoj+'"}';

HttpRequestWrappersUtil.WhatsAppRequestWrapper whatsAppReq= new HttpRequestWrappersUtil.WhatsAppRequestWrapper();
whatsAppReq = HttpRequestUtil.prepareWhatsappRequest('Bus_Cancellation_WHATSAPP',bodyText,2,tinn,c.Booking_Mobile_No__c,'en');
System.debug('request b-->'+Json.serialize(json.serialize(whatsAppReq)));
wappHt = HTTPUtil.sendGenericHTTPRequest([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification'].Endpoint__c,'Post',Json.serialize(json.serialize(whatsAppReq)),whatsappheaders,100000);
}


}
}*/
    
    
    // Acko policy Initiation
    @future(callout=true)
    public static void policyInitiate(set<id> setIds)
    {
        system.debug('policyInitiate-->>');
        List<Case> caseList=new List<Case>();
        List<Case> casesToUpdate=new List<Case>();
        list<DBLog_Summary__c> listDBlogs = new List<DBLog_Summary__c>();
        caseList=[SELECT id,CaseNumber,Policy_Id__c,Insurance_Provider_Name__c,Claim_id__c,Type,Claim_Initiated_Time__c,Issue_Type__c,Issue_Sub_Category__c,status,Claim_Status__c,Claim_Type_ctp__c,TIN_No__c,TIN__c FROM Case where id in: setIds AND Issue_Type__c=:system.Label.IssueTypes_Acko.split(',') AND Issue_Sub_Category__c=:system.Label.Issue_Sub_Category_Acko.split('__') limit 49];
        
        for(case cs :caseList)
        {
            if(String.isBlank(cs.Claim_id__c) && ('Bus Operator Service'.equalsIgnoreCase(cs.Issue_Type__c) || ('Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c) && !'B2B'.equalsIgnoreCase(cs.Type))))
            {
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.type__c = 'Acko Claim Creation';
                dbl.Case_Number__c = cs.caseNumber;
                String policyId = String.isNotBlank(cs.Policy_Id__c)?cs.Policy_Id__c:'';
                string vendor=String.isNotBlank(cs.Insurance_Provider_Name__c)?cs.Insurance_Provider_Name__c:'';
                try
                {
                    if(String.isBlank(policyId))
                    {
                        
                        Http h= new Http();
                        HttpRequest req = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        req =HttpRequestUtil.populateAckoInsuranceHeaders(req);
                        req.setMethod('GET');           
                        req.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Get_Policy_Id'].Endpoint__c+cs.TIN_No__c);
                        //dbl.Payment_Request_Sent_Data__c = String.valueOf(req+'..endpoint..'+req.getEndpoint());                
                        dbl.Request_Data__c = String.valueOf(req+'..endpoint..'+req.getEndpoint());  
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        resp=h.send(req);
                        dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
                        system.debug('resp==>>'+resp);
                        //dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'..Body..'+resp.getBody());     
                        dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody()); 
                        system.debug('resp==>>'+resp.getbody());
                        
                        if(resp!=null && resp.getStatusCode() ==200 && String.isNotBlank(resp.getBody()))
                        {
                            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
                            policyId = (String)resMap.get('policyId');
                            vendor=(String)resMap.get('vendor');
                            system.debug('policyId==>>'+policyId);
                            cs.Policy_Id__c = policyId;
                            cs.Insurance_Provider_Name__c=vendor;
                            system.debug('Policy_Id__c==>>'+ cs.Policy_Id__c);
                            
                        }
                        
                    }
                    if(String.isNotBlank(policyId))
                    {
                        system.debug('systempolicyId==>>'+policyId);
                        String claimtype='';
                        String tin =String.isNotBlank(cs.TIN_No__c)?cs.TIN_No__c:String.isNotBlank(cs.TIN__c)?cs.TIN__c:'';
                        string vendorname=String.isNotBlank(cs.Insurance_Provider_Name__c)?cs.Insurance_Provider_Name__c:'ACKO';
                        
                        if(('ICICI'.equalsIgnoreCase(vendorname) && Boolean.valueOf(System.Label.Enable_ICICI_Flows)) || ('ACKO'.equalsIgnoreCase(vendorname) && Boolean.valueOf(System.Label.Enable_Acko_Flows)))
                        {                       
                            
                            claimtype =String.isNotBlank(cs.Claim_Type_ctp__c)?cs.Claim_Type_ctp__c:'Bus Cancellation'.equalsIgnoreCase(cs.Issue_Type__c)?'BOC':'BTM';
                            string jsonbody='{"policy_id":"'+policyId+'","tin":"'+tin+'","claim_type":"'+claimtype+'","vendor":"'+vendorname+'"}';
                            system.debug('jsonbody==>>'+jsonbody);
                            Http ht= new Http();
                            HttpRequest req = new HttpRequest();
                            HttpResponse res = new HttpResponse();
                            req =HttpRequestUtil.populateAckoInsuranceHeaders(req);
                            req.setHeader('Channel',vendorname);                      
                            req.setMethod('POST');
                            req.setBody(jsonbody);
                            system.debug('setbody==>>'+jsonbody);
                            req.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Policy_API'].Endpoint__c);
                            
                            dbl.Request_Data__c = string.valueof(req)+'..Body..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--Cache-Control--'+req.getHeader('Cache-Control')+'--AuthToken--'+req.getHeader('AuthToken')+'--Channel--'+req.getHeader('Channel')+'--country--'+req.getHeader('Country');
                            
                            res=ht.send(req);
                            dbl.Response_Received__c = String.valueOf(res);
                            system.debug('res==>>'+res.getBody());
                            if(res!=null && res.getStatusCode()==200 && String.isNotBlank(res.getBody()))
                            {
                                system.debug('res Body==>>'+res.getbody());
                                dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                                map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                                
                                if((boolean)resMap.get('success'))
                                {
                                    map<string,object> resultMap= (map<string,object>)resMap.get('result');
                                    cs.Claim_id__c = (String)resultMap.get('claim_id');
                                    cs.Claim_Initiated_Time__c = Datetime.now();
                                    cs.Claim_Status__c ='Claim Initiation Successful';
                                }
                                
                                else
                                {
                                    cs.Claim_Status__c ='Claim Initiation Failed';
                                }
                            }
                        }
                        
                    }
                }
                Catch(Exception e)
                {
                    dbl.Exception_Description__c = String.valueOf(e);
                }
                casesToUpdate.add(cs);
                listDBlogs.add(dbl);
            }
        }
        
        try
        {
            insert listDBlogs;
            update casesToUpdate;
        }
        catch(Exception e)
        {
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c = 'Claim Creation Case Update Failure';
            dbl.Exception_Description__c = String.valueOf(e);
            insert dbl;
        }
        
    }
    //Acko ApproveorRejectedstatus
    @future(callout=true)
    public static void ApproveorRejectedstatus(set<id> setCaseIds,String claimSts,String claimsucStatus,String claimFailStatus){
        
        List<Case> caseList=new List<Case>();
        List<Case> casesToUpdate=new List<Case>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        caseList=[SELECT id,CaseNumber,Policy_Id__c,Claim_id__c,Claim_Initiated_Time__c,Channel_ct__c,Issue_Type__c,Insurance_Provider_Name__c,Issue_Sub_Category__c,status,Claim_Status__c,Claim_Type_ctp__c,TIN_No__c,TIN__c FROM Case where id in: setCaseIds AND Issue_Type__c='Bus Cancellation' limit 49];
        
        for(case cs :caseList)
        {
            string policyid = String.isNotBlank(cs.Policy_Id__c)?cs.Policy_Id__c:'';
            String tin =String.isNotBlank(cs.TIN_No__c)?cs.TIN_No__c:'';
            String claimid = String.isNotBlank(cs.Claim_id__c)?cs.Claim_id__c:'';
            String claimtype =String.isNotBlank(cs.Claim_Type_ctp__c)?cs.Claim_Type_ctp__c:'BOC';
            String claimstatus = claimSts;
            string jsonbody='{"policy_id":"'+policyid+'","tin":"'+tin+'","claim_id":"'+claimid+'","claim_type":"'+claimtype+'","claim_status":"'+claimstatus+'"}';
            string endPointData  =[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Approve_Claim'].Endpoint__c;     
            Http h= new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req =HttpRequestUtil.populateAckoInsuranceHeaders(req);
            String chanel = String.isNotBlank(cs.Insurance_Provider_Name__c)?cs.Insurance_Provider_Name__c:'ACKO';
            req.setHeader('Channel',chanel);
            req.setEndpoint(endPointData);
            req.setMethod('POST');
            req.setBody(jsonbody);
            dbl.Type__c = chanel+'Claim Process -'+claimstatus;
            //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--Cache-Control--'+req.getHeader('Cache-Control')+'--AuthToken--'+req.getHeader('AuthToken')+'--Channel--'+req.getHeader('Channel')+'--country--'+req.getHeader('Country');
            dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--Cache-Control--'+req.getHeader('Cache-Control')+'--AuthToken--'+req.getHeader('AuthToken')+'--Channel--'+req.getHeader('Channel')+'--country--'+req.getHeader('Country');
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            
            res=h.send(req);
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
            // dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
            if(res!=null && res.getStatusCode()==200 && String.isNotBlank(res.getBody()))
            {
                map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                Boolean issuccess = (Boolean)resMap.get('success');
                if(issuccess!=null)
                    cs.Claim_Status__c = issuccess?claimsucStatus:claimFailStatus;
            }
            casesToUpdate.add(cs);
        }
        Database.update(casesToUpdate,false);
        insert dbl;
    }
    // BusCancelAgeing Proc
    public static void BusCanclProcessBuilder(set<id> busCanclIds){
        system.debug('---BusCanclProcessBuilder-----');
        List<Case> caseList=new List<Case>();   
        caseList=[select BOAgentContactByCSE__c,Transaction_ID__c,Date_Of_Journey_New__c,SPOCName_By_CSE__c,CreatedDate,BOAgentNameByCSE__c,Route_Id__c,OrderItem_Uuid__c,SS_Route_Id__c,Transaction_UUID__c,casenumber,id,status,description,Tin_no__c,TIN__c,SourceT__c,DestinationT__c,SS_DOJ__c,Issue_Type__c,Send_Notification__c,Booking_Mobile_No__c,Phone_No_ct__c from case where id in: busCanclIds];
        list<BusCancelInitiationProcess.JsonWrapper> lstwrpr= new list<BusCancelInitiationProcess.JsonWrapper>();
        for(case c :caseList)
        {
            
            if(String.isNotBlank(c.TIN__c) || String.isNotBlank(c.TIN_No__c))
            {
                BusCancelInitiationProcess.JsonWrapper busCancl = new BusCancelInitiationProcess.JsonWrapper();
                busCancl.status='INITIATED';
                busCancl.createdTime=string.valueof(c.createddate);
                busCancl.boAgentNameByCSE= c.BOAgentNameByCSE__c;
                busCancl.SPOCNameByCSE= c.SPOCName_By_CSE__c;
                busCancl.boAgentContactByCSE =c.BOAgentContactByCSE__c;
                busCancl.initiatedBy = UserInfo.getName()+'('+UserInfo.getUserName()+')';
                busCancl.updatedTime =string.valueof(c.createddate);
                busCancl.notes='';
                
                if(c.Transaction_ID__c!=null)
                {
                    busCancl.tin= c.TIN__c;
                    busCancl.doj=string.valueof(c.Date_Of_Journey_New__c);
                    busCancl.routeId= String.isNotBlank(c.Route_Id__c)?Integer.valueof(c.Route_Id__c):null;
                    busCancl.orderItemUuid= c.OrderItem_Uuid__c;
                }
                else
                {
                    busCancl.tin= c.TIN_No__c;
                    busCancl.doj= c.SS_DOJ__c!=null?String.valueOf(c.SS_DOJ__c):null;
                    busCancl.routeId= String.isNotBlank(c.SS_Route_Id__c)?Integer.valueof(c.SS_Route_Id__c):null;
                    busCancl.orderItemUuid= c.Transaction_UUID__c;
                }
                
                lstwrpr.add(busCancl);
            }
        }
        string finaljsonbdy=JSON.serialize(lstwrpr).removestart('[').removeEnd(']');
        system.debug('--lst--'+finaljsonbdy);
        if(String.isNotBlank(finaljsonbdy))
        {    
            BusCancellationHandler.insertCancelItems(finaljsonbdy); 
        } 
    }
    
    
    /* @future(callout=true)
public static void ProcessExceptionalRefund(set<id> csIds){
list<case> csList=new list<case>();
String conBusUnit ='';String selcountry ='';String selCurrency='';
csList=[select id,TIN_No__c,Business_Unit_ct__c,Service_Providerr_Id__c,Service_Provider_Id__c,Service_Id__c,Booking_Email_ID__c,Booking_EMail_Copy__c,casenumber,Transaction_UUID__c,Approved_By__c,Refund_Amount__c,Price_Paid_Currency_ctp__c from case where id in:csIds];       
list<case> csUpList=new list<case>();
list<Cancellation_Process_DB_Log__c> cpList=new list<Cancellation_Process_DB_Log__c>();
for(case csObj:csList){
case cs=new case();
cs=csObj;
ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
exceRfndReq.ticketNo = csObj.TIN_No__c;
exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)?csObj.Booking_EMail_Copy__c:'';
exceRfndReq.cancellationType = '1';
exceRfndReq.selectedSeat='';
exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
exceRfndReq.orderItemUuid = csObj.Transaction_UUID__c;
exceRfndReq.createdby = 'BO ('+csObj.Service_Provider_Id__c+') from RB+';
exceRfndReq.reason = 'Collectible From BO';
exceRfndReq.isExceptionalCancellation = true;
exceRfndReq.operatorContribution = csObj.Refund_Amount__c;

ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
monyMod.amount = csObj.Refund_Amount__c;
monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)?csObj.Price_Paid_Currency_ctp__c:'INR';
exceRfndReq.refund = monyMod;
string strExceRfndReq=Json.serialize(exceRfndReq);

HttpRequest req = new HttpRequest();
req = HttpRequestUtil.populateCAPIHeaders(req);
req.setTimeout(120000);
req.setMethod('POST');
HttpResponse res = new HttpResponse();
Http http = new Http(); 
req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);
conBusUnit = String.isNotBlank(csObj.Business_Unit_ct__c)?'REDBUS_'+csObj.Business_Unit_ct__c.split('_')[1]:'REDBUS_IN';
System.debug('conBusUnit ...'+conBusUnit);
selcountry = OrderItemTransactionResource__c.getValues(conBusUnit).Auth_Key__c;
selCurrency= OrderItemTransactionResource__c.getValues(conBusUnit).Default_Currency__c;
req.setHeader('SelectedCurrency',selCurrency);
req.setHeader('Country_Name',selcountry);        
req.setBody(strExceRfndReq);
Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
cp.Type__c='Exceptional Refund RB+';
cp.FC_API_Request_Data__c = string.valueof(req)+'Body :'+strExceRfndReq+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+selcountry+',SelectedCurrency :'+selCurrency;
res = http.send(req); 
string responseValue=res.getBody();
System.debug('responseValue-->'+responseValue);
if(res.getStatusCode()==200 && !string.isBlank(res.getBody()))
{
cs.Refund_status__c= 'Exceptional Refund Processed';
cp.FC_IsSuccess__c =true;               
}else{
cs.Refund_status__c= 'Exceptional Refund Process Failed';
cp.FC_IsSuccess__c =false;
}

cp.FC_API_Request_Response__c = responseValue; 
csUpList.add(cs);
cpList.add(cp);
}

if(!csUpList.isEmpty())
database.update(csUpList);

if(!cpList.isEmpty())
database.insert(cpList);
}
*/  @future(callout=true)
    public static void CompletePaymentApproveIndia(set<id> csIds){
        system.debug('called here CompletePaymentApproveIndia');
        List<Case> caseList=new List<Case>();   
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='PaaS UpdatePGTxnId-IND';
        caseList=[select id,Country__c,All_Payment_Online_UUIDs__c,createdby.name,Owner.name,PG_Id__c,Approved_By__c,Transaction_UUID__c,Payment_Item_UUID__c,PG_Ttransaction_Id__c,Order_UUId__c,status from case where id in:csIds LIMIT 1];
        string allPaymentOnlineUUIds;
        Map<string,case> caseMap=new Map<string,case>();
        List<case> csList=new List<case>();
        List<casecomment> ccList=new List<casecomment>();
        for(Case csobj:caseList)
        {
            if(String.isNotBlank(csObj.Order_UUId__c) && csobj.Country__c=='India')
            {
                if(string.isBlank(allPaymentOnlineUUIds))
                    allPaymentOnlineUUIds=csObj.All_Payment_Online_UUIDs__c;
                else
                    allPaymentOnlineUUIds=allPaymentOnlineUUIds+','+csObj.All_Payment_Online_UUIDs__c;
                
                
                string reqJson='{"IdsToSyncPaymentStatus":{"TxnId":null,"OnlinePaymentItemUUID":['+allPaymentOnlineUUIds+']}}';
                HTTP http = new HTTP();
                HttpRequest reqq= new HttpRequest();
                HTTPResponse ress=new HTTPResponse(); 
                reqq = HttpRequestUtil.populatePassUpdatePGTxnIdHeaders(reqq);     
                reqq.setHeader('Country_Name', 'IND');        
                reqq.setMethod('POST');  
                reqq.setBody(reqJson);
                reqq.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='UpdatePGTxnId_IND'].Endpoint__c);
                dbl.Request_Data__c =string.valueof(reqq)+'..Body..'+reqJson+'---Header--Content-Type--'+reqq.getHeader('Content-Type')+'--setTimeout--'+reqq.getHeader('setTimeout')+'--AuthToken--'+reqq.getHeader('AuthToken')+'--Country_Name--'+reqq.getHeader('Country_Name');
                
                ress= http.send(reqq);
                dbl.Response_Received__c =String.valueOf(ress+'..Body..'+ress.getBody());
                string responseValue=ress.getBody();
                map<string,object> resMap = (map<string,object>)JSON.deserializeUntyped(responseValue);
                List<object> respOrders= (List<Object>)resMap.get('TxnStatus');
                
                List<string> respStatus=new List<string>();
                for(object o:respOrders){
                    Map<string,object> inObj=(Map<string,object>)o; 
                    string respOrdId=string.valueOf(inObj.get('OrderId'));
                    string respOrdStatus=string.valueOf(inObj.get('Syncstatus'));
                    respStatus.add(respOrdStatus);                        
                }
                casecomment cc=new casecomment();
                if(respStatus.contains('SUCCESS')){
                    csObj.status='Closed';
                    cc.parentid=csObj.id;
                    cc.commentbody='Payment Status As Marked As Completed Successfully';
                } else{
                    csObj.status='Open';
                    cc.parentid=csObj.id;
                    cc.commentbody='Payment Status failed to update, Pelase try again!';
                }
                
                csList.add(csObj);
                ccList.add(cc);
            }
        }      
        insert dbl;
        if(!csList.isEmpty()){
            insert ccList;
            update csList;
        }
        
        
    }
    @future(callout=true)
    public static void CompletePaymentApprove(set<id> csIds){
        List<Case> caseList=new List<Case>();   
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Pass UpdatePGTxnId';
        Map<String,List<CompletePaymentReqWrap>> mapOrderUUidToPayments = new Map<String,List<CompletePaymentReqWrap>>();
        
        caseList=[select id,Country__c,Business_Unit_ct__c,createdby.name,Owner.name,PG_Id__c,Approved_By__c,Transaction_UUID__c,Payment_Item_UUID__c,PG_Ttransaction_Id__c,Order_UUId__c,status from case where id in:csIds LIMIT 99];
        
        for(Case csobj:caseList)
        {
            if(String.isNotBlank(csObj.Order_UUId__c))
            {
                Payment pay = new Payment();
                pay.id=long.valueof(csobj.PG_Id__c);
                pay.paymentSystem='ONLINE';
                pay.paymentSystemRefNo =csobj.PG_Ttransaction_Id__c;
                pay.requestedBy=csobj.createdby.name;
                pay.approvedBy =csobj.Approved_By__c;
                
                CompletePaymentReqWrap cmplPayreqwrap = new CompletePaymentReqWrap();
                cmplPayreqwrap.amendType ='CONFIRM';
                cmplPayreqwrap.payment=pay;
                
                if(mapOrderUUidToPayments.containsKey(csobj.Order_UUId__c))
                    mapOrderUUidToPayments.get(csobj.Order_UUId__c).add(cmplPayreqwrap);
                else
                    mapOrderUUidToPayments.put(csobj.Order_UUId__c,new List<CompletePaymentReqWrap>{cmplPayreqwrap});
            }
        }
        
        Map<String,String> mapGeoEndPoint = new Map<String,String>();
        For(API_EndPoints__mdt met:[SELECT Endpoint__c,DeveloperName,EnableLog__c FROM API_EndPoints__mdt where DeveloperName IN('NeonWFT2GFT','NeonIntlWFT2GFT')])
        {
            mapGeoEndPoint.put(met.DeveloperName,met.Endpoint__c);
        }
        
        Id payQueueId=[select id from Group where type='Queue' AND developername='Payment_Update_Queue'].id;
        Id IntlpayQueueId=[select id from Group where type='Queue' AND developername='Intl_Payment_Update_Queue'].id;
        Id RedbusComUpdQuId=[select id from Group where type='Queue' AND developername='Redbus_Com_Queue'].id;
        
        Map<String, String> cmpltpayHeaders= new Map<String, String>();
        cmpltpayHeaders.put('Content-Type','application/json');
        list<case> csUpdtlst=new list<case>();
        list<CaseComment> listCommToInsert=new list<CaseComment>();
        for(Case c:caseList)
        {
            
            
            if(mapOrderUUidToPayments.containsKey(c.Order_UUId__c))
            {
                system.debug('==2509==');
                HTTP http = new HTTP();
                HttpRequest reqq= new HttpRequest();
                HTTPResponse ress=new HTTPResponse(); 
                reqq = HttpRequestUtil.populatePassUpdatePGTxnIdHeaders(reqq);               
                reqq.setMethod('POST');
                
                HttpRequestWrappersUtil.PassUpdatePGTxnIdWrap PGTxnIdWrap= new HttpRequestWrappersUtil.PassUpdatePGTxnIdWrap ();
                PGTxnIdWrap.TransactionID=0;
                PGTxnIdWrap.PaymentItemUUID=c.Payment_Item_UUID__c;
                PGTxnIdWrap.PGTransactionID=c.PG_Ttransaction_Id__c;
                String jsonBody=json.serialize(PGTxnIdWrap);  
                reqq.setBody(jsonBody);
                reqq.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='UpdatePGTxnId'].Endpoint__c);
                dbl.Request_Data__c =string.valueof(reqq)+'..Body..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+reqq.getHeader('Content-Type')+'--setTimeout--'+reqq.getHeader('setTimeout')+'--AuthToken--'+reqq.getHeader('AuthToken');
                
                ress= http.send(reqq);
                //string ressp='{"ISSuccess":true,"ErrorMessage":""}';
                system.debug('==2525=='+ress+'..Body..'+ress.getBody()); 
                dbl.Response_Received__c =String.valueOf(ress+'..Body..'+ress.getBody());
                Boolean isSucc =false;
                if(ress.getStatusCode()==200 && string.isNotBlank(ress.getBody()))
                {
                    
                    CaseComment comm = new CaseComment();
                    case css = new case();
                    css.id = c.id;
                    map<String,Object> resMap= (map<string,object>)JSON.deserializeUntyped(ress.getBody());
                    isSucc = resMap.containsKey('ISSuccess')?Boolean.valueOf(resMap.get('ISSuccess')):false;
                    if(isSucc)
                    { 
                        
                        comm.commentbody='passUpdate true';
                        
                        String endpoint ='India'.equalsIgnoreCase(c.Country__c)?mapGeoEndPoint.get('NeonWFT2GFT'):mapGeoEndPoint.get('NeonIntlWFT2GFT');
                        endpoint = endpoint+c.Order_UUId__c+'/payment-items';
                        HttpResponse res = new HttpResponse();
                        res = HTTPUtil.sendGenericHTTPRequest(endpoint,'PUT',JSON.serialize(JSON.serialize(mapOrderUUidToPayments.get(c.Order_UUId__c))),cmpltpayHeaders,100000,'Mark Payemt As Completed');
                        system.debug('--2413 res--'+res+'--2413 resBody--'+res.getbody());
                        system.debug('country-->'+c.country__c);
                        if(res.getStatusCode()==200 && res.getStatus()=='OK' && string.isNotBlank(res.getBody()))
                        {
                            map<string,object> respMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                            
                            if(respMap.containsKey('status') && respMap.get('status')!=null && respMap.get('status')=='SUCCESS')
                            {
                                comm.commentbody =  comm.commentbody+'--Payment Status As Marked As Completed Successfully';
                                css.status='Closed';
                                //css.ownerid=c.createdbyId;
                                system.debug('if res---'+res+'--resBody--'+res.getbody());
                            } 
                            
                            else
                            {
                                css.status='Open';
                                if('India'.equalsIgnoreCase(c.country__c)){
                                    css.ownerid=payQueueId;
                                }else if('REDBUS_COM'.equalsIgnoreCase(c.Business_Unit_ct__c)){
                                    css.ownerid=RedbusComUpdQuId;
                                }else{
                                    css.ownerid=IntlpayQueueId;
                                }
                                css.Approved_By__c='';
                                comm.commentbody ='System tried to update payment status details but failed.So,reseted the status,please re-try';
                            }
                        }
                        
                        else
                        {
                            css.status='Open';
                            if('India'.equalsIgnoreCase(c.country__c)){
                                css.ownerid=payQueueId;
                                system.debug('---if---');
                            }
                            else if('REDBUS_COM'.equalsIgnoreCase(c.Business_Unit_ct__c))
                            {
                                css.ownerid=RedbusComUpdQuId;
                            }else{
                                css.ownerid=IntlpayQueueId;
                            }
                            css.Approved_By__c='';
                            comm.commentbody ='System tried to update payment status but received invalid status.';
                        }
                        comm.parentId = css.id;
                        listCommToInsert.add(comm);
                        csUpdtlst.add(css);
                        
                    } 
                    else{
                        
                        comm.CommentBody='-Pass update--'+string.valueof(resMap.get('ErrorMessage'));
                        css.status='Open';
                        comm.parentId = css.id;
                        listCommToInsert.add(comm);
                        csUpdtlst.add(css);
                        insert dbl;
                        
                    }
                }
                
            }
            
        }
        
        
        if(!csUpdtlst.isEmpty())
        {
            DataBase.insert(listCommToInsert,false);
            DataBase.update(csUpdtlst,false);
            
        }
    }
    
    @future(callout=true)
    public static void MMTApproveBusCancellation(set<id> csIds){
        System.debug('calling mmt');
        list<case> csList=new list<case>();
        csList=[select id,TIN_No__c,No_of_Seats__c from case where id in:csIds];
        string endPointData  =[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='MMT_BusCancel_Approve'].Endpoint__c;     
        list<DBLog_Summary__c> dbList=new list<DBLog_Summary__c>();
        list<case> csUpList=new list<case>();
        list<casecomment> ccList=new list<casecomment>();
        for(case c:cslist){
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c='MMT Bus Cancellation Approval';
            //string jsonbody='{ "bookingId": "'+c.TIN_No__c+'", "preview": false, "refundOption": "RefundToCustomer", "lineNumbers": ['+c.No_of_Seats__c+'], "specialClaim": true }';
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName ='MMT_BusCancel_Approve'];
            string jsonBusCbody='{"userId":"RED_BUS","bookingID":"'+c.TIN_No__c+'","specialClaim":true,"refundAdjustmentent":"Refund_To_Customer","operatorCancelled":false}';
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
            for(string o:headers.keyset()){
                hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
            }
            String headerJson=json.serialize(hlist);
            String headerJson2=json.serialize(headerJson); 
            string jsonBody='{"action":"POST","body":'+JSON.serialize(jsonBusCbody)+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+',"isIncreasedTimeout":true}';        
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName ='Generic_CMAPI'];
            
            Http h= new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req = HttpRequestUtil.populateHeaders(req);               
            req.setMethod('POST');
            req.setBody(jsonBody);
            req.setEndpoint(APIMData.Endpoint__c); 
            //dbl.Payment_Request_Sent_Data__c = String.valueOf(req+'..endpoint..'+req.getBody()); 
            dbl.Request_Data__c = String.valueOf(req+'..endpoint..'+req.getBody());
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            res=h.send(req);
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());  
            dbl.Response_Received__c =  String.valueOf(res+'..Body..'+res.getBody());  
            system.debug('res==>>'+res.getbody());
            map<string,object> resObj;
            if(res.getbody()!='')
                resObj = (map<string,object>)JSON.deserializeUntyped(res.getbody());
            casecomment cc=new casecomment();
            if(resObj!=null && resObj.get('status')==1){
                c.status='Closed';
                cc.parentid=c.id;
                cc.commentbody='Successfully approved for Bus Cancellation';     
                csUpList.add(c);
                ccList.add(cc);
            }else if(resObj!=null && resObj.get('responseText')=='The Requested Booking is already Cancelled'){
                c.status='Closed'; 
                cc.parentid=c.id;
                cc.commentbody='The Requested Booking is already Cancelled';     
                csUpList.add(c);
                ccList.add(cc);
            }else{     
                c.status='Initiated';   
                cc.parentid=c.id;
                cc.commentbody='Failed to approve Bus Cancellation, Please Try again';   
                if(resObj!=null && resObj.get('responseText')!=''){
                    cc.commentbody='Failed to approve Bus Cancellation!! Error Message->'+ resObj.get('responseText');   
                }  
                csUpList.add(c);
                ccList.add(cc);               
            }
            //string statusResp=string.valueOf(resObj.get('status'));
            //  map<string,object> resObj1=(map<string,object>)resObj.get('data');
            dbList.add(dbl);
        }
        
        if(!ccList.isEmpty())
            insert ccList;   
        
        if(!csUpList.isEmpty())
            update csUpList;    
        
        if(!dbList.isEmpty())
            insert dbList;
        
    }
    
    public class Payment
    {
        public long id { get; set; }
        public string paymentSystem { get; set; }
        public string paymentSystemRefNo { get; set; }
        //public string pgName { get; set; }
        public string requestedBy { get; set; }
        public string approvedBy { get; set; }
    }
    
    public class CompletePaymentReqWrap
    {
        public string amendType { get; set; }
        public Payment payment { get; set; }
    }
    @future(callout=true)
    public static void DisbursalNEFT(List<id> disbursalNEFTIds)
    {
        system.debug('--DisbursalNEFT--'+disbursalNEFTIds);
        system.debug('<<<disbursalNEFTIds'+disbursalNEFTIds);
        List<Case> disbursalNEFTList=new List<Case>();
        disbursalNEFTList=[select id,status,Disbursal_Id__c,Closed_By__c,Disbursal_Mode__c,Voucher_Ref_Id__c,Voucher_Validity__c,type,notes__c,TIN_No__c,PG_Ttransaction_Id__c,Paas_OrderId__c,Refund_Amount__c,CaseNumber,LastModifiedByid,LastModifiedBy.Name,Description,Trip_Id_ct__c,Email_Id_ct__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Account_Holder_Name__c, Business_Unit_ct__c from case where status IN ('Error in NEFT','Closed') and id in:disbursalNEFTIds];
        system.debug('--disbursalNEFTList--'+disbursalNEFTList);
        HttpRequestWrappersUtil.UpdateDisbursalStatusWrap updtDisbStatus = new HttpRequestWrappersUtil.UpdateDisbursalStatusWrap();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        list<CaseComment> listCommToInsert=new list<CaseComment>();
        dbl.type__c = 'Disbursal NEFT Refund Paas Update';
        HTTP http = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse(); 
        list<case> clsLst = new list<case>();
        for(case c:disbursalNEFTList)
        {
            CaseComment cc=new CaseComment();
            updtDisbStatus.DisbursalID=c.Disbursal_Id__c;
            updtDisbStatus.ReferenceID=c.PG_Ttransaction_Id__c;
            if('Closed'.equalsIgnoreCase(c.status))
            {
              if('MANUAL_NEFT'.equalsIgnoreCase(c.Disbursal_Mode__c) ){
                system.debug('-----if----');
                    updtDisbStatus.Status='DISBURSAL_SUCCESS';
                    updtDisbStatus.DisbursalFailureReason='';
                    updtDisbStatus.ConfirmationResonse='';
                }else{
                    updtDisbStatus.Status='DISBURSAL_SUCCESS';
                    updtDisbStatus.DisbursalFailureReason='';
                    updtDisbStatus.voucherRefId=c.Voucher_Ref_Id__c;
                    updtDisbStatus.voucherValidity= string.valueof(c.Voucher_Validity__c);
                    updtDisbStatus.ConfirmationResonse='REFUNDED_VIA_VOUCHER';
                }
            }else if('Error in NEFT'.equalsIgnoreCase(c.status)){
                system.debug('-----else----');
                updtDisbStatus.Status='DISBURSAL_FAILED';
                updtDisbStatus.DisbursalFailureReason='account number is Wrong';
                updtDisbStatus.ConfirmationResonse='';
                
            }
            try{
                req = HttpRequestUtil.populateDisbursalHeaders(req); 
                string countryName; 
                If(String.isNotBlank(c.Business_Unit_ct__c) && BusinessUnitMapping__c.getValues(c.Business_Unit_ct__c)!=null){
                    countryName = String.valueOf(BusinessUnitMapping__c.getValues(c.Business_Unit_ct__c).Country__c);
                }else{
                    countryName = '';
                }
                req.setHeader('Country_Name', +countryName);          
                req.setBody(JSON.serialize(updtDisbStatus));
                req.setMethod('POST'); 
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Disbursal_update_Status'].Endpoint__c);
                dbl.Request_Data__c =string.valueof(req)+'..Body..'+String.valueOf(JSON.serialize(updtDisbStatus))+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--AuthToken--'+req.getHeader('AuthToken')+'--Country_Name--'+req.getHeader('Country_Name');
                res = http.send(req); 
                system.debug('---disbursal resp--'+res+'...bidy.'+req.getbody()+'--respBody--'+res.getbody());
                dbl.Response_Received__c = res+'..Resp Body..'+res.getBody();
                
                if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
                {
                    map<String,Object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                    if((boolean)resMap.get('IsSuccess'))
                    {
                        system.debug('--Case status is updated--');
                        dbl.Response_Received__c = dbl.Response_Received__c+'--System Update- Disbursal NEFT Successful';
                        cc.CommentBody=c.status+'--System Update- Disbursal NEFT Successful';
                    }else{
                      if(C.Closed_By__c!='Test user'){
                        c.status='Open';
                        clsLst.add(c);
                        system.debug('--Case status is Fail--');
                        dbl.Response_Received__c = dbl.Response_Received__c+'--System Update- Disbursal NEFT Successful';
                        cc.CommentBody=c.status+'--'+string.valueof(resMap.get('ErrorMsg'));
                       }
                    } 
                    
                }else{
                    dbl.Response_Received__c='-resp-'+res;
                    cc.CommentBody='-resp-'+res;
                }
                
            }
            Catch(Exception e)
            { 
                cc.CommentBody=String.valueOf(e);
                System.debug('error case status update..'+e);
                dbl.Exception_Description__c = String.valueOf(e);
            }
            cc.parentId = c.id;
            listCommToInsert.add(cc);
        } 
        
        if(!listCommToInsert.isEmpty())
        {
            DataBase.insert(listCommToInsert,false);
            insert dbl;  
            update clsLst;
        } 
        
    } 
    /*Moving  Cases from default queque to Email support Queue */
    @future(callout=true)
    public static void DefaultQueToEmailsupporQue(set<id> cIds){
        
        List<case> caseListUpdte=new List<case>();
        List<case> caseList=new List<case>();
        caseList=[select id,status,Description,ownerid from case where status='Open'and RecordType.DeveloperName='Complaint_Tracker' and TAT_Value__c=Null and HFT__c!='Primo' and origin='Complaint Tracker' and id in: cIds ];
        
        Id emailSupportQueue=[select id from Group where type='Queue' AND developername='Email_Support_Queue'].id;
        
        
        for(case c:caseList){       
            c.ownerid=emailSupportQueue;
            c.Reason='Moved from Default queue';
            caseListUpdte.add(c);
        }
        
        if(!caseListUpdte.isEmpty()){
            update caseListUpdte;
        }
    }
    
    public static void SyncMethod(set<Id> caseIds){
        system.debug('---SyncMethod-------');
        List <Case> casesL= [SELECT Id,Transaction_UUID__c,country__c FROM Case where Issue_Type__c='NEFT Refund' and id in:caseIds];
        for(Case c: casesL)
        { 
            string CountryCode='';
            if('India'.equalsIgnoreCase(c.country__c)){
                CountryCode='IND';
            }else{
                CountryCode='INTL';
            }
            string jsonbody = '{"orderId":"'+c.Transaction_UUID__c+'","emailId":"","phone":"","tin":"","caller":"SF Agent"}';
            SyncAPICntrl.asyncProcess(jsonbody,CountryCode);
        }
        
    }
    public static void closeChildCases( List<Case> TriggerNewList, Map<Id,Case> TriggerOldMap){
        List<casecomment> ccList= new List<casecomment>();
        set<id> caseids=new set<id>();
        list<case> caseNList=new List<case>();
        list<case> caseUpdateList=new list<Case>();
        
        for(case c: TriggerNewList){
            caseids.add(c.id);
        }
        
        caseNList=[SELECT id,Business_Type__c,Issue_Type__c,parentid,status,parent.casenumber,origin from case where id in :caseids];
        
        if(trigger.isupdate){
            for(case c: caseNList){
                if(c.Business_Type__c!='L2 Support' && c.Business_Type__c!='RTC Support' && c.ParentId!=TriggerOldMap.get(c.Id).ParentId && !('Closed'.equalsIgnoreCase(c.status)) && c.ParentId != null && c.Issue_Type__c !='Exceptional Refund' && c.Issue_Type__c !='Wallet Credit' && c.origin !='Alerts TRIMAX' && c.origin !='Email BO/BD' && c.origin !='Alert BOGDS' && c.origin !='Alerts BITLA' && c.origin !='Alerts ITS' ){
                    c.status='Closed';
                    c.Stop_sending_feedback_mail__c=true;
                    c.Does_Customer_Require_CallBack__c=false;
                    caseUpdateList.add(c);
                }else if((c.Business_Type__c=='L2 Support' || c.Business_Type__c == 'RTC Support') && 'Closed'.equalsIgnoreCase(c.status) && c.ParentId != null ){
                    system.debug('>>>parentid..'+c.ParentId);
                    list<case> clst =[select id,status from case where id=:c.ParentId];
                    commentsL2Support=true;
                    if(!clst.isEmpty()){
                        case cs =new case();
                        cs.status='Tech Revert';
                        cs.id=clst[0].id;
                        caseUpdateList.add(cs);
                    }
                }                    
            }
        }
        if(trigger.isInsert){
            for(case c: caseNList){
                if(c.Business_Type__c!='L2 Support' && c.Business_Type__c!='RTC Support' && c.Business_Type__c!='UGCSupport' && !('Closed'.equalsIgnoreCase(c.status)) && c.ParentId != null && c.Issue_Type__c !='Exceptional Refund' && c.Issue_Type__c !='Wallet Credit' && c.origin !='Alerts TRIMAX'&& c.origin !='Email BO/BD' && c.origin !='Alert BOGDS' && c.origin !='Alerts BITLA' && c.origin !='Alerts ITS' ){
                    c.status='Closed';
                    c.Stop_sending_feedback_mail__c=true;
                    c.Does_Customer_Require_CallBack__c=false;
                    caseUpdateList.add(c);
                    caseComment cc= new casecomment();
                    cc.parentid=c.Id;
                    cc.commentbody='Closing as this is a child case related to '+c.parent.caseNumber;
                    Insert cc;
                }
            }
            
        }
        if(!commentsL2Support && caseUpdateList.size()>0 && trigger.isUpdate){
            for(case c:caseUpdateList){
                caseComment cc= new casecomment();
                cc.commentbody='Closing as this is a child case related to '+c.parent.caseNumber;
                cc.parentid=c.Id;
                ccList.add(cc);
            }   
        }
        
        
        
        
        if(caseUpdateList.size()>0){
            update caseUpdateList;
        }
        if(!ccList.isEmpty())
            insert(cclist);
        
    }
    /*public static void updateAgentAssignedTime(List<case> triggerNew, Map<id,case> TriggerOldMap){
for(case c : triggerNew){
if( c.OwnerId!=TriggerOldMap.get(c.Id).OwnerId ){
string caseQueue;
Try{
caseQueue = [select id from Group where type='Queue' AND id=:c.OwnerId].id;                    
}
catch(exception e){
system.debug('error message-->'+ e.getMessage());
}
system.debug('<<<CaseQueue<<<'+caseQueue);
if(CaseQueue== null && c.Agent_Assigned_Time__c==null)
c.Agent_Assigned_Time__c = system.now();
}
}

}*/
    public static void updateAgentAssignedTime(List<case> triggerNew, Map<id,case> TriggerOldMap){
        for(case c : triggerNew){
            if( c.OwnerId!=TriggerOldMap.get(c.Id).OwnerId && c.owner.type=='User' && c.Agent_Assigned_Time__c==null){
                c.Agent_Assigned_Time__c = system.now();
            }
        }
    }
    
    public static void UpdateBDmailId(List<case> TriggerNew){
        Map<String,Service_Provider__c> servMap=new Map<String,Service_Provider__c>();
        Set<String> setNonCallableIssueTypes = new Set<String>(System.label.NonCallableIssueTypes.split('_'));
        Group noncallableQueueId=[Select Id from Group where name='Non Callable Queue' limit 1];
        
        Set<String> servSet=new Set<String>();
        
        Set<String> developerNames = new Set<String>{'Non_Callable_Bo_Ids','Bolt_Bo_Ids'};
            Map<String, RPW_BO_ids__mdt> developerNameToMetaDataMap = new Map<String, RPW_BO_ids__mdt>();
        
        List<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c, Non_Callable_BO_Id__c, DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName IN :developerNames];
        
        
        for (RPW_BO_ids__mdt metadata : rpwMetaData) {
            developerNameToMetaDataMap.put(metadata.DeveloperName, metadata);
        }
        
        
        RPW_BO_ids__mdt nonCallableMetadata = developerNameToMetaDataMap.get('Non_Callable_Bo_Ids');
        RPW_BO_ids__mdt boltMetadata = developerNameToMetaDataMap.get('Bolt_Bo_Ids');
        
        Set<String> NonCallableBoIds = new Set<String>(nonCallableMetadata.Non_Callable_BO_Id__c.split(','));
        Set<String> instantRefundBoIds = new Set<String>(boltMetadata.Bolt_Bo_ids__c.split(','));
        
        for(case c:triggernew){
            string serviceProvId =  String.isNotBlank(c.Service_Provider_Id__c)?c.Service_Provider_Id__c:String.isNotBlank(c.Service_Providerr_Id__c)?c.Service_Providerr_Id__c:'';            if(serviceProvId!=null){
                servSet.add(serviceProvId);
            }
        }
        
        List<Service_Provider__c> servList =[SELECT Operator_Id__c,Location__c,BD_Email__c,BD_Email1__c,BO_Email__c,BO_Email1__c,BO_Type__c FROM Service_Provider__c where Operator_Id__c IN :servSet];
        if(servList.size()>0){
            for(Service_Provider__c se:servList){
                servMap.put(se.Operator_Id__c,se);
            }
        }
        
        system.debug('>>>>>'+instantRefundBoIds);
        system.debug('>>>>>'+NonCallableBoIds);
        system.debug('>>>>>'+setNonCallableIssueTypes);
        
        for(case c: triggerNew){
            string servicProvId =  String.isNotBlank(c.Service_Provider_Id__c)?c.Service_Provider_Id__c:String.isNotBlank(c.Service_Providerr_Id__c)?c.Service_Providerr_Id__c:'';
            if(servicProvId!= null && servMap.size()>0 && servMap.containsKey(servicProvId)) {
                Try{
                    system.debug('>>>>'+servicProvId);
                    c.BD_Email__c = servMap.get(servicProvId).BD_Email__c;
                    c.BD_Email1__c = servMap.get(servicProvId).BD_Email1__c;
                    c.BO_Email__c = servMap.get(servicProvId).BO_Email__c;
                    c.BO_Email1__c = servMap.get(servicProvId).BO_Email1__c;
                    c.BD_Location__c= servMap.get(servicProvId).Location__c;
                    if(Trigger.isInsert && !instantRefundBoIds.contains(servicProvId) && NonCallableBoIds.contains(servicProvId) && setNonCallableIssueTypes.contains(c.issue_type__c)){
                        c.BO_Type__c ='Non Callable';
                        c.status='Awaiting BO/BD Response';
                        c.All_Previous_Status_Dates__c=c.status+','+String.valueOf(System.now())+';'+c.All_Previous_Status_Dates__c;
                        c.ownerid=noncallableQueueId.id;
                    }
                }
                
                catch(exception e){
                    system.debug('<<<Exception occured---->'+e.getMessage());
                    
                }
            }
        }   
    }
    
    
    //Map YourBus Details. CRM-1230
    public static void mapYourBusDetails(List<case> TriggerNew){
        System.debug(':: Inside mapYourBusDetails ::::');
        Group g=[Select Id from Group where name='BD Queue' limit 1];
        Map<String,String> servLocationMap = new Map<String,String>();
        Set<String> servSet=new Set<String>();
        for(case c:triggernew){
            if(c.Service_Providerr_Id__c!=null){
                servSet.add(c.Service_Providerr_Id__c);
            }
        }
        List<Service_Provider__c> spLocationList =[SELECT Operator_Id__c,Location__c FROM Service_Provider__c where Operator_Id__c IN :servSet AND Location__c!=Null];
        if(spLocationList.size()>0){
            for(Service_Provider__c se:spLocationList){
                servLocationMap.put(se.Operator_Id__c,se.Location__c);
            }
        }
        
        for(case c:TriggerNew){
            if(c.Issue_Type__c=='New vehicle- GPS details needed' && c.Channel_ct__c=='YourBus'){
                if(c.Service_Providerr_Id__c != null && c.BD_Location__c==null && servLocationMap.size()>0){
                    c.status='Escalated to BD';
                    c.Assigned_to_BD__c=System.now();
                    c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();
                    c.BD_Location__c=servLocationMap.get(c.Service_Providerr_Id__c);
                    c.ownerid=g.id;
                }else{
                    c.Status='Open';
                }
            }
        }
    }
    
    //Crm - 1491  
    public static void CreateLtoSupportcases(set<id> LsprtIds, string support){
        List<case> cslst=[select id,Origin,status,Email_Id_ct__c,Country__c,Business_Type__c,ownerId,Business_Unit_ct__c,Phone_No_ct__c,Booking_Mobile_No__c,ParentId,Issue_Type__c,Issue_Sub_Category__c from case where id in:LsprtIds];
        List<case> insertcslst =new List<case>();
        
        for(case cs:cslst){
            case css=new case();
            css.status='Open';
            css.Email_Id_ct__c=cs.Email_Id_ct__c;
            css.Phone_No_ct__c=cs.Phone_No_ct__c;
            css.Booking_Mobile_No__c=cs.Booking_Mobile_No__c;
            css.Country__c=cs.Country__c;
            css.ParentId =cs.id;
            css.Business_Unit_ct__c=cs.Business_Unit_ct__c;
            if (support == 'L2') {
                // Id L2RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('L2 Support').getRecordTypeId();
                Id LQuId = [Select id from Group where type='Queue' AND developername='L2_Queue'].id;
                css.Issue_Type__c=cs.Issue_Type__c;
                css.Issue_Sub_Category__c=cs.Issue_Sub_Category__c;
                // css.RecordTypeId = L2RecordTypeId;
                css.Business_Type__c='L2 Support';
                css.ownerId=LQuId;
                css.Origin = cs.Origin;
            }
            else if (support == 'RTC'){
                Id RTCid = [select id from Group where type = 'Queue' AND developername = 'RTC_Community_Support_Queue'].id;
                Id RTCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RTC Support').getRecordTypeId();
                css.RecordTypeId = RTCRecordTypeId;
                css.Business_Type__c= 'RTC Support';
                css.Issue_Type__c=cs.Issue_Type__c;
                css.Issue_Sub_Category__c=cs.Issue_Sub_Category__c;
                css.ownerId=RTCid;
                css.Origin = cs.Origin;
            }else if(support == 'UGC'){
                Id LQuId = [Select id from Group where type='Queue' AND developername='UGC_Support_Queue'].id;
                Id ugcRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('UGCSupport').getRecordTypeId();
                css.RecordTypeId = ugcRecordTypeId;
                css.ownerId=LQuId;
                css.Business_Type__c='UGCSupport';
                css.origin = 'Email - ugc_support@redbus.com';
            }
            insertcslst.add(css);    
        }
        if(!insertcslst.isEmpty()){
            insert insertcslst;
        }
        
    }
    
    public static void UpdateEscMEteamcases(set<id> escMEteamIds){
        system.debug('=='+escMEteamIds);
        List<case> cslst=[select id,status,Escalated_to_ME_Team_Time__c,Escalated_to_ME_By_Agent__c from case where status='Escalated to ME Team' and id in:escMEteamIds];
        List<case> updtcslst =new List<case>();
        for(case cs:cslst){
            
            case css=new case();
            Id mqId = [Select id from Group where type='Queue' AND developername='Management_Queue'].id;
            css.Escalated_to_ME_Team_Time__c=system.now();
            css.Escalated_to_ME_By_Agent__c=userinfo.getName();
            css.ownerId=mqId;
            css.id=cs.id;
            updtcslst.add(css);
        }
        
        if(!updtcslst.isEmpty()){
            update updtcslst;
        }
    }
    
    /*Mapping values from mobile and email to other fields */
    @future(callout=true)
    public static void MapEmailMobileValues(set<id> cIds){
        List<case> caseList=new List<case>();
        List<case> updatecslst =new List<case>();
        caseList=[select id,status,Complaint_Mobile_No__c,booking_mobile_no__c,booking_email_id__c,Phone_No_ct__c,booking_email_copy__c,booking_user_email__c,signed_in_user_email__c,signed_in_user_mobile__c,booking_user_mobile__c,ownerid from case where id in:cIds];
        for(case c:caseList){  
            String singnUsrmble = String.isNotBlank(c.signed_in_user_mobile__c)?c.signed_in_user_mobile__c:string.isNotBlank(c.booking_user_mobile__c)?c.booking_user_mobile__c:''; 
            String bookingEmail = String.isNotBlank(c.booking_email_copy__c)?c.booking_email_copy__c:String.isNotBlank(c.signed_in_user_email__c)?c.signed_in_user_email__c:String.isNotBlank(c.booking_user_email__c)?c.booking_user_email__c:'';
            String cmplntTrackermble = String.isNotBlank(c.Complaint_Mobile_No__c)?c.Complaint_Mobile_No__c :'';
            
            case cs =new case();
            if(string.isNotBlank(singnUsrmble)){
                cs.booking_mobile_no__c =singnUsrmble;
            }
            
            if(string.isNotBlank(bookingEmail)){
                cs.booking_email_id__c=bookingEmail;
            }
            
            
            if(string.isNotBlank(bookingEmail)){
                cs.Phone_No_ct__c=cmplntTrackermble;
            }
            cs.id =c.id;
            updatecslst.add(cs);
        }    
        
        if(!updatecslst.isEmpty()){
            update updatecslst;
        }
    }
    
    @future(callout=true)
    public static void B2bCopassenger(set<id> b2bCsIds, string type){
        System.debug('::: Type === '+type);
        List<case> caseRecords=new List<case>();
        List<DBLog_Summary__c> dbLogRecords=new List<DBLog_Summary__c>();
        caseRecords=[select id,casenumber,Service_Id__c,Route_Id__c,Date_Of_Journey_New__c from case where id in:b2bCsIds and Date_Of_Journey_New__c!=null];
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='B2BCopassengerTins'].Endpoint__c;   
        for(case cs:caseRecords){
            String dojStr = cs.Date_Of_Journey_New__c.format('yyyy-MM-dd');
            System.debug('dateTimeStr-->'+dojStr);
            // if(type=='B2C'){
            //     endPoint=endPoint+cs.Service_Id__c+'&doj='+dojStr;
            // }else {
            //     endPoint=endPoint+cs.Route_Id__c+'&doj='+dojStr;
            // }
            endPoint=endPoint+cs.Route_Id__c+'&doj='+dojStr;
            Http h= new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            //req = HttpRequestUtil.populateHeaders(req);
            req.setHeader('Accept', 'application/json');
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            res=h.send(req);
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c='B2BCo-PassengerTins';
            dbl.Case_Number__c = string.valueOf(cs.casenumber);
            dbl.Request_Data__c=endPoint;
            dbl.Response_Received__c=res.getBody();
            dbLogRecords.add(dbl);
            
        }
        if(!dbLogRecords.isEmpty())
            insert dbLogRecords;
    }
    
    @future
    public static void sendEmailAlertToNonCallableBOs(set<id> nonCallableCsIds)
    {
        
        List<case> caseRecords= [select id,BO_Description__c,Bus_Type__c,Auto_Closure__c,caseNumber,CreatedDate,Issue_Type__c,Issue_Sub_Category__c,PNR_No__c,Source_And_Destination__c,Source_Destination_id__c,IsShortRoute__c,Boarding_Point__c,Boarding_Time__c,Total_Ticket_Amount__c,BO_Type__c,Country__c,BO_Email__c,BO_Email1__c,BD_Email__c,BD_Email1__c,status,Assigned_to_BD__c,Assigned_By__c,Assigned_to_BD_OwnerName__c,ownerid,Thread_Id__c,Owner.name,Owner.userRole.name,Reminders__c from case where BO_Type__c ='Non Callable' and id in :nonCallableCsIds];
        list<EmailMessage> emsgList=new list<EmailMessage>();
        list<case> csList=new list<case>();
        
        for(case c:caseRecords){
            
            if(c.Issue_Type__c=='Bus Cancellation'){
                c.Origin= 'InBound Call';
            }
            
            EmailMessage emailMsg = new EmailMessage();
            List<String> toAddresses = new List<String>();  
            List<String> CcAddresses = new List<String>();
            
            string BoMailAddress = string.isNotBlank(c.BO_Email__c) ? c.BO_Email__c : string.isNotBlank(c.BO_Email1__c) ? c.BO_Email1__c :'';
            
            string BdMailAddress = string.isNotBlank(c.BD_Email__c) ? c.BD_Email__c : string.isNotBlank(c.BD_Email1__c) ? c.BD_Email1__c :'';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setUseSignature(false);
            email.setSaveAsActivity(true);
            
            c.Reminders__c='1';
            email.setSubject(' First Email - '+'caseNumber:'+c.caseNumber);
            email.setHtmlBody('<html><body>Dear Bus Operator, <br/> <br/> Kindly check the below complaint received from customer and reply to us at the earliest. <br/> <br/>Issue Type :  '+c.Issue_Type__c+'<br/>Sub-issue Type :  '+c.Issue_Sub_Category__c+'<br/>Case comments- '+c.BO_Description__c+'<br/><br/>Ticket Details :<br/>PNR No- '+c.PNR_No__c+'<br/>Source & Destination- '+c.Source_And_Destination__c+'<br/>Boarding point date & time- '+c.Boarding_Point__c+'/'+c.Boarding_Time__c+'<br/>Bus type- '+c.Bus_Type__c+'<br/>Total Fare-'+c.Total_Ticket_Amount__c+' <br/><br/> Thanks for your support, <br/>Team redBus</body></html>');
            
            toAddresses.add(BoMailAddress);
            CcAddresses.add(BdMailAddress);
            
            email.setToAddresses(toAddresses);
            email.setCcAddresses(CcAddresses);
            //noncallablebo@263o95hdom324eg6l6t3v9p3si5rnscfbes44g0vdfr0ah6d3c.28-1kzyaeaw.ind112.apex.salesforce.com
            email.setReplyTo('noncallablebo@263o95hdom324eg6l6t3v9p3si5rnscfbes44g0vdfr0ah6d3c.28-1kzyaeaw.ind112.apex.salesforce.com');          
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
                if(!test.isRunningTest()){
                    Messaging.sendEmail(emailList);
                }              
            System.debug(emailList[0].getToAddresses());
            emailMsg.ToAddress=(emailList[0].getToAddresses())[0];
            emailMsg.Subject=emailList[0].getSubject();
            emailMsg.HtmlBody=emailList[0].getHtmlBody();
            emailMsg.ParentId = c.Id; //Attach with the case
            emailMsg.MessageDate = system.now();
            emailMsg.Status = '0';
            emsgList.add(emailMsg);
            csList.add(c);
            
        }
        
        if(!csList.isEmpty()){
            update csList;
        }
        
        if(!emsgList.isEmpty()){
            insert emsgList;
        }
    }    
    
    //UpdateParentCaseHaveExpRefCheck
    public static void UpdateParentCaseHaveExpRefCheck(set<id> setParentExpRefcsIds)
    {
        List<case> updatecslst =new List<case>();
        List<case> parentCaseRecords= [select id,Has_Exceptional_Refund_Case__c from case  where id in :setParentExpRefcsIds and Has_Exceptional_Refund_Case__c=false and Type != 'B2B'];
        for(case c:parentCaseRecords){
            c.Has_Exceptional_Refund_Case__c=true;
        }
        if(!parentCaseRecords.isEmpty()){
            update parentCaseRecords;
        }
    }
    
}