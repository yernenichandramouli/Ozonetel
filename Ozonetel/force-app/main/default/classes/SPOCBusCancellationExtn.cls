/**
* (c) 2016 RedBus
*
* Name           : SPOCBusCancellationExtn
* Created Date   : 10 Dec 2016
* Created By     : Sreenivas M
* Purpose        : Extension class for SPOCBusCancellation Page
*
**/

public class SPOCBusCancellationExtn {
    
    public string tin{get;set;}
    public date doj{get;set;}
    public datetime dojt{get;set;}
    public date doi{get;set;}
    public case c{get;set;}
    public List<Case> listCase{get;set;}
    public List<CaseWrapper> listWrapCase{get;set;}
    public List<IVRBusCancellation> ivrObjList{get;set;}
    public Map<String,List<CaseWrapper>> mapfinSerIdtoCase{get;set;}
    public Map<String,Set<String>> mapServiceIdtoRouteId{get;set;}
    public string busCanRecType;
    public String selStatus{get;set;}
    public String selBO{get;set;}
    public boolean showSearchResult{get;set;}
    public boolean noResultfound{get;set;}
    public String tableIdtoRender{get;set;}
    public string routeIdtoRender{get;set;}
    public string updateAction{get;set;}
    public string hiddenHtmlDropId{get;set;}
    public List<JsonBodyWrapper> jsBodyWraper{get;set;}
    public Map<string,List<String>> mapSFStattoApiStat{get;set;}
    public boolean runQuery{get;set;}
    public boolean reEnablePopup{get;set;}
    public Map<String,List<CaseWrapper>> mapRouteIdtoCase{get;set;}
    public set<String> setAddedRoutes{get;set;}
    public string tinStatus{get;set;}
    public string caseComment{get;set;}
    public boolean reEnableCCPopup{get;set;}
    public string boPhoneNo{get;set;}
    public boolean reEnableBOPopup{get;set;}
    public string btValue{get;set;}
    public string callStatus{get;set;}
    
    public SPOCBusCancellationExtn(ApexPages.StandardController controller) {
        
        tinStatus='';
        ivrObjList=new List<IVRBusCancellation>();       
        busCanRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        listCase = new List<Case>();
        c = new Case();
        listWrapCase = new List<CaseWrapper>();
        jsBodyWraper = new List<JsonBodyWrapper>();
        mapfinSerIdtoCase= new map<String,list<CaseWrapper>>();
        mapRouteIdtoCase = new map<String,list<CaseWrapper>>();
        mapServiceIdtoRouteId = new Map<String,set<string>>();
        setAddedRoutes = new Set<String>();
        showSearchResult = false;
        selStatus = 'All';
        runQuery = true;
        noResultfound = true;
        c.approved_by__c =UserInfo.getName()+'('+UserInfo.getUserName()+')';
        
        mapSFStattoApiStat = new Map<string,List<String>>();
        mapSFStattoApiStat.put('Re-Approved',new List<String>{'Approved for Bus Cancellation','APPROVED',''});      
        mapSFStattoApiStat.put('Approved',new List<String>{'Approved for Bus Cancellation','APPROVED',''});
        mapSFStattoApiStat.put('Rejected',new List<String>{'Rejected For Bus Cancellation','DISAPPROVED',''});
        mapSFStattoApiStat.put('Alternative Arrangement by redBus',new List<String>{'CLOSED','CLOSED','Alternative Arrangement by redBus'});    
        mapSFStattoApiStat.put('Alternative Arrangement by BO',new List<String>{'CLOSED','CLOSED','Alternative Arrangement by BO'});
        mapSFStattoApiStat.put('Refunded by redBus',new List<String>{'CLOSED','CLOSED','Cancel Ticket'});
        mapSFStattoApiStat.put('Refunded by BO',new List<String>{'CLOSED','CLOSED','Refund by BO'});
        mapSFStattoApiStat.put('RTC COUNTER',new List<String>{'CLOSED','CLOSED','Diverted Customer to Counter'});
        mapSFStattoApiStat.put('WEBSITE CANCEL',new List<String>{'CLOSED','CLOSED','Diverted Customer to Cancel on Website'});
        
        
    }
    
    public list<SelectOption> getboOptions()
    {
        list<SelectOption> options = new list<Selectoption>();
        options.add(new SelectOption('--None--','--None--'));
        Set<string> setBoNames = new Set<String>();
        
        
        for(case c : [select Bus_Operator_Name__c from case where (status NOT IN ('Closed','Rejected For Bus Cancellation') and recordTypeId=:busCanRecType and Bus_Operator_Name__c!=null) limit 999 ])
        {
            if(!setBoNames.contains(c.Bus_Operator_Name__c))
            {
                options.add(new SelectOption(c.Bus_Operator_Name__c,c.Bus_Operator_Name__c));
                setBoNames.add(c.Bus_Operator_Name__c);
            }             
            
        }
        System.debug('..options....'+options);
        return options;
    }
    
    public list<SelectOption> getstatusOptions()
    {
        list<SelectOption> options = new list<Selectoption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Initiated','Initiate Bus Cancellation'));
        options.add(new SelectOption('Approved For Bus Cancellation','Approved for Bus Cancellation'));
        options.add(new SelectOption('Rejected For Bus Cancellation','Rejected for Bus Cancellation'));
        options.add(new SelectOption('Alternative Arrangement by BO','Alternative Arrangement by BO'));
        options.add(new SelectOption('Alternative Arrangement by redBus','Alternative Arrangement by redBus'));
        options.add(new SelectOption('Refund by redBus','Refunded by redbus'));
        options.add(new SelectOption('Refund by BO','Refunded by BO'));
        return options;
    }
    
    
    public void connectCall(){
        
        user uObj=[select id,Phone,MobilePhone,CZentrix_Agent_Id__c from user where id=:UserInfo.getUserID()];
        
        if(String.isBlank(boPhoneNo) || String.isBlank(uObj.CZentrix_Agent_Id__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'BO Mobile Number Is Missing Or Agent Id Is Not Configured In C-Zentrix'));
        }
        else
        {
            Case selCase = new Case();      
            String toupleId = tableIdtoRender.replace('caseTableRB','');      
            System.debug('listWrapCase -->'+listWrapCase );
            
            for(CaseWrapper wrap: listWrapCase )
            {
                if(wrap.isSelect && wrap.routeId.equalsIgnoreCase(toupleId))
                    selCase = wrap.cs;
            }      
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SinfinyCall'];
            
            string jsonBody;
            RequestWrapper.BOCallWrapper boWrap=new RequestWrapper.BOCallWrapper(boPhoneNo,uObj.MobilePhone,selCase,uObj.CZentrix_Agent_Id__c);
            String boCallerJson=json.serialize(boWrap); 
            System.debug('boCallerJson-->'+boCallerJson);
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req); 
            /*   req.setHeader('Channel_Name', 'INFINI');
req.setHeader('auth_key','483594d8-1467-47b2-83b5-1d42451c532d');   */          
            req.setMethod('POST');
            req.setBody(boCallerJson);
            req.setEndpoint(APIMData.Endpoint__c);  
            CZentrix_Info__c cInfObj=new CZentrix_Info__c();
            cInfObj.Call_Type__c='BO Call';
            try{          
                res=h.send(req); 
                if(res!=null && String.isNotBlank(res.getbody()))
                {
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
                    System.debug('resObj-->'+resObj);
                    System.debug('status-->'+boolean.valueof(resObj.get('status')));
                    if(resObj.containsKey('status') && boolean.valueof(resObj.get('status'))==true)
                    {
                        System.debug('resp-->'+res.getbody());
                        cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                        cInfObj.Case__c=selCase.id;
                        cInfObj.Agent_Phone_Number__c=uObj.MobilePhone;
                        cInfObj.Campaign_Name__c='SPOC BO Confirmation';
                        cInfObj.BO_Phone_Number__c=boPhoneNo;
                        cInfObj.Operator_Id__c=selCase.Service_Provider_Id__c;
                        cInfObj.Operator_Name__c=selCase.Bus_Operator_Name__c;
                        cInfObj.TIN__c=selCase.TIN_No__c;
                        cInfObj.Message__c='Success';
                        cInfObj.Agent_ID__c = String.valueOf(uObj.CZentrix_Agent_Id__c);                   
                        insert cInfObj;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call will connect soon'));
                    } 
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Received Invalid Status From API, Please try again'));
                    
                }
                
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Response from API, Please try again'));
                
            } 
            
            catch(Exception e){        
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'));
            }               
        }
    }
    
    
    public pagereference performUpdate()
    {
        
        
        runQuery = false;
        if(String.isBlank(c.BOAgentNameBySPOC__c) && 'Initiated'.equalsIgnoreCase(tinStatus) )
        {
            reEnablePopup = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter value for BOAgentNamebySPOC'));
            return null;     
        }
        
        if('Initiated'.equalsIgnoreCase(tinStatus) && (String.isBlank(c.BOAgentContactBySPOC__c) || (String.isNotBlank(c.BOAgentContactBySPOC__c) && c.BOAgentContactBySPOC__c.length()!=10)) && updateAction!='Awaiting BO/BD Response')
        {
            reEnablePopup = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter correct value for BOAgentContactBySPOC'));
            return null;
        }
        
        if(caseComment=='' && 'Approved For Bus Cancellation'.equalsIgnoreCase(tinStatus)){
            reEnableCCPopup=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Enter Description'));
            return null;
        }
        
        reEnablePopup = false;
        reEnableCCPopup=false;
        
        System.debug('..entered...performUpdate...'+tableIdtoRender+'..'+routeIdtoRender+'..'+updateAction);      
        
        List<case> listCaseToUpdate = new List<case>();
        Map<String,String> mapTinCsId = new Map<String,String>();
        List<String> opTypeApporvals = new List<String>();
        jsBodyWraper.clear();
        String toupleId = tableIdtoRender.replace('caseTableRB','');
        
        System.debug('toupleId...'+toupleId);
        
        Set<String> setTins = new Set<String>();
        set<string> ccIds=new set<string>();
        set<string> approvedIds=new set<string>();
        List<casecomment> ccList=new List<casecomment>();
        
        for(CaseWrapper wrap: listWrapCase )
        {
            if(wrap.isSelect && wrap.routeId.equalsIgnoreCase(toupleId))
            {
                System.debug('wrap...'+wrap.routeId);
                wrap.isSelect = false;
                wrap.cs.status= mapSFStattoApiStat.get(updateAction)[0];
                System.debug('status check-->'+mapSFStattoApiStat.get(updateAction)[0]);
                wrap.cs.notes__c = mapSFStattoApiStat.get(updateAction)[2];
                opTypeApporvals.add(updateAction);
                
                
                if('Refunded by redBus'.equalsIgnoreCase(updateAction))
                {
                    wrap.cs.notes__c ='Refund by redBus';
                }
                
                if('Approved'.equalsignorecase(updateAction) || 'Rejected'.equalsIgnoreCase(updateAction))
                {          
                    wrap.cs.BOAgentContactBySPOC__c = c.BOAgentContactBySPOC__c;
                    wrap.cs.BOAgentNameBySPOC__c = c.BOAgentNameBySPOC__c;
                    wrap.cs.Approved_By__c = c.Approved_By__c;
                    wrap.cs.Approved_Rejected_Time__c = System.now();
                    opTypeApporvals.add(c.BOAgentContactBySPOC__c);
                    opTypeApporvals.add(c.BOAgentNameBySPOC__c);
                    opTypeApporvals.add(c.Approved_By__c);
                    
                }
                mapTinCsId.put(wrap.cs.TIN__c,wrap.cs.id);
                System.debug(wrap.cs.status+'...'+wrap.cs.tin__c+'...'+wrap.cs);
                listCaseToUpdate.add(wrap.cs);
                setTins.add(wrap.cs.TIN__c);
                
                if(wrap.cs.status=='Closed')
                    ccIds.add(wrap.cs.id);
                
                /* This is used for IVR Bus cancellation
if(wrap.cs.status=='Approved For Bus Cancellation')
approvedIds.add(wrap.cs.id);
*/     
                
                jsBodyWraper.add(new JsonBodyWrapper(wrap.cs,mapSFStattoApiStat.get(updateAction)[1],mapSFStattoApiStat.get(updateAction)[2]));
            }
        }
        
        if(caseComment!=''){
            for(string s:ccIds){
                casecomment ccObj=new casecomment();
                ccObj.CommentBody=caseComment;
                ccObj.parentid=s;
                ccList.add(ccObj);
            }
        }else if('RTC COUNTER'.equalsignorecase(updateAction) || 'WEBSITE CANCEL'.equalsIgnoreCase(updateAction)){
            for(string s:ccIds){
                casecomment ccObj=new casecomment();
                ccObj.CommentBody='Diverted Customer to Counter or Diverted Customer to Cancel on Website';
                ccObj.parentid=s;
                ccList.add(ccObj);
            }
        }  
        
        
        /*   This is used for IVR Bus cancellation

for(case cObj:[select id,Booking_Mobile_No__c,tin__c,Date_Of_Journey_New__c,Service_Provider_Name__c,Customer_Name__c,Customer_Name__r.name,source__c,Destination__c from case where id in :approvedIds]){
IVRBusCancellation ivrObj=new IVRBusCancellation();
ivrObj.mobileNumber=cObj.Booking_Mobile_No__c;
ivrObj.tin=cObj.tin__c;
ivrObj.doj=cObj.Date_Of_Journey_New__c;
ivrObj.travel=cObj.Service_Provider_Name__c;
ivrObj.name=cObj.Customer_Name__r.name;
ivrObj.source=cObj.source__c;
ivrObj.destination=cObj.Destination__c;
ivrObjList.add(ivrObj);
}
System.debug('approvedIds-->'+approvedIds+'ivrObjList-->'+ivrObjList);

System.debug('IVR obj list-->'+JSON.serialize(ivrObjList));
if(!ivrObjList.isEmpty()){
BusCancellationHandler.busCancelApprove(JSON.serialize(ivrObjList));
}*/
        
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
                
                runQuery = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Records updated successfully!'));
                return null;
                
            }         
            catch(Exception e)
            {
                System.debug('Exception ..'+e);
                Database.rollback(sp);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            } 
        }
        
        return null;
        
    }
    
    public void doSearch()
    {
        showSearchResult = true;
        runQuery = true;
        noResultfound = true;
        setAddedRoutes.clear();
        
    }
    
    
    public Map<String,List<CaseWrapper>> getmapServiceIdtoCase()
    {
        if(runQuery)
        {
            listCase.clear();
            listWrapCase.clear();
            mapServiceIdtoRouteId.clear();
            mapfinSerIdtoCase.clear();
            mapRouteIdtoCase.clear();
            
            Map<String,List<CaseWrapper>> tempmapServiceIdtoCase = new Map<String,List<CaseWrapper>>();
            
            //    String strQry ='SELECT '+System.Label.Bus_Cancellation_Query + ' (recordTypeId=:busCanRecType AND Route_Id__c!=null AND Type!=\'B2B\' ';   
            //String strQry ='SELECT '+System.Label.Bus_Cancellation_Query + ' ( Route_Id__c!=null and Date_Of_Journey_New__c!=null';
            
            String strQry ='SELECT '+System.Label.bus_cancellation_query_cz+ ' (recordTypeId=:busCanRecType AND Route_Id__c!=null AND Type!=\'B2B\' ';   
            
            System.debug('..selBo...'+selBo+'...'+selStatus);
            String userId = UserInfo.getUserID();
            
            
            Set<String> setClosedOptions = new Set<String>{'Alternative Arrangement by BO','Refund by redBus','Refund by BO','Alternative Arrangement by redBus'};
                
                if(selBo!='--None--')
                strQry = strQry +' AND Bus_Operator_Name__c=:selBO ';
            
            System.debug('tin-->'+tin);
            if(tin!='' && tin!=null)
                strQry = strQry +' AND TIN__c=:tin';    
            
            
            if(doj!=null)
            {
                DateTime tempDOJ = doj.addDays(-1);
                DateTime startDOJ = DateTime.newInstanceGMT(tempDOJ.year(),tempDOJ.month(),tempDOJ.day(),18,30,00);
                DateTime endDOJ = DateTime.newInstanceGMT(doj.year(),doj.month(),doj.day(),18,29,59);
                strQry = strQry +' AND (Date_Of_Journey_New__c>=:startDOJ AND Date_Of_Journey_New__c<=:endDOJ) ';
                System.debug('...startDOJ..endDOJ..'+startDOJ+'..'+endDOJ);
            }
            
            if(doi!=null)
            {
                DateTime tempDOI = doi.addDays(-1);
                DateTime startDOi = DateTime.newInstanceGMT(tempDOI.year(),tempDOI.month(),tempDOI.day(),18,30,00);
                DateTime endDOi = DateTime.newInstanceGMT(doi.year(),doi.month(),doi.day(),18,29,59);
                strQry = strQry +' AND (createddate>=:startDOi AND Createddate<=:endDOi) ';
                System.debug('...startDOi..endDOi..'+startDOi+'..'+endDOi);
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
            //strQry = strQry+' ) ';
            
            System.debug('..strQry...'+strQry);
            
            Set<string> rtcIds=new Set<String>();
            rtcIds.addAll(System.Label.RTC_BO_IDS.split(','));
            List<Case> listCases = new List<Case>();
            listCases = Database.query(strQry);
            
            set<id> cIds=new set<id>();
            list<case> fListCases=new list<case>();
            // fListCases.addall(listCases);
            
            if(callStatus=='To-be-Called'){
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
            
            System.debug('f size-->'+fListCases.size());
            Map<id,CZentrix_Info__c> czMap=new Map<id,CZentrix_Info__c>();
            Map<id,list<CZentrix_Info__c>> czMapList=new Map<id,list<CZentrix_Info__c>>();
          
            
            for(CZentrix_Info__c cz:[select id,case__c,case__r.id from CZentrix_Info__c where case__c in: cIds]){     
                if(czMapList.containsKey(cz.case__r.id))
                    czMapList.get(cz.case__r.id).add(cz);
                else
                    czMapList.put(cz.case__r.id,new List<CZentrix_Info__c>{cz});

            }
            System.debug('czMapL-->'+czMapList.keyset());
            for(Case c : fListCases)
            {
                noResultfound = false;
                String serviceId;
           
                CZentrix_Info__c s=  czMap.get(c.id);
                System.debug('cc-->'+czMap.get(c.id)); 
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
                
                
                System.debug('rtc ids-->'+rtcIds);
                System.debug('rtc id-->'+nonRTC);
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
            return tempmapServiceIdtoCase;
        }
        
        else
            return mapfinSerIdtoCase;
    }
    
    public void loadCaseData()
    {
        string selRId = ApexPages.currentPage().getParameters().get('selRouid');
        System.debug('load Case data selRId'+selRid);
        if(mapRouteIdtoCase.containsKey(selRId) && !setAddedRoutes.contains(selRId))
        {
            listWrapCase.addall(mapRouteIdtoCase.get(selRId));
            runQuery = false;
            setAddedRoutes.add(selRId);
            
        }
    }
    
    public class CaseWrapper
    {
        public boolean isSelect{get;set;}
        public Case cs{get;set;}
        public String servcId{get;set;}
        public string routeId{get;set;}
        public string createddate{get;set;}
        public boolean callButton{get;set;}
        public string btValue{get;set;}
        public integer callsCount{get;set;}
        
        public CaseWrapper(Case cse,string servId,boolean callButton,string btValue,integer callsCount)
        {
            this.isSelect = false;
            this.callsCount=callsCount;
            this.cs = cse;
            this.callButton=callButton;
            this.btValue=btValue;
            servcId = servId;
            System.debug('Case..'+cs);
            routeId = cs.Route_Id__c+'_'+String.valueOf(cs.Date_Of_Journey_New__c.date())+'_'+String.valueOf(cs.Bus_Operator_Name__c.normalizeSpace().replaceAll(System.Label.Special_Chars,'_').removeEnd('_'));
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
        }
        
    }
    public class IVRBusCancellation{
        public string mobileNumber{get;set;}
        public string tin{get;set;}
        public datetime doj{get;set;}
        public string travel{get;set;}
        public string name{get;set;}
        public string source{get;set;}
        public string destination{get;set;}
        
    }
    
}