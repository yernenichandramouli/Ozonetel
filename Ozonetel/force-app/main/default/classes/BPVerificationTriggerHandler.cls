/**
*
* Name           : BPVerificationTriggerHandler 
* Created Date   : 02 Jul 2021
* Created By     : Mahendra
* Purpose        : To handle BO region details
* Test class     : BPVerificationTriggerTest
*
**/

public class BPVerificationTriggerHandler{
    
    public static boolean stopOpenCaseCreation=true;
    public static boolean UpdateCallstatusTime=true;
    
    
    public static void BeforeInsert(List<BP_Verification__c> TriggerNew){
        
        Set<String> servcPrset=new Set<String>();
        Map<String,String> servMap=new Map<String,String>();
        
        for(BP_Verification__c bpv:triggernew){
            if(bpv.Service_Provider_Id__c!=null){
                servcPrset.add(bpv.Service_Provider_Id__c);
            }
            
        }
        List<Service_Provider__c> servList =[SELECT Operator_Id__c,Location__c FROM Service_Provider__c where Location__c!=null and Operator_Id__c IN :servcPrset];
        if(servList.size()>0){
            for(Service_Provider__c se:servList){
                servMap.put(se.Operator_Id__c,se.Location__c);
            }
            
        }
        
        for(BP_Verification__c bp: triggerNew){
            if(bp.Service_Provider_Id__c != null && servMap.size()>0) {
                Try{
                    bp.BO_Region__c = servMap.get(bp.Service_Provider_Id__c);
                }
                catch(exception e){
                    system.debug('<<<Exception occured---->'+e.getMessage());
                    
                }
            }
        }
        
        
    }
    
    public static void AfterUpdate(List<BP_Verification__c> TriggerNew,Map<Id,BP_Verification__c> TriggerOldMap){
        
        Set<String> setCallStatus = new Set<String>(System.label.bpVerificationStatus.split(','));
        map<id,BP_Verification__c> BpVmap = new map<id,BP_Verification__c>();
        list<BP_Verification__c> bplist = new list<BP_Verification__c>();
        set<id> setbpIds = new set<id>();
        set<id> Oldstatusbpids = new set<id>();
        
        
        for(BP_Verification__c bpv:triggernew){
            
            
            if(string.isNotBlank(bpv.Call_Status__c) && setCallStatus.contains(bpv.Call_Status__c)){
                BpVmap.put(bpv.id,bpv);
                setbpIds.add(bpv.id);
            }
            
            
            String  oldcallStatus = TriggerOldMap.get(bpv.Id).Call_Status__c;
            system.debug('==oldcallStatus=='+oldcallStatus);
            if(oldcallStatus!=bpv.Call_Status__c){
                system.debug('--57--');
                Oldstatusbpids.add(bpv.id);
            }
            
        }
        
        if(!Oldstatusbpids.isEmpty() && BPVerificationTriggerHandler.UpdateCallstatusTime)
        {
            BPVerificationTriggerHandler.UpdateCallstatusTime = false;
            BPVerificationTriggerHandler.CallStatusTimeUpdate(Oldstatusbpids);         
        }
        
        
        
        if(!setbpIds.isEmpty() && BPVerificationTriggerHandler.stopOpenCaseCreation)
        {
            BPVerificationTriggerHandler.stopOpenCaseCreation = false;
            BPVerificationTriggerHandler.caseCreation(setbpIds);    
            BPVerificationTriggerHandler.caseNumberUpdate(setbpIds);     
        }
        
        
        
    }
    public static void CallStatusTimeUpdate(set<id> OldbpIds){
        list<BP_Verification__c> bplst=[select id,Call_Status__c,CallstatusDatetime__c from BP_Verification__c where id in:OldbpIds ];
        list<BP_Verification__c> lstBP=new list<BP_Verification__c>();
        for(BP_Verification__c bpp:bplst){
            BP_Verification__c bp = new BP_Verification__c();
            bp.CallstatusDatetime__c=system.now();
            bp.id=bpp.id;
            lstBP.add(bp);
            system.debug('==CallstatusDatetime__c=='+bpp.CallstatusDatetime__c);
            
        }
        update lstBP;
    }
    
