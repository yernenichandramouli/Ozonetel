/*
* Name           : PredictionBusCancellation
* Created Date   : 10 May 2018
* Created By     : Veeramanikanta R
* Purpose        : Getting prediction buscancellation cases, Calling functionality and Approving or Rejecting cases
* Test class     : PredictionBusCancellationTest
*/
public class PredictionBusCancellation {
    public date doj{get;set;}
    public string tintime{get;set;}
    public list<Response> tinList{get;set;}
    public boolean reEnableBOPopup{get;set;}
    public string boPhoneNo{get;set;}
    public set<string> tins{get;set;}
    public string bophone{get;set;}
    public string selectedTin{get;set;}
    public boolean boPhoneT{get;set;}
    public string boAgentName{get;set;}
    public list<case> listCases{get;set;}
    public list<Response> resWrapper{get;set;}
    public List<Response> resTins{get;set;}
    public Map<string,case> caseMap;
    public boolean initBt{get;set;}
    public string caseId{get;set;}
    public string status{get;set;}
    public string routeId{get;set;}
    public Map<string,List<String>> mapSFStattoApiStat{get;set;}
    public List<SPOCBusCancellationExtn.JsonBodyWrapper> jsBodyWraper{get;set;}
    public list<Order_Items__c> tList=new list<Order_Items__c>();
    public Map<string,Order_Items__c> trnMap;
    
    
    public PredictionBusCancellation (){
        
        mapSFStattoApiStat = new Map<string,List<String>>();
        mapSFStattoApiStat.put('Approved For Bus Cancellation',new List<String>{'Approved For Bus Cancellation','APPROVED',''});
        mapSFStattoApiStat.put('Rejected For Bus Cancellation',new List<String>{'Rejected For Bus Cancellation','DISAPPROVED',''});
        jsBodyWraper = new List<SPOCBusCancellationExtn.JsonBodyWrapper>();        
        selectedtin='';
        initBt=false;
        caseMap=new Map<string,case>();
        tins=new set<string>();
        listCases=new list<case>();
        resWrapper=new list<Response>();
        trnMap=new Map<string,Order_Items__c>();
    }
    public void search(){
        resWrapper.clear(); 
        caseMap.clear();
        trnMap.clear();
        selectedTin='';
        boPhoneT=false;
        System.debug('doj-->'+doj+'tintime-->'+tintime);
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PredictionBC'];
        string ep=APIMData.Endpoint__c+tintime+'&doj='+doj;
        string jsonCM='{"action":"GET","body":"","endPoint":"'+ep+'","headers":""}';
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setMethod('POST');
        req.setBody(jsonCM);
        req.setEndpoint(APIMData.Endpoint__c);  
        try{
            res=h.send(req);  
            System.debug('req-->'+req);
            System.debug('rr-->'+res.getStatus());                   
            tinList=new List<Response>();
            string mJson='[{"tin":"TM5N62346289"},{"tin":"TM5R49721669"},{"tin":"TM5W91090115"},{"tin":"TM5J37938592"},{"tin":"TM5E61773593"},{"tin":"TM5X99580184"},{"tin":"TM5W15116204"},{"tin":"TM5H48294107"}]';
            
            resTins= (List<Response>)System.JSON.deserialize(res.getbody(),List<Response>.class);
            
            System.debug('res-->'+resTins);
            
            for(Response r:resTins){
                tinList.add(r);
                tins.add(r.tin);
            }
            
            listCases=[select id,tin_no__c,transaction_id__c,transaction_id__r.name,caseNumber,status from case where tin_no__c in:tins];
            for(case c:listCases){
                caseMap.put(c.tin_no__c,c);
            }
            
            tList=[select id,Order_Item_Reference_No__c,name from Order_Items__c where Order_Item_Reference_No__c in:tins];
            for(Order_Items__c t:tList){
                trnMap.put(t.Order_Item_Reference_No__c,t);
            }
            
            for(Response re:resTins){
                Response r=new Response();
                if(trnMap.get(re.tin)!=null){
                    r.tredcId=trnMap.get(re.tin).id;
                    r.trnId=trnMap.get(re.tin).name;
                }
                r.tin=re.tin;
                r.doj=re.doj;
                r.operator_id=re.operator_id;
                r.route_id=re.route_id;
                if(caseMap.get(re.tin)!=null){
                    r.caseNumber=caseMap.get(re.tin).casenumber;
                    r.caseStatus=caseMap.get(re.tin).status;
                }
                resWrapper.add(r);
            }
        }catch(Exception e){           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Search API is failed, Please try again'));            
        } 
        
    }

    public void initiateCase(){
        List<Order_Items__c> tList=new List<Order_Items__c>();
        tList=[select id from Order_Items__c where Order_Item_Reference_No__c=:selectedtin limit 1];
        
        if(selectedtin==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select at least one tin to Initiate case'));            
        }        
        else if(tList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Transaction is not available, Plz sync this transaction to SF'));            
        }
        else{
            Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
            
            Case cs = new Case();
            cs.Status = 'Initiated';
            cs.RecordTypeId = RecTypeId ;
            cs.Issue_Type__c ='Bus Cancellation';
            cs.Origin ='Predication BC';
            cs.Is_Secondary_SourceInfo__c = false;
            cs.tin_no__c=selectedtin;
            cs.Transaction_ID__c=tList[0].id;
           
            insert cs;
            refreshTable();          
        }
    }
    
    public void refreshTable(){
        resWrapper.clear(); 
        caseMap.clear();
        System.debug('resWrapper-->'+resWrapper);
        listCases=[select id,tin_no__c,tin__c,caseNumber,status from case where tin_no__c in:tins ];
        for(case c:listCases){
            caseMap.put(c.tin_no__c,c);
        }
        System.debug('caseMap-->'+caseMap);
        for(Response re:resTins){
            Response r=new Response();
            r.tin=re.tin;
            r.doj=re.doj;
            r.operator_id=re.operator_id;
            r.route_id=re.route_id;
            if(caseMap.get(re.tin)!=null){
                r.caseNumber=caseMap.get(re.tin).casenumber;
                r.caseStatus=caseMap.get(re.tin).status;
            }
            resWrapper.add(r);
        }
        selectedtin='';
        caseId='';  
    }
    
    public void caseUpdate(){  
        if(selectedtin==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select at least one tin to update case'));
            
        }else{
            Savepoint sp = Database.setSavepoint();
            try{
                case cObj=[select id,Date_Of_Journey_New__c,tin__c,Route_Id__c from case where caseNumber=:caseId limit 1];
                cObj.status=status;
                update cObj;
               
                List<string> opTypeApporvals=new List<string>();
                set<string> setTins=new set<string>();
                Map<string,string> mapTinCsId=new Map<string,string>();
                
                opTypeApporvals.add(status);
                opTypeApporvals.add(bophone);
                opTypeApporvals.add(boAgentName);
                opTypeApporvals.add(UserInfo.getName()+'('+UserInfo.getUserName()+')');
                
                setTins.add(selectedTin);
                mapTinCsId.put(selectedTin,caseId);
                System.debug('status-->'+status);
                System.debug('g s-->'+mapSFStattoApiStat);
                System.debug('cObj-->'+cObj);
                
                jsBodyWraper.add(new SPOCBusCancellationExtn.JsonBodyWrapper(cObj,mapSFStattoApiStat.get(status)[1],mapSFStattoApiStat.get(status)[2]));           
                BusCancellationHandler.getAllViaRoutesTins(JSON.serialize(jsBodyWraper),opTypeApporvals,setTins,mapTinCsId);
                
                refreshTable(); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,'Case has been updated successfully!!'));            
            }catch(Exception e){
                Database.rollback(sp);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Case update is failed, Please try again'+e));            
                
            }
        }
    }
    
    public void connectCall2(){
        
        user uObj=[select id,Phone,MobilePhone from user where id=:UserInfo.getUserID()];
        
        if(selectedtin==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select at least one tin for calling to BO'));
            
        }       
        else if(String.isBlank(boPhoneNo) || String.isBlank(uObj.MobilePhone)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'BO Mobile Number Is Missing Or Signed in Agent Mobile Number is Not Configured'));
        }
        else if(caseId=='') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please initiate a case before calling to BO'));        
        }
        else
        {
            Case selCase = new Case();      
            System.debug('caseid C-->'+caseId);
            selCase =[select id,casenumber,tin_no__c,Service_Provider_Id__c,SS_Route_Id__c,Bus_Operator_Name__c,Is_Primary__c,Date_Of_Journey_New__c,Route_Id__c from case where casenumber=:caseId limit 1];
            System.debug('selCase-->'+selCase);
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SinfinyCall'];
            
            string jsonBody;
            RequestWrapper.BOCallWrapper boWrap=new RequestWrapper.BOCallWrapper(boPhoneNo,uObj.MobilePhone,selCase);
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
                        cInfObj.Agent_Phone_Number__c=uObj.MobilePhone;
                        cInfObj.Campaign_Name__c='SPOC BO Confirmation';
                        cInfObj.BO_Phone_Number__c=boPhoneNo;
                        cInfObj.Operator_Id__c=selCase.Service_Provider_Id__c;
                        cInfObj.Operator_Name__c=selCase.Bus_Operator_Name__c;
                        cInfObj.TIN__c=selCase.TIN_No__c;
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'));
            } 
            selectedtin='';
            caseId='';              
        }
    }
    
    public class Response{
        public string trnId{get;set;}
        public string tredcId{get;set;}
        public string tin{get;set;}
        public string doj{get;set;}
        public string route_id{get;set;}
        public string operator_id{get;set;}
        public string boPhoneW{get;set;}
        public string caseNumber{get;set;}
        public string caseStatus{get;set;}
    }
}