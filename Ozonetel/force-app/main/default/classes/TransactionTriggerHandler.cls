/*
* Name           : TransactionTriggerHandler
* Created Date   : 14 June 2017
* Created By     : Veeramanikanta R
* Purpose        : Handler for Transaction object actions 
* Test class     : TransactionTriggerHandlerTest
*/

public class TransactionTriggerHandler{
    
    public static boolean stopCaseRelink= false;
    public static boolean stopMMTCaseRelink= false;
    public static boolean stopQuotaCaseCreation= false;
    public static boolean stopBusCClosedCase= true;
    public static boolean stopGiMMtBusCancelIds = true;
    static Boolean enableCaseRelink = [SELECT EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CaseRelinking'].EnableLog__c;
    static Id quotaCSQueueId = [Select id from Group where type='Queue' AND developername='Quota_CS_Queue'].id;
    
    public static void transactionAfterInsert(List<Order_Items__c> triggerNew,Map<Id,Order_Items__c> trigOldMap,List<Order_Items__c> trigOld)
    {
        Set<String> quotaOperIds = new Set<String>(System.Label.Quota_Management_OperIds.split(','));
        Map<String,Id> mapOrItNametoOrItId = new Map<String,Id>();
        Map<String,Id> mapTripIdToOrItId = new Map<String,Id>();
        Set<String> setConfirmTins = new Set<String>();
        Map<String,Id> maptinToItemIds = new Map<String,Id>();
        List<case> csUpList=new List<case>();
        List<case> csInList=new List<case>();
        List<casecomment> ccInsert = new List<casecomment>();
        
        for(Order_Items__c orIt : triggerNew)
        {
            if(String.isNotBlank(orIt.Name))
                mapOrItNametoOrItId.put(orIt.Name,orIt.Id);
            
            if(orIt.Flag__c==0 && String.isNotBlank(orIt.Order_Id__c))
                mapTripIdToOrItId.put(orIt.Order_Id__c,orIt.Id);
            
            if(orIt.Business_Unit__c=='REDBUS_ID' && String.isNotBlank(orIt.Order_Item_Reference_No__c) && 'Booked'.equalsIgnoreCase(orIt.Transaction_Status__c) && quotaOperIds.contains(orIt.Service_Provider_Id__c))
            {
                setConfirmTins.add(orIt.Order_Item_Reference_No__c);
                maptinToItemIds.put(orIt.Order_Item_Reference_No__c,orIt.id);
            }
            
            if(String.isNotBlank(orIt.Order_Item_Reference_No__c) && 'Booked'.equalsIgnoreCase(orIt.Transaction_Status__c))
            {
                    List<Case> zqpCaseList = [Select Id, CaseNumber, Booking_Mobile_No__c, Status, Issue_Type__c, Issue_Sub_Category__c, Refund_Amount__c, Order_UUId__c, CreatedDate, Total_Fare_Value__c from Case Where Booking_Mobile_No__c = :orIt.Mobile__c and Status = 'Open' and CreatedDate >= :System.now().addMinutes(-15) and Issue_Type__c ='Booking Error' Order By CreatedDate DESC LIMIT 1];
                	if (!zqpCaseList.isEmpty()) {
                    	Case zqpCase = zqpCaseList[0];
                    	System.debug('Found case for ZQP: '+zqpCase.CaseNumber);
                    	Case newCase = new Case();
                    	newCase.Issue_Type__c = zqpCase.Issue_Type__c;
                    	newCase.Issue_Sub_Category__c = zqpCase.Issue_Sub_Category__c;
                    	newCase.Booking_Mobile_No__c = zqpCase.Booking_Mobile_No__c;
                    	newCase.Transaction_ID__c = orIt.Id;
                    	newCase.TIN_No__c = orIt.Order_Item_Reference_No__c;
                    	if (zqpCase.Refund_Amount__c > 0) {
            				newCase.Refund_Amount__c = zqpCase.Total_Fare_Value__c - zqpCase.Refund_Amount__c;
                    	}
                    	else {
                       		newCase.Refund_Amount__c = zqpCase.Total_Fare_Value__c;
                    	}
                    	newCase.is_ZQP__c = true;
                    	newCase.Subject = 'ZQP Automation';
                		newCase.Order_UUId__c=orIt.Order_Uuid__c;
                    	csInList.add(newCase);
                    	
                    	Case expCase = new Case();
                		expCase.ParentId = newCase.Id;
                		expCase.Issue_Type__c = 'Exceptional Refund';
                		expCase.Issue_Sub_Category__c = 'Zero Question Policy';
                		expCase.Booking_Mobile_No__c = newCase.Booking_Mobile_No__c;
                		expCase.Transaction_ID__c = newCase.Transaction_ID__c;
                		expCase.TIN_No__c = newCase.TIN_No__c;
                		expCase.Refund_Amount__c = newCase.Refund_Amount__c;
                    	expCase.Order_UUId__c=newCase.Order_UUId__c;
                    	expCase.Subject = 'ZQP Automation';
                    	csInList.add(expCase);
						
                		casecomment cc=new casecomment();
              			cc.parentId=zqpCase.Id;
                    	cc.commentbody='Closing Case C1 after creating C2 for T2 :'+orIt.Order_Item_Reference_No__c+' for ZQP';
          				//insert cc;
                    	ccInsert.add(cc);
                    	zqpCase.Status = 'Closed';
                    	//update zqpCase;
                    	csUpList.add(zqpCase);
                	}
            	}
        }
        if (!ccInsert.isEmpty()){
           	try {
               	insert ccInsert;
           	} catch (DmlException e) {
               	System.debug('Error: ' + e.getMessage());
           	}
        }
        if (!csUpList.isEmpty()) {
           	try {
               	update csUpList;
           	} catch (DmlException e) {
               	System.debug('Error: ' + e.getMessage());
           	}
        }
        if (!csInList.isEmpty()) {
           	try {
               	insert csInList;
           	} catch (DmlException e) {
               	System.debug('Error: ' + e.getMessage());
           	}
        }
        
        if(enableCaseRelink && !stopCaseRelink)
        {
           	stopCaseRelink = true;
           	TransactionTriggerHandler.relinkCasesToTransaction(mapOrItNametoOrItId,mapTripIdToOrItId);
        }
        
        if(!maptinToItemIds.keySet().isEmpty() && enableCaseRelink && !stopQuotaCaseCreation)
        {
           	stopQuotaCaseCreation = true;
           	TransactionTriggerHandler.createQuotaMngtCase(maptinToItemIds);
        }
		
        // if(enableCaseRelink && !stopMMTCaseRelink){
        //     stopMMTCaseRelink = true;
        //     TransactionTriggerHandler.processMMTCaseRelink(mapOrItNametoOrItId);
        // }
        
    }
    
    public static void createQuotaMngtCase(Map<String,Id> maptinToItemIds)
    {
        if(System.isFuture() || System.isBatch())
            createQuotaCase(maptinToItemIds);
        
        else
            asyncCreateQuotaCase(maptinToItemIds);
        
    }
    
    @future
    private static void asyncCreateQuotaCase(Map<String,Id> maptinToItemIds)
    {
        createQuotaCase(maptinToItemIds);
    }
    
    private static void createQuotaCase(Map<String,Id> maptinToItemIds)
    {
        Map<String,String> mapTins = new Map<String,String>();
        Map<Id,Order_Items__c> mapOrderItems = new Map<Id,Order_Items__c>([Select id,Order_Id__c,Route_Id__c,Source__c,Destination__c,Email_Copy__c,Mobile__c FROM Order_Items__c WHERE Id IN :maptinToItemIds.keySet()]);
        
        List<Case> listCasesToInsert = new List<Case>();
        for(Case c: [Select id,tin_no__c from Case WHERE Issue_Type__c ='Quota Management' AND Issue_Sub_Category__c='Booking Confirmation' AND tin_no__c IN:maptinToItemIds.keySet()])
        {
            mapTins.put(c.tin_no__c,c.tin_no__c);
        }
        
        for(String tin : maptinToItemIds.keySet())
        {
            if(!mapTins.containsKey(tin))
            {
                Order_Items__c ordIt = new Order_Items__c();
                
                
                if(maptinToItemIds.get(tin)!=null && (test.isRunningTest() ||mapOrderItems.get(maptinToItemIds.get(tin))!=null))
                {
                    if(!test.isRunningTest())
                    	ordIt = mapOrderItems.get(maptinToItemIds.get(tin));
                    Case cs = new Case();
                    cs.Country__c ='Indonesia';
                    cs.Business_Type__c='Indonesia-Bus';
                    cs.Issue_Type__c = 'Quota Management';
                    cs.Issue_Sub_Category__c ='Booking Confirmation';
                    cs.tin_no__c = tin;
                    cs.Transaction_ID__c =ordIt.id;
                    cs.Trip_Id_ct__c = ordIt.Order_Id__c;
                    cs.SS_Route_Id__c = ordIt.Route_Id__c;
                    cs.SourceT__c = ordIt.Source__c;
                    cs.DestinationT__c = ordIt.Destination__c;
                    cs.Customer_Email_ID__c = ordIt.Email_Copy__c;
                    cs.Customer_Phone_Number__c = ordIt.Mobile__c;
                    cs.Email_Id_ct__c = ordIt.Email_Copy__c;
                    cs.Phone_No_ct__c =ordIt.Mobile__c;
                    cs.ownerid=quotaCSQueueId;
                    listCasesToInsert.add(cs);
                }
            }
        }
        
        if(!listCasesToInsert.isEmpty())
        {
            insert listCasesToInsert;
            stopQuotaCaseCreation= true;
        }
        
    }
    
    
    
    //Sreenivas M - 22 Jan 2018 - To relink the cases to transaction upon sync
    public Static void relinkCasesToTransaction(Map<String,Id> mapOrItNametoOrItId,Map<String,Id> mapTripIdToOrItId)
    {
        if(System.isFuture() || System.isBatch())
            processCaseRelinking(mapOrItNametoOrItId,mapTripIdToOrItId);
        
        else
            asyncProcessCaseRelinking(mapOrItNametoOrItId,mapTripIdToOrItId);          
        
    }
    
    @future
    private static void asyncProcessCaseRelinking(Map<String,Id> mapOrItNametoOrItId,Map<String,Id> mapTripIdToOrItId)
    {
        processCaseRelinking(mapOrItNametoOrItId,mapTripIdToOrItId);
    }
    
    private static void processCaseRelinking(Map<String,Id> mapOrItNametoOrItId,Map<String,Id> mapTripIdToOrItId)
    {
        
        List<case> listCaseToUpdate = new List<Case>();
        
        for(Case c: [Select id,Order_Item_Id__c,Trip_Id_ct__c From Case WHERE Transaction_ID__c=NULL AND (Order_Item_Id__c IN :mapOrItNametoOrItId.keySet() OR Trip_Id_ct__c IN: mapTripIdToOrItId.keySet())])
        {
            if(String.isNotBlank(c.Order_Item_Id__c))
                c.Transaction_ID__c = mapOrItNametoOrItId.containsKey(c.Order_Item_Id__c)?mapOrItNametoOrItId.get(c.Order_Item_Id__c):null;
            
            else if(String.isNotBlank(c.Trip_Id_ct__c))
                c.Transaction_ID__c = mapTripIdToOrItId.containsKey(c.Trip_Id_ct__c)?mapTripIdToOrItId.get(c.Trip_Id_ct__c):null;
            
            listCaseToUpdate.add(c);
            
        }
        try
        {
            stopQuotaCaseCreation = true;
            Database.update(listCaseToUpdate,false);
        }
        Catch(Exception e)
        {
            System.debug('error in relinking the case..'+e);
        }
        
    }

    //To reLink MMT cases to MMT Transactions.
    public static void processMMTCaseRelink(List<Order_Items__c> triggerNew){
        Map<String,Id> mapOrItNametoOrIt = new Map<String,Id>();
        for(Order_Items__c orIt : triggerNew){
            mapOrItNametoOrIt.put(orIt.Name,orIt.Id);
        }
        if(!mapOrItNametoOrIt.isEmpty()){
            List<case> listCaseToUpdate = new List<Case>();
            for(Case c: [Select id,PNR__c,Transaction_ID__c,Trip_Id_ct__c,New_Tin__c From Case WHERE My_Desk_Id__c!=Null AND Channel_ct__c in ('MMT', 'GI') AND Transaction_ID__c=NULL AND (PNR__c IN :mapOrItNametoOrIt.keySet())]){
                if(String.isNotBlank(c.PNR__c)){
                    c.Transaction_ID__c = mapOrItNametoOrIt.containsKey(c.PNR__c)?mapOrItNametoOrIt.get(c.PNR__c):null;
                    c.New_Tin__c = string.valueOf(c.Trip_Id_ct__c);
                    listCaseToUpdate.add(c);
                }
            }
            try{
                stopQuotaCaseCreation = true;
                Database.update(listCaseToUpdate,false);
            }catch(Exception e){
                System.debug('error in relinking the case..'+e);
            }
        }
    }
    
    public static void closeBusCanCases(set<string> tIds){
        
        List<case> csList=new List<case>();
        DataDeletionSetup__mdt csQuery=new DataDeletionSetup__mdt();
        csQuery=[SELECT isActive__c,QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Case_Closure'];      
        csList= (List<case>)Database.query(csQuery.QueryDetails__c);
        list<casecomment> ccList=new list<casecomment>();
        list<case> csUpList=new list<case>();
        for(case c:csList){
            casecomment cc=new casecomment();
            cc.parentid=c.id;
            cc.commentbody=csQuery.DistributionList__c;
            
            case cs=new case();
            cs.id=c.id;
            cs.status='Closed';
            cs.Closed_By__c='Salesforce System';
            cs.Closed_By_Agent__c='Salesforce System';
            cs.Notes__c='Refund by redBus';
            csUpList.add(cs);
            ccList.add(cc);
            
        }
        
        if(!ccList.isEmpty())
            insert ccList;
        
        if(!csUpList.isEmpty())
            Database.update(csUpList,false);
        
    }
    
    //To update bo numbers at transaction based Operator id
    public static void transactionBeforeUpdate(List<Order_Items__c> triggerNew,Map<Id,Order_Items__c> TriggerOldMap){
        string boNumber='';
        string boNumber2='';
        string boNumber3='';
        for(Order_Items__c orIt : triggerNew){
            if(String.isNotBlank(orIt.BO_Numbers__c) && (string.isNotBlank(orIt.Service_Provider_Id__c) || orIt.Inventory_Type__c =='Amazon')){
                List<String> boNumberList = new List<String>(orIt.BO_Numbers__c.split('/'));
                if(boNumberList.size()==3){
                    boNumber=boNumberList[0];
                    boNumber2=boNumberList[1];
                    boNumber3=boNumberList[2];
                }else if(boNumberList.size()==2){
                    boNumber=boNumberList[0];
                    boNumber2=boNumberList[1];
                }else if(boNumberList.size()==1){
                    boNumber=boNumberList[0];
                }
                if(!String.isNotBlank(orIt.BO_Number__c) || !String.isNotBlank(orIt.BO_Number2__c) || !String.isNotBlank(orIt.BO_Number3__c) || orIt.BO_Number__c!=boNumber || orIt.BO_Number2__c!=boNumber2 || orIt.BO_Number3__c!=boNumber3){
                    orIt.BO_Number__c=string.isNotBlank(boNumber)?boNumber:'';
                    orIt.BO_Number2__c=string.isNotBlank(boNumber2)?boNumber2:'';  
                    orIt.BO_Number3__c=string.isNotBlank(boNumber3)?boNumber3:'';  
                }
            }else if(!String.isNotBlank(orIt.BO_Numbers__c)){
                orIt.BO_Number__c='';
                orIt.BO_Number2__c='';
                orIt.BO_Number3__c='';
            }
        }
    }

    // Method to cancel the GiMMT bus cancellation Cases CRM - 1895
    public static void giMMTcloseBusCanCases(set<string> tIds){
        List<case> csList=new List<case>();
        list<casecomment> caseCommentInsertList = new list<casecomment>();
        list<case> caseUpdateList = new list<case>();
        DataDeletionSetup__mdt csQuery=new DataDeletionSetup__mdt();
        csQuery=[SELECT isActive__c,QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MMT_Bus_Cancel_Closure'];      
        csList= (List<case>)Database.query(csQuery.QueryDetails__c);
        System.debug(':: csList = '+csList);
    
        for(case c:csList){
            try{
                casecomment cc=new casecomment();
                cc.parentid=c.id;
                cc.commentbody=csQuery.DistributionList__c;
            
                case cs=new case();
                cs.id=c.id;
                cs.Refund_status__c='Bus Cancellation Approved';
                cs.redCare_Status__c='Instant resolution with refund-Approved';
                cs.Approved_By__c = UserInfo.getUserName();
                cs.Closed_By__c='Salesforce System';
                cs.Closed_By_Agent__c='Salesforce System';
                cs.Notes__c='Refund by redBus';
                cs.Approved_Rejected_Time__c = System.Now();
                cs.Amount__c = c.Max_Refund_Amount__c;
                cs.Status='Closed';
            
                caseUpdateList.add(cs);
                caseCommentInsertList.add(cc);
                if(!caseCommentInsertList.isEmpty()){
                    insert caseCommentInsertList;
                }
            
                if(!caseUpdateList.isEmpty()){
                    Update caseUpdateList;
                }
            }catch (Exception e){
                System.debug('::: Exception has occured at line '+e.getLineNumber()+ 'With an error message of '+e.getMessage());
            }
        }
    }
    
    public static void ZQPCaseCreationOnUpdate(List<Order_Items__c> triggerNew,Map<Id,Order_Items__c> TriggerOldMap){
        List<case> csUpList=new List<case>();
        List<case> csInList=new List<case>();
        List<casecomment> ccInsert = new List<casecomment>();
        
        for (Order_Items__c orIt: triggerNew) {
            Order_Items__c oldorIt = TriggerOldMap.get(orIt.Id);
             if (orIt.status__c != oldorIt.status__c && 'TR_CONFIRMED_PO_COMPLETED'.equalsIgnoreCase(orIt.status__c)) {
                List<Case> zqpCaseList = [Select Id, CaseNumber, Booking_Mobile_No__c, Status, Issue_Type__c, Issue_Sub_Category__c, Refund_Amount__c, Order_UUId__c, CreatedDate, Total_Fare_Value__c from Case Where Booking_Mobile_No__c = :orIt.Mobile__c and Status = 'Open' and CreatedDate >= :System.now().addMinutes(-15) and Issue_Type__c ='Booking Error' Order By CreatedDate DESC LIMIT 1];
                if (!zqpCaseList.isEmpty()) {
                    Case zqpCase = zqpCaseList[0];
                    System.debug('Found case for ZQP: '+zqpCase.CaseNumber);
                    Case newCase = new Case();
                    newCase.Issue_Type__c = zqpCase.Issue_Type__c;
                    newCase.Issue_Sub_Category__c = zqpCase.Issue_Sub_Category__c;
                    newCase.Booking_Mobile_No__c = zqpCase.Booking_Mobile_No__c;
                    newCase.Transaction_ID__c = orIt.Id;
                    newCase.TIN_No__c = orIt.Order_Item_Reference_No__c;
                    if (zqpCase.Refund_Amount__c > 0) {
                    	newCase.Refund_Amount__c = zqpCase.Total_Fare_Value__c - zqpCase.Refund_Amount__c;
                    }
                    else {
                       newCase.Refund_Amount__c = zqpCase.Total_Fare_Value__c;
                    }
                    newCase.is_ZQP__c = true;
                    newCase.Subject = 'ZQP Automation';
                	newCase.Order_UUId__c=orIt.Order_Uuid__c;
                    csInList.add(newCase);
                    
                    Case expCase = new Case();
                	expCase.ParentId = newCase.Id;
                	expCase.Issue_Type__c = 'Exceptional Refund';
                	expCase.Issue_Sub_Category__c = 'Zero Question Policy';
                	expCase.Booking_Mobile_No__c = newCase.Booking_Mobile_No__c;
                	expCase.Transaction_ID__c = newCase.Transaction_ID__c;
                	expCase.TIN_No__c = newCase.TIN_No__c;
                	expCase.Refund_Amount__c = newCase.Refund_Amount__c;
                    expCase.Order_UUId__c=newCase.Order_UUId__c;
                    expCase.Subject = 'ZQP Automation';
                    csInList.add(expCase);

                	casecomment cc=new casecomment();
              		cc.parentId=zqpCase.Id;
                    cc.commentbody='Closing Case C1 after creating C2 :'+newCase.CaseNumber+' for T2 :'+orIt.Order_Item_Reference_No__c+' for ZQP';
                    ccInsert.add(cc);
                    
                    zqpCase.Status = 'Closed';
                    csUpList.add(zqpCase);
              }
          }
      }
        
        if (!ccInsert.isEmpty()){
            try {
                insert ccInsert;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
        if (!csUpList.isEmpty()) {
            try {
                update csUpList;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
        if (!csInList.isEmpty()) {
            try {
                insert csInList;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
  }
}