    public static void caseCreation(set<id> bpIds ){
        
        List<case> caseListInsert=new List<case>();
        list<CaseComment> listCommToInsert=new list<CaseComment>();
        Group BPQ=[select id from Group where type='Queue' AND developername='BD_Queue']; 
        map<id,BP_Verification__c> mapbp= new map<id,BP_Verification__c>();
        Map<id,case> mapcs=new Map<id,case>();
        map<string,string> mapContact=new map<string,string>();
        map<string,BP_Verification__c> mapbpContact = new map<string,BP_Verification__c>();
        list<BP_Verification__c> bpListUpdate = new list<BP_Verification__c>();
        
        List<Case> csLst =[Select id,CaseNumber,BP_Contact_Number__c,BP_Verification__c from case where BP_Verification__c in:bpIds];
        for(case css:csLst){
            mapcs.put(css.BP_Verification__c,css);   
            mapContact.put(css.BP_Contact_Number__c,css.casenumber);  
        }
        list<BP_Verification__c>  bplst=[select id,Service_Provider_Name__c,Service_Provider_Id__c,Source__c,Destination__c,BP_Name__c,Call_Status__c,BP_Contact_No__c,CallstatusDatetime__c,BO_Region__c,BP_Id__c,Vendor_BP_name__c from BP_Verification__c where id in:bpIds];
        system.debug('==bplst=='+bplst);
        
        
        
        for(BP_Verification__c bp:bplst){
            if(string.isNotBlank(bp.Call_Status__c)){
                mapbpContact.put(bp.BP_Contact_No__c,bp);   
                system.debug('>>>mapbpContact>>>'+mapbpContact);
            }
        }
        
        
        
        
        list<BP_Verification__c>  bpSameContatclst=[select id,Service_Provider_Name__c,Service_Provider_Id__c,Source__c,Destination__c,BP_Name__c,Call_Status__c,BP_Contact_No__c,CallstatusDatetime__c,BO_Region__c,BP_Id__c,Vendor_BP_name__c from BP_Verification__c where BP_Contact_No__c in:mapbpContact.keySet() ];
        for(BP_Verification__c bpcon:bpSameContatclst){
            system.debug('===bpppp=='+mapContact.get(bpcon.BP_Contact_No__c));
            if(mapbpContact.containsKey(bpcon.BP_Contact_No__c)){
                system.debug('==>>bp>>'+mapbpContact.containsKey(bpcon.BP_Contact_No__c));
                BP_Verification__c bpv =new BP_Verification__c();
                bpv.Call_Status__c =mapbpContact.get(bpcon.BP_Contact_No__c).Call_Status__c;
                bpv.id=bpcon.id;
                bpListUpdate.add(bpv); 
                system.debug(bpListUpdate);
            } 
        } 
        
        
        for(BP_Verification__c bp:bplst){
            
            case cs =new case();
            system.debug('===bp con=='+mapContact.containsKey(bp.BP_Contact_No__c)+'---b--'+bp+'===con='+bp.BP_Contact_No__c);
            if(!mapcs.containsKey(bp.id) && !'Correct Number'.equalsIgnorecase(bp.Call_Status__c)){
                system.debug('===89===');
                mapbp.put(bp.id,bp);
                CaseComment csCom = new CaseComment();
                cs.Issue_Type__c='BP Verification';
                cs.Issue_Sub_Category__c='Verifying BP contact';
                cs.status='Escalated to BD';
                cs.Type_ctp__c=bp.BP_Name__c;
                cs.BP_Contact_Number__c=bp.BP_Contact_No__c;
                cs.BD_Location__c=bp.BO_Region__c;
                cs.Business_Unit_ct__c='REDBUS_IN';
                cs.Bus_Operator_Namee__c=bp.Service_Provider_Name__c;
                cs.Service_Providerr_Id__c=bp.Service_Provider_Id__c;
                cs.SourceT__c=bp.Source__c;
                cs.DestinationT__c=bp.Destination__c;
                cs.Customer_provided_Boarding_Point__c=bp.BP_Name__c;
                cs.country__c=OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Country__c;
                cs.Business_Type__c=OrderItemTransactionResource__c.getValues(cs.Business_Unit_ct__c).Case_Business_Type__c;
                cs.Assigned_to_BD__c=system.now();
                cs.ownerid=BPQ.id;   
                cs.BP_Verification__c=bp.id;
                cs.Origin='InBound Call';
                caseListInsert.add(cs);
                system.debug('==caseListInsert=='+caseListInsert);
            }
            
            
        }
        try{
            if(!bpListUpdate.isEmpty()){
                update bpListUpdate;
            }
            
            if(!caseListInsert.isEmpty()){
                insert caseListInsert;
            }
            
            
            if(!caseListInsert.isEmpty()){
                for(case cs:caseListInsert){
                    
                    CaseComment csCom = new CaseComment();
                    string bpdetails='BP no:'+mapbp.get(cs.BP_Verification__c).BP_Contact_No__c+ ',--BP Name:'+mapbp.get(cs.BP_Verification__c).BP_Name__c+',--BP id--'+mapbp.get(cs.BP_Verification__c).BP_Id__c+ ',--call status--'+mapbp.get(cs.BP_Verification__c).Call_Status__c+ ',--BP vendor name-'+mapbp.get(cs.BP_Verification__c).Vendor_BP_name__c+',--service providerName--'+mapbp.get(cs.BP_Verification__c).Service_Provider_Name__c+',--service provider id--'+mapbp.get(cs.BP_Verification__c).Service_Provider_Id__c;
                    csCom.commentBody =bpdetails;
                    csCom.parentid =cs.id;
                    listCommToInsert.add(csCom);
                }
                
                if(!listCommToInsert.isEmpty()){
                    insert listCommToInsert;
                }
                
            }
        }Catch(Exception e)
        {
            
            System.debug('Error='+e);
            
        }
        
        
    }
    
