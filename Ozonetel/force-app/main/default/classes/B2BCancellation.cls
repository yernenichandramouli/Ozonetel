/*
* Name           : B2BCancellation
* Created Date   : 14 June 2019
* Created By     : Veeramanikanta R
* Purpose        : Cancellation flow for B2B Tickets 
* Test class     : B2BCancellationTest
*/
public class B2BCancellation{
    public B2BCancellation(ApexPages.StandardController controller) {
        //boolean isMMTchannel;
        ordObj=new Order_Items__c();
        ordObj=(Order_Items__c)controller.getRecord();
        oauthObj=new OAuthGeneric(); 
        cpl=new Cancellation_Process_DB_Log__c();
        breakUpblk=false;      
        cancelBlk=false;
        expBlk=false;
        cancelChargeMap=new Map<string,string>();
        fareMap=new Map<string,string>();
        fareList=new list<FareWrapper>();
        ordItm=new Order_Items__c();
        ordItm = [select id,Total_Fare_Value__c,Inventory_Type__c,Total_Fare__c,id__c,Total_Fare_Currency__c,Cancelled_Seats__c,status__c,OrderUuid__c,Order_Id__c,Seat_No__c,Guid__c,Order_Name__r.Guid__c, Business_Unit__c,Transaction_Status__c, Order_Item_Reference_No__c,Item_Type__c, Email__c, Email_Copy__c,Date_Of_Purchase__c,Date_Of_Service__c from Order_Items__c where id=:ordObj.id limit 1];
        tin=ordItm.Order_Item_Reference_No__c;
        cancelBt=false;
        if(string.isNotBlank(ordItm.Cancelled_Seats__c)){
            partialCancelled=true;
        }
        expCsList=new list<case>();
        string rStatus = '%Rejected For Exceptional Refund%';       
        expCsList=[select id,casenumber,All_Previous_Status_Dates__c,transaction_id__c from case where transaction_id__c=:ordItm.id and issue_type__c='Exceptional Refund' and (status='Approved For Exceptional Refund' or status='Closed' )and Previous_Status__c!='Rejected For Exceptional Refund' limit 1];
        excepCs=false;
        if(!expCsList.isEmpty()){
            excepCs=true;
        }
        System.debug('dos->'+ordItm.Date_Of_Service__c+'---Now-->'+System.now());
        if(ordItm.Date_Of_Service__c>system.now()){
            canexpBts=true;
        }else{
            canexpBts=false;
        }
        picklistMap = new Map<String, List<String>>();
        picklistMap.put('--None--', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
        picklistMap.put('Operator Refund', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
        picklistMap.put('Technical Error', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
        picklistMap.put('Customer delight', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
       
         if(String.isNotBlank(ordItm.Inventory_Type__c) && (String.valueOf(ordItm.Inventory_Type__c)=='MMT' || String.valueOf(ordItm.Inventory_Type__c)=='GOIBIBO')){
            isMMTchannel = true;
              picklistMap.put('Instant refund - customer delight', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
              picklistMap.put('Instant refund - Collectible from BO', new List<String>{'--None--', 'Service Issue','Redbus Tech Issue', 'Vendor Tech Issue', 'SS-API Tech Issue'});
       
         }
        getPrimaryPickVals();
        System.debug('excepCs->'+excepCs+'-canexpBts->'+canexpBts);
    }
    
    public List<case> expCsList;
    public Order_Items__c ordObj;
    public string isCancellableReq;
    public string isCancellableResp;
    public string cancellationReq;
    public string cancellationResp;
    public API_EndPoints__mdt APIMData;
    public list<CancellationCharges> charges{get;set;}
    public CancelResponseWrapper cancelRespObj{get;set;}
    public string restResp{get;set;}
    public OAuthGeneric oauthObj;  
    public string tin{get;set;}
    public string endPoint;
    public string cancellationType{get;set;}
    public string refundReason{get;set;}
    public Map<String, List<String>> picklistMap { get; set; }
    public List<SelectOption> selectList { get; set; }
    public List<SelectOption> reasonSelectList { get; set; }
    public boolean cancelBlk{get;set;}
    public decimal expRefAmount{get;set;}
    public decimal mmtMaxRefundAmount{get;set;}
    public decimal suggestedAmount{get;set;}
    public boolean expBlk{get;set;}
    public string description{get;set;}
    public Map<string,string> cancelChargeMap{get;set;}
    public Map<string,string> fareMap{get;set;}
    public list<FareWrapper> fareList{get;set;}
    public string cancellation{get;set;}
    public string partialCancellation{get;set;}
    public boolean partialCancelled{get;set;}
    public string parentCase{get;set;}
    public Order_Items__c ordItm{get;set;}
    public string orItemId{get;set;}
    public string isCancelResp;
    public boolean breakUpblk{get;set;}
    public string cancelJsbody{get;set;}
    public Cancellation_Process_DB_Log__c cpl;
    public boolean cancelBt{get;set;}
    public boolean excepCs{get;set;}
    public boolean canexpBts{get;set;}
    public boolean isMMTchannel{get;set;}
    public decimal totalTktAmount{get;set;}
    public decimal cancellationCharges{get;set;}
    public decimal refundAmount{get;set;}
    public static list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];

    public void getPrimaryPickVals(){
        selectList = new List<selectOption>();

        for(String s : picklistMap.keySet())
            selectList.add(new SelectOption(s, s));
    }

    public void getReasonPickVals(){
        if(cancellationType != null){
            reasonSelectList = new List<selectOption>();

            for(String s : picklistMap.get(cancellationType))
            reasonSelectList.add(new SelectOption(s, s));
        }
    }
    
    
    public void ExceptionalRefundBlock(){
        expBlk=true;
        cancelBlk=false;
    }

    public object ExceptionalRefund(){
        
        case c=new case();
        List<Case> listCases = new List<Case>();
        List<case> exceptionalCaseList = New list<case>();
        try{
            parentCase=parentCase.trim();
            
            
            listCases =[Select id,status,Service_Provider_Id__c,Transaction_ID__c,My_Desk_Id__c,Issue_Type__c,Max_Refund_Amount__c,Amount__c,Trip_Id_ct__c,TIN_No__c,PNR__c,Channel_ct__c,Refund_Amount__c,Refund_Type__c,Inventory_Type__c,Service_Providerr_Id__c from Case where caseNumber=:parentCase];
            exceptionalCaseList = [SELECT Id, caseNumber FROM case WHERE Transaction_ID__c=:listCases[0].Transaction_ID__c AND Issue_Type__c='Exceptional Refund'];
          //  System.debug('tt-->'+listCases[0].Transaction_ID__c+'--ordID-->'+ordItm.id);
           
            if(cancellationType=='Technical Error' && string.isBlank(description)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter description'));
            }
            //  if(listCases.isEmpty() || (String.isNotBlank(listCases[0].Transaction_ID__c) && listCases[0].Transaction_ID__c!=orIt.id) || (String.isNotBlank(listCases[0].TIN_No__c) && listCases[0].TIN_No__c!=orIt.Order_Id__c))
            else If(string.isBlank(parentCase) || listCases.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide valid parent case number'));
                return null;
            }
            else if((String.isBlank(listCases[0].Transaction_ID__c) || listCases[0].Transaction_ID__c!=ordItm.id))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Entered case number might be related to other transaction!! Please provide the valid Case Number.'));
                return null;
            }else if(String.isNotBlank(listCases[0].My_Desk_Id__c) && expRefAmount>listCases[0].Max_Refund_Amount__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Refund amount should be less than max refund amount.'));
                return null;
            }else if(expRefAmount>ordItm.Total_Fare_Value__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Refund amount should not be more than ticket amount'));
                return null;
            }else if(exceptionalCaseList.size()>0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There is already an exceptional refund case('+exceptionalCaseList[0].CaseNumber+') existing for this transaction'));
                return null;
            }else if(expRefAmount==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter valid refund amount'));
                return null;
            }else{ 
                c.issue_type__c='Exceptional Refund';
                c.Issue_Sub_Category__c=cancellationType;
                c.Reason_For_Report__c=refundReason;
                c.Parentid=listCases[0].id;
                c.status='Open';
                c.Origin='InBound Call';
                c.Refund_Amount__c=expRefAmount;
                c.description=description;
                c.Transaction_ID__c=ordItm.id;
                c.PNR__c= ordItm.Order_Item_Reference_No__c;
                c.My_Desk_Id__c = String.isNotBlank(listCases[0].My_Desk_Id__c)?String.valueOf(listCases[0].My_Desk_Id__c):'';
                c.Channel_ct__c = String.isNotBlank(listCases[0].Channel_ct__c)?String.valueOf(listCases[0].Channel_ct__c):'';
                c.Inventory_Type__c = String.isNotBlank(listCases[0].Inventory_Type__c)?String.valueOf(listCases[0].Inventory_Type__c):'';
                c.Trip_Id_ct__c = ordItm .Order_Id__c;
                c.TIN_No__c = ordItm.Order_Item_Reference_No__c;
                c.Booking_Email_ID__c = ordItm.Email__c;
                c.OwnerId = System.Label.ExceptionalRefundQueueId;
                c.subject='Exceptional Refund-B2B';
                c.Business_Unit_ct__c = ordItm.Business_Unit__c;
                String conBusUnit = 'REDBUS_'+ordItm.Business_Unit__c.split('_')[1];
                c.Business_Type__c=String.isNotBlank(OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c)?OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c:'';
                c.country__c=string.isNotBlank(OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c)?OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c:'';
                if(string.isNotBlank(ordItm.Total_Fare_Currency__c)){
                  c.Price_Paid_Currency_ctp__c = ordItm.Total_Fare_Currency__c;
                }else{
                  c.Price_Paid_Currency_ctp__c='INR';
                }
                c.Type='B2B';
                if(String.isNotBlank(listCases[0].My_Desk_Id__c)){
                    if(listCases[0].Issue_Type__c == 'Bus Cancellation'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Exceptional refund case is not allowed for bus cancellation issue types.'));
                        return null;
                    }
                    List<case> parcaseToUpdateList = New List<case>();
                    listCases[0].Refund_Amount__c=expRefAmount;
                    listCases[0].Amount__c=expRefAmount;
                    Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
                    c.Service_Providerr_Id__c = listCases[0].Service_Providerr_Id__c;
                    c.User_Level_Team__c = 'GI/MMT';
                    string serviceProviderId = string.isNotBlank(listCases[0].Service_Providerr_Id__c)?listCases[0].Service_Providerr_Id__c:listCases[0].Service_Provider_Id__c;
                    if(string.isNotBlank(serviceProviderId) && instantRefundBoIds.contains(serviceProviderId)){
                        if('Instant refund - collectible from BO'.equalsIgnoreCase(c.Issue_Sub_Category__c)){
                            c.Refund_Type__c = 'Instant resolution with refund';
                            listCases[0].Refund_Type__c = 'Instant resolution with refund';
                        }else if('Instant refund - customer delight'.equalsIgnoreCase(c.Issue_Sub_Category__c)){
                            c.Refund_Type__c = 'Instant resolution - redBus Delight';
                            listCases[0].Refund_Type__c = 'Instant resolution - redBus Delight';
                        }
                    }
                    if(string.isNotBlank(serviceProviderId) && instantRefundBoIds.contains(serviceProviderId) && expRefAmount<= suggestedAmount ){
                        c.Exceptional_Refund_Initiated__c = true;
                        c.Refund_status__c='Exceptional Refund Approved';
                        c.redCare_Status__c ='Instant resolution with refund-Approved';
                        c.Approved_Rejected_Time__c = System.Now();
                        c.Approved_By__c = UserInfo.getUserName();
                        c.Status='Approved For Exceptional Refund';
                        listCases[0].Refund_status__c='Exceptional Refund Approved';
                        listCases[0].redCare_Status__c='Instant resolution with refund-Approved';
                        listCases[0].Approved_Rejected_Time__c = System.Now();
                        listCases[0].Approved_By__c = UserInfo.getUserName();
                        listCases[0].status = 'Closed';
                        string casecommentBody = 'The case was auto-approved by skip TL approval process, since the exceptional refund amount is less than the suggested amount.';
                        casecomment cc = New casecomment();
                        cc.Parentid = listCases[0].Id;
                        cc.CommentBody = casecommentBody;
                        insert cc;  
                    }
                    parcaseToUpdateList.add(listCases[0]);
                    c.My_Desk_Id__c  = String.isNotBlank(listCases[0].My_Desk_Id__c)?String.valueOf(listCases[0].My_Desk_Id__c):'';
                    if(!parcaseToUpdateList.isEmpty()){
                        update parcaseToUpdateList;
                    }
                }
                insert c;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request has been submitted succcessfully for Approval, Post approval Refund will be processed'));
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Something went wrong. Please contact Admin!! Error->'+string.valueOf(e)));
        }
        
        return null; 
    }

    // public void fetchMaxRefundAmount(){
    //     List<Case> listCases = new List<Case>();
    //     listCases =[Select id,Max_Refund_Amount__c from Case where caseNumber=:parentCase LIMIT 1];
    //     if(!listCases.isEmpty()){
    //         mmtMaxRefundAmount = listCases[0].Max_Refund_Amount__c;
    //     }else{
    //         mmtMaxRefundAmount = 0;
    //     }
        
    // }

    public void getSuggestedRefundAmount(){

        list<case> csParList=new list<case>();
        csParList=[select id,Issue_Type__c,Issue_Sub_Category__c, Max_Refund_Amount__c from case where casenumber=:parentCase LIMIT 1];
        System.debug('csParList--->'+csParList);
        suggestedAmount=0;
        if(!csParList.isEmpty()){
            mmtMaxRefundAmount = csParList[0].Max_Refund_Amount__c;
            List<Issue_Based_TAT__mdt> im=new List<Issue_Based_TAT__mdt>();
            im=[select id,Exceptional_Refund_Suggested_Amount_Per__c from Issue_Based_TAT__mdt where Issue_Type__c=:csParList[0].Issue_Type__c and Issue_Sub_Category__c=:csParList[0].Issue_Sub_Category__c and Version__c='V2' AND Type__c='B2B'];
            System.debug('im-->'+im);
            if(!im.isEmpty() && im[0].Exceptional_Refund_Suggested_Amount_Per__c!=null)
                suggestedAmount=((ordItm.Total_Fare_Value__c/100)*im[0].Exceptional_Refund_Suggested_Amount_Per__c);
            if(suggestedAmount>mmtMaxRefundAmount){
                suggestedAmount = mmtMaxRefundAmount;
            }else{
                suggestedAmount=suggestedAmount;
            }
            
        }   
        System.debug('suggestedAmount-->'+suggestedAmount);
    }
    
    public object IsTicketCancellable(){
        cancelBt=false;      
        expBlk=false;
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BIsCancellable'];
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();        
        req.setEndpoint(APIMData.Endpoint__c+tin);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');                 
        string oauthParams=oauthObj.sign(req,ordItm.Inventory_Type__c);
        endPoint=APIMData.Endpoint__c+tin+'&'+oauthParams;
        req.setEndpoint(endPoint);
        System.debug('endPoint-->'+endPoint);
        cpl.IsCacellable_API_Request_Data__c =string.valueOf(req);
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetIsCancellableResponse';
        this.isCancellableReq= con.addHttpRequest(req); 
        return con;
    }
    
    public Object GetIsCancellableResponse()
    {
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        fareList.clear();
        cpl.IsTicket_CancellableAPI_Request__c = true;
        cpl.Type__c='B2B Cancellation';       
        try{
            cpl.TIN_Number__c=ordItm.Order_Item_Reference_No__c;
            cpl.Transaction_Name__c=ordItm.id;
            HttpResponse response = Continuation.getResponse(this.isCancellableReq);
            this.isCancellableResp= response.getBody();
            System.debug('isCancResp-->'+this.isCancellableResp);
            cpl.IsCacellable_API_Request_Response__c=this.isCancellableResp;
            isCancelResp=this.isCancellableResp;
            string mockResp='{ "cancellable": "true", "cancellationCharges": { "entry": [ { "key": "6", "value": "10.00" }, { "key": "7", "value": "10.00" }, { "key": "8", "value": "10.00" }, { "key": "9", "value": "10.00" }, { "key": "10", "value": "10.00" } ] }, "fares": { "entry": [ { "key": "6", "value": "105.00" }, { "key": "7", "value": "105.00" }, { "key": "8", "value": "105.00" }, { "key": "9", "value": "105.00" }, { "key": "10", "value": "105.00" } ] }, "freeCancellationTime": "0", "partiallyCancellable": "true", "serviceCharge": "0", "tatkalTime": "0" }';
            map<string,object> usMap= (map<string,object>)JSON.deserializeUntyped(isCancelResp);
            
            cancellation=string.valueOf(usMap.get('cancellable'));           
            partialCancellation=string.valueOf(usMap.get('partiallyCancellable'));
            cancelBlk=true;
            cpl.isTicketCancellable__c=boolean.valueOf(cancellation);
            cpl.isPartialCancellation__c=boolean.valueOf(partialCancellation);  
            
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again. If still persists please contact Admin.'));
        }
        database.upsert(cpl);
        return null;
    }
    
    public object CancelTicket(){
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BCancelTicket']; 
        CancelTicketWrapper cnObj=new CancelTicketWrapper();
        try{
            string selType;
            System.debug('fl-->'+fareList);
            for(FareWrapper f:fareList){              
                cnObj.tin=tin;
                System.debug('selc-->'+f.isSelected+'--cancellationType-->'+cancellationType);
                if(cancellationType=='PC' && f.isSelected){
                    cnObj.seatsToCancel.add(f.seat);
                    selType='PCAN';
                }else if(cancellationType=='FC'){
                    cnObj.seatsToCancel.add(f.seat);
                    selType='FCAN';
                }else if(selType!='PCAN' && selType!='FCAN'){
                    selType='None';
                }
                cnObj.agentId=UserInfo.getName()+'('+UserInfo.getUserName()+')';
            } 
            System.debug('selType-->'+selType);           
            if(selType=='None'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one seat'));  
                return null;
            }else{
                System.debug('cnObj-->'+cnObj);
                cancelJsbody=json.serialize(cnObj);  
                system.debug('cancelJson-->'+cancelJsbody); 
                HttpRequest req= new HttpRequest();      
                req.setMethod('POST');
                req.setBody(cancelJsbody);
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(APIMData.Endpoint__c);
                string oauthParams=oauthObj.sign(req,ordItm.Inventory_Type__c);
                endPoint=APIMData.Endpoint__c+'?'+oauthParams;
                req.setEndpoint(endPoint);
                cpl.NC_API_Request_Data__c=string.valueOf(req)+'--Body-->'+cancelJsbody;
                System.debug('endPoint-->'+endPoint);
                Continuation con = new Continuation(120);         
                con.continuationMethod='GetCancellationResponse';
                this.cancellationReq= con.addHttpRequest(req); 
                return con;                 
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Occured!! Please try again!'+string.valueOf(e)));  
            return null;
        }
        
    }    
    
    public Object GetCancellationResponse()
    {
        System.debug('calling cancel');
        
        try{
            System.debug('can req-->'+cancelJsbody);
            cancelRespObj=new CancelResponseWrapper();
            HttpResponse response = new HttpResponse();
            response =Continuation.getResponse(this.cancellationReq);            
            this.cancellationResp= response.getBody();
            cpl.NC_API_Request_Response__c = string.valueof(response )+'--Body-->'+this.cancellationResp;
            System.debug('resp body-->'+response.getBody());          
            restResp=response.getBody();
            string mockResp='{"cancellationCharge":0,"tin":"84AQ8XUQ","refundAmount":500}';
            cancelRespObj= (CancelResponseWrapper)JSON.deserialize(this.cancellationResp,CancelResponseWrapper.class);
            if(cancelRespObj.tin!=null && cancelRespObj.refundAmount!=null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Ticket Successfully Cancelled'));
            }else if(cancelRespObj.errorCode!=null && cancelRespObj.errorMessage!=null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Failed to Cancel ticket!! Error is '+cancelRespObj.errorMessage));
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again. If still persists please contact Admin.'));
        }
        database.upsert(cpl);      
        cancelJsbody='';
        return null;
    }
    
    public void CancellationBreakup(){
        System.debug('cancellationType-->'+cancellationType);
        breakUpblk=false;
        cancelBt=true;       
        if(cancellationType=='--None--' || (cancellation=='false' && partialCancellation=='false')){
            cancelBt=false;
        }
        //  if(cancellationType=='PC'){
        if(cancellationType=='PC'){
            breakUpblk=true;
        }else{
            breakUpblk=false;
        }
        fareList.clear();
        map<string,object> usMap= (map<string,object>)JSON.deserializeUntyped(isCancelResp);
        
        cancellation=string.valueOf(usMap.get('cancellable'));
        partialCancellation=string.valueOf(usMap.get('partiallyCancellable'));
        System.debug('usMap-->'+usMap.get('cancellable'));
        map<string,object> ccMap=new map<string,object>();            
        ccMap= (map<string,object>)usMap.get('cancellationCharges');
        if(ccMap!=null){
        cancellationCharges=0;
            for(object o:ccMap.values()){
                string ss=string.valueOf(o);
                integer i=ss.countMatches('key');
                System.debug('i-->'+i);
                if(i<2){
                    CancelChargeWrapper ccw=new CancelChargeWrapper();
                    map<string,object> sm=(map<string,object>)o;
                    ccw.seat=string.valueOf(sm.get('key'));
                    ccw.cancelChargeAmount=string.valueOf(sm.get('value'));
                    if(sm.get('value')!=null)
                     cancellationCharges=cancellationCharges+double.valueOf(sm.get('value'));                
                     cancelChargeMap.put(ccw.seat,ccw.cancelChargeAmount);
                }else{
                    list<object> lsOb=(list<object>)o;
                    for(object o2:lsOb){
                        CancelChargeWrapper ccw=new CancelChargeWrapper();
                        map<string,object> sm=(map<string,object>)o2;
                        System.debug('o2c-->'+o2);
                        ccw.seat=string.valueOf(sm.get('key'));
                        ccw.cancelChargeAmount=string.valueOf(sm.get('value'));
                        
                        
                        if(sm.get('value')!=null)
                        cancellationCharges=cancellationCharges+double.valueOf(sm.get('value'));                       
                        cancelChargeMap.put(ccw.seat,ccw.cancelChargeAmount);
                    }             
                }              
            }  
        } 
        map<string,object> cfMap=new map<string,object>();
        cfMap= (map<string,object>)usMap.get('fares');
        if(cfMap!=null){
        totalTktAmount=0;
            for(object o:cfMap.values()){
                string ss=string.valueOf(o);
                integer i=ss.countMatches('key');
                System.debug('i-->'+i);
                if(i<2){
                    FareWrapper ccw=new FareWrapper();
                    map<string,object> sm=(map<string,object>)o;
                    ccw.seat=string.valueOf(sm.get('key'));
                    ccw.ticketAmount=string.valueOf(sm.get('value'));
                    if(sm.get('value')!=null)
                    totalTktAmount=totalTktAmount+double.valueOf(sm.get('value'));
                    fareMap.put(ccw.seat,ccw.ticketAmount);
                    fareList.add(ccw);
                }else{
                    list<object> lsOb=(list<object>)o;
                    for(object o2:lsOb){
                        FareWrapper ccw=new FareWrapper();                
                        System.debug('o2f-->'+o2);
                        map<string,object> sm=(map<string,object>)o2;
                        ccw.seat=string.valueOf(sm.get('key'));
                        ccw.ticketAmount=string.valueOf(sm.get('value'));
                         if(sm.get('value')!=null)
                         totalTktAmount=totalTktAmount+double.valueOf(sm.get('value'));
                        fareMap.put(ccw.seat,ccw.ticketAmount);
                        fareList.add(ccw);
                    }             
                }              
            }
        }
        if(totalTktAmount!=null && cancellationCharges!=null )
        refundAmount=totalTktAmount-cancellationCharges;
        // }
    }
    
    public class CancelTicketWrapper{
        public string tin;
        public list<string> seatsToCancel=new list<string>();
        public string agentId;
    }
    
    public class fares{
        public list<entry> entry{get;set;}    
    }
    public class CancellationCharges{
        public list<entry> entry{get;set;}
    }
    public class entry{
        public string key{get;set;}
        public string value{get;set;}
        public boolean isSelected{get;set;}
    }
    public class CancelResponseWrapper{
        public string cancellationCharge;
        public string tin;
        public string refundAmount;
        public string errorCode;
        public string errorMessage;    
    }  
    
    public class CancelChargeWrapper{
        public string seat{get;set;}
        public string cancelChargeAmount{get;set;}
    }
    public class FareWrapper{
        public boolean isSelected{get;set;}
        public string seat{get;set;}
        public string ticketAmount{get;set;}
    }
}