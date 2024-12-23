/**
* (c) 2016 RedBus
*
* Name           : B2BSPOCBusCancellationExtn
* Created Date   : 29 Mar 2017
* Created By     : Praveen
* Purpose        : Extension class for B2BSPOCBusCancellation Page
*
**/

public class B2BSPOCBusCancellationExtn {
    
    public date doj{get;set;}
    public datetime dojt{get;set;}
    public date doi{get;set;}
    public case c{get;set;}  
    public List<CaseWrapper> listWrapCase{get;set;}  
    public string busCanRecType;
    public String selStatus{get;set;}
    public String selBO{get;set;}   
    public String selRId{get;set;}
    public boolean showSearchResult{get;set;}
    public boolean noResultfound{get;set;}  
    public boolean runQuery{get;set;}
    public list<selectOption> notesUpdate{get;set;}
    public list<selectOption> statusUpdate{get;set;}
    public string selectedNotes{get;set;}
    public string selectedupdstatus{get;set;}
    public string selTin{get;set;}
    public boolean rejctedstatus{get;set;}
    public String selSearchStatus{get;set;}
    public Map<string,List<String>> mapSFStattoApiStat;
    public string caseComments{get;set;}
    
    
    public B2BSPOCBusCancellationExtn(ApexPages.StandardController controller) 
    {
        busCanRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();      
        c = new Case();
        
        statusUpdate= new list<selectOption>();
        listWrapCase = new List<CaseWrapper>();       
        showSearchResult = false;
        selStatus = 'All';
        runQuery = true;
        noResultfound = true;
        rejctedstatus=false;
        c.approved_by__c =UserInfo.getName()+'('+UserInfo.getUserName()+')';
        mapSFStattoApiStat = new Map<string,List<String>>();
        
        mapSFStattoApiStat.put('Approved for Bus Cancellation',new List<String>{'Approved for Bus Cancellation','APPROVED','',''});
        mapSFStattoApiStat.put('Rejected For Bus Cancellation',new List<String>{'Rejected For Bus Cancellation','DISAPPROVED','','Instant resolution with refund-Rejected'});
        mapSFStattoApiStat.put('Alternative Arrangement by BO',new List<String>{'CLOSED','Alternative Arrangement by BO','Alternative Arrangement by BO',''});
        mapSFStattoApiStat.put('Refunded by redBus',new List<String>{'CLOSED','Cancel Ticket','Refund by redBus','Instant resolution with refund-Approved'});
        mapSFStattoApiStat.put('Refunded by BO',new List<String>{'CLOSED','Refunded by BO','Refund by BO',''});
        mapSFStattoApiStat.put('Refunded as suggested by BO',new List<String>{'CLOSED','Cancel Ticket','Refunded as suggested by BO',''});
        mapSFStattoApiStat.put('Refund rejected by BO',new List<String>{'CLOSED','DISAPPROVED','Refund rejected by BO',''});
        //mapSFStattoApiStat.put('Alternative arranged by BO',new List<String>{'CLOSED','Alternative arranged by BO','Alternative arranged by BO'});
        
    }
    
    public list<SelectOption> getsearchStatusOptions()
    {
        list<SelectOption> options = new list<Selectoption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Initiated','Initiated For Bus Cancellation'));
        options.add(new SelectOption('Approved For Bus Cancellation','Approved for Bus Cancellation'));
        
        return options;
    }
    
    
    public void doSearch()
    {
        listWrapCase.clear();    
        showSearchResult = true;
        runQuery = true;
        noResultfound = true;            
        DateTime tempDOJ;
        DateTime tempDOI;      
        
        String strQry ='SELECT '+System.Label.Bus_Cancellation_Query + ' (recordTypeId=:busCanRecType and Type=\'B2B\' '; 
        
        if(string.isNotBlank(selTin)){
            strQry = strQry +'AND TIN_No__c=:selTin';
        }
        
        if(doj!=null)
        {         
            tempDOJ = doj.addDays(-1);
            DateTime startDOJ = DateTime.newInstanceGMT(tempDOJ.year(),tempDOJ.month(),tempDOJ.day(),18,30,00);
            DateTime endDOJ = DateTime.newInstanceGMT(doj.year(),doj.month(),doj.day(),18,29,59);
            strQry = strQry +' AND (SS_DOJ__c>=:startDOJ AND SS_DOJ__c<=:endDOJ) ';
            
        }
        
        if(doi!=null)
        {
            tempDOI = doi.addDays(-1);
            DateTime startDOi = DateTime.newInstanceGMT(tempDOI.year(),tempDOI.month(),tempDOI.day(),18,30,00);
            DateTime endDOi = DateTime.newInstanceGMT(doi.year(),doi.month(),doi.day(),18,29,59);
            strQry = strQry +' AND (createddate>=:startDOi AND Createddate<=:endDOi) ';
            
        }
        
        
        if('All'.equalsIgnoreCase(selSearchStatus))
        {
            strQry = strQry +' AND status!=null';
        }
        else if('Pending Auto Refunded'.equalsIgnoreCase(selSearchStatus)){
            strQry = strQry +' AND status IN(\'Refunded By Ageing Scheduler\',\'Department Revert\') AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true';
        }
        
        else{
            strQry = strQry +' AND status=:selSearchStatus';        
        }
        
        String userId = UserInfo.getUserID();
        system.debug('--userId --'+userId );
        strQry = strQry+' AND OwnerId=:userId) ';
        system.debug('--strQry--'+strQry);
        for(Case c : Database.query(strQry))
        {
            noResultfound = false;            
            CaseWrapper cw = new CaseWrapper(c);
            listWrapCase.add(cw);
        }
        
        statusUpdate.clear();       
        
        if(selSearchStatus=='Initiated'){
            statusUpdate.add(new SelectOption('','--None--'));
            statusUpdate.add(new selectOption('Approved for Bus Cancellation','Approved for Bus Cancellation'));
            statusUpdate.add(new selectOption('Rejected For Bus Cancellation','Rejected For Bus Cancellation'));
        }
        
        if(selSearchStatus=='Approved For Bus Cancellation'){
            statusUpdate.add(new SelectOption('','--None--'));
            statusUpdate.add(new selectOption('Refunded by redBus','Refunded by redBus'));
            statusUpdate.add(new selectOption('Alternative Arrangement by BO','Alternative Arrangement by BO'));
            statusUpdate.add(new selectOption('Refunded by BO','Refunded by BO'));
        }
        
        if(selSearchStatus=='Pending Auto Refunded'){
            statusUpdate.add(new SelectOption('','--None--'));
            statusUpdate.add(new selectOption('Refunded as suggested by BO','Refund as suggested by BO'));
            statusUpdate.add(new selectOption('Refund rejected by BO','Refund rejected by BO'));
            //statusUpdate.add(new selectOption('Alternative arranged by BO','Alternative arranged by BO'));
        }  
    }
    
    
    
    
    /* 
Name: updateFinalStatus
Description: Update Final Status in Salesforce and Seat Seller 
*/
    public PageReference updateFinalStatus(){
        
        
        List<HttpRequestWrappersUtil.CaseRequestWrapper> cReqList=new list<HttpRequestWrappersUtil.CaseRequestWrapper>(); 
        set<string> caseNumbers=new set<string>();
        List<Case> listCaseToUpdate = new List<Case>();
        Set<String> csCsNos = new Set<String>();
        Map<String,Case> csMap = new Map<String,Case>();
        List<CaseComment> listCommToInsert = new List<CaseComment>();
        set<string> csIds=new set<string>();
        
        system.debug('--caseComments--'+caseComments+'---selectedupdstatus---'+selectedupdstatus);
        
        if(string.isBlank(caseComments)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Comments'));
            return null;
        }
        else
        {  
            system.debug('-listWrapCase --'+listWrapCase );
            if(selectedupdstatus=='Approved for Bus Cancellation')
            {
                for(CaseWrapper wrap: listWrapCase )
                {       
                    if(wrap.isSelect==true && selectedupdstatus=='Approved for Bus Cancellation')
                    {
                        wrap.cs.status = 'Approved For Bus Cancellation';
                        // wrap.cs.redCare_Status__c = wrap.cs.My_Desk_Id__c!= null?'Instant resolution with refund-Approved':'';
                        listCaseToUpdate.add(wrap.cs);
                        csIds.add(wrap.cs.id);
                    }
                }
                
                if(!listCaseToUpdate.isEmpty())
                {
                    try
                    {        
                        DataBase.update(listCaseToUpdate,false);
                        B2BSPOCBusCancellationExtn.B2BBusCancellationInitiation(csIds,'B2B');

                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All Records Updated Successfully'));
                       
                        return null;
                    }
                    catch(Exception e)
                    {
                        System.debug('Case updation error-->'+e);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error While Updating .Please retry'+String.valueOf(e)));
                        return null;
                    }
                }
            }
            else
            {
                for(CaseWrapper wrap: listWrapCase)
                {       
                    
                    if(wrap.isSelect==true)
                    {
                        if(string.isNotBlank(wrap.cs.Channel_ct__c) && (wrap.cs.Channel_ct__c=='MMT' ||wrap.cs.Channel_ct__c == 'GI')){
                            cReqList.add(new HttpRequestWrappersUtil.CaseRequestWrapper(wrap.cs.PNR__c,mapSFStattoApiStat.get(selectedupdstatus)[1]));    
                        }else{
                            cReqList.add(new HttpRequestWrappersUtil.CaseRequestWrapper(wrap.cs.TIN_No__c,mapSFStattoApiStat.get(selectedupdstatus)[1]));    
                        }
                        
                        csCsNos.add(wrap.cs.casenumber);
                    }
                }
                
                
                if(!cReqList.isEmpty())
                {
                    
                    for(case c:[select id,tin_no__c,PNR__c,casenumber,Channel_ct__c, My_Desk_Id__c from case where Casenumber in:csCsNos]){
                        if(string.isNotBlank(c.Channel_ct__c) && (c.Channel_ct__c=='MMT' ||c.Channel_ct__c == 'GI')){
                            csMap.put(c.PNR__c,c);
                        }else{
                            csMap.put(c.tin_no__c,c);
                        }
                    }
                    
                    Http h= new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    req.setHeader('Accept', 'application/json');
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SSBusCancellation'].Endpoint__c);
                    req.setMethod('POST');
                    req.setBody(json.serialize(cReqList));
                    DBLog_Summary__c dbl = new DBLog_Summary__c();
                    dbl.Type__c = 'Bus Cancellation SS '+ selectedupdstatus +'Update';
                    dbl.SentAt__c = system.now();
                    dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(json.serialize(cReqList));
                    try
                    {
                        res=h.send(req);
                        dbl.Payment_Request_Response_Time__c = System.now();
                        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                        dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                        List<HttpRequestWrappersUtil.ResponseWrapper> respWprlist = new List<HttpRequestWrappersUtil.ResponseWrapper>();
                        respWprlist = (list<HttpRequestWrappersUtil.ResponseWrapper>)system.JSON.deserialize(res.getBody(), list<HttpRequestWrappersUtil.ResponseWrapper>.class);
                        String succCasesMsg ='';
                        String errCaseMsg='';
                        for(HttpRequestWrappersUtil.ResponseWrapper reswpr:respwprlist)
                        {
                            case cs = new case();
                            cs=csMap.get(reswpr.tin);
                            caseComment comm = new CaseComment();
                            comm.parentId = cs.id;
                            
                            if(reswpr.responseCode =='200' && reswpr.responseMessage=='SUCCESS')
                            {
                                cs.Notes__c = mapSFStattoApiStat.get(selectedupdstatus)[2];
                                cs.status= mapSFStattoApiStat.get(selectedupdstatus)[0];
                                cs.redCare_Status__c = (cs.My_Desk_Id__c!= null && mapSFStattoApiStat.get(selectedupdstatus)[2]=='Refund by redBus')?mapSFStattoApiStat.get(selectedupdstatus)[3]:'';
                                comm.commentbody = 'Case Details Updated Successfully in Seat Seller'+'--Agent-->'+caseComments;
                                listCommToInsert.add(comm);
                                listCaseToUpdate.add(cs);
                                succCasesMsg =succCasesMsg+','+cs.CaseNumber;
                                
                            }else if(reswpr.responseCode =='200' && reswpr.responseMessage=='Duplicate request;Already processed' && 'Refunded by BO'.equalsIgnoreCase(selectedupdstatus)){
                                
                                cs.Notes__c =mapSFStattoApiStat.get(selectedupdstatus)[2];
                                cs.status= mapSFStattoApiStat.get(selectedupdstatus)[0];
                                comm.commentbody = 'Ticket is Already in cancelled state hence closing the case with selected status-'+'--Agent-->'+caseComments;
                                listCommToInsert.add(comm);
                                listCaseToUpdate.add(cs);
                                succCasesMsg =succCasesMsg+','+cs.CaseNumber;
                            }
                            
                            else
                            {
                                errCaseMsg = errCaseMsg+','+cs.CaseNumber;
                                cs=csMap.get(reswpr.tin);
                                comm.commentbody = 'Error ocuucred While Updating in Seat Seller-'+reswpr.responseMessage+'--Agent-->'+caseComments;                  
                                listCommToInsert.add(comm);
                                listCaseToUpdate.add(cs);
                            }
                        }
                        
                        DataBase.insert(dbl,false);
                        
                        if(!listCaseToUpdate.isEmpty())
                        {
                            
                            DataBase.insert(listCommToInsert,false);
                            DataBase.update(listCaseToUpdate,false);
                        }
                        
                        String finMsg='';
                        if(String.isNotBlank(succCasesMsg))
                            finMsg = succCasesMsg+' Cases Updated in Seat Seller Successfully.';
                        
                        if(String.isNotBlank(errCaseMsg))
                            finMsg = errCaseMsg+' Cases Failed To Update in Seat Seller.';
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,finMsg));
                        return null;
                        
                    }
                    
                    Catch(Exception e)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Has Occured While Updating---'+String.valueOf(e)));
                        return null;
                        
                    }
                    return null;
                    
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select At Least One Record For Update'));
                    return null;
                }
                
                
            }              
            return null;
        }
        
    }
    
    
    
    public class CaseWrapper
    {
        public boolean isSelect{get;set;}
        public Case cs{get;set;}
        public string routeId{get;set;}
        
        public CaseWrapper(Case cse)
        {
            this.isSelect = false;
            this.cs = cse;           
            System.debug('Case..'+cs);
            routeId = cs.Route_Id__c;            
            System.debug('routeId...'+routeId);
        }
    }
    
    @future(callout=true)
    public static void B2BBusCancellationInitiation(set<string> caseIds,string type){
        System.debug('caseIds-->'+caseIds);
        System.debug('type-->'+type);
        Set<String> setRouteIds = new Set<String>();
        Set<DateTime> setDateTime = new Set<DateTime>();
        Set<String> setRouteDOJLong = new Set<String>();
        List<case> newCopassRecords=new List<case>();
        List<DBLog_Summary__c> dbLogRecords=new List<DBLog_Summary__c>();
        Map<string,case> caseMap=new Map<string,case>();
        List<case> csLst=new List<case>();
        csLst=[select id,origin,status,Route_Id__c,SS_Route_Id__c,Date_Of_Journey_New__c,Partner__c,parentid, Service_Id__c   from case where id in:caseIds and Date_Of_Journey_New__c!=null];
        for(case cs:csLst){
            String rId;
            // if(type=='B2B'){
            //     rId = String.isNotBlank(cs.Route_Id__c)?cs.Route_Id__c:cs.SS_Route_Id__c;
            // }else{
            //     rId = String.isNotBlank(cs.Service_Id__c)?cs.Service_Id__c: '';
            // }
            rId = String.isNotBlank(cs.Route_Id__c)?cs.Route_Id__c:cs.SS_Route_Id__c;
            setRouteIds.add(rId);
            setDateTime.add(cs.Date_Of_Journey_New__c);
            string riDoj=rId+String.valueOf(cs.Date_Of_Journey_New__c.getTime());
            setRouteDOJLong.add(riDoj);
            caseMap.put(riDoj,cs);
        }
        System.debug('::: setRouteIds = '+setRouteIds);
        System.debug('::: setDateTime = '+setDateTime);
        List<Order_Items__c>  lstordrItm = new list<Order_Items__c>();
        string b2bRecType = Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();      
        
        lstordrItm =[select id,Boarding_Time__c,Inventory_Type__c,Date_Of_Service__c,recordtypeid,RecordType.Name,Guid__c,Mobile__c,Transaction_Status__c,Service_Provider_Id__c,Service_Provider_Name__c,Boarding_Point__c,Agent_IP__c,Service_Provider_Reference_PNR_No__c,Service_Provider_Reference_No__c,status__c,Order_Item_Reference_No__c,Business_Unit__c,Order_Id__c,Cancellation_Policy__c,Route_Id__c,DOI_DOJ__c,Seat_No__c,No_of_seats__c,(SELECT id,origin,status from cases__r where Issue_Type__c='Bus Cancellation') from Order_Items__c where recordTypeId=:b2bRecType and Route_Id__c IN :setRouteIds AND Transaction_Status__c='Booked' and Date_Of_Service__c IN :setDateTime];
       // lstordrItm =[select id,Boarding_Time__c,Inventory_Type__c,Date_Of_Service__c,recordtypeid,RecordType.Name,Guid__c,Mobile__c,Transaction_Status__c,Service_Provider_Id__c,Service_Provider_Name__c,Boarding_Point__c,Agent_IP__c,Service_Provider_Reference_PNR_No__c,Service_Provider_Reference_No__c,status__c,Order_Item_Reference_No__c,Business_Unit__c,Order_Id__c,Cancellation_Policy__c,Route_Id__c,DOI_DOJ__c,Seat_No__c,No_of_seats__c,(SELECT id,origin,status from cases__r where Issue_Type__c='Bus Cancellation') from Order_Items__c where Route_Id__c IN :setRouteIds AND Transaction_Status__c='Booked' and Date_Of_Service__c IN :setDateTime];
        List<casecomment> newCopassComments=new List<casecomment>();
        for(Order_Items__c orItem:lstordrItm){
            String rIdDoj = orItem.Route_Id__c + String.valueOf(orItem.Date_Of_Service__c.getTime());
            System.debug('rIdDoj-->'+rIdDoj);
            if(setRouteDOJLong.contains(rIdDoj) && orItem.cases__r.size()<=0)
            {
                API_EndPoints__mdt APIMData= [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BBusCancellation'];   
                user uObj=[select id,Phone,MobilePhone,email from user where id=:UserInfo.getUserID()];
                string jsonBody='{"tin":"'+orItem.Order_Item_Reference_No__c+'","agentId":"'+uObj.email+'"}';  
                OAuthGeneric oauthObj=new OAuthGeneric(); 
                DBLog_Summary__c  dbLogBC=new DBLog_Summary__c();     
                Http h= new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(APIMData.Endpoint__c);
                req.setMethod('POST');
                req.setBody(jsonBody);    
                System.debug('jsonBody-->'+jsonBody);
               // string oauthParams=oauthObj.sign(req,orItem.Inventory_Type__c);        
               // string endPoint=APIMData.Endpoint__c+'?'+oauthParams;
               // req.setEndpoint(endPoint);  
                res=h.send(req);
                string busCResp= res.getBody();     
                System.debug('busCResp->'+busCResp);
                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(busCResp);
                if(resObj!=null && string.valueof(resObj.get('status'))=='Initiated'){
                    string busCRecType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                    Case caseObj = new Case();
                    caseObj.Issue_Type__c = 'Bus Cancellation';
                    caseObj.Issue_Sub_Category__c = 'Initiate Bus Cancellation';
                    if(type=='B2B'){
                    caseObj.Status = 'Approved For Bus Cancellation';
                    }else if(type=='B2C'){
                    caseObj.Status = 'Initiated';
                    }
                    caseObj.Origin = caseMap.get(rIdDoj).origin;
                    caseObj.Transaction_ID__c = orItem.id ;
                    caseObj.SS_DOJ__c=orItem.Boarding_Time__c;
                    caseObj.Country__c='India';
                    caseObj.Business_Type__c='Domestic-Bus';
                    caseObj.recordtypeid= busCRecType;
                    caseObj.Is_Secondary_SourceInfo__c=true;
                    //System.debug('cObj.ParentId..>'+caseMap.get(rIdDoj).id);
                    caseObj.ParentId = caseMap.get(rIdDoj).ParentId;
                    caseObj.Type='B2B';
                    if(string.valueOf(orItem.Inventory_Type__c)=='MMT' || string.valueOf(orItem.Inventory_Type__c)=='GI'){
                        caseObj.OwnerId = [Select id from Group where type='Queue' AND developername='B2B_MMT_IBIBO_Cancellation'].id;
                    }else if(string.valueOf(orItem.Inventory_Type__c)=='Amazon' || string.valueOf(orItem.Inventory_Type__c)=='IRCTC'){
                        caseObj.OwnerId = [Select id from Group where type='Queue' AND developername='B2B_Amazon_IRCTC_Bus_Cancellation'].id;
                    }else{
                        caseObj.OwnerId = [Select id from Group where type='Queue' AND developername='Partners_Agents_Bus_Cancellation'].id;
                    }
                    //caseObj.OwnerId=UserInfo.getUserID();
                    caseObj.Partner__c=caseMap.get(rIdDoj).Partner__c;
                    newCopassRecords.add(caseObj);               
                }
                dbLogBC.Type__c='B2B-Auto-Bus Cancellation';
                dbLogBC.Request_Data__c = string.valueof(req)+'..Body..'+String.valueOf(jsonBody);
                dbLogBC.EndPoint__c = String.valueOf(req.getEndpoint());
                dbLogRecords.add(dbLogBC);
            }
        }
        
        if(!newCopassRecords.isEmpty()){       
            insert newCopassRecords;
            for(case c:newCopassRecords){
                    casecomment cc=new casecomment();
                    if(type=='B2B'){
                    cc.CommentBody='Auto Approved For Bus Cancellation as Co-Passenger is Approved';
                    }else if(type=='B2C'){
                    cc.CommentBody='Auto Created For Bus Cancellation as Co-Passenger is Approved';
                    }
                    cc.ParentId=c.id;
                    newCopassComments.add(cc);
            }
            if(!newCopassComments.isEmpty())
                insert newCopassComments;
        }
        if(!dbLogRecords.isEmpty()){
            insert dbLogRecords;
        }
    }   
}