    public static void caseNumberUpdate(set<id> csbpIds){
        system.debug('@future');
        list<BP_Verification__c> bpListUpdate = new list<BP_Verification__c>();
        list<BP_Verification__c>  bpclst=[select id,Service_Provider_Name__c,Service_Provider_Id__c,Source__c,Destination__c,BP_Name__c,Call_Status__c,BP_Contact_No__c,CallstatusDatetime__c,BO_Region__c,BP_Id__c,Vendor_BP_name__c from BP_Verification__c where id in:csbpIds];
        map<string,BP_Verification__c> mapbpContact = new map<string,BP_Verification__c>();
        map<string,string> mapContact=new map<string,string>();
        
        for(BP_Verification__c bp:bpclst){
            if(string.isNotBlank(bp.Call_Status__c) && (!'Correct Number'.EqualsIgnoreCase(bp.Call_Status__c) || !'RNR'.EqualsIgnoreCase(bp.Call_Status__c) )){
                mapbpContact.put(bp.BP_Contact_No__c,bp);   
                system.debug('>>>mapbpContact>>>'+mapbpContact);
            }
        }
        
        List<Case> csLst =[Select id,CaseNumber,BP_Contact_Number__c,BP_Verification__c from case where Issue_Type__c='BP Verification' and Issue_Sub_Category__c='Verifying BP contact' and BP_Contact_Number__c in:mapbpContact.keyset()];
        If(!csLst.isEmpty()){
            for(case css:csLst){
                mapContact.put(css.BP_Contact_Number__c,css.casenumber);  
            }
            
            list<BP_Verification__c>  bpSameContatclst=[select id,Service_Provider_Name__c,Service_Provider_Id__c,Source__c,Destination__c,BP_Name__c,Call_Status__c,BP_Contact_No__c,CallstatusDatetime__c,BO_Region__c,BP_Id__c,Vendor_BP_name__c from BP_Verification__c where Exist_Case_Number__c=null and Call_Status__c!=null and BP_Contact_No__c in:mapContact.keySet()];
            for(BP_Verification__c bpcon:bpSameContatclst){
                system.debug('===bpppp=='+mapContact.get(bpcon.BP_Contact_No__c));
                if(mapContact.containsKey(bpcon.BP_Contact_No__c)){
                    BP_Verification__c bpv = new BP_Verification__c();
                    if(!'Correct Number'.EqualsIgnoreCase(bpcon.Call_Status__c) || !'RNR'.EqualsIgnoreCase(bpcon.Call_Status__c)){
                        bpv.Exist_Case_Number__c=mapContact.get(bpcon.BP_Contact_No__c);
                    }
                    
                    bpv.id=bpcon.id;
                    bpListUpdate.add(bpv); 
                    system.debug(bpListUpdate);
                }
            } 
            
        }
        if(!bpListUpdate.isEmpty()){
            update bpListUpdate;
        }
        
    }  
}