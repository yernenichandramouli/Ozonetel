/**
* (c) 2018 RedBus
*
* Name           : BusCancelWalletCreditCntrl 
* Created Date   : 10 April 2018
* Created By     : Sreenivas M
* Purpose        : Handler class for Bus Cancel WalletCreditPage
* Test class     : BusCancelWalletCreditCntrlTest
*
**/

public class BusCancelWalletCreditCntrl {
    
    public List<case> caseList{get;set;}
    public case cs{get;set;}
    public Id csId{get;set;}
    public Boolean enableButton{get;set;}
    public Boolean enableCallButton{get;set;}
    public String statusMessage{get;set;}
    
    public case caseObj{get;set;}
    public list<Payment_Items__c> pObj;
    public string paymentUUID;
    public boolean enableDBT{get;set;}
    public boolean enableChatBt{get;set;}
    public boolean disChatBt{get;set;}
    public string boPhoneNo{get;set;}
    public list<case> sitCaseLs{get;set;}
    public string chatReq;
    public string chatResp;
    public string genericEndpoint;
    public string UserSelectVal {set;get;}
    public  List<SelectOption> listValues {get;set;}
        
    public BusCancelWalletCreditCntrl(ApexPages.StandardController sc)
    {
        caseObj=[select id,casenumber,BO_Mobile_Number__c,Trip_Id_ct__c,transaction_id__c,amountd__c,issue_type__c,Phone_No_ct__c from case where id=:Apexpages.currentpage().getparameters().get('id')];
        csId=caseObj.id;
        enableChatBt=false;
        getListVal();
             
        if(caseObj.issue_type__c=='Quota Management'){
            enableChatBt=true;
        }      
        If(caseObj.issue_type__c=='DBT'){
            if(caseObj.Trip_Id_ct__c!=null){
                pObj=[select id,Payment_System__c,Guid__c,Order_ID__c,Creation_Time__c from Payment_Items__c where Order_ID__c=:caseObj.Trip_Id_ct__c and Payment_System__c ='ONLINE' ORDER BY Creation_Time__c DESC limit 1];
                if(!pObj.isEmpty()){
                    paymentUUID=pObj[0].Guid__c;
                    enableDBT=true;
                }else
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Online Payment items is not available, Please sync the transaction'));
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'Trip id is not exist'));
            }
        }else{
            
            Set<String> setRTCOpIds =new Set<String>();
            setRTCOpIds.addAll(System.Label.RTC_BO_IDS.split(','));
            caseList = new List<Case>();
            this.cs = new Case();
            enableButton = false;
            enableCallButton = false;
            this.cs = (Case)sc.getRecord();
            csId = this.cs.Id;
            String strQry ='SELECT Issue_Type__c,Transaction_ID__r.Rb_User_ID__c,Transaction_Business_Type__c,RecordType.Name, '+System.Label.Bus_Cancellation_Query + ' Id=:csId AND Transaction_ID__c!=null';
            caseList =Database.query(strQry);
            if(!caseList.isEmpty())
                this.cs = caseList[0];
            System.debug('this.cs...'+this.cs);
            
            if(!caseList.isEmpty() && 'REDBUS_IN'.equalsIgnoreCase(cs.Transaction_Business_Type__c) && String.isNotBlank(cs.Transaction_ID__r.Rb_User_ID__c) && (Integer.valueOf(cs.Transaction_ID__r.Rb_User_ID__c)>0) && 'Bus Cancellation'.equalsIgnoreCase(cs.Issue_type__c) && 'Approved For Bus Cancellation'.equalsIgnoreCase(cs.status) && cs.Transaction_ID__c!=null && String.isNotBlank(cs.tin_no__c) && !setRTCOpIds.contains(cs.Service_Provider_Id__c))
                enableButton = true;
            
            if(!caseList.isEmpty() && cs.Status!='Closed' && ('External - SIT Case'.equalsIgnoreCase(cs.RecordType.Name) || 'Internal - SIT Case'.equalsIgnoreCase(cs.RecordType.Name)))           
                enableCallButton = true;
            
            
        }
        
    }
    
    public List<SelectOption> getListVal()
     {
    List<SelectOption> listValues = new List<SelectOption>();
    listValues.add(new SelectOption('','--None--'));
    if(caseObj.BO_Mobile_Number__c!=null){
    for(string s: caseObj.BO_Mobile_Number__c.split(','))
    {
        listValues.add(new SelectOption(s,s));
    }
    }
    System.debug('ls V-->'+listValues);
    return listValues;
   }
    public object chatEnable(){
   
       if(UserSelectVal=='--None--'|| UserSelectVal==null){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select the mobile number')); 
       }else{
        genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c;    
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='QuotaMgmtChatRequest'];
        string mobile =caseObj.Phone_No_ct__c;
        ChatMgmtWrapper cwp=new ChatMgmtWrapper(UserSelectVal);
        string jsonBody=json.serialize(cwp); 
        jsonBody=json.serialize(jsonBody); 
        Map<String, String> headers = new Map<String, String>();                           
        headers.put('Content-Type','application/json');              
        list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
        for(string o:headers.keyset()){
            hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o))); 
        }
        String headerJson=json.serialize(hlist); 
        String headerJson2=json.serialize(headerJson);    
        string jsonB='{"action":"POST","body":'+jsonBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
        System.debug('josnB-->'+jsonB);
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='ChatProcess'; 
        this.chatReq= con.addHttpRequest(httpReq);        
        return con;
        //enableChatBt=false;
        }
        return null;
    }
    public Object ChatProcess()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.chatReq);
            this.chatResp= response.getBody();
            System.debug('dd-->'+this.chatResp);
            string jsonT='[{"ID": 309, "rideTripId": "62036034", "account": "61733875", "amount": -20, "billingGroup": "PAX_RIDE", "billingCode": 401, "transactionId": "GYUGZQS9416", "description": "point debited from pax wallet", "notes": "billing for pax ride trip", "createdTime": "2019-04-04T16:30:55Z" } ]';
            disChatBt=true;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        return null;
    } 
    
    public void submit(){
        
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='DBT'];
        String userName=UserInfo.getName()+'('+UserInfo.getUserName()+')';
        userName= userName.replace('@', '-');
        string bankRefId=caseObj.casenumber;
        string slatId='656d7f6d7hf6adf68ds77fd6sd8fs7d86f7ds6f7s';
        // string hashValue=Generatehash(paymentUUID+'|'+bankRefId+'|'+slatId);
        string hashValue = GenericUtils.getsha512hash(paymentUUID+'|'+bankRefId+'|'+slatId);
        if(hashValue==null){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Error,'Encryption Failed'));
        }else{
            Request reqW=new Request('true',userName,paymentUUID,bankRefId,hashValue);
            String dbtJson=json.serialize(reqW); 
            
            System.debug('dbj-->'+dbtJson);
            
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req.setMethod('POST');
            req.setBody(dbtJson);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Country_Name', 'IDN'); 
            req.setTimeout(100020);
            req.setendpoint(APIMData.Endpoint__c);
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'DBT Confirmation';
            dbl.Request_Data__c=req.getbody();
            dbl.Payment_Transaction_Name__c=caseObj.transaction_id__c;
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            try{
                System.debug('req body-->'+req);
                res=h.send(req);
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                dbl.Response_Received__c=res.getbody();
                System.debug('res-->'+res.getbody());
                string resP='{"isTicketGenrated":"true","isGFT":"false","concludeResponse":""}';
                map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());  
                
                if(string.valueOf(resObj.get('isTicketGenrated'))=='true'){
                    dbl.Payment_Ping_Status__c='Ticket Generated';
                    CaseComment csComm = new CaseComment();
                    csComm.ParentId = caseObj.id;
                    csComm.commentBody = 'DBT Ticket Confirmed successfully';
                    insert csComm;
                    
                    caseObj.status ='Closed';
                    update caseObj;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Ticket is generated'));
                }
                else if(string.valueOf(resObj.get('IsvoucherExpired'))=='true'){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'Voucher is expired'));
                    dbl.Payment_Ping_Status__c='Voucher Expired';
                }
                else if(string.valueOf(resObj.get('isGFT'))=='true'){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'Ticket is not generated, GFT'));
                    dbl.Payment_Ping_Status__c='GFT';
                }
                else{
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Warning,'Ticket is not generated->'+string.valueOf(resObj.get('Error'))));
                    dbl.Payment_Ping_Status__c='Ticket not Generated';
                }
            }catch(Exception e){
                dbl.Payment_Ping_Status__c='API Failed';
                dbl.Exception_Description__c=string.valueof(e);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,'API failed, Please try again!!'+e));
                
            }
            insert dbl;
        }
    }
    /* public static string Generatehash(string hV) {
        string jsBody='{"text" :"'+hV+'"}';
        
        string encryptedValue;
        Http ht = new http();
        HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
        HttpResponse resp = new HttpResponse();
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='DBT_Encryption'].Endpoint__c);
        req.setMethod('POST');
        req.setBody(jsBody);
        resp=ht.send(req);
        // System.debug('resp--->'+resp+'-->resp b-->'+resp.getbody());
        
        if(resp.getStatus() =='OK' && resp.getStatusCode() ==200 && String.isNotBlank(resp.getBody()))
        {
            encryptedValue= String.valueOf(resp.getBody());
            encryptedValue= encryptedValue.removeStart('"').removeEnd('"');
            System.debug('encryptedValue-->'+encryptedValue);
        }   
        
        return encryptedValue;
    }*/
    public class Request{
        public string IsPaid;
        public string AgentName;
        public string PaymentItemUUID;
        public string Pgtxnid;
        public string Hash;     
        public Request(string IsPaid,string AgentName,string PaymentItemUUID,string Pgtxnid,string Hash){
            this.IsPaid=IsPaid;
            this.AgentName=AgentName;
            this.PaymentItemUUID=PaymentItemUUID;
            this.Pgtxnid=Pgtxnid;
            this.Hash=Hash;
            
        }
        
    }
    
    
    public PageReference refundintoWallet()
    {
        
        statusMessage='';
        Order_Items__c orIt = new Order_Items__c();
        orIt = [select transaction_status__c,Customer_Name__c,Customer_Name__r.PersonMobilePhone,Customer_Name__r.Email_Copy__c,(SELECT Id from Refund_Order_Items__r) from Order_Items__c where id=:cs.Transaction_ID__c limit 1];
        
        if(orIt.Transaction_Status__c.containsIgnoreCase('Ticket Cancelled'))
        {
            statusMessage = 'Ticket is already in cancelled state.So,Please check refund details and close this case on priority.!';
            return null;
        }
        if(!orIt.Refund_Order_Items__r.isEmpty())
        {
            statusMessage = 'It Seems To Be Refund Has Already Processed For This Ticket Under Exceptional Processing.Please Check Once!';
            return null;
        }
        
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
        SPOCBusCancellationExtn.JsonBodyWrapper jsonWarper = new SPOCBusCancellationExtn.JsonBodyWrapper(this.cs,'CLOSED','Cancel Ticket');
        String finalJsonBody = JSON.serialize(jsonWarper);
        finalJsonBody = '['+finalJsonBody.removeEnd('}')+',"refundMode":"BACK_TO_WALLET"}]';
        System.debug('listBusCancelRequest...'+finalJsonBody);
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusCancellation'].Endpoint__c+'Update');
        req.setMethod('POST');
        req.setBody(finalJsonBody);
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'Bus Cancellation Wallet Credit';
        dbl.Payment_Request_Sent_Time__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+finalJsonBody;
        dbl.Order_Items_Data_Received_Ids__c = String.valueOf(cs.TIN_No__c);
        dbl.Payment_Transaction_Name__c = cs.Transaction_ID__c;
        
        System.debug('Request..'+req+'.Body..'+finalJsonBody);
        
        try
        {
            resp = http.send(req);
            //string responseValue ='[{"TIN":"TM4D90891128","Status":"CLOSED","IsSuccess":true,"Notes":"Cancel Ticket","RouteId":"9165487"}]';
            string responseValue=resp.getBody();
            dbl.Response_Received__c = String.valueOf(resp+'Resp Body..'+responseValue);
            dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
            dbl.Payment_Request_Response_Time__c = System.now();
            
            List<Case> listCasesToUpsert = new List<case>();
            
            if(resp.getStatus()=='OK' && resp.getStatusCode()==200)
            {
                dbl.Payment_Ping_Status__c = 'Bus Cancellation Update Success';        
                System.debug('Bus cancel update success...'+responseValue);
                List<BusCancellationHandler.ViaRouteTinsResponse> listTinsForViaRoute = new  List<BusCancellationHandler.ViaRouteTinsResponse>();
                listTinsForViaRoute = (List<BusCancellationHandler.ViaRouteTinsResponse>)System.JSON.deserialize(responseValue ,List<BusCancellationHandler.ViaRouteTinsResponse>.class);
                statusMessage = 'Refund Processing Has Failed From The Backend System.Please Retry..!';
                BusCancellationHandler.ViaRouteTinsResponse res = listTinsForViaRoute[0];
                if(res.isSuccess)
                {
                    statusMessage = 'Refund Has Credited into Customer Wallet Successfully!! Customer SignedIn Wallet Phone Number-'+orIt.Customer_Name__r.PersonMobilePhone+' AND EmailId -'+orIt.Customer_Name__r.Email_Copy__c;
                    enableButton = false;
                    CaseComment csComm = new CaseComment();
                    csComm.ParentId = cs.id;
                    csComm.commentBody = 'System Update -'+UserInfo.getName()+'('+UserInfo.getUserName()+')- Refund Has Credited into Customer Wallet Successfully';
                    insert csComm;
                    
                    cs.status ='Closed';
                    cs.notes__c ='Refunded by redBus';
                    update cs;
                }
            }  
            
            else
            {
                System.debug('Bus cancellation ERROR: '+resp.getStatusCode()+': '+resp.getStatus()+'..'+resp.getBody());
                dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'Bus Cancellation Update Failed';
                statusMessage = 'Unable to process The refund request at this Momentum.Please retry after sometime!!';    
            }
            
        }
        Catch(Exception e)
        {
            System.debug('Error Occured While Invoking Bus cancellation/updating the case: '+e);
            dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'Bus Cancellation Ping Failed/Case Update Failed';
            dbl.Exception_Description__c = String.valueOf(e);
            statusMessage = 'Error Occured While Processing Request'+String.valueOf(e); 
        }
        
        insert dbl;
        return null;
    }
    
    public class ChatMgmtWrapper{
        public string mobile;
        public string country='IDN';
        public string endpoint_identifier='INDONESIA_PARTNER_SUPP';
        public string channel='whatsapp';
        public ChatMgmtWrapper(string mobile){
            this.mobile=mobile;       
        }
    }
}