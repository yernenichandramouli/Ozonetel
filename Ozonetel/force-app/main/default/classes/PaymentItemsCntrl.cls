/**
* (c) 2018 RedBus
*
* Name           : PaymentItemsCntrl
* Created Date   : 19 Dec 2018
* Created By     : Sreenivas M
* Purpose        : Fetch the payment details based on tripid
*
**/
public class PaymentItemsCntrl {

   public string recId;
    public PaymentItemsCntrl(ApexPages.StandardController controller) {
     recId = ((Order_Items__c)controller.getRecord()).id;
     if(string.isBlank(recId)){
     recId =ApexPages.currentPage().getParameters().get('ordId');
     }
           listPayItems = new List<HttpRequestWrappersUtil.PaymentItem>();
        pgOrderIdVals= new List<SelectOption>();
        // refundStatusLs=new List<HttpRequestWrappersUtil.RefundStatusWrapper>();
        refundStatusLs=new HttpRequestWrappersUtil.RefundStatusWrapper();
        dbl = new DBLog_Summary__c();
        genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c; 
        uObj=[select id,Phone,MobilePhone,email,username from user where id=:UserInfo.getUserID()];
        
        upieb=false;
        ordItem=new Order_Items__c();
        //String orderId = ApexPages.currentPage().getParameters().get('ordId');
        ordItem = [Select Order_Id__c,Business_Unit__c,Transaction_Source__c,OrderUuid__c,Guid__c,Total_Fare_Value__c from Order_Items__c Where id=:recId limit 1];
        orderId=ordItem.Order_Id__c;
        refOrdItems=new List<Refund_Order_Items__c>();
        refOrdItems=[select id,name,PG_Type__c,Status__c,Refunded_Amount__c,Trip_ID__c from Refund_Order_Items__c where Trip_ID__c=:orderId limit 1];
        if(!refOrdItems.isEmpty() && refOrdItems[0].PG_Type__c=='UPI' && (refOrdItems[0].Status__c=='Refund_Created' || refOrdItems[0].Status__c=='PG_REFUND_INITIATED' ||refOrdItems[0].Status__c=='PG_REFUND_INITIATION_FAILED')){
            refAmount=refOrdItems[0].Refunded_Amount__c;
            refAmount=refAmount.setScale(2);
        }
    }

    
    public string orderId{get;set;}
    public List<HttpRequestWrappersUtil.PaymentItem> listPayItems{get;set;}
    public string requestLabel{get;set;}
    public string result{get;set;}
    public DBLog_Summary__c dbl;
    public list<SelectOption> rbPGRefIds{get;set;}
    public string rbPGRefId{get;set;}
    public string orderUUid{get;set;}
    public string genericEndpoint;
    public string refReq;
    public string refResp;
    public string trexOrderItmId{get;set;}
    //public List<HttpRequestWrappersUtil.RefundStatusWrapper> refundStatusLs{get;set;}
    public HttpRequestWrappersUtil.RefundStatusWrapper refundStatusLs{get;set;}
    public List<SelectOption> pgOrderIdVals{get;set;}
    public boolean upiBts{get;set;}
    public List<Refund_Order_Items__c> refOrdItems{get;set;}
    
    public string vpa{get;set;}
    public string tId{get;set;}
    public API_EndPoints__mdt APIMData;
    //public string genericEndpoint;
    public string refStReq{get;set;}
    public string refStResp{get;set;}
    public string refAmtStResp{get;set;}
    public decimal refAmount{get;set;}
    public string pgTransactionId{get;set;}
    public string pgOrderId{get;set;}
    public Order_Items__c ordItObj{get;set;}
    //  public string trexOrderItmId{get;set;}
    public boolean enableRefund{get;set;}
    public boolean disInputs{get;set;}
    public user uObj{get;set;}
    public boolean refInitBt{get;set;}
    public string processCheck;
    public string countryName;
    public string InitRequest;
    public set<string> payUUids;
    public List<Orders__c> ordLs;
    public set<string> transIds;
    public Order_Items__c ordItem;
    public boolean upiRefAccess{get;set;}
    public boolean pgTranId{get;set;}
    public PaymentItemsCntrl()
    {
       
        /* else{
refAmount=ordItem.Total_Fare_Value__c;
refAmount=refAmount.setScale(2);
}*/
    }
    
    public Object getPaymentDetails()
    {
        upiBts=false;
        upieb=false;
        //disInputs=true;
       // String orderId = ApexPages.currentPage().getParameters().get('ordId');
        
        ordItem = [Select Order_Id__c,Business_Unit__c,Amount_Recieved_Currency__c,Transaction_Source__c,OrderUuid__c,Guid__c from Order_Items__c Where id=:recId  limit 1];
        trexOrderItmId=ordItem.Guid__c;
        String busiUnit = ordItem.Business_Unit__c;
        String bookingChannel = ordItem.Transaction_Source__c ;
        orderUUid=ordItem.OrderUuid__c;
        string country='';
        string selCurrency='';
        string paasChannel='';
        string comCurrency='';
        if('REDBUS_COM'.equalsIgnoreCase(busiUnit)){
            comCurrency=ordItem.Amount_Recieved_Currency__c;
            country ='RDC';
            selCurrency=comCurrency;    
        }else{
             country = OrderItemTransactionResource__c.getValues(busiUnit).Auth_Key__c;
             selCurrency = OrderItemTransactionResource__c.getValues(busiUnit).Default_Currency__c;
        }
        paasChannel = OrderItemTransactionResource__c.getValues(bookingChannel).Channel_Name__c;

        system.debug('--country'+country+'--selCurrency'+selCurrency+'--paasChannel--'+paasChannel);
        if(String.isBlank(country))
        {
            String finBusiunit = 'REDBUS_'+busiUnit.Split('_')[0];
            selCurrency = OrderItemTransactionResource__c.getValues(finBusiunit).Default_Currency__c;
            country = OrderItemTransactionResource__c.getValues(busiUnit).Auth_Key__c;
            countryName = country;
        }
        
        if(String.isBlank(ordItem.Order_Id__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'TripId/CartId is required to process the request'));
            return null;
        }
        else
        {
            dbl = new DBLog_Summary__c();
            dbl.type__c ='Payment Details On Demand';
            dbl.Payment_Ping_Status__c = 'Payment Fetch Initiated';
            dbl.Payment_Transaction_Name__c = ordItem.id;
            
            HttpRequest httpReq= new HttpRequest();
            httpReq = HttpRequestUtil.populateHeaders(httpReq);
            httpReq.setHeader('Country_Name',country);
            httpReq.setHeader('SelectedCurrency',selCurrency);
            httpReq.setMethod('GET');
            httpReq.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='PaymentItemsInfo'].Endpoint__c+ordItem.Order_Id__c+'/'+paasChannel);
            System.debug('Request headers..'+httpReq.getHeader('auth_key')+'..'+httpReq.getHeader('Country_Name')+'..'+httpReq.getHeader('Content-Type')+'..'+httpReq.getHeader('Channel_Name')+'..'+httpReq.getHeader('BusinessUnit')+'..'+httpReq.getHeader('SelectedCurrency'));        
            Continuation con = new Continuation(120);         
            con.continuationMethod='processPaymentsResponse'; 
            System.debug('httpReq....'+httpReq);
            dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
            this.requestLabel = con.addHttpRequest(httpReq);
            return con;
        } 
    }
    
    public Object processPaymentsResponse()
    { 
        try
        {
           system.debug('-----156----');
            System.debug('this.requestLabel...'+this.requestLabel);
            HttpResponse response = Continuation.getResponse(this.requestLabel);
            System.debug('response...'+response);           
            this.result = response.getBody();
            dbl.Response_Received__c =this.result;
            System.debug('this.result...'+this.result);
            listPayItems.clear();
            //this.result='[{ "id": 12529736072520433, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 548.2, "amount_payable_currency": "INR", "amount_payable_value": 548.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms0ZSLKZUlnc", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50776c5e9077f0055722993401030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148209, "IsOffline": false, "bankName": null, "operationType": "UPDATE" }, { "id": 12529736077109306, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 549.2, "amount_payable_currency": "INR", "amount_payable_value": 549.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms0gwt6x2TgX", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50802d079077f005e2483f9f02030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148210, "IsOffline": false, "bankName": null, "operationType": "UPDATE" }, { "id": 12529736077829082, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 550.2, "amount_payable_currency": "INR", "amount_payable_value": 550.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms1VoPAKfHZd", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50818c7b9077f005e2483f9f02030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148216, "IsOffline": false, "bankName": null, "operationType": "UPDATE" } ]';
            listPayItems = (list<HttpRequestWrappersUtil.PaymentItem>)JSON.deserialize(this.result,list<HttpRequestWrappersUtil.PaymentItem>.class);
            
            list<object> mapSS=(list<object>)JSON.deserializeUntyped(this.result);
            System.debug('mapSS-->'+mapSS);
            rbPGRefIds=new list<SelectOption>();
            for(object ob:mapSS){
                System.debug('ob-->'+ob);
                Map<String, Object> mpObj= (Map<String, Object>)ob;
                if(string.valueOf(mpObj.get('payment_system'))=='ONLINE' && string.valueOf(mpObj.get('pgName'))=='UPI'){   
                    upiBts=true;
                    refAmount=(Decimal)mpObj.get('amount_payable_value');
                    pgTransactionId=string.valueOf(mpObj.get('PgRefNo'));
                    string pgOrdId=string.valueOf(mpObj.get('guid'));
                    System.debug('pgOrdId-->'+pgOrdId);
                    pgOrderIdVals.add(new SelectOption(pgOrdId,pgOrdId));
                    System.debug('pgOrderIdVals-->'+pgOrderIdVals);
                    rbPGRefIds.add(new SelectOption(pgTransactionId,pgTransactionId));
                }
            }
            
            if(listPayItems.isEmpty())
                dbl.Payment_Ping_Status__c = 'Payment Fetch Failed';
            else
                dbl.Payment_Ping_Status__c = 'Payment Fetch Success';
        }
        Catch(Exception e)
        {
            dbl.Exception_Description__c = String.valueOf(e);
        }
        
        insert dbl;
        return null;
        
    }
    
    public void RefundAmount(){
        System.debug('calling');
        if(Test.isRunningTest()){
        this.result='[{ "id": 12529736072520433, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 548.2, "amount_payable_currency": "INR", "amount_payable_value": 548.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms0ZSLKZUlnc", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50776c5e9077f0055722993401030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148209, "IsOffline": false, "bankName": null, "operationType": "UPDATE" }, { "id": 12529736077109306, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 549.2, "amount_payable_currency": "INR", "amount_payable_value": 549.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms0gwt6x2TgX", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50802d079077f005e2483f9f02030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148210, "IsOffline": false, "bankName": null, "operationType": "UPDATE" }, { "id": 12529736077829082, "additional_details": null, "created_by": null, "creation_time": "2019-08-19T17:46:49", "transaction_source": null, "updated_by": null, "updated_time": null, "version": null, "business_unit_currency": "INR", "business_unit_value": 550.2, "amount_payable_currency": "INR", "amount_payable_value": 550.2, "order_id": 12529735259784721, "payment_status": "INITIATED", "payment_session_id": null, "payment_system": "ONLINE", "payment_system_ref_no": "pay_D7ms1VoPAKfHZd", "settled_currency": "INR", "settled_value": null, "settlement_time": null, "creation_time_public": null, "settlement_time_public": null, "has_discrepancy": null, "is_reconceiled": null, "commission": 0.0, "payment_type": 1, "is_complete": false, "guid": "50818c7b9077f005e2483f9f02030100", "pgName": "UPI", "pgtype": "UPI", "bankAccountNumber": null, "accountHolderName": null, "latestPgStatus": "FAIL", "PgRefNo": 1080148216, "IsOffline": false, "bankName": null, "operationType": "UPDATE" } ]';
        }
        list<object> mapSS=(list<object>)JSON.deserializeUntyped(this.result);
        System.debug('mapSS-->'+mapSS);
        // rbPGRefIds=new list<SelectOption>();
        for(object ob:mapSS){
            System.debug('ob-->'+ob);
            Map<String, Object> mpObj= (Map<String, Object>)ob;
            if(string.valueOf(mpObj.get('payment_system'))=='ONLINE' && string.valueOf(mpObj.get('pgName'))=='UPI' && string.valueOf(mpObj.get('PgRefNo'))==pgTransactionId){                    
                refAmount=(Decimal)mpObj.get('amount_payable_value');
            }
        }  
        System.debug('refAmount-->'+refAmount);      
    }
    public object RefundAteempts(){
        //mobile='7022000932';
        // orderUUid='1f87900285d8f0055722993401010100';
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='rPoolWalletHistory'];
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        headers.put('Source','SALESFORCE');
        headers.put('Authorization','Bearer j1QDNJnu8kaSqkoJVVm_MQ');
        headers.put('Country_Name',countryName);
        list<UPIController.HeadersWrapper> hlist=new list<UPIController.HeadersWrapper>();
        for(string o:headers.keyset()){                     
            hlist.add(new UPIController.HeadersWrapper(o,headers.get(o))); 
        }
        String headerJson=json.serialize(hlist); 
        String headerJson2=json.serialize(headerJson);  
        string refBody='{"trexOrderId":"'+orderUUid+'"}'; 
        refBody=json.serialize(refBody);  
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='UPIRefundStatusAttempts'];
        string jsonB='{"action":"POST","body":'+refBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
        System.debug('josnB-->'+jsonB);
        HttpRequest httpReq= new HttpRequest();
        httpReq = HttpRequestUtil.populateHeaders(httpReq);          
        httpReq.setMethod('POST');
        httpReq.setBody(jsonB);
        httpReq.setEndpoint(genericEndpoint);
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetRefundAttemptsResponse'; 
        System.debug('httpReq....'+httpReq);
        // dbl.Request_Data__c = 'Request headers--auth_key:'+httpReq.getHeader('auth_key')+',Country_Name:'+httpReq.getHeader('Country_Name')+',Content-Type:'+httpReq.getHeader('Content-Type')+',Channel_Name:'+httpReq.getHeader('Channel_Name')+',BusinessUnit:'+httpReq.getHeader('BusinessUnit')+',SelectedCurrency:'+httpReq.getHeader('SelectedCurrency')+'..End Point..'+httpReq.getEndpoint();          
        this.refReq= con.addHttpRequest(httpReq);
        return con;
        
    }
    public Object GetRefundAttemptsResponse()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.refReq);
            this.refResp= response.getBody();
            System.debug('wall Resp'+this.refResp);
            string jsonT='[ { "ID": 309, "rideTripId": "62036034", "account": "61733875", "amount": -20, "billingGroup": "PAX_RIDE", "billingCode": 401, "transactionId": "GYUGZQS9416", "description": "point debited from pax wallet", "notes": "billing for pax ride trip", "createdTime": "2019-04-04T16:30:55Z" } ]';
            system.debug('hist resp-->'+this.refResp);
            // refundStatusLs= (List<HttpRequestWrappersUtil.RefundStatusWrapper>)JSON.deserialize(this.refResp,List<HttpRequestWrappersUtil.RefundStatusWrapper>.class);
            refundStatusLs= (HttpRequestWrappersUtil.RefundStatusWrapper)JSON.deserialize(this.refResp,HttpRequestWrappersUtil.RefundStatusWrapper.class);
            
            System.debug('refundStatusLs-->'+refundStatusLs);
            // getWalletBalance();
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please try again.'));
        }
        return null;
    } 
    public boolean upieb{get;set;}
    public void processUPI(){
        list<String> UPIUsers= new list<String>();          
        UPIUsers.addAll(System.Label.UPI_Users.split(','));
        if(UPIUsers.contains(uObj.username)){
            upieb=true;
        }else{
            upiRefAccess=true;
        }
    }
    
    public Object RefundStatusCheck()
    {
        pgTranId=true;
        vpa=vpa.trim();
        pgTransactionId=pgTransactionId.trim();
        If(vpa=='' || refAmount==null || pgTransactionId==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter all values'));
        }else{
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Source','SALESFORCE');
            headers.put('Authorization','Bearer j1QDNJnu8kaSqkoJVVm_MQ');
            headers.put('Country_Name',countryName);
            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            for(string o:headers.keyset()){                     
                hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);  
            // UPIRefundWrapper urw=new UPIRefundWrapper();
            string upiBody='{"r_a":"'+refAmount+'","c_vpa":"'+vpa+'","t":"'+pgTransactionId+'"}'; 
            upiBody=json.serialize(upiBody);  
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='UPIRefundStatusCheck'];
            string jsonB='{"action":"POST","body":'+upiBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
            System.debug('josnB-->'+jsonB);
            HttpRequest httpReq= new HttpRequest();
            httpReq = HttpRequestUtil.populateHeaders(httpReq);          
            httpReq.setMethod('POST');
            httpReq.setEndpoint(genericEndpoint);
            httpReq.setBody(jsonB);
            processCheck='Req-->'+httpReq+'--Body-->'+httpReq.getBody();
            Continuation con = new Continuation(120);         
            con.continuationMethod='RefundStatusCheckProcess'; 
            System.debug('httpReq....'+httpReq);
            this.refStReq= con.addHttpRequest(httpReq);
            return con;
        }
        return null;
    }  
    public Object RefundStatusCheckProcess(){
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.type__c='UPI Refund Check';
        try{
            dbLog.Request_Data__c=processCheck;      
            HttpResponse response = Continuation.getResponse(this.refStReq);
            refStResp=response.getBody();
            System.debug('refStResp-->'+refStResp);
            dbLog.Response_Received__c=refStResp;
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(refStResp);      
            string mockResp='{message=Transaction Already exists, status=false}';
            System.debug('resObj-->'+resObj);
            System.debug('sss-->'+resObj.get('status'));
            if(resObj.get('status')==true){
                enableRefund=true;
                disInputs=true;
                dbLog.Orders_Process_Status__c='Success';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'This amount can be refundable'));
            }else{
                enableRefund=false;
                disInputs=false;
                dbLog.Orders_Process_Status__c='Fail';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,string.valueOf(resObj.get('message'))));
            }
        }catch(Exception e){
            dbLog.Orders_Process_Status__c='Exception';
            dbLog.Exception_Description__c=String.valueOf(e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured. Please try again/contact Admin'));
        }
        insert dbLog;
        return null;   
    }  
    public Object RefundInitiate(){
        pgOrderId=pgOrderId.trim();
        trexOrderItmId=trexOrderItmId.trim();
        If(pgOrderId=='' || trexOrderItmId==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter all values'));
        }else{
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='UPIRefundProcess'];
            UPIRefundWrapper urw=new UPIRefundWrapper(pgOrderId,pgTransactionId,uObj.email,string.valueOf(refAmount),trexOrderItmId,vpa);
            string refInJs=json.serialize(urw);  
            refInJs=json.serialize(refInJs);  
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Source','OMS');
            headers.put('Authorization','Bearer MAfuiy0u7EWkwZUkrLY-kA');
            headers.put('Country_Name',countryName);
            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            for(string o:headers.keyset()){                     
                hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);  
            string jsonB='{"action":"POST","body":'+refInJs+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
            System.debug('josnB-->'+jsonB);
            HttpRequest httpReq= new HttpRequest();
            httpReq = HttpRequestUtil.populateHeaders(httpReq);          
            httpReq.setMethod('POST');
            httpReq.setEndpoint(genericEndpoint);
            httpReq.setBody(jsonB);
            InitRequest=httpReq.getBody();
            Continuation con = new Continuation(120);         
            con.continuationMethod='RefundInitiateProcess'; 
            System.debug('httpReq....'+httpReq);
            this.refStReq= con.addHttpRequest(httpReq);
            return con;  
        }       
        return null; 
    }  
    public Object RefundInitiateProcess(){
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.type__c='UPI Refund';
        try{
            dbLog.Request_Data__c=InitRequest;        
            HttpResponse response = Continuation.getResponse(this.refStReq);
            refAmtStResp=response.getBody();
            dbLog.Response_Received__c=refAmtStResp;
            // string mockResp='{"publishStatus":"SUCCESS","errors":""}';
            map<string,object> resInObj= (map<string,object>)JSON.deserializeUntyped(refAmtStResp);
            System.debug('ini Amut-->'+refAmtStResp);
            //System.debug('st--->'+resInObj.get('status'));      
            if(resInObj.get('publishStatus')=='SUCCESS'){
                refInitBt=true;
                dbLog.Orders_Process_Status__c='Success';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully published into Kafka and will be credited into customer within 10 min'));                
            }else{
                dbLog.Orders_Process_Status__c='Fail';
                refInitBt=false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Unable to publish into Kafka, Please try again!!'));
            }
        }catch(Exception e){
            dbLog.Orders_Process_Status__c='Exception';
            dbLog.Exception_Description__c=String.valueOf(e);
        }
        insert dbLog;                
        return null;        
    }  
    
    public class HeadersWrapper{       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
    public class UPIRefundWrapper{
        public string d_t='REFUND';
        public string o;
        public string t;
        public string tn_a;
        public string t_s='1';
        public string r_s='INITIATED';
        public string cntry='INDIA';
        public string r_ib='SF';
        public string r_t='ONLINE';
        public string r_pb;
        public string r_a;
        public string r_rsn='User Cancellation';
        public string r_refId;
        public string t_bn;
        public UPIRefundWrapper(string o,string t,string r_pb,string r_a,string r_refId,string t_bn){
            this.o=o;
            this.t=t;         
            this.r_pb=r_pb;
            this.r_a=r_a;
            this.r_refId=r_refId;
            this.t_bn=t_bn;
        }   
    }  
}