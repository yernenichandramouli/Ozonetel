/**
*
* Name           : BusCancellationRefundedCases
* Created Date   : 09 April 2018
* Created By     : Veeramanikanta R
* Purpose        : Getting confirmation from BO for Bus cancellation cases (Only for refunded cases)
*
**/

public class BusCancellationRefundedCases{
    
    public string tin{get;set;}
    public date doj{get;set;}
    public date doi{get;set;}
    public case c{get;set;}
    public List<Case> listCase{get;set;}
    public List<CaseWrapper> listWrapCase{get;set;}
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
    
    public BusCancellationRefundedCases(ApexPages.StandardController controller) {
        
        tinStatus='';
        busCanRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        listCase = new List<Case>();
        c = new Case();
        listWrapCase = new List<CaseWrapper>();
        mapfinSerIdtoCase= new map<String,list<CaseWrapper>>();
        mapRouteIdtoCase = new map<String,list<CaseWrapper>>();
        mapServiceIdtoRouteId = new Map<String,set<string>>();
        setAddedRoutes = new Set<String>();
        showSearchResult = false;
        selStatus = 'All';
        runQuery = true;
        noResultfound = true;
        c.approved_by__c =UserInfo.getName()+'('+UserInfo.getUserName()+')';        
        
    }
    
    public list<SelectOption> getboOptions()
    {
        list<SelectOption> options = new list<Selectoption>();
        options.add(new SelectOption('--None--','--None--'));
        Set<string> setBoNames = new Set<String>();
        String logUserId = UserInfo.getUserID();
        
        for(case c : [select Bus_Operator_Name__c from case where (status IN ('Refunded By Ageing Scheduler','Department Revert') and recordTypeId=:busCanRecType and Bus_Operator_Name__c!=null AND OwnerId=:logUserId) limit 999 ])
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

    public void connectCall(){
        
        user uObj=[select id,Phone,MobilePhone,CZentrix_Agent_Id__c from user where id=:UserInfo.getUserID()];
        
        if(String.isBlank(boPhoneNo) || String.isBlank(uObj.CZentrix_Agent_Id__c)){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'BO Mobile Number Is Missing Or Agent Id Is Not Configured In C-Zentrix'));        }
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
                        cInfObj.Agent_Phone_Number__c=uObj.Phone;
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
        
        if(caseComment==''){
            reEnableCCPopup=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Enter Description'));
            return null;
        }
        
        reEnableCCPopup=false;
        
        System.debug('..entered...performUpdate...'+tableIdtoRender+'..'+routeIdtoRender+'..'+updateAction);      
        
        List<case> listCaseToUpdate = new List<case>();
        Map<String,String> mapTinCsId = new Map<String,String>();
        String toupleId = tableIdtoRender.replace('caseTableRB','');
        
        System.debug('toupleId...'+toupleId);
        
        set<string> ccIds=new set<string>();
        List<casecomment> ccList=new List<casecomment>();
        list<RequestWrapper.orders> orList=new list<RequestWrapper.orders>();
        
        for(CaseWrapper wrap: listWrapCase )
        {
            if(wrap.isSelect && wrap.routeId.equalsIgnoreCase(toupleId))
            {
                RequestWrapper.orders orObj=new RequestWrapper.orders();
                orObj.orderItemUUID=wrap.cs.Transaction_id__r.Guid__c;
                orObj.tin=wrap.cs.tin_no__c;               
                orlist.add(orObj);  
                wrap.isSelect = false;               
                mapTinCsId.put(wrap.cs.TIN__c,wrap.cs.id);
            }
        }
        
        
        RequestWrapper.BOSponcerWrapper rObj=new RequestWrapper.BOSponcerWrapper('SFA',UserInfo.getName()+'('+UserInfo.getUserName()+')',updateAction,orlist);
        
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ExcepRefundBusCancellation'];
        string boJsonBody=JSON.serialize(rObj);
        System.debug('req body-->'+bojsonbody);
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        req.setEndpoint(APIMData.Endpoint__c);
        req.setMethod('POST');
        req.setBody(boJsonBody);
        try{
        resp = http.send(req);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Bus Cancellation Refunded Cases';
        dbl.Request_Data__c = string.valueof(req)+'-Body-->'+boJsonBody;
        dbl.Order_Items_Process_Status__c=updateAction; 
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
        dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
        if(resp!=null && String.isNotBlank(resp.getbody())){

        System.debug('tot req-->'+req);
        List<BOSponcerResponse> boResp=new List<BOSponcerResponse>();
        System.debug('res body-->'+resp.getbody());
        dbl.Response_Received__c=String.valueOf(resp+'..Body..'+resp.getBody());
        
        String mockJson='[{"tin":"TM4N54341643","status":"Success"},{"tin":"SGM4U26589393","status":"Success"}]';
        boResp = (List<BOSponcerResponse>)System.JSON.deserialize(resp.getbody(),List<BOSponcerResponse>.class);
        
        //  List<BOSponcerResponse> boRespList=new List<BOSponcerResponse>();
        List<DBLog_Summary__c> dblpList=new List<DBLog_Summary__c>();
        if(resp.getStatus()=='OK' && resp.getStatusCode()==200){
        for(BOSponcerResponse bObj:boResp){
        DBLog_Summary__c dblp = new DBLog_Summary__c();
        
            if(bObj.status=='Success'){
                Case cs = new Case();
                cs.id = mapTinCsId.get(bObj.tin); 
                //cs.id = caseMap.get(bObj.tin).id;  
                cs.status ='Closed';
                cs.notes__c =updateAction;
                System.debug('cs.id-->'+cs.id);
                if(cs.id!=null){
                    listCaseToUpdate.add(cs);
                    ccIds.add(cs.id);
                }
            } 
            dblp.Type__c='BusC Refunded Case'; 
            dblp.Order_Items_Process_Status__c=updateAction;  
            dblp.User_Id__c= bObj.tin;       
            dblp.Case_Number__c=mapTinCsId.get(bObj.tin);
            dblp.Response_Received__c = bObj.status;
            dblp.EndPoint__c = String.valueOf(req.getEndpoint());
            dblp.CallOut_Status__c = string.valueOf(resp.getStatus());
            dblp.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
            dblpList.add(dblp);
        }     
        
        System.debug('caseComment-->'+caseComment+'<--ccIds--->'+ccIds);
        if(caseComment!=''){
            for(string s:ccIds){
                casecomment ccObj=new casecomment();
                ccObj.CommentBody=caseComment;
                ccObj.parentid=s;
                ccList.add(ccObj);
            }
        }
        
        String jsonB='{"reason":"BUS_CANCELLATION","refundedBy":"'+UserInfo.getName()+'('+UserInfo.getUserName()+')'+'","channel":"WEBDIRECT"}';
        
        
        System.debug('cList--->'+ccList);
        
        if(!listCaseToUpdate.isEmpty())
        {
            System.debug('listCaseToUpdate..size..'+listCaseToUpdate.size());
            Savepoint sp = Database.setSavepoint();
            try
            { 
                if(!dblpList.isEmpty())
                 insert dblpList;
               
                if(!ccList.isEmpty())
                    insert ccList;
                
                update listCaseToUpdate;                
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
        }else{
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'API failed, Please try again');
                ApexPages.addMessage(myMsg);
                return null;
        
        }
      
        }
        else{
           dbl.Response_Received__c='No Response from API';
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Response from API, Please try again'));
        }
         insert dbl;
      } catch(Exception e){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Something went wrong, Please try again'));
       
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
            
            String strQry ='SELECT '+System.Label.Bus_Cancellation_Query + ' (Issue_Type__c=\'Bus Cancellation\' AND Transaction_ID__c!=null AND Type!=\'B2B\' ';   
            //String strQry ='SELECT '+System.Label.Bus_Cancellation_Query + ' ( Route_Id__c!=null and Date_Of_Journey_New__c!=null';
            
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
            
            
            strQry = strQry +' AND status IN(\'Refunded By Ageing Scheduler\',\'Department Revert\') AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true AND OwnerId=:userId )';
            
            
            System.debug('..strQry...'+strQry);
            
            list<string> rtcIds=System.Label.RTC_BO_IDS.split(',');
            
            
            set<id> cIds=new set<id>();
            for(Case c : Database.query(strQry))
            {
                cIds.add(c.id);
                
            }   
            Map<id,CZentrix_Info__c> czMap=new Map<id,CZentrix_Info__c>();
            list<CZentrix_Info__c> czList=[select id,case__c from CZentrix_Info__c where case__c in: cIds];
            
            for(CZentrix_Info__c cz:czList){    
                czMap.put(cz.case__c,cz);
            }
            
            for(Case c : Database.query(strQry))
            {
                noResultfound = false;
                String serviceId;
                // String serviceId = c.Service_Id__c;
                CZentrix_Info__c s=  czMap.get(c.id);
                System.debug('cc-->'+czMap.get(c.id));  
                
                if(s!=null) 
                    btValue='Call Again';
                else
                    btValue='Call';
                
                tinStatus=c.status; 
                System.debug('tinStatus--->'+tinStatus);           
                if(String.isBlank(serviceId))
                    serviceId = 'RB';
                
                boolean nonRTC=true;
                if(rtcIds.contains(c.Service_Provider_Id__c))
                    nonRTC=false;
                
                
                System.debug('rtc ids-->'+rtcIds);
                System.debug('rtc id-->'+nonRTC);
                CaseWrapper cw = new CaseWrapper(c,serviceId,nonRTC,btValue);
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
        
        public CaseWrapper(Case cse,string servId,boolean callButton,string btValue)
        {
            this.isSelect = false;
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
    
    
    public class BOSponcerResponse{
        public string tin;
        public string status;
    }
    
}