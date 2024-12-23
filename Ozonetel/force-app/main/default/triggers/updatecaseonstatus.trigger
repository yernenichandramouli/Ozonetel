trigger updatecaseonstatus on Order_Items__c(after update,after insert,before update)
{
    Set<id> tripids = new Set<id>();
    Map<String,RecTypesAndStatus__c> maprec = new Map<String,RecTypesAndStatus__c>();
    Map<id,Case> mapcases = new Map<id,Case>();
    Map<String,String> mapstatus = new Map<String,String>();
    List<Case> Updcases = new List<Case>();
    List<Case> UpdClosedcases = new List<Case>();
    List<casecomment> ccList=new List<casecomment>();
    public set<id> bpNumberIds=new set<id>();
    ID RedTypeId= Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('Bus Booking').getRecordTypeId();
    ID B2BRecTypeId= Schema.getGlobalDescribe().get('Order_Items__c').getDescribe().getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
    Set<String> quotaOpers = new Set<String>(System.Label.Quota_Management_OperIds.split(','));
    Map<String,id> mapTinItemIds = new Map<String,id>();
    set<string> canTripIds=new set<string>();
    set<string> busCancelIds=new set<string>();
    
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        
        for(Transaction_Status_Category__c t: Transaction_Status_Category__c.getAll().Values())
        {
            mapstatus.put(t.Status__c,t.Category__c);
        }
        for(RecTypesAndStatus__c r: RecTypesAndStatus__c.getAll().Values())
        {
            maprec.put(r.Transaction_Status__c,r);
        }
        for(Order_Items__c o: trigger.new)
        {
            if(RedTypeId==o.RecordTypeId)
            { 
                if(o.status__c!=Null && trigger.oldMap.get(o.id).status__c!=Null && trigger.oldMap.get(o.id).status__c!=o.status__c)
                {
                    if(maprec.containsKey(o.status__c) && maprec.containsKey(trigger.oldMap.get(o.id).status__c) && maprec.get(o.status__c).Case_Type__c!= maprec.get(trigger.oldMap.get(o.id).status__c).Case_Type__c)
                    {
                        tripids.add(o.id);
                    }
                    else if(mapstatus.containskey(o.status__c) && mapstatus.get(o.status__c)=='Confirmed')
                    {
                        tripids.add(o.id);
                    }
                }
                if(o.Transaction_Latest_status__c=='SUCCESS' && o.Transaction_Latest_status__c!=Trigger.oldMap.get(o.Id).Transaction_Latest_status__c)
                {
                    tripids.add(o.id);
                }
                
                if(o.Business_Unit__c=='REDBUS_ID' && String.isNotBlank(o.Order_Item_Reference_No__c) && o.Order_Item_Reference_No__c!=Trigger.oldMap.get(o.id).Order_Item_Reference_No__c && 'Booked'.equalsIgnoreCase(o.Transaction_Status__c) && quotaOpers.contains(o.Service_Provider_Id__c))
                {
                    mapTinItemIds.put(o.Order_Item_Reference_No__c,o.id);
                }
                
                /*  if(string.isNotBlank(o.Transaction_Status__c) && o.Transaction_Status__c.contains('Cancelled') && o.Business_Unit__c=='REDBUS_IN' && string.isNotBlank(o.Order_Id__c) && o.Transaction_Status__c!=Trigger.oldMap.get(o.id).Transaction_Status__c){
canTripIds.add(o.Order_Id__c);
}*/
            }

            if(B2BRecTypeId==o.RecordTypeId && (o.Inventory_Type__c=='GOIBIBO' || o.Inventory_Type__c=='MMT') && 'Bus cancellation'.equalsIgnoreCase(o.Cancellation_Reason__c)){
                if(string.isNotBlank(o.Transaction_Status__c) && o.Transaction_Status__c.contains('Cancelled') && o.Business_Unit__c=='REDBUS_IN' && string.isNotBlank(o.Order_Item_Reference_No__c) && o.Transaction_Status__c!=Trigger.oldMap.get(o.id).Transaction_Status__c){
                    busCancelIds.add(o.Id);
                }
            }
        }
        
        if(!mapTinItemIds.keySet().isEmpty() && !TransactionTriggerHandler.stopQuotaCaseCreation)
        {
            TransactionTriggerHandler.stopQuotaCaseCreation = true;
            TransactionTriggerHandler.createQuotaMngtCase(mapTinItemIds);
        }
        
        /*if(!canTripIds.isEmpty() && TransactionTriggerHandler.stopBusCClosedCase){
TransactionTriggerHandler.stopBusCClosedCase=false;
TransactionTriggerHandler.closeBusCanCases(canTripIds);
}*/
        if(!busCancelIds.isEmpty() && TransactionTriggerHandler.stopGiMMtBusCancelIds){
            TransactionTriggerHandler.stopGiMMtBusCancelIds=false;
            TransactionTriggerHandler.giMMTcloseBusCanCases(busCancelIds);
        }
        
        for(Case c: [Select id,Transaction_ID__c,Transaction_ID__r.status__c,RecordTypeid,Recordtype.Name FROm Case WHERE Transaction_ID__c IN: tripids])
        {
            mapcases.put(c.Transaction_ID__c,c);
        }
        for(Order_Items__c o: trigger.new)
        {
            if(RedTypeId==o.RecordTypeId)
            {
                if(o.status__c!=Null && mapcases.containskey(o.id))
                {
                    System.debug('---CloseStatus---'+o.status__c);
                    System.debug('---CloseStatus---'+mapstatus.get(o.status__c));
                    
                    id Recid1 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();                   
                    if(mapcases.get(o.id).RecordTypeid==Recid1)
                    {
                        id Recid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                        mapcases.get(o.id).RecordTypeid=Recid;
                        Updcases.add(mapcases.get(o.id));
                    }
                    if(mapstatus.containskey(o.status__c) && mapstatus.get(o.status__c) == 'Confirmed')
                    {
                        System.debug('@@mapstatus.get(o.status__c)@@@'+mapstatus.get(o.status__c));
                        if(mapcases.get(o.Id).Recordtype.Name=='White Failed Transaction (WFT)' || mapcases.get(o.Id).Recordtype.Name=='Green Failed Transaction (GFT)')
                        {
                            casecomment ccObj=new casecomment();                          
                            ccObj.CommentBody='Auto Closure WFT/GFT Case';
                            ccObj.parentid=mapcases.get(o.Id).id;
                            ccList.add(ccObj);
                            mapcases.get(o.id).Status= 'Closed';
                            System.debug('@@@@@ CASE STATUS'+ mapcases.get(o.id).Status);
                            UpdClosedcases.add(mapcases.get(o.id));
                        }
                    }
                }
                
                
            }
        }
        if(!ccList.isEmpty()){
            insert ccList;
        }   
        if(UpdClosedcases.size()>0)
        {
            StaticBooleans.CreateCase = False;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            update UpdClosedcases;
        }
        if(Updcases.size()>0)
        {
            StaticBooleans.CreateCase = False;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            update Updcases;
        }
        
        TransactionTriggerHandler.ZQPCaseCreationOnUpdate(Trigger.New,Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        TransactionTriggerHandler.transactionAfterInsert(Trigger.New,Trigger.oldMap,Trigger.Old);
        TransactionTriggerHandler.processMMTCaseRelink(Trigger.New);
        //CRM 1895
        for(Order_Items__c o: trigger.new){
            if(B2BRecTypeId==o.RecordTypeId && (o.Inventory_Type__c=='GOIBIBO' || o.Inventory_Type__c=='MMT') && 'Bus cancellation'.equalsIgnoreCase(o.Cancellation_Reason__c)){
                if(string.isNotBlank(o.Transaction_Status__c) && o.Transaction_Status__c.contains('Cancelled') && o.Business_Unit__c=='REDBUS_IN' && string.isNotBlank(o.Order_Item_Reference_No__c)){
                    busCancelIds.add(o.Id);
                }
                if(!busCancelIds.isEmpty() && TransactionTriggerHandler.stopGiMMtBusCancelIds){
                    TransactionTriggerHandler.stopGiMMtBusCancelIds=false;
                    TransactionTriggerHandler.giMMTcloseBusCanCases(busCancelIds);
                }
            }
        }
    }  
    
    if(Trigger.isBefore && Trigger.isUpdate && System.Label.BoNumberUpdateCheck=='TRUE')
    {
        TransactionTriggerHandler.transactionBeforeUpdate(Trigger.New,Trigger.oldMap);
        TransactionTriggerHandler.processMMTCaseRelink(Trigger.New);
    }  
    
}