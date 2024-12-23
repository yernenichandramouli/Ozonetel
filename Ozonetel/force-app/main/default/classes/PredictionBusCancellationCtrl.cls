/*
* Name           : PredictionBusCancellationCtrl 
* Created Date   : 10 May 2018
* Created By     : Veeramanikanta R
* Purpose        : Getting prediction buscancellation cases, Calling functionality and Approving or Rejecting cases
* Test class     : PredictionBusCancellationCtrlTest
*/
public class PredictionBusCancellationCtrl {
    public date doj{get;set;}
    public string tintime{get;set;}
    public boolean reEnableBOPopup{get;set;}
    public boolean reEnablePopup{get;set;}
    public string boPhoneNo{get;set;}
    public set<string> tins{get;set;}
    public string bophone{get;set;}
    public string selectedTin{get;set;}
    public string selTin;
    public string boAgentName{get;set;}
    public list<case> listCases{get;set;}
    public list<Response> resWrapper{get;set;}
    public List<Response> resTins{get;set;}
    public Map<string,case> caseMap;
    public boolean initBt{get;set;}
    public string caseId{get;set;}
    public string status{get;set;}
    public Map<string,List<String>> mapSFStattoApiStat{get;set;}
    public List<SPOCBusCancellationExtn.JsonBodyWrapper> jsBodyWraper{get;set;}
    public list<Order_Items__c> tList=new list<Order_Items__c>();
    public Map<string,Order_Items__c> trnMap;
    public list<case> casesToCreate{get;set;}
    public list<case> caseQList{get;set;}
    
    
    public PredictionBusCancellationCtrl (){
         doj=System.today();
        caseQList=new List<case>();
        mapSFStattoApiStat = new Map<string,List<String>>();
        mapSFStattoApiStat.put('Approved For Bus Cancellation',new List<String>{'Approved For Bus Cancellation','APPROVED',''});
        mapSFStattoApiStat.put('Rejected For Bus Cancellation',new List<String>{'Rejected For Bus Cancellation','DISAPPROVED',''});
        jsBodyWraper = new List<SPOCBusCancellationExtn.JsonBodyWrapper>();        
        selectedtin='';
        reEnablePopup=false;
        selTin='';
        initBt=false;
        caseMap=new Map<string,case>();
        tins=new set<string>();
        listCases=new list<case>();
        resWrapper=new list<Response>();
        trnMap=new Map<string,Order_Items__c>();
        resTins=new List<Response>();
        casesToCreate=new list<case>();
    }
    
    public void search(){
        
        System.debug('calling');
        resWrapper.clear(); 
        caseMap.clear();
        trnMap.clear();
        casesToCreate.clear();
        selectedTin='';
        selTin='';
        System.debug('doj --->'+doj );
        System.debug('tinTime---->'+tinTime);
        caseQList=[select id,tin_no__c,Route_Id__c,PD_DOJ__c,Service_Provider_Id__c ,transaction_id__c,transaction_id__r.name,transaction_id__r.id,caseNumber,status from case where PD_DOJ__c =:doj AND BusC_PD_Time__c=:tinTime ];
        System.debug('caseQlist--->'+caseQList.size());
        for(case c:caseQList){
            Response r=new Response();
            r.isSelected=false;             
            r.tin=c.tin_no__c;
            r.doj=String.valueof(c.PD_DOJ__c);
            r.operator_id=c.Service_Provider_Id__c;
            r.route_id=c.Route_Id__c;
            r.caseNumber=c.casenumber;
            r.caseStatus=c.status;
            r.caseRecId=c.id;
            r.trnId=c.transaction_id__r.name;
            r.tredcId=c.transaction_id__r.id;
            resWrapper.add(r);
        }
    }
    
    
    public void refreshTable(){
        resWrapper.clear(); 
        caseMap.clear();
        System.debug('resWrapper-->'+resWrapper);
        listCases=[select id,tin_no__c,tin__c,transaction_id__r.name,transaction_id__r.id,caseNumber,status from case where tin_no__c in:tins ];
        for(case c:listCases){
            caseMap.put(c.tin_no__c,c);
        }
        
        caseQList.clear();
        caseQList=[select id,tin_no__c,Route_Id__c,PD_DOJ__c,Service_Provider_Id__c ,transaction_id__c,transaction_id__r.name,transaction_id__r.id,caseNumber,status from case where PD_DOJ__c =:doj AND BusC_PD_Time__c=:tinTime ];
        
        for(case c:caseQList){
            Response r=new Response();
            if(selectedtin==c.tin_no__c)
                r.isSelected=true;    
            else
                r.isSelected=false;                 
            r.tin=c.tin_no__c;
            r.doj=String.valueof(c.PD_DOJ__c);
            r.operator_id=c.Service_Provider_Id__c;
            r.route_id=c.Route_Id__c;
            r.caseNumber=c.casenumber;
            r.caseStatus=c.status;
            r.caseRecId=c.id;
            r.trnId=c.transaction_id__r.name;
            r.tredcId=c.transaction_id__r.id;
            resWrapper.add(r);
        }        
    }
    
    public PageReference caseUpdate(){  
        
        String selTinForUpdate;
        String selCaseForUpdate;
        
        if(String.isBlank(status))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select The Status'));
            return null;
        }
        if(String.isBlank(bophone) || String.isBlank(boAgentName))
        {
            reEnablePopup=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter BO Name/BO Phone'));
            return null;
        }
        
        reEnablePopup=false;
        for(Response re:resWrapper)
        {
            system.debug('re val-->'+re);
            if(re.isSelected)
            {
                selTinForUpdate =re.tin;
                selCaseForUpdate = re.caseNumber;
                selTin = selTinForUpdate;
            }
        }
        
        System.debug('selCaseForUpdate..'+selCaseForUpdate+'selTinForUpdate..'+selTinForUpdate);
        if(String.isBlank(selCaseForUpdate))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select At least One Case For Update or Selected Transactions is Not Having any Case to Update'));
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            Order_Items__c tO=[select id from Order_Items__c where Order_Item_Reference_No__c=:selTinForUpdate];
            System.debug('selCaseForUpdate --->'+selCaseForUpdate );
            case cObj=new case();
            cObj= [select id,Date_Of_Journey_New__c,tin__c,Route_Id__c from case where caseNumber=:selCaseForUpdate limit 1];
            cObj.status=status; 
            cObj.Transaction_id__c=tO.id;           
            cObj.BOAgentContactBySPOC__c=bophone;
            cObj.BOAgentNameBySPOC__c=boAgentName;
            cObj.Approved_By__c=UserInfo.getName()+'('+UserInfo.getUserName()+')';
            
            update cObj;
            System.debug('cObj.doj-->'+cObj);
            cObj= [select id,Approved_By__c,BOAgentContactBySPOC__c,BOAgentNameBySPOC__c,createdby.Name,createdby.Username,CreatedDate,LastModifiedDate,BOAgentNameByCSE__c,BOAgentContactByCSE__c,OrderItem_Uuid__c,Date_Of_Journey_New__c,tin__c,Route_Id__c from case where caseNumber=:selCaseForUpdate limit 1];
            List<string> opTypeApporvals=new List<string>();
            set<string> setTins=new set<string>();
            Map<string,string> mapTinCsId=new Map<string,string>();
            
            opTypeApporvals.add(status);
            opTypeApporvals.add(bophone);
            opTypeApporvals.add(boAgentName);
            opTypeApporvals.add(UserInfo.getName()+'('+UserInfo.getUserName()+')');
            
            System.debug('opTypeApporvals-->'+opTypeApporvals);
            
            setTins.add(selTinForUpdate);
            mapTinCsId.put(selTinForUpdate,selCaseForUpdate);
            System.debug('status-->'+status);
            System.debug('g s-->'+mapSFStattoApiStat);
            System.debug('cObj-->'+cObj);
            
            jsBodyWraper.add(new SPOCBusCancellationExtn.JsonBodyWrapper(cObj,mapSFStattoApiStat.get(status)[1],mapSFStattoApiStat.get(status)[2]));           
            BusCancellationHandler.getAllViaRoutesTins(JSON.serialize(jsBodyWraper),opTypeApporvals,setTins,mapTinCsId);
            
            refreshTable(); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,'Case '+selCaseForUpdate+' has been updated successfully!!'));            
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Case '+selCaseForUpdate+' update is failed, Please try again'+e));            
            
        }
        return null;
    }
    
    public class BOCallWrapper{
        public string tin;
        public string OperatiorId;
        public string OperatorName;
        public string caller;
        public string receiver;
        public boolean primary;
        public String doj;
        public string routeId;
        public BOCallWrapper(string boPhoneNo,string agentPhoneNo,Order_Items__c tObj){
            this.tin=tObj.Order_Item_Reference_No__c;
            this.OperatiorId=tObj.Service_Provider_Id__c;
            this.OperatorName=tObj.Service_Provider_Name__c;
            caller=agentPhoneNo;
            receiver=boPhoneNo;
            this.primary=true;
            this.doj= String.valueOf(tObj.Date_Of_Service__c.format('dd-MM-yyyy h:mm a','Asia/Kolkata'));
            this.routeId=tObj.Route_Id__c;
            
        }
    }
    
    public void connectCall(){   
        user uObj=[select id,Phone,MobilePhone from user where id=:UserInfo.getUserID()];
        
        if(selectedtin==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select at least one tin for calling to BO'));
            
        }       
        else if(String.isBlank(boPhoneNo) || String.isBlank(uObj.MobilePhone)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'BO Mobile Number Is Missing Or Signed in Agent Mobile Number is Not Configured'));
        }        
        else
        {
            Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
            Order_Items__c tObj=[select id,Order_Item_Reference_No__c,Service_Provider_Id__c,Service_Provider_Name__c,Date_Of_Service__c,Route_Id__c from Order_Items__c where Order_Item_Reference_No__c=:selectedtin limit 1];
            
            Case selCase = new Case();      
            System.debug('caseid C-->'+caseId);            
            System.debug('selCase-->'+selCase);
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SinfinyCall'];
            
            string jsonBody;
            BOCallWrapper boWrap=new BOCallWrapper(boPhoneNo,uObj.MobilePhone,tObj);
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
                        
                        list<case> csObjList=new list<case>();
                        csObjList=[select id,Service_Provider_Id__c,Bus_Operator_Name__c,TIN_No__c from case where tin_no__c=:tObj.Order_Item_Reference_No__c limit 1];
                        
                        System.debug('resp-->'+res.getbody());
                        cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                        cInfObj.Case__c=csObjList[0].id;    
                        cInfObj.Operator_Id__c=csObjList[0].Service_Provider_Id__c;
                        cInfObj.Operator_Name__c=csObjList[0].Bus_Operator_Name__c;
                        cInfObj.TIN__c=csObjList[0].TIN_No__c;
                        cInfObj.Agent_Phone_Number__c=uObj.MobilePhone;
                        cInfObj.Campaign_Name__c='SPOC BO Confirmation';
                        cInfObj.BO_Phone_Number__c=boPhoneNo;
                        cInfObj.Message__c='Success';                   
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'+e));
            } 
            selTin=selectedtin;           
            refreshTable();             
        }
    }
    
    public class Response{
        public string trnId{get;set;}
        public string tredcId{get;set;}
        public string tin{get;set;}
        public string doj{get;set;}
        public string route_id{get;set;}
        public string operator_id{get;set;}
        public string caseNumber{get;set;}
        public string caseStatus{get;set;}
        public Boolean isSelected{get;set;}
        public string caseRecId{get;set;}
    }
}