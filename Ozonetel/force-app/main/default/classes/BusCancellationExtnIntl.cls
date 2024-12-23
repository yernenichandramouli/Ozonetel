public class BusCancellationExtnIntl {
    public static string busCanRecType {get; set;}   
    public static List<Case> listCase{get;set;}
    public static List<CaseWrapper> listWrapCase{get;set;}
    public static Map<String,Set<String>> mapServiceIdtoRouteId{get;set;}
    public static Map<String,List<CaseWrapper>> mapfinSerIdtoCase{get;set;}
    public static Map<String,List<CaseWrapper>> mapRouteIdtoCase{get;set;}
    public static boolean noResultfound{get;set;}
    public static string btValue{get;set;}
    public static string tinStatus{get;set;}
    public static List<JsonBodyWrapper> jsBodyWraper{get;set;}
    public static Map<string,List<String>> mapSFStattoApiStat{get;set;}
       
    @AuraEnabled(Cacheable=true) 
    public static List<case> getboListValues(){
        busCanRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        List<case> boList = new List<case>();       
        Set<string> setBoNames = new Set<String>(); 
        
        for(case c : [select Bus_Operator_Name__c from case where (status NOT IN ('Closed','Rejected For Bus Cancellation') and recordTypeId=:busCanRecType and Bus_Operator_Name__c!=null) limit 999 ])
        {
            if(!setBoNames.contains(c.Bus_Operator_Name__c))
            {
                setBoNames.add(c.Bus_Operator_Name__c);
                boList.add(c);
            }                         
        }    
        return boList;    
    }
    @AuraEnabled    
    //public static List<string> getmapServiceIdtoCase( String selBo, string tin, date doj, date doi, string selStatus)
    //   public static List<CaseWrapper> getmapServiceIdtoCase( String selBo, string tin, date doj, date doi, string selStatus, string callStatus )
    public static Map<String,List<CaseWrapper>> getmapServiceIdtoCase(String selBo, string tin, date doj, date doi, string selStatus)
    {
        System.debug('<<<entered the method');
        system.debug('selbo :'+selbo);
        system.debug('tin:'+tin);
        system.debug('doj:'+doj);
        system.debug('doi:'+doi);
        system.debug('selStatus:'+selStatus);
        listCase = new List<Case>();
        listWrapCase = new List<CaseWrapper>();
        mapfinSerIdtoCase= new map<String,list<CaseWrapper>>();
        mapRouteIdtoCase = new map<String,list<CaseWrapper>>();
        mapServiceIdtoRouteId = new Map<String,set<string>>();
        noResultfound = true;
        listCase.clear();
        listWrapCase.clear();
        mapServiceIdtoRouteId.clear();
        mapfinSerIdtoCase.clear();
        mapRouteIdtoCase.clear();
        system.debug('<<mapRouteIdtoCase'+mapRouteIdtoCase);
        Map<String,List<CaseWrapper>> tempmapServiceIdtoCase = new Map<String,List<CaseWrapper>>();
        busCanRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();        
        String strQry ='SELECT '+System.Label.bus_cancellation_query_cz+ ' (recordTypeId=:busCanRecType AND Route_Id__c!=null AND Type!=\'B2B\' ';   
        String userId = UserInfo.getUserID();
        system.debug(userId);
        Set<String> setClosedOptions = new Set<String>{'Alternative Arrangement by BO','Refund by redBus','Refund by BO','Alternative Arrangement by redBus'};
            
       if(selBo!='')
            strQry = strQry +' AND Bus_Operator_Name__c=:selBo ';
        if(tin!='' && tin!=null)
            strQry = strQry +' AND TIN__c=:tin';    
        
        
        if(doj!=null)
        {
            DateTime tempDOJ = doj.addDays(-1);
            DateTime startDOJ = DateTime.newInstanceGMT(tempDOJ.year(),tempDOJ.month(),tempDOJ.day(),18,30,00);
            DateTime endDOJ = DateTime.newInstanceGMT(doj.year(),doj.month(),doj.day(),18,29,59);
            strQry = strQry +' AND (Date_Of_Journey_New__c>=:startDOJ AND Date_Of_Journey_New__c<=:endDOJ) ';
        }
        
        if(doi!=null)
        {
            DateTime tempDOI = doi.addDays(-1);
            DateTime startDOi = DateTime.newInstanceGMT(tempDOI.year(),tempDOI.month(),tempDOI.day(),18,30,00);
            DateTime endDOi = DateTime.newInstanceGMT(doi.year(),doi.month(),doi.day(),18,29,59);
            strQry = strQry +' AND (createddate>=:startDOi AND Createddate<=:endDOi) ';
        }
        
        if('All'.equalsIgnoreCase(selStatus) )
            strQry = strQry +' AND status!=null ';
        
        else if(setClosedOptions.contains(selStatus))
        {
            strQry = strQry +' AND status=\'Closed\' AND Notes__c =:selStatus';
        }
        
        else
            strQry = strQry +' AND status=:selStatus';
        
        strQry = strQry+' AND OwnerId=:userId) ';
        Set<string> rtcIds=new Set<String>();
        rtcIds.addAll(System.Label.RTC_BO_IDS.split(','));
        List<Case> listCases = new List<Case>();
        listCases = Database.query(strQry);
		system.debug('<<ListCases'+listCases);
        system.debug('Query'+strQry);
        
        set<id> cIds=new set<id>();
        list<case> fListCases=new list<case>();
        
/*        if(callStatus=='To-be-Called'){
            for(Case c :listCases){  
                if(c.CZentrix_Info__r.size()==0 )
                    fListCases.add(c);
                
                cIds.add(c.id);              
            }
        }
        else if(callStatus=='BOs Called-Already'){
            for(Case c :listCases){   
                if(c.CZentrix_Info__r.size()>0 )
                    fListCases.add(c);
                
                cIds.add(c.id);              
            }
        }
        else{
            for(Case c :listCases){ 
                fListCases.add(c);                 
                cIds.add(c.id);              
            }                
        }
*/        
			for(Case c :listCases){ 
                fListCases.add(c);                 
                cIds.add(c.id);              
            }                


        Map<id,CZentrix_Info__c> czMap=new Map<id,CZentrix_Info__c>();
        Map<id,list<CZentrix_Info__c>> czMapList=new Map<id,list<CZentrix_Info__c>>();     
        
        for(CZentrix_Info__c cz:[select id,case__c,case__r.id from CZentrix_Info__c where case__c in: cIds]){     
            if(czMapList.containsKey(cz.case__r.id))
                czMapList.get(cz.case__r.id).add(cz);
            else
                czMapList.put(cz.case__r.id,new List<CZentrix_Info__c>{cz});
            
        }
        for(Case c : fListCases)
        {
            noResultfound = false;
            String serviceId;
            
            CZentrix_Info__c s=  czMap.get(c.id);
            integer callsCount;
            if(czMapList.containsKey(c.id)){
                System.debug('czMapList-->'+c.id+'--Count--'+czMapList.get(c.id).size());  
                callsCount=czMapList.get(c.id).size();
                btValue='Call Again';
            }else{
                btValue='Call';
            }
            
            tinStatus=c.status; 
            System.debug('tinStatus--->'+tinStatus);           
            if(String.isBlank(serviceId))
                serviceId = 'RB';
            
            boolean nonRTC=true;
            if(rtcIds.contains(c.Service_Provider_Id__c))
                nonRTC=false;
            
            CaseWrapper cw = new CaseWrapper(c,serviceId,nonRTC,btValue,callsCount);
            String rouId = cw.routeId;
            
            if(mapRouteIdtoCase.containsKey(rouId))
                mapRouteIdtoCase.get(rouId).add(cw);            
            else
                mapRouteIdtoCase.put(rouId,new List<CaseWrapper>{cw});                
            
            if(tempmapServiceIdtoCase.containsKey(serviceId))
            {                
                tempmapServiceIdtoCase.get(serviceId).add(cw);
                mapfinSerIdtoCase.get(serviceId).add(cw);
                mapServiceIdtoRouteId.get(serviceId).add(rouId);               
            }
            else
            {                
                tempmapServiceIdtoCase.put(serviceId,new list<CaseWrapper>{cw});
                mapfinSerIdtoCase.put(serviceId,new list<CaseWrapper>{cw});
                mapServiceIdtoRouteId.put(serviceId,new Set<string>{rouId});
            }
        }
        system.debug('<<mapRouteIdtoCase 2'+mapRouteIdtoCase);
        return mapRouteIdtoCase;
    }
    
    @AuraEnabled 
    public static void performUpdate(string updateAction,string BOAgentContactBySPOC,string BOAgentNameBySPOC,string casecomment,string updateCases){

        mapSFStattoApiStat = new Map<string,List<String>>();
        mapSFStattoApiStat.put('Re-Approved',new List<String>{'Approved for Bus Cancellation','APPROVED',''});      
        mapSFStattoApiStat.put('Approved',new List<String>{'Approved for Bus Cancellation','APPROVED',''});
        mapSFStattoApiStat.put('Rejected',new List<String>{'Rejected For Bus Cancellation','DISAPPROVED',''});
        mapSFStattoApiStat.put('Alternative Arrangement by redBus',new List<String>{'CLOSED','CLOSED','Alternative Arrangement by redBus'});    
        mapSFStattoApiStat.put('Alternative Arrangement by BO',new List<String>{'CLOSED','CLOSED','Alternative Arrangement by BO'});
        mapSFStattoApiStat.put('Refunded by redBus',new List<String>{'CLOSED','CLOSED','Cancel Ticket'});
        mapSFStattoApiStat.put('Refunded by BO',new List<String>{'CLOSED','CLOSED','Refund by BO'});
        
        list<string> casenumbers =  updateCases.split(';');
        system.debug('case numbers'+casenumbers);
        list<case> caseList = [select id,OwnerId,Trip_ID__c,Is_Secondary_SourceInfo__c,OrderItem_Uuid__c,SS_DOJ__c,SS_Route_Id__c,Sales_Channel__c,Is_Primary__c,Seats__c,BOAgentNameBySPOC__c,Approved_Rejected_Time__c,
								Transaction_ID__c,BOAgentContactBySPOC__c,LastModifiedById,Approved_By__c,Date_Of_Journey_New__c,CaseNumber,Status,Bus_Operator_Name__c,Service_Provider_Id__c,
								Origin,Service_Id__c,TIN__c,TIN_No__c,Route_Id__c,LastModifiedDate,createdby.Name,createdby.Username,CreatedDate,CreatedById,Customer_Name__c,BOAgentNameByCSE__c,BOAgentContactByCSE__c from case where CaseNumber in :casenumbers];
        system.debug('cases list'+ caseList);
        List<case> listCaseToUpdate = new List<case>();
        Map<String,String> mapTinCsId = new Map<String,String>();
        List<String> opTypeApporvals = new List<String>();
        string approvedBy=UserInfo.getName()+'('+UserInfo.getUserName()+')';
        jsBodyWraper = new List<JsonBodyWrapper>();
        // String toupleId = tableIdtoRender.replace('caseTableRB','');
        
        
        
        Set<String> setTins = new Set<String>();
        set<string> ccIds=new set<string>();
        set<string> approvedIds=new set<string>();
        List<casecomment> ccList=new List<casecomment>();
        
        system.debug('<<caseList'+caseList);
        for(case cse : caseList){
            system.debug('<<update action '+updateAction);	
            cse.status = mapSFStattoApiStat.get(updateAction)[0];
            cse.Notes__c = mapSFStattoApiStat.get(updateAction)[2];
            opTypeApporvals.add(updateAction);
                if('Refunded by redBus'.equalsIgnoreCase(updateAction))
                {
                   cse.notes__c ='Refund by redBus';
                }
                if('Approved'.equalsignorecase(updateAction) || 'Rejected'.equalsIgnoreCase(updateAction))
                {          
                    cse.BOAgentContactBySPOC__c = BOAgentContactBySPOC;
                    cse.BOAgentNameBySPOC__c = BOAgentNameBySPOC;
                    cse.Approved_By__c = approvedBy;
                    cse.Approved_Rejected_Time__c = System.now();
                    opTypeApporvals.add(BOAgentContactBySPOC);
                    opTypeApporvals.add(BOAgentNameBySPOC);
                    opTypeApporvals.add(approvedBy);                    
                }
                mapTinCsId.put(cse.TIN__c,cse.id);
                listCaseToUpdate.add(cse);
                setTins.add(cse.TIN__c);
                
                if(cse.status=='Closed')
                    ccIds.add(cse.id);
                
                jsBodyWraper.add(new JsonBodyWrapper(cse,mapSFStattoApiStat.get(updateAction)[1],mapSFStattoApiStat.get(updateAction)[2]));

        }	        
        if(caseComment!=''){
            for(string s:ccIds){
                casecomment ccObj=new casecomment();
                ccObj.CommentBody=caseComment;
                ccObj.parentid=s;
                ccList.add(ccObj);
            }
        }
        System.debug('cList--->'+ccList);
        
        if(!listCaseToUpdate.isEmpty())
        {
            System.debug('listCaseToUpdate..size..'+listCaseToUpdate.size());
            Savepoint sp = Database.setSavepoint();
            try
            {
                if(!ccList.isEmpty())
                    insert ccList;
                
                update listCaseToUpdate;
                
                BusCancellationHandler.getAllViaRoutesTins(JSON.serialize(jsBodyWraper),opTypeApporvals,setTins,mapTinCsId);
            }         
            catch(Exception e)
            {
                System.debug('Exception ..'+e);
                Database.rollback(sp);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
            } 
        }
        
        
    }
    public class CaseWrapper
    {
        @AuraEnabled
        public boolean isSelect{get;set;}
        @AuraEnabled
        public Case cs{get;set;}
        @AuraEnabled
        public String servcId{get;set;}
        @AuraEnabled
        public string routeId{get;set;}
        @AuraEnabled
        public string createddate{get;set;}
        @AuraEnabled
        public boolean callButton{get;set;}
        @AuraEnabled
        public string btValue{get;set;}
        @AuraEnabled
        public integer callsCount{get;set;}
		@AuraEnabled
	    public string custName{get;set;}
                
        public CaseWrapper(Case cse,string servId,boolean callButton,string btValue,integer callsCount)
        {
            this.isSelect = false;
            this.callsCount=callsCount;
            this.cs = cse;
            this.callButton=callButton;
            this.btValue=btValue;
            if(cse.Customer_Name__r.Name != Null){
	            this.custName=cse.Customer_Name__r.Name;                
            }
            else{
                this.custName=' ';
            }
            servcId = servId;
            System.debug('Case..'+cs);
            routeId = 'Route Id : '+ cs.Route_Id__c+'_'+String.valueOf(cs.Date_Of_Journey_New__c.date())+'_'+String.valueOf(cs.Bus_Operator_Name__c.normalizeSpace().replaceAll(System.Label.Special_Chars,'_').removeEnd('_'));
            createddate=cs.createddate.addminutes(330).formatGMT('yyyy-MM-dd\'T\'HH:mm');
            System.debug('routeId...'+routeId);
        }
    }
    public class JsonBodyWrapper
    {
        public string approvedBy{get;set;}
        public string boAgentContactBySPOC{get;set;}
        public string boAgentNameBySPOC{get;set;}
        public string status{get;set;}
        public string doj{get;set;}
        public string tin{get;set;}
        public string notes{get;set;}
        public Integer routeId{get;set;}       
        public string initiatedBy{get;set;}
        public string cancellationStatus{get;set;}
        public string createdTime{get;set;}
        public string updatedTime{get;set;}
        public string boAgentNameByCSE{get;set;}
        public string boAgentContactByCSE{get;set;}
        public string SPOCNameByCSE{get;set;} 
        public string orderItemUuid{get;set;} 
        public string localeName{get;set;}
        public string TransactionID{get;set;}

        public JsonBodyWrapper(Case c,String pStatus,String pNotes)
        {
            this.approvedBy = c.Approved_By__c;
            this.boAgentContactBySPOC = c.BOAgentContactBySPOC__c;
            this.boAgentNameBySPOC = c.BOAgentNameBySPOC__c;
            this.status =pStatus;
            if(c.Date_Of_Journey_New__c!=null)
                this.doj = String.valueOf(c.Date_Of_Journey_New__c.format('yyyy-MM-dd 00:00:00','Asia/Kolkata'));
            else if(c.SS_DOJ__c!=null)
                this.doj = String.valueOf(c.SS_DOJ__c.format('yyyy-MM-dd 00:00:00','Asia/Kolkata'));
            System.debug('..this.doj..'+this.doj);
            this.tin = String.isBlank(c.TIN__c)?c.TIN_No__c:c.TIN__c;
            this.notes = pNotes;
            this.routeId =String.isNotBlank(c.Route_Id__c)?Integer.valueOf(c.Route_Id__c):String.isNotBlank(c.SS_Route_Id__c)?Integer.valueOf(c.SS_Route_Id__c):null;            
            this.initiatedBy = String.valueOf(c.createdby.Name+'('+c.createdby.Username+')');
            this.cancellationStatus ='0';
            this.createdTime = String.valueOf(c.CreatedDate);
            this.updatedTime = String.valueOf(c.LastModifiedDate);
            this.boAgentNameByCSE = c.BOAgentNameByCSE__c;
            this.boAgentContactByCSE = c.BOAgentContactByCSE__c;
            this.SPOCNameByCSE= UserInfo.getName()+'('+UserInfo.getUserName()+')';//c.SPOCName_By_CSE__c;
            this.orderItemUuid = c.OrderItem_Uuid__c;
            this.TransactionID = c.Transaction_ID__c;
        }   
    }
}