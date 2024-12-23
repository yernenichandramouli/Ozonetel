public class redBusLiveDataPing 
{
    public string orItemId {get; set;}
    public boolean PGPaymentshow {get; set;}
    public List<Order_Items__c> orditms;
    public List<Case> casecre;
    public List<Case> caselst;
    public Map<id,Case> MapCasesins = new Map<id,Case>();
    public Boolean enableconformation{get;set;}
    public boolean refundEnable {get; set;}
    public boolean syncEnable{get;set;}
    public Boolean enableNeftLink{get;set;}
    public Boolean enableUPIRefund{get;set;}
    public String refundStatus{get;set;}
    public String walletRefundStatus{get;set;}
    public String refundStatusMesssage{get;set;}
    public String walletRefundStatusMessage {get; set;}
    public Order_Items__c orIt{get;set;}    
    public boolean BusCancelEnable {get;set;}
    public string recId{get;set;}
    public boolean iSwalletCreditEnable {get; set;}
    public Case caseToClose;
    public Map<String,String> mapBUToSenEMail;
    public String neftRefundAmt{get;set;}
    public Boolean enableUpdateRefund{get;set;}
    public DateTime dojDate{get;set;}
    public string finalDoj{get;set;}
    public Boolean gftRebboking{get;set;}
    public string agentId{get;set;}
    public static boolean showInrefRebo=false;
    public static boolean cnfrmFail=true;
    public boolean enableRebooking{get;set;}
    public string rebookingURL{get;set;}
    public Set<String> setNonNeftPgTypes;
    public map<String,string> mapBUtoRbkUrl;
    public list<Payment_Items__c> paymntItem{get;set;}
    public boolean enableCompltPymntBtn{get;set;}
    public string disbursalId{get;set;}
    public Boolean disburaslIdForNwCase{get;set;}
    public Boolean genrateDisbursalid{get;set;}
    Public Boolean genrateDisbrslid{get;set;}
    public string paymntUUid{get;set;}
    public boolean isAmountReceivable{get;set;}
    
    public redBusLiveDataPing(ApexPages.StandardController controller) 
    {
        enableRebooking = false;
        enableconformation = false;
        enableUpdateRefund = false;
        isAmountReceivable = false;
        setNonNeftPgTypes = new Set<String>(System.Label.Non_NEFT_PG_Types.split(','));
        orItemId = ApexPages.currentPage().getParameters().get('id'); 
        orditms = new List<Order_Items__c>();
        mapBUToSenEMail= new Map<String,String>();
        mapBUtoRbkUrl = new Map<String,String>();
        for(OrderItemTransactionResource__c res :OrderItemTransactionResource__c.getall().values())
        {
            if(res.Name.contains('REDBUS_'))
                mapBUToSenEMail.put(res.Name.right(3),res.SenderEmail__c);
            if(String.isNotBlank(res.ReBookingURL__c))
                mapBUtoRbkUrl.put(res.Name,res.ReBookingURL__c);
            
        }
        caseToClose= new Case();
        orIt = new Order_Items__c();
        casecre = new List<Case>();
        caselst = new List<Case>();
        //refundEnable = true;
        //refundStatus = '';
        BusCancelEnable = false;
        enableNeftLink = false;
        enableUPIRefund=false;
        genrateDisbursalid=false;
        //PGPaymentshow = PaymentButtonEnable();
        // iSwalletCreditEnable= walletCreditButtonEnable();
        paymntItem=[select id,ID__c,PG_Type__c,Latest_Payment_Status__c, PG_Reference_ID__c,Payment_Status__c,Order_Item_Name__c,Order_Item_Name__r.Transaction_Status__c from Payment_Items__c where Payment_Status__c='INITIATED' AND Latest_Payment_Status__c NOT IN ('SUCCESS') AND Payment_System__c = 'ONLINE' AND Order_Item_Name__c=:orItemId];
        
        if(!paymntItem.isEmpty() && 'WFT'.equalsIgnoreCase(paymntItem[0].Order_Item_Name__r.Transaction_Status__c))
        {
            enableCompltPymntBtn =  True;
        }
        else
        {
            enableCompltPymntBtn = False;   
        }
    }
    
    //This enables wallet credit button for hotel transaction if cases are there for denial of checkin or hygine issue
    public boolean walletCreditButtonEnable()
    {
        //caseToClose= new Case();
        boolean returnValue=false;
        caselst = new List<Case>();
        //caselst = [SELECT id,Transaction_ID__c,Issue_Type__c FROM Case WHERE Transaction_ID__c =:orItemId AND Issue_Type__c='redHotels'];
        caselst= [SELECT id,Status,IsClosed,CreatedDate,Transaction_ID__c,Issue_Type__c,Issue_Sub_Category__c FROM Case WHERE Transaction_ID__c =:orItemId AND Issue_Type__c='redHotel'];
        
        system.debug('-------------------caselst------------'+JSON.serialize(caselst));
        for (Case hotelCase:caselst)
        {
            //List<Attachment> hotelAttachments= new List<Attachment>();
            //hotelAttachments=[SELECT Id, ParentId, Name FROM Attachment where ParentId=:hotelCase.id];
            List<ContentDocumentLink> cdList=new list<ContentDocumentLink>();
            cdList=[SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id=:hotelCase.id ) and LinkedEntity.Type='Case'];
            
            //system.debug('-------------------hotelAttachments------------'+JSON.serialize(hotelAttachments));
            system.debug('-------------------cdList------------'+JSON.serialize(cdList));
            system.debug('-------------------hotelCase Out------------'+JSON.serialize(hotelCase));
            if(System.now()>hotelCase.CreatedDate.addHours(1) && !hotelCase.IsClosed && (hotelCase.Issue_Sub_Category__c=='Early Checkin denial' || !cdList.isEmpty()))
            {
                system.debug('-------------------hotelCase------------'+JSON.serialize(hotelCase));
                caseToClose=hotelCase;
                system.debug('-------------------caseToClose------------'+JSON.serialize(caseToClose));
                System.debug('---returnValue-- '+'true');
                returnValue=true;
            }           
        }
        return returnValue;
    }
    
    //This method credits the amount into wallet for hotel transaction 
    //@future(callout=true)
    public void creditAmountToWallet()
    {   
        system.debug('-------------------inside creditAmountToWallet------------');
        String tId=Apexpages.currentpage().getparameters().get('Id');
        Order_Items__c orItem=new Order_Items__c ();
        System.debug('tid-->'+tId);
        if(tId!=null){
            orItem=[select id,Total_Fare_Value__c,Discount_Value__c,Email__c,Mobile__c from Order_Items__c where id=:tId];  
            system.debug('----------orItem------------ '+JSON.serialize(orItem));     
        }
        
        JSONGenerator gen = JSON.createGenerator(true);       
        gen.writeStartObject();
        gen.writeStringField('userid','');
        gen.writeNumberField('amount', orItem.Total_Fare_Value__c-orItem.Discount_Value__c);
        gen.writeStringField('emailId', orItem.Email__c);
        gen.writeStringField('phone', orItem.Mobile__c);
        gen.writeEndObject();
        
        string countryHeader='IND';        
        String walletJson= gen.getAsString();
        System.debug('walletJson-->'+walletJson);
        
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Wallet_Credit'].Endpoint__c;      
        string json45='{ "userId":"","amount": 1,"emailId" :"kadamba.t@gmail.com","phone": "7760471596"}';       
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        Http h= new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Country_Name', countryHeader);
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(walletJson);
        CaseComment cc=new CaseComment();
        system.debug('-------------------caseToClose------------'+JSON.serialize(caseToClose));
        cc.parentid=caseToClose.id;
        try{
            res=h.send(req);
            System.debug('Response-->'+res.getBody());
            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
            map<String,Object> statusMap= (map<string,object>)resMap.get('Status');
            
            
            if(string.valueof(statusMap.get('statusCode'))=='201'){
                walletRefundStatus= 'Success';
                cc.CommentBody='System Update- Case has been approved for wallet credit';
                caseToClose.status='Closed';
            }else{
                walletRefundStatus= 'Failed';
                walletRefundStatusMessage= ' '+resMap.get('ResponseMessage');
                caseToClose.status='Open';
                cc.CommentBody='System Update- Wallet Credit has failed.Reason-'+resMap.get('ResponseMessage');
                
            }
            
            
            dbl.Type__c = 'Wallet Credit';
            //dbl.Payment_Request_Sent_Data__c=walletJson;
            dbl.Request_Data__c = walletJson;
            //dbl.Payment_Request_Response_Data__c=res.getBody(); 
            dbl.Response_Received__c = res.getBody(); 
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            insert cc;
            update caseToClose;      
            insert dbl;
        }
        catch(Exception e){
            walletRefundStatus= 'Failed';
            walletRefundStatusMessage= 'Wallet Credit.Exception- '+String.valueOf(e);
            dbl.Type__c = 'Wallet Credit';
            caseToClose.status='Open';
            //dbl.Payment_Request_Sent_Data__c=walletJson;
            dbl.Request_Data__c = walletJson;
            //dbl.Payment_Request_Response_Data__c=res.getBody()+'<--Exception-->'+e;
            dbl.Response_Received__c = res.getBody()+'<--Exception-->'+e;
            cc.CommentBody='System Update- Exception In Wallet Credit.Exception-'+String.valueOf(e);
            // insert cc;
            //  update caseToClose;        
            insert dbl;
        }
    }
    
    public void PaymentButtonEnable()
    {
        string PayType = system.label.PaymentItemType;
        list<string> PaymentType = new list<string>();
        PaymentType = PayType.split(',');
        
        string PaymentGateway = system.label.Payment_Gateway_type;
        list<string> PaymentGatewayList = new list<string>();
        PaymentGatewayList = PaymentGateway.split(','); 
        
        list<Payment_Items__c> paymentItems = new list<Payment_Items__c>();
        paymentItems = [select id, ID__c,PG_Type__c,Payment_System__c, Latest_Payment_Status__c, PG_Reference_ID__c,PG_Reference_ID_Ping__c, Payment_Status__c, Order_Item_Name__c,Order_Item_Name__r.Transaction_Source__c,Order_Item_Name__r.Item_Type__c, Order_Item_Name__r.Business_Unit__c,Payment_Gateway_Type__c from Payment_Items__c where Order_Item_Name__c=:orItemId and Payment_System__c IN: PaymentType and Payment_Gateway_Type__c IN: PaymentGatewayList];
        if(!paymentItems.isEmpty())
        {
            PGPaymentshow =  True;
        }
        else
        {
            PGPaymentshow = False;   
        }
        
    }
    
    
    //-----------------    
    public void PaymentUpdatePing()
    {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Get PG Name';
        if(!string.isBlank(orItemId))
        {
            dbl.Payment_Transaction_Name__c = orItemId;
            dbl.Payment_Request_Sent_Time__c = system.now();
            string PayType = system.label.PaymentItemType;
            list<string> PaymentType = new list<string>();
            PaymentType = PayType.split(','); 
            list<string> PayItemList = new list<string>(); 
            Set<String> mapwftgft = new Set<String>();
            system.debug('-----------PaymentType--------------'+PaymentType);
            map<string, Payment_Items__c> PIMap = new map<string,Payment_Items__c>();
            map<string, Order_Items__c> OIMap = new map<string,Order_Items__c>();
            for(Order_Items__c OI: [select id, ID__c,Transaction_Latest_Status__c,status__c,Date_of_Service__c,Corrected_Boarding_Time__c from Order_Items__c where id=:orItemId])
            {
                OIMap.put(OI.id,OI);
            }
            
            for(Payment_Items__c pI: [select id, ID__c,Guid__c,Amount_Payable_Currency__c,Payment_System__c, Latest_Payment_Status__c, PG_Reference_ID__c,PG_Reference_ID_Ping__c, Payment_Status__c, Order_Item_Name__c,Order_Item_Name__r.Transaction_Source__c,Order_Item_Name__r.Item_Type__c, Order_Item_Name__r.Business_Unit__c,Order_Item_Name__r.Amount_Recieved_Currency__c from Payment_Items__c where Order_Item_Name__c=:orItemId and Payment_System__c IN: PaymentType])
            {
                system.debug('-------PI---------------'+pI);
                system.debug('-------Order_Item_Name__r.Transaction_Source__c----------------'+PI.Order_Item_Name__r.Transaction_Source__c);
                system.debug('-------Order_Item_Name__r.Item_Type__c----------------'+PI.Order_Item_Name__r.Item_Type__c);
                system.debug('-------Order_Item_Name__r.Business_Unit__c----------------'+PI.Order_Item_Name__r.Business_Unit__c);
                if(!string.isBlank(string.valueof(pI.ID__c)))
                {
                    
                    PayItemList.add(pI.ID__c);
                    PIMap.put(pI.ID__c,pI);
                    
                }
            }
            if(!PayItemList.isEmpty())
            {
                List<OrderItemTransactionResource__c> oitr = OrderItemTransactionResource__c.getall().values();
                map<string,OrderItemTransactionResource__c> oitrMap = new map<string,OrderItemTransactionResource__c>();
                Map<String,String> maprectypes = new Map<String,String>();
                Set<id> cusids = new Set<id>();
                Map<String,List<Order_Items__c>> mapoitms = new Map<String,List<Order_Items__c>>(); 
                Map<String,Order_Items__c> mapoids = new Map<String,Order_Items__c>();
                orditms = [SELECT id,Name,Customer_Name__c,Amount_Recieved_Currency__c,Primary_Contact_Customer__c,status__c,Customer_Name__r.Name,Date_Of_Service__c,Corrected_Boarding_Time__c,Business_Unit__c FROM Order_Items__c WHERE id=:orItemId LIMIT 1];
                mapoids.put(orditms[0].id,orditms[0]);                
                if(orditms[0].Customer_Name__c!=NUll)
                {
                    cusids.add(orditms[0].Customer_Name__c);
                }
                if(orditms[0].Primary_Contact_Customer__c!=NUll)
                {
                    cusids.add(orditms[0].Primary_Contact_Customer__c);
                }
                caselst = [SELECT id,Transaction_ID__c,RecordType.DeveloperName FROM Case WHERE Transaction_ID__c =:orItemId AND (RecordType.DeveloperName='White_Failed_Transaction_WFT' OR RecordType.DeveloperName='Green_Failed_Transaction_GFT')];
                for(Order_Items__c o:[Select id,Name,Customer_Name__c,Amount_Recieved_Currency__c,Primary_Contact_Customer__c  FROM Order_Items__c WHERE Customer_Name__c IN: cusids OR Primary_Contact_Customer__c IN: cusids])
                {
                    if(o.Customer_Name__c!=null)
                    {
                        if(!mapoitms.containskey(o.Customer_Name__c))
                        {
                            List<Order_Items__c> innerlist = new List<Order_Items__c>();
                            innerlist.add(o);
                            mapoitms.put(o.Customer_Name__c,innerlist);
                        }
                        else
                        {
                            mapoitms.get(o.Customer_Name__c).add(o);
                        }
                    }
                    if(o.Primary_Contact_Customer__c!=null)
                    {
                        if(!mapoitms.containskey(o.Primary_Contact_Customer__c))
                        {
                            List<Order_Items__c> innerlist = new List<Order_Items__c>();
                            innerlist.add(o);
                            mapoitms.put(o.Primary_Contact_Customer__c,innerlist);
                        }
                        else
                        {
                            mapoitms.get(o.Primary_Contact_Customer__c).add(o);
                        }
                    }
                }
                for(OrderItemTransactionResource__c oi: oitr)
                {
                    //system.debug('-------OI---------------'+OI);
                    oitrMap.put(oi.name,oi);
                }
                system.debug('-------oitrMap---------------'+oitrMap);
                for(RecTypesAndStatus__c r: RecTypesAndStatus__c.getAll().Values())
                {
                    maprectypes.put(r.Transaction_Status__c,r.Case_Type__c);
                }
                for(WFT_GFT_Business_Units__c w: WFT_GFT_Business_Units__c.getAll().Values())
                {
                    if(w.Account_DOJ_Check__c)
                    {
                        mapwftgft.add(w.Name);
                    }
                }
                
                for(string PayId : PayItemList)
                {
                    string Channel_Name;
                    string auth_key;
                    string Country_Name;
                    string BusinessUnit;
                    string SelectedCurrency;
                    
                    if(PIMap.KeySet().Contains(PayId))
                    {
                        if(!string.isBlank(string.valueof(PIMap.get(PayId).Order_Item_Name__r.Transaction_Source__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Order_Item_Name__r.Transaction_Source__c))
                        {
                            Channel_Name = oitrMap.get(PIMap.get(PayId).Order_Item_Name__r.Transaction_Source__c).Channel_Name__c;
                            auth_key = oitrMap.get(PIMap.get(PayId).Order_Item_Name__r.Transaction_Source__c).Auth_Key__c;
                            system.debug('-------Channel_Name---------------'+Channel_Name);
                            system.debug('-------auth_key---------------'+auth_key);
                        }
                        if(!string.isBlank(string.valueof(PIMap.get(PayId).Order_Item_Name__r.Item_Type__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Order_Item_Name__r.Item_Type__c))
                        {
                            BusinessUnit  = oitrMap.get(PIMap.get(PayId).Order_Item_Name__r.Item_Type__c).Auth_Key__c;
                            system.debug('-------BusinessUnit---------------'+BusinessUnit);
                        }
                        if(!string.isBlank(string.valueof(PIMap.get(PayId).Order_Item_Name__r.Business_Unit__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Order_Item_Name__r.Business_Unit__c))
                        {   
                            if('REDBUS_COM'.equalsIgnoreCase(string.valueof(PIMap.get(PayId).Order_Item_Name__r.Business_Unit__c))){
                                Country_Name='RDC';
                                SelectedCurrency=string.valueof(PIMap.get(PayId).Order_Item_Name__r.Amount_Recieved_Currency__c);
                            }else{
                                Country_Name = oitrMap.get(PIMap.get(PayId).Order_Item_Name__r.Business_Unit__c).Auth_Key__c;
                                SelectedCurrency = oitrMap.get(PIMap.get(PayId).Order_Item_Name__r.Business_Unit__c).Default_Currency__c;
                            }
                            system.debug('-------Country_Name---------------'+Country_Name+'---SelectedCurrency--'+SelectedCurrency);
                        }
                        if(String.isNotBlank(PIMap.get(PayId).Amount_Payable_Currency__c))
                        {
                            SelectedCurrency = PIMap.get(PayId).Amount_Payable_Currency__c;
                            system.debug('-------SelectedCurrency---------------'+SelectedCurrency);
                        }
                        if(String.isBlank(SelectedCurrency))
                            SelectedCurrency = 'INR';
                    }
                    
                    if(!string.IsBlank(Channel_Name) && !string.IsBlank(auth_key) && !string.IsBlank(BusinessUnit) && !string.IsBlank(Country_Name) )
                    {
                        String payGuid=string.valueof(PIMap.get(PayId).Guid__c);
                        system.debug('-------Ping---------------');
                        HttpRequest req = new HttpRequest();
                        req.setTimeout(120000);
                        HttpResponse res = new HttpResponse();
                        Http http = new Http(); 
                        Map<String,Payment_API_endpoint__c> mapauth = Payment_API_endpoint__c.getAll();
                        String endpoint = mapauth.get('End Point').End_Point__c+PayId+'&paymentUuid='+payGuid;
                        system.debug('-------mapcusauth---------------'+mapauth.get('End Point').End_Point__c);
                        system.debug('-------endpoint---------------'+endpoint);
                        //req.setEndpoint('http://cmapi-pp.redbus.com/api/Payment/v1/Status?paymentItemId='+PayId);
                        req.setEndpoint(endpoint);
                        req.setHeader('Channel_Name', Channel_Name);
                        req.setHeader('auth_key', auth_key);
                        req.setHeader('BusinessUnit', BusinessUnit);
                        req.setHeader('Country_Name', Country_Name);
                        System.debug('Before call---'+SelectedCurrency);
                        req.setHeader('SelectedCurrency',SelectedCurrency);
                        req.setMethod('GET');
                        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;
                        dbl.Request_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        try
                        {
                            res = http.send(req);
                            string responseValue = res.getBody();
                            dbl.Payment_Request_Response_Time__c = system.now();
                            //dbl.Payment_Request_Response_Data__c = string.valueof(res.getBody());    
                            dbl.Response_Received__c = string.valueof(res.getBody());    
                            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                            Response  resp = new Response();
                            if(res.getStatus()=='OK')
                            {
                                dbl.Payment_Ping_Status__c = 'Success';    
                                resp = (Response)JSON.deserialize( responseValue, Response.class);
                                PGPaymentshow =  True;
                                system.debug('---------resp---------------'+resp);
                                if(!String.isBlank(resp.RbPgId) && string.valueof(resp.RbPgId)!= '0') 
                                {
                                    
                                    PIMap.get(PayId).PG_Reference_ID_Ping__c =  string.valueof(resp.RbPgId);
                                    PIMap.get(PayId).PG_Reference_ID__c =  string.valueof(resp.PgTransactionId);
                                    PIMap.get(PayId).Latest_Payment_Status__c = string.valueof(resp.PaymentStatus); 
                                    PIMap.get(PayId).Payment_Gateway_Type__c = string.valueof(resp.GatewayName);
                                    PIMap.get(PayId).PG_Type__c = string.valueof(resp.PGType);
                                    
                                    system.debug('******resp.IsOffline**'+resp.IsOffline);
                                    PIMap.get(PayId).IsOffline__c = Boolean.valueof(resp.IsOffline);
                                    system.debug('******resp.IsOffline**'+resp.IsOffline);
                                    if(OIMap.KeySet().contains(PIMap.get(PayId).Order_Item_Name__c))
                                    {
                                        OIMap.get(PIMap.get(PayId).Order_Item_Name__c).Transaction_Latest_Status__c = string.valueof(resp.PaymentStatus);
                                        if(caselst.IsEmpty())
                                        {
                                            if(OIMap.get(PIMap.get(PayId).Order_Item_Name__c).Transaction_Latest_Status__c == 'SUCCESS')
                                            {
                                                if(maprectypes.get(orditms[0].status__c) == 'White Failed Transaction (WFT)' || maprectypes.get(orditms[0].status__c) == 'Green Failed Transaction (GFT)')
                                                {
                                                    Case c = new Case();
                                                    c.Transaction_ID__c= orItemId ;
                                                    c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                    c.Customer_Name__c=orditms[0].Customer_Name__c;
                                                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                                                    system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                    c.RecordTypeId=recordTypeId;
                                                    casecre.add(c);
                                                }    
                                            }
                                            else if(OIMap.get(PIMap.get(PayId).Order_Item_Name__c).Transaction_Latest_Status__c == 'FAIL')
                                            {
                                                if(orditms[0].status__c!=Null && maprectypes.containskey(orditms[0].status__c))
                                                {
                                                    if(maprectypes.get(orditms[0].status__c) == 'White Failed Transaction (WFT)')
                                                    {
                                                        if(orditms[0].Business_Unit__c!=Null && mapwftgft.contains(orditms[0].Business_Unit__c))
                                                        { 
                                                            if(date.valueof(orditms[0].Corrected_Boarding_Time__c) == system.today())
                                                            {
                                                                if(orditms[0].Primary_Contact_Customer__c!=Null && orditms[0].Customer_Name__c!=null)
                                                                {
                                                                    if(orditms[0].Customer_Name__r.Name!='N/A')
                                                                    {
                                                                        if(mapoitms.containskey(orditms[0].Customer_Name__c) && mapoitms.containskey(orditms[0].Primary_Contact_Customer__c))
                                                                        {
                                                                            if(mapoitms.get(orditms[0].Customer_Name__c).size()==1 && mapoitms.get(orditms[0].Primary_Contact_Customer__c).size()==1)
                                                                            {
                                                                                if(mapoitms.get(orditms[0].Customer_Name__c)[0].id==orditms[0].id && mapoitms.get(orditms[0].Primary_Contact_Customer__c)[0].id==orditms[0].id)
                                                                                {
                                                                                    Case c=new Case();
                                                                                    c.Transaction_ID__c=orditms[0].id;
                                                                                    c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                                                    c.Customer_Name__c=orditms[0].Customer_Name__c;
                                                                                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                                                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                                                    system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                                                    c.RecordTypeId=recordTypeId;
                                                                                    casecre.add(c);
                                                                                    
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    if(orditms[0].Primary_Contact_Customer__c!=Null && orditms[0].Customer_Name__r.Name=='N/A')
                                                                    {
                                                                        //system.debug('4th criteria'+o);
                                                                        if(mapoitms.containskey(orditms[0].Primary_Contact_Customer__c))
                                                                        {
                                                                            //system.debug('4th criteriaacccus'+o);
                                                                            if(mapoitms.get(orditms[0].Primary_Contact_Customer__c).size()==1)
                                                                            {
                                                                                //system.debug('4th criteriaacc'+o);
                                                                                if(mapoitms.get(orditms[0].Primary_Contact_Customer__c)[0].id==orditms[0].id)
                                                                                {
                                                                                    //system.debug('4th criteriacase'+o);
                                                                                    Case c=new Case();
                                                                                    c.Transaction_ID__c=orditms[0].id;
                                                                                    c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                                                    //c.Customer_Name__c=o.Customer_Name__c;
                                                                                    c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                                                    Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                                                    system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                                                    c.RecordTypeId=recordTypeId;
                                                                                    casecre.add(c);
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                else if(orditms[0].Primary_Contact_Customer__c==Null && orditms[0].Customer_Name__c!=null)
                                                                {
                                                                    //System.debug('2nd Condition'+o);
                                                                    if(mapoitms.containskey(orditms[0].Customer_Name__c))
                                                                    {
                                                                        if(mapoitms.get(orditms[0].Customer_Name__c).size()==1)
                                                                        {
                                                                            //System.debug('---mapcustomername---'+mapoitms.get(orditms[0].Customer_Name__c)[0].id);
                                                                            if(mapoitms.get(orditms[0].Customer_Name__c)[0].id==orditms[0].id)
                                                                            {
                                                                                Case c=new Case();
                                                                                c.Transaction_ID__c=orditms[0].id;
                                                                                //c.AccountId=o.Primary_Contact_Customer__c;
                                                                                c.Customer_Name__c=orditms[0].Customer_Name__c;
                                                                                c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                                                Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                                                system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                                                c.RecordTypeId=recordTypeId;
                                                                                casecre.add(c);
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                else if(orditms[0].Primary_Contact_Customer__c!=Null && orditms[0].Customer_Name__c==null)
                                                                {
                                                                    if(mapoitms.containskey(orditms[0].Primary_Contact_Customer__c))
                                                                    {
                                                                        if(mapoitms.get(orditms[0].Primary_Contact_Customer__c).size()==1)
                                                                        {
                                                                            //system.debug('3rd criteriaacc'+o);
                                                                            //System.debug('---mapcustomername---'+mapoitms.get(o.Primary_Contact_Customer__c)[0].id);
                                                                            if(mapoitms.get(orditms[0].Primary_Contact_Customer__c)[0].id==orditms[0].id)
                                                                            {
                                                                                Case c=new Case();
                                                                                c.Transaction_ID__c=orditms[0].id;
                                                                                c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                                                //c.Customer_Name__c=o.Customer_Name__c;
                                                                                c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                                                Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                                                system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                                                c.RecordTypeId=recordTypeId;
                                                                                casecre.add(c);
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                            } 
                                                            
                                                        }
                                                        else
                                                        {
                                                            Case c=new Case();
                                                            c.Transaction_ID__c=orditms[0].id;
                                                            c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                            c.Customer_Name__c=orditms[0].Customer_Name__c;
                                                            c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                            Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                            system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                            c.RecordTypeId=recordTypeId;
                                                            casecre.add(c); 
                                                        }
                                                    }
                                                    else if(maprectypes.get(orditms[0].status__c) == 'Green Failed Transaction (GFT)')
                                                    {
                                                        Case c = new Case();
                                                        c.Transaction_ID__c= orItemId ;
                                                        c.AccountId=orditms[0].Primary_Contact_Customer__c;
                                                        c.Customer_Name__c=orditms[0].Customer_Name__c;
                                                        c.Origin = System.Label.WFT_GFT_Case_Origin;
                                                        Id recordTypeId=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(maprectypes.get(orditms[0].status__c)).getRecordTypeId();
                                                        system.debug('@@@@=====>>>>>>'+recordTypeId);
                                                        c.RecordTypeId=recordTypeId;
                                                        casecre.add(c);
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    dbl.X0_PG_Reference_ID__c = TRUE;
                                }
                                
                            }
                            else
                            {
                                dbl.Payment_Ping_Status__c = 'Fail';
                            }
                        }
                        catch(exception e)
                        {
                            dbl.Payment_Ping_Status__c = 'Failed';
                            dbl.Exception_Description__c = string.valueof(e);
                            //insert dbl;
                        }
                    }
                    else
                    {
                        dbl.Payment_Ping_Status__c = 'Authentication Failed';
                        //dbl.Payment_Request_Sent_Data__c = 'Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name;
                        dbl.Request_Data__c =  'Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name;
                    }
                }
                if(!PIMap.isEmpty())
                {
                    Database.update(PIMap.values(),false);
                }
                if(!OIMap.isEmpty())
                {
                    Database.update(OIMap.values(),false);
                }
                Set<String> wftbsunits = new Set<String>();
                Set<String> gftbsunits = new Set<String>();
                for(WFT_GFT_Business_Units__c bs: WFT_GFT_Business_Units__c.getAll().Values())
                {
                    if(bs.Create_WFT__c)
                    {
                        wftbsunits.add(bs.Name);
                    }
                    if(bs.Create_GFT__c)
                    {
                        gftbsunits.add(bs.Name);
                    }
                }
                for(Case c: casecre)
                {
                    System.debug('-----Casecre-----'+mapoids.get(c.Transaction_ID__c).Business_Unit__c);
                    String wfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
                    String gfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                    if((c.RecordTypeid == wfrecid && mapoids.containskey(c.Transaction_ID__c)  && wftbsunits.contains(mapoids.get(c.Transaction_ID__c).Business_Unit__c)) || (c.RecordTypeid==gfrecid && mapoids.containskey(c.Transaction_ID__c) && gftbsunits.contains(mapoids.get(c.Transaction_ID__c).Business_Unit__c)))
                    {
                        MapCasesins.put(c.Transaction_Id__c,c);
                        System.debug('-----MapCasesins-----'+MapCasesins);
                    }
                }
                if(!MapCasesins.Values().isEmpty())
                {
                    Database.insert(MapCasesins.values(),false);
                }
            }
            else
            {
                dbl.Payment_Ping_Status__c = 'Payment Id Not Available';
            }
        }
        else
        {
            dbl.Payment_Ping_Status__c = 'Transaction Id not valid';
        }
        insert dbl;
    }
    
    public void refundAPIping()
    {
        refundStatus = 'local';
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Get Refund Details';
        if(!string.isBlank(orItemId))
        {
            dbl.Payment_Transaction_Name__c = orItemId;
            dbl.Payment_Request_Sent_Time__c = system.now();
            string userName = userinfo.getName();
            Order_Items__c orIt = [select id,id__c,Order_Id__c,OrderUuid__c,Guid__c,Amount_Recieved_Currency__c,Business_Unit__c, Item_Type__c,Refund_CustRefund_ID__c, Refund_Initiated_Time__c, Refund_IsSuccess__c, Refund_Response_Message__c, Country__c from Order_Items__c where id=:orItemId limit 1];
            Map<String,RefundAPISettings__c> SyncSettings = RefundAPISettings__c.getAll();
            if(!string.IsBlank(orIt.id__c))
            {
                string Channel_Name;
                string auth_key;
                string Country_Name;
                string SelectedCurrency;
                string BusinessUnit;
                Map<string,string> bodyValue = new map<string,string>();
                if(!string.IsBlank(orIt.Business_Unit__c))
                {
                    if(SyncSettings.KeySet().Contains(orIt.Business_Unit__c))
                    {
                        Channel_Name = SyncSettings.get(orIt.Business_Unit__c).Channel_Name__c;
                        system.debug('-------------------Channel_Name------------'+Channel_Name);
                        auth_key = SyncSettings.get(orIt.Business_Unit__c).Auth_Key__c;
                        system.debug('-------------------auth_key------------'+auth_key);
                        Country_Name = SyncSettings.get(orIt.Business_Unit__c).Country_Name__c;
                        system.debug('-------------------Country_Name------------'+Country_Name);
                        SelectedCurrency =  SyncSettings.get(orIt.Business_Unit__c).Currency_Type__c;
                        system.debug('-------------------SelectedCurrency------------'+SelectedCurrency);
                        if(!string.IsBlank(orIt.Item_Type__c) && SyncSettings.get(orIt.Business_Unit__c).Business_Unit__c==orIt.Item_Type__c)
                        {
                            BusinessUnit = SyncSettings.get(orIt.Business_Unit__c).Business_Unit__c;
                        }
                        system.debug('-------------------BusinessUnit------------'+BusinessUnit);
                        if(!string.isBlank(Channel_Name) && !string.isBlank(auth_key) && !string.isBlank(Country_Name) && !string.isBlank(BusinessUnit) )
                        {
                            if(SyncSettings.KeySet().Contains('URL'))
                            {
                                bodyValue.put('transactionNo',orIt.Id__c);
                                bodyValue.put('cseName',userName);
                                bodyValue.put('cartId',orIt.Order_Id__c);
                                
                                HttpRequest req = new HttpRequest();
                                req.setTimeout(120000);
                                HttpResponse res = new HttpResponse();
                                Http http = new Http(); 
                                system.debug('-------------------URL------------'+SyncSettings.get('URL').URL__c);
                                req.setEndpoint(SyncSettings.get('URL').URL__c);
                                req.setMethod('POST');
                                if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                                    system.debug('---com---');
                                    SelectedCurrency=orIt.Amount_Recieved_Currency__c;
                                    req.setHeader('SelectedCurrency', SelectedCurrency);
                                    req.setHeader('Currency', SelectedCurrency);
                                }else{
                                    req.setHeader('Channel_Name', Channel_Name);
                                    req.setHeader('auth_key', auth_key);
                                    req.setHeader('Country_Name', Country_Name);
                                    req.setHeader('SelectedCurrency', SelectedCurrency);
                                    req.setHeader('BusinessUnit', BusinessUnit);
                                }
                                //req.setHeader('Currency', SelectedCurrency);
                                req.setHeader('Content-Type', 'application/json');
                                system.debug('-------------------BODY------------'+JSON.serialize(bodyValue));
                                req.setBody(JSON.serialize(bodyValue));
                                //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+'SelectedCurrency'+SelectedCurrency;
                                dbl.Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+'SelectedCurrency'+SelectedCurrency;
                                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                                try
                                {
                                    res = http.send(req);
                                    string responseValue = res.getBody();
                                    dbl.Payment_Request_Response_Time__c = system.now();
                                    //dbl.Payment_Request_Response_Data__c = string.valueof(res.getBody());         
                                    dbl.Response_Received__c = string.valueof(res.getBody());     
                                    dbl.CallOut_Status__c = string.valueOf(res.getStatus());  
                                    dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode()); 
                                    if(res.getStatusCode()==200)
                                    {
                                        system.debug('-------------responseValue-----------------'+responseValue); 
                                        dbl.Payment_Ping_Status__c = 'Success';  
                                        refundResponse resp   = new refundResponse();
                                        resp = (refundResponse)JSON.deserialize( responseValue, refundResponse.class);
                                        if(resp.IsSuccess=='true')
                                        {
                                            System.Debug('IsSuccess');
                                            if(!string.isBlank(resp.CustRefundId))
                                            {
                                                orIt.Refund_CustRefund_ID__c = resp.CustRefundId;
                                            }
                                            if(string.valueof(resp.InitiatedTime).contains('T') && !string.valueof(resp.InitiatedTime).contains('0001-01-01T00:00:00'))
                                            {
                                                orIt.Refund_Initiated_Time__c = datetime.valueof(string.valueof(resp.InitiatedTime).replace('T',' '));
                                            }
                                            else
                                                if(!string.valueof(resp.InitiatedTime).contains('0001-01-01T00:00:00'))
                                            {
                                                orIt.Refund_Initiated_Time__c = datetime.valueof((string)resp.InitiatedTime);
                                            }
                                            //orIt.Refund_Initiated_Time__c = datetime.valueof(string.valueof(resp.InitiatedTime));
                                            orIt.Refund_IsSuccess__c = boolean.valueof(resp.IsSuccess);
                                            if(!string.isBlank(resp.ResponseMessage))
                                            {
                                                orIt.Refund_Response_Message__c = resp.ResponseMessage;
                                            }
                                            list<case> caseList = new list<case>();
                                            String wfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
                                            String gfrecid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();
                                            for(case cs: [SELECT id,Transaction_ID__c,RecordType.DeveloperName,status,IsClosed FROM Case WHERE Transaction_ID__c =:orItemId AND (RecordType.DeveloperName='White_Failed_Transaction_WFT' OR RecordType.DeveloperName='Green_Failed_Transaction_GFT')])
                                            {
                                                if(cs.RecordType.DeveloperName=='White_Failed_Transaction_WFT')
                                                {
                                                    cs.RecordTypeid = gfrecid;
                                                    cs.status = system.Label.Case_Status;
                                                    // cs.IsClosed = true;
                                                }
                                                else
                                                    if(cs.RecordType.DeveloperName=='Green_Failed_Transaction_GFT')
                                                {
                                                    cs.status = system.Label.Case_Status;
                                                    // cs.IsClosed = true;
                                                }
                                                caseList.add(cs);
                                            }
                                            refundStatus = 'Success';
                                            database.update(caseList);
                                            database.update(orIt);
                                        }
                                        else
                                        {
                                            System.Debug('IsSuccess=false');
                                            refundStatus = 'Failed';
                                            refundStatusMesssage = 'Response Message :'+resp.ResponseMessage;
                                        }
                                    }
                                    else
                                    {
                                        refundStatus = 'Failed Wrong Status Code Received';
                                        dbl.Payment_Ping_Status__c = 'Failed';
                                    }
                                }
                                catch(exception e)
                                {
                                    refundStatus = 'Failed '+string.valueof(e);
                                    dbl.Payment_Ping_Status__c = 'Failed';
                                    dbl.Exception_Description__c = string.valueof(e);
                                }
                            }
                        }
                        else
                        {
                            refundStatus = 'Failed Authentication Failed';
                            dbl.Payment_Ping_Status__c = 'Authentication Failed';
                            //dbl.Payment_Request_Sent_Data__c = 'Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+'SelectedCurrency'+SelectedCurrency;
                            dbl.Request_Data__c = 'Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+'SelectedCurrency'+SelectedCurrency;
                        }
                    }
                }  
                
            }
        }
        insert dbl;
        system.debug('----------dbLog-----------'+dbl);
    }
    
    public void refundEnableCheck()
    {
        if(!string.isBlank(orItemId))
        {
            refundEnable = true;
            isAmountReceivable = false;
            orIt = [select id, id__c,Total_Fare_Value__c,Payment_Details__c,isreturn__c,Source__c,OrderUuid__c,Guid__c,Boarding_Time__c,isReturnTrip__c,Destination__c,Email_Copy__c,Mobile__c,Corrected_Date_of_Journey__c,Email__c, RecordType.Name, Route_Id__c,transaction_status__c,Transaction_Source__c,Order_Item_Reference_No__c, Flag__c,Source_City_Id__c , Order_Id__c, Business_Unit__c,Destination_City_Id__c ,Item_Type__c,Refund_CustRefund_ID__c, Refund_Initiated_Time__c, Refund_IsSuccess__c, Refund_Response_Message__c,Order_Uuid__c,Cancellation_Policy__c,Service_Provider_Reference_No__c,DOI_DOJ__c,Seat_No__c,(SELECT Id,TIN__c,Refund_Amount__c,Refund_Type__c,Status__c,Business_UnitF__c,PG_Name__c,Disbursal_ID__c from Refund_Order_Items__r),(SELECT Id from Payment_Items__r),
                    (Select Id from Cases__r where Issue_Type__c='Bus Cancellation') from Order_Items__c where id=:orItemId limit 1];
            recId= orIt.id;
            
            agentId=UserInfo.getUserName();
            if(orIt.Boarding_Time__c!=null){
                dojDate=orIt.Corrected_Date_of_Journey__c;
                finalDoj= dojDate.format('dd-MMM-yyyy');
            }
            
            List<Order_Items__c> listOrdItems = new List<Order_Items__c>();
            listOrdItems = [SELECT id,Total_Fare_Value__c,Business_Unit__c,id__c,isreturn__c,Payment_Details__c,Rebooked_To__c,Rebooking_For__c,Order_Id__c,status__c,Source__c,Transaction_Status__c,Destination__c,RecordType.DeveloperName from Order_Items__c where RecordType.DeveloperName='Bus_Booking' and Order_Id__c=:orIt.Order_Id__c and Source_City_Id__c=:orIt.Source_City_Id__c and Destination_City_Id__c=:orIt.Destination_City_Id__c ORDER BY Creation_Time__c DESC];
            
            list<Payment_Items__c> paymntItemlst = new list<Payment_Items__c>();
            paymntItemlst=[select id,ID__c,PG_Type__c,Guid__c,Latest_Payment_Status__c, PG_Reference_ID__c,Payment_Status__c,Order_Item_Name__c,Order_Item_Name__r.Transaction_Status__c from Payment_Items__c where Payment_System__c='ONLINE' and PG_Reference_ID__c!=null and Order_Item_Name__c=:orItemId];
            
            if(!paymntItemlst.isEmpty()){
                genrateDisbrslid=true;
                paymntUUid=paymntItemlst[0].Guid__c;
            }
            
            if(string.isNotBlank(orIt.Order_Item_Reference_No__c) && String.isNotBlank(orIt.Route_Id__c) && orIt.Cases__r.isEmpty() && 'Booked'.equalsIgnoreCase(orIt.Transaction_Status__c) && orIt.Refund_Order_Items__r.isEmpty())
            {
                BusCancelEnable = true;
                recId= orIt.id;
            }
            if(!orIt.Refund_Order_Items__r.isEmpty())
            {
                Integer failedRefCnt =0;
                Integer upiCount=0;
                
                for(Refund_Order_Items__c ref:orIt.Refund_Order_Items__r)
                {
                    String refundBusUnit='';
                    if(string.isNotBlank(ref.Business_UnitF__c)){
                        refundBusUnit = 'REDBUS_'+ref.Business_UnitF__c.split('_')[1];
                    }
                    
                    if('ONLINE'.equalsIgnoreCase(ref.Refund_Type__c) && string.Isblank(ref.Disbursal_ID__c) && (ref.Status__c!='REFUND_SUCCESSFUL' || ref.Status__c!='PG_REFUND_INITIATED'))
                    {
                        neftRefundAmt = ref.Refund_Amount__c.replace('INR','RS');
                        genrateDisbursalid = true;
                    }
                    
                    if(string.isNotblank(ref.Disbursal_ID__c) && (('REDBUS_IN'.equalsIgnoreCase(refundBusUnit) && ref.Status__c=='REFUND_FAILURE') || (!'REDBUS_IN'.equalsIgnoreCase(refundBusUnit) &&ref.Status__c!='REFUND_SUCCESSFUL')) && ('ONLINE'.equalsIgnoreCase(ref.Refund_Type__c) || 'REDBUS_ADJUSTMENT'.equalsIgnoreCase(ref.PG_Name__c)) && !setNonNeftPgTypes.contains(ref.PG_Name__c) && !'REDBUS_COM'.equalsIgnoreCase(refundBusUnit))
                    {
                        failedRefCnt++;
                        disbursalId = ref.Disbursal_ID__c;
                        neftRefundAmt = ref.Refund_Amount__c.replace('INR','RS');
                    }
                    
                    
                    if('ONLINE'.equalsIgnoreCase(ref.Refund_Type__c) && ref.Status__c=='REFUND_CREATED' && orIt.Refund_IsSuccess__c && String.Isblank(ref.TIN__c))
                        enableUpdateRefund = true;
                    
                    if(ref.PG_Name__c=='UPI' && ref.Status__c!='REFUND_SUCCESSFUL'){
                        upiCount++;
                    } 
                }
                if(failedRefCnt==1)
                    enableNeftLink = true;
                
                if(upiCount>0)
                    enableUPIRefund=true;
                
            }
            
            if(orIt.Refund_IsSuccess__c==true || !String.Isblank(orIt.Order_Item_Reference_No__c) || orIt.Flag__c != 0 || orIt.transaction_status__c!='GFT - Payment Debited but Ticket not Generated')
            {
                refundEnable = false;
                
            }
            else if(!orIt.Refund_Order_Items__r.isEmpty())
            {
                refundEnable = false;
            }
            
            if(orIt.Payment_Details__c!=null){ 
                Map<string,object> payMap=(Map<string,object>)JSON.deserializeUntyped(orIt.Payment_Details__c);
                Map<string,object> payMaap=(Map<string,object>) payMap.get('amountReceivable');            
                object amountReceivable = payMaap.get('amount');
                
                String noBUsString = System.label.GFT_Rebooking_Slab;
                List<String> noBUsList = noBUsString.split('_');
                decimal finalGFTrebaAmount;
                if (string.isNotBlank(orIt.Business_Unit__c) && orIt.Business_Unit__c == 'REDBUS_ID' && orIt.Total_Fare_Value__c!=null){
                    decimal percentage = Decimal.valueOf(noBUsList[0]);
                    integer limitedAmount = integer.valueof(noBUsList[1]);
                    Decimal tcAmount =  orIt.Total_Fare_Value__c * percentage;
                    system.debug('>>>>'+percentage+'>>>'+limitedAmount+'>>>'+tcAmount+'>>>'+orIt.Total_Fare_Value__c);
                    integer tcAmounte= integer.valueof(tcAmount);
                    
                    if (amountReceivable instanceof Integer) {
                        Integer intValue = (Integer)amountReceivable;                        
                        if (intValue <= 0 ){
                            isAmountReceivable = false;
                        }else if(intValue <= limitedAmount){
                            if(intValue < tcAmounte ){
                                isAmountReceivable = false;
                            }else{
                                isAmountReceivable = true;
                            }
                        }else{
                            isAmountReceivable = true;
                        }
                    }else if (amountReceivable instanceof Double) {
                        Decimal doubleValue = (Decimal)amountReceivable;
                        Decimal limitedAmounte = Decimal.valueof(limitedAmount);
                        if (doubleValue <= 0.0){
                            isAmountReceivable = false;
                        }else if(doubleValue <= limitedAmounte){
                            if(doubleValue < tcAmount ){
                                isAmountReceivable = false;
                            }else{
                                isAmountReceivable = true;
                            }
                            
                        } else {
                            isAmountReceivable = true;
                        }
                    }
                    
                    
                }else{
                    
                    system.debug('>>>>'+amountReceivable);
                    if (amountReceivable instanceof Integer) {
                        Integer intValue = (Integer)amountReceivable;                        
                        if (intValue <= 0) {
                            isAmountReceivable = false;
                        } else {
                            isAmountReceivable = true;
                        }
                    } else if (amountReceivable instanceof Double) {
                        Double doubleValue = (Double)amountReceivable;
                        if (doubleValue <= 0.0) {
                            isAmountReceivable = false;
                            system.debug('>>>if>>>'+isAmountReceivable);
                        } else {
                            isAmountReceivable = true;
                        }
                    } 
                }
            }     
            if(refundEnable && string.isNotBlank(orIt.Business_Unit__c) && mapBUtoRbkUrl.containskey(orIt.Business_Unit__c) && !isAmountReceivable )
            {
                rebookingURL= mapBUtoRbkUrl.get(orIt.Business_Unit__c);
                System.debug('rebookingURL....'+rebookingURL);
                enableRebooking = true;
            }
            
            if(listOrdItems.size()>1 && string.isNotBlank(orIt.Business_Unit__c) && mapBUtoRbkUrl.containskey(orIt.Business_Unit__c))
            {
                Boolean lastTransisWFT = false;
                Boolean lastTransisGFT = false;
                Boolean isInLatestTransaction = false;
                
                for(Integer i=0;i<1;i++)
                {
                    Order_Items__c trans = listOrdItems[i];
                    if(i==0 && trans.Id__c== orIt.Id__c)
                        isInLatestTransaction = true;
                    
                    if(trans.status__c=='TR_TENTATIVE_SUCCESSFUL_PO_COMPLETED' && String.isNotBlank(trans.Rebooking_For__c))
                        lastTransisWFT = true;
                    if(trans.status__c!=null && trans.status__c.containsIgnoreCase('TR_CONFIRMATION_FAILURE') && String.isNotBlank(trans.Rebooking_For__c))
                        lastTransisGFT = true;
                    
                    if(string.isNotBlank(trans.Payment_Details__c)){ 
                        Map<string,object> payMapVal=(Map<string,object>)JSON.deserializeUntyped(trans.Payment_Details__c);
                        Map<string,object> payMapAmnt=(Map<string,object>) payMapVal.get('amountReceivable');            
                        object amountRecVal =payMapAmnt.get('amount');
                        system.debug('>>>>>>>>>>>>'+amountRecVal);
                        
                        String noBUsString = System.label.GFT_Rebooking_Slab;
                        List<String> noBUsList = noBUsString.split('_');
                        decimal finalGFTrebaAmount;
                        if (string.isNotBlank(trans.Business_Unit__c) && trans.Business_Unit__c == 'REDBUS_ID' && trans.Total_Fare_Value__c!=null) {
                            
                            decimal percentage = Decimal.valueOf(noBUsList[0]);
                            integer limitedAmount = integer.valueof(noBUsList[1]);
                            Decimal tcAmount =  trans.Total_Fare_Value__c * percentage;
                            system.debug('>>>>'+percentage+'>>>'+limitedAmount+'>>>'+tcAmount+'>>>'+trans.Total_Fare_Value__c);
                            integer tcAmounte= integer.valueof(tcAmount);
                            
                            if (amountRecVal instanceof Integer) {
                                Integer intValue = (Integer)amountRecVal;                        
                                if (intValue <= 0 ){
                                    isAmountReceivable = false;
                                }else if(intValue <= limitedAmount){
                                    if(intValue < tcAmounte ){
                                        isAmountReceivable = false;
                                    }else{
                                        isAmountReceivable = true;
                                    }
                                }else{
                                    isAmountReceivable = true;
                                }
                            }else if (amountRecVal instanceof Double) {
                                Decimal doubleValue = (Decimal)amountRecVal;
                                Decimal limitedAmounte = Decimal.valueof(limitedAmount);
                                if (doubleValue <= 0.0){
                                    isAmountReceivable = false;
                                }else if(doubleValue <= limitedAmounte){
                                    if(doubleValue < tcAmount ){
                                        isAmountReceivable = false;
                                    }else{
                                        isAmountReceivable = true;
                                    }
                                    
                                } else {
                                    isAmountReceivable = true;
                                }
                            }
                        }else {
                            
                            if (amountRecVal instanceof Integer) {
                                Integer intValue = (Integer)amountRecVal;
                                if (intValue <= 0) {
                                    isAmountReceivable = false;
                                } else {
                                    isAmountReceivable = true;
                                }
                            } else if (amountRecVal instanceof Double) {
                                Double doubleValue = (Double)amountRecVal;
                                if (doubleValue <= 0.0) {
                                    isAmountReceivable = false;
                                } else {
                                    isAmountReceivable = true;
                                }
                            } 
                        } 
                    }  
                }
                
                if((isInLatestTransaction && lastTransisWFT) || (!isInLatestTransaction && lastTransisGFT))
                {
                    enableRebooking = false;
                    refundEnable = false;
                }
                
                if(isInLatestTransaction && lastTransisGFT)
                {
                    enableRebooking = false;
                    refundEnable = true;
                    System.debug('enableRebooking ...'+enableRebooking);
                }
                
                if(!isInLatestTransaction && lastTransisWFT && !isAmountReceivable)
                {
                    enableRebooking = true;
                    refundEnable = true;
                }
                
            }
            if(orIt.Payment_Items__r.isEmpty())
                syncEnable = true;
        }
        
        if(string.isBlank(orIt.Order_Item_Reference_No__c) && (orIt.Business_Unit__c == 'REDBUS_PE'|| orIt.Business_Unit__c == 'REDBUS_CO') && orIt.Refund_Order_Items__r.isEmpty() && orIt.transaction_status__c =='GFT - Payment Debited but Ticket not Generated'){
            
            enableconformation =true;
        }
    }
    
    public void syncDataCall()
    {
        string body='';
        String countryCode='';
        if('REDBUS_RAILS_IN'.equalsIgnoreCase(orIt.Business_Unit__c) || 'REDRAILS_IN'.equalsIgnoreCase(orIt.Business_Unit__c)){
            body = '{"orderId":"'+orIt.Order_Id__c+'","emailId":"","phone":"","caller":"SyncRedBusData","isRails":true}';
            countryCode='IND';
        }else if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
            body = '{"orderId":"'+orIt.Order_Id__c+'","emailId":"","phone":"","caller":"SyncRedBusData"}';
            countryCode ='RDC';
        }else {
            body = '{"orderId":"'+orIt.Order_Id__c+'","emailId":"","phone":"","caller":"SyncRedBusData"}';
            countryCode = String.isBlank(orIt.Business_Unit__c)?'IND':'REDBUS_IN'.equalsIgnoreCase(orIt.Business_Unit__c)?'IND':'INTL';
        }
        System.debug('..body...'+body+'....countryCode...'+countryCode);
        
        SyncAPICntrl.asyncProcess(body,countryCode);
    }
    
    /*public void sendNEFTlink()
{
Set<String> setNonWhiteLabelBUs = new Set<String>(System.label.NonWhiteLabelBUs.split(','));

if(String.isBlank(orIt.Order_Id__c) || String.isBlank(orIt.Business_Unit__c))
{
refundStatusMesssage = 'Required Fields Data Like Business Unit Or TripId is Missing.So,You Can\'t Perform This Action';
}
else
{
DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.type__c ='Send NEFT Link';
String tin =String.isNotBlank(orIt.Order_Item_Reference_No__c)?orIt.Order_Item_Reference_No__c:'';
Http ht = new http();
HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
HttpResponse resp = new HttpResponse();
//req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Encryption'].Endpoint__c+tin+'&tripId='+orIt.Order_Id__c+'&pullFromNeon=false&orderItemUUID=&businessUnit='+orIt.Business_Unit__c+'&saleschannel='+orIt.Transaction_Source__c);

req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Encryption'].Endpoint__c+tin+'&tripId='+orIt.Order_Id__c+'&pullFromNeon=false&orderItemUUID=&businessUnit='+orIt.Business_Unit__c);

req.setMethod('GET');
try
{
dbl.Request_Data__c = String.valueOf(req);
resp=ht.send(req);

if(resp.getStatus() =='OK' && resp.getStatusCode() ==200 && String.isNotBlank(resp.getBody()))
{
string EmailtemplName='';
string SmstemplName='';
String BusUnit='';
string language='';
string subject='';
string selCurrency=' - ';
string neftUrl = String.valueOf(resp.getBody());
neftUrl= neftUrl.removeStart('"').removeEnd('"');
dbl.Response_Received__c = resp+'--Neft URL--'+resp.getBody();

if(!setNonWhiteLabelBUs.contains(orIt.Business_Unit__c))
{
String repUrl= neftUrl.replace('Refund/Refund','neftskip/Refund');
neftUrl = repUrl+'&BU='+orIt.Business_Unit__c;
}  

if(string.isNotBlank(orIt.Business_Unit__c)){
BusUnit = 'REDBUS_'+orIt.Business_Unit__c.right(2);
EmailtemplName=OrderItemTransactionResource__c.getValues(BusUnit).EmailTtemplateName__c;
SmstemplName=OrderItemTransactionResource__c.getValues(BusUnit).SMStemplateName__c;
language=OrderItemTransactionResource__c.getValues(BusUnit).Language__c;
subject=OrderItemTransactionResource__c.getValues(BusUnit).Subject__c;
// selCurrency= OrderItemTransactionResource__c.getValues(BusUnit).Default_Currency__c;


} 

String encodedUrl = EncodingUtil.urlEncode(neftUrl,'UTF-8');
string urlBody='url='+encodedUrl+',cD='+System.now();


Http shrtHt = new Http();
HttpRequest shrtReq = new HttpRequest();
HttpResponse shrtResp = new HttpResponse();                                   
shrtReq.setMethod('POST');                  
shrtReq.setBody(urlBody);
shrtReq.setendpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Shorten'].Endpoint__c);
shrtResp=shrtHt.send(shrtReq);
dbl.Complaint_Tracker_Body_Received__c= 'Request..'+shrtReq+'..'+urlBody+'..Response..'+shrtResp.getbody();
map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(shrtResp.getbody());
map<string,object> resObj1=(map<string,object>)resObj.get('data');
string shortenURL='https://s.redbus.com/'+resObj1.get('short');    

HttpRequestWrappersUtil.SendSMSEMailReqWrapper smsEmailReq = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
smsEmailReq.type= new List<String>{'smsdata','emaildata'};
string bodyText = '{"refundAmount":"'+neftRefundAmt+'","refundLink":"'+shortenURL+'"}';
smsEmailReq.smsdata = HttpRequestUtil.prepareSMSReqData(SmstemplName,bodyText,'','',orIt.Mobile__c,'',false,language,true);
smsEmailReq.emaildata = HttpRequestUtil.prepareEmailReqData(EmailtemplName,bodyText,'',subject+selCurrency+neftRefundAmt,mapBUToSenEMail.get(orIt.Business_Unit__c.right(3)),orIt.Email__c,'','RedBus Support',language,language,true);


Http ht2 = new http();
HttpRequest req2 = HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),BusUnit,'');
HttpResponse resp2 = new HttpResponse();
req2.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'].Endpoint__c);
req2.setBody(Json.serialize(smsEmailReq ));
req2.setMethod('POST');
//dbl.Payment_Request_Sent_Data__c = String.valueOf(req2) +'..SMS Body..'+Json.serialize(smsEmailReq )+'-Headers-currency--'+req2.getHeader('SelectedCurrency')+'---countryname--'+req2.getHeader('Country_Name');
dbl.Request_Data__c = String.valueOf(req2) +'..SMS Body..'+Json.serialize(smsEmailReq )+'-Headers-currency--'+req2.getHeader('SelectedCurrency')+'---countryname--'+req2.getHeader('Country_Name');
resp2 = ht2.send(req2);
//dbl.Payment_Request_Response_Data__c = 'SMS Response..'+String.valueOf(resp2);
dbl.Response_Received__c = 'SMS Response..'+String.valueOf(resp2);
refundStatus ='';
refundStatusMesssage='';
if(resp2.getStatus() =='OK' && resp2.getStatusCode() ==200 && String.isNotBlank(resp2.getBody()))
{
System.debug('sms resp-->'+resp2.getBody());
//dbl.Payment_Request_Response_Data__c ='SMM Response..'+resp2.getBody();
dbl.Response_Received__c ='SMM Response..'+resp2.getBody();
refundStatus = 'Link has shared successfully Through SMS and EMAIL';
}
else
{
refundStatusMesssage = String.valueOf(resp2.getBody());
}



//Start Send WhatsApp Notification please comment this code start 
Map<String, String> whatsappheaders = new Map<String, String>();
whatsappheaders.put('Content-Type','application/json');
whatsappheaders.put('Channel_Name','MOBILE_WEB');
whatsappheaders.put('Country_Name','IND');
whatsappheaders.put('BusinessUnit','BUS');
whatsappheaders.put('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');

HttpResponse wappHt = new HttpResponse();
HttpRequestWrappersUtil.WhatsAppRequestWrapper whatsAppReq= new HttpRequestWrappersUtil.WhatsAppRequestWrapper();
whatsAppReq = HttpRequestUtil.prepareWhatsappRequest('NEFT_WhatsApp',bodyText,2,tin,orIt.Mobile__c,'en');
wappHt = HTTPUtil.sendGenericHTTPRequest([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification'].Endpoint__c,'Post',Json.serialize(json.serialize(whatsAppReq)),whatsappheaders,100000);
dbl.Orders_Success__c = String.valueOf(wappHt);

if(wappHt.getStatus() =='OK' && wappHt.getStatusCode() ==200 && String.isNotBlank(wappHt.getBody()))
{
dbl.Orders_Success__c = wappHt.getBody();
refundStatus = String.isBlank(refundStatus)?'Link has shared successfully Through WhatsApp and SMS,EMAIL Failed':refundStatus+' and WhatsApp';
}
else
{
refundStatusMesssage = refundStatusMesssage+String.valueOf(resp2.getBody());
} // comment ends

}
}
Catch(Exception e)
{
System.debug('error sending neft link..'+e);
dbl.Exception_Description__c = String.valueOf(e);
refundStatusMesssage = dbl.Exception_Description__c;
}
insert dbl;
}
}*/
    
    public void sendDisbursallink()
    {
        //Set<String> setNonWhiteLabelBUs = new Set<String>(System.label.NonWhiteLabelBUs.split(','));
        system.debug('----Disbursal-----');
        if(String.isBlank(orIt.Order_Id__c) || String.isBlank(orIt.Business_Unit__c))
        {
            refundStatusMesssage = 'Required Fields Data Like Business Unit Or TripId is Missing.So,You Can\'t Perform This Action';
        }
        else
        {
            case cs = new case();
            disburaslIdForNwCase= false;
            string busUnit;
            if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                busUnit=orIt.Business_Unit__c;
            }else{
                busUnit = 'REDBUS_'+orIt.Business_Unit__c.split('_')[1];
            }
            String tin =String.isNotBlank(orIt.Order_Item_Reference_No__c)?orIt.Order_Item_Reference_No__c:'';
            system.debug('--Guid--'+orIt.Guid__c);
            string Guid=String.isNotBlank(orIt.Guid__c)?orIt.Guid__c:'';
            list<Case> existNeftCaseLst = [Select id,Issue_Type__c,status,Transaction_UUID__c from Case Where Issue_Type__c='NEFT Refund' and (TIN_No__c=:tin or Transaction_UUID__c=:Guid)];
            system.debug(':::: existNeftCaseLst '+existNeftCaseLst);
            if(existNeftCaseLst.isEmpty()){
                disburaslIdForNwCase=true;            
                cs.Issue_Type__c ='NEFT Refund';
                cs.Issue_Sub_Category__c='Initiate NEFT Refund';
                cs.origin = 'Salesforce System';
                cs.Status='Open';
                cs.country__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Country__c;
                cs.Business_Type__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Business_Type__c;
                cs.tin_no__c = orIt.Order_Item_Reference_No__c;
                cs.Transaction_ID__c =orIt.id;
                cs.Trip_Id_ct__c = orIt.Order_Id__c;
                cs.SS_Route_Id__c = orIt.Route_Id__c;
                cs.SourceT__c = orIt.Source__c;
                cs.Disbursal_Id__c =disbursalId;
                cs.DestinationT__c = orIt.Destination__c;
                cs.Customer_Email_ID__c = orIt.Email_Copy__c;
                cs.Customer_Phone_Number__c = orIt.Mobile__c;
                cs.Email_Id_ct__c = orIt.Email_Copy__c;
                cs.Phone_No_ct__c =orIt.Mobile__c;
                insert cs;
                if(disburaslIdForNwCase){
                    refundStatus = 'Disbursal Form Link has shared please Check in related case comments';
                    sendDisbursallinkForNewcase(disbursalId);
                }
            }else{
                
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.type__c ='Send DisbursalForm Link';
                CaseComment cc=new CaseComment();
                
                HttpRequestWrappersUtil.DisbursalRequestWrap disBursalReqWrap= new HttpRequestWrappersUtil.DisbursalRequestWrap();
                HttpRequestWrappersUtil.RequestedBy reqstBy= new HttpRequestWrappersUtil.RequestedBy ();
                
                reqstBy.SystemName='SF';
                reqstBy.UserName=UserInfo.getUsername();
                disBursalReqWrap.DisbursalID=disbursalId;
                disBursalReqWrap.RequestedBy=reqstBy;
                string Jsonbody = JSON.serialize(disBursalReqWrap);
                
                HTTP http = new HTTP();
                HttpRequest req= new HttpRequest();
                HTTPResponse res=new HTTPResponse(); 
                req = HttpRequestUtil.populateDisbursalHeaders(req);  
                if(String.isNotBlank(OrderItemTransactionResource__c.getValues(busUnit).Auth_Key__c)){
                    req.setHeader('Country_Name', +String.valueOf(OrderItemTransactionResource__c.getValues(busUnit).Auth_Key__c));     
                }else{
                    req.setHeader('Country_Name', null);     
                }
                req.setBody(Jsonbody);  
                req.setMethod('POST');        
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SendDisbursalFormLink'].Endpoint__c);
                dbl.Request_Data__c =string.valueof(req)+'..Body..'+String.valueOf(Jsonbody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--AuthToken--'+req.getHeader('AuthToken')+'--Country_Name--'+req.getHeader('Country_Name');
                system.debug('----Disbursal BODY----'+String.valueOf(Jsonbody));
                try
                {
                    res = http.send(req); 
                    system.debug('--Disbursal res--'+res);
                    refundStatus ='';
                    refundStatusMesssage='';
                    if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
                    {
                        dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                        map<String,Object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                        if((boolean)resMap.get('IsSuccess'))
                        {
                            system.debug('----Disbursal Success----');
                            cc.CommentBody='--Disbursal Form Link has shared successfully--';
                            refundStatus = 'Disbursal Form Link has shared successfully';
                            dbl.Exception_Description__c ='--Disbursal Form Link has shared successfully--';                    
                        }else{
                            system.debug('----Disbursal fail----');
                            cc.CommentBody='-Sending Disbursal Link is failed--'+string.valueof(resMap.get('ErrorMsg'));
                            refundStatusMesssage =string.valueof(resMap.get('ErrorMsg'));
                            dbl.Exception_Description__c ='-Sending Disbursal Link is failed--'+string.valueof(resMap.get('ErrorMsg'));
                        }
                    }
                }
                Catch(Exception e)
                {
                    System.debug('error sending neft link..'+e);
                    dbl.Exception_Description__c = String.valueOf(e);
                    refundStatusMesssage = dbl.Exception_Description__c;
                }
                cc.parentId = existNeftCaseLst[0].id;
                insert cc;
                insert dbl;   
            }   
            
        }   
    } 
    
    public void GenrateDisbursalid()
    {
        system.debug('----Disbursal-----');
        if(String.isBlank(orIt.Order_Id__c) || String.isBlank(orIt.Business_Unit__c))
        {
            refundStatusMesssage = 'Required Fields Data Like Business Unit Or TripId is Missing.So,You Can\'t Perform This Action';
        }
        else
        {
            case cs = new case();
            string busUnit;
            if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                busUnit=orIt.Business_Unit__c;
            }else{
                busUnit = 'REDBUS_'+orIt.Business_Unit__c.split('_')[1];
            }
            string emailId=String.isNotBlank(orIt.Email__c)?orIt.Email__c:'';
            String country =OrderItemTransactionResource__c.getValues(busUnit).Case_Country__c;
            String countryCode =OrderItemTransactionResource__c.getValues(busUnit).Auth_Key__c;
            system.debug('--Guid--');
            string mobile=String.isNotBlank(orIt.Mobile__c)?orIt.Mobile__c:'';   
            string orderUuid=String.isNotBlank(orIt.OrderUuid__c)?orIt.OrderUuid__c:'';   
            string refund1=string.valueof(neftRefundAmt);
            string refund = refund1.replaceAll(' ', '_');
            String FinalRefund=refund.split('_')[1];
            system.debug('---red---'+refund+'---'+FinalRefund);
            Decimal FinalRefundDecimalValue = Decimal.valueOf(FinalRefund);
            
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='Generaterate Disbursalid';
            CaseComment cc=new CaseComment();
            
            HttpRequestWrappersUtil.generateDisReq disBursalidReq= new HttpRequestWrappersUtil.generateDisReq();            
            // disBursalidReq.amount=Integer.valueof(FinalRefund);
            disBursalidReq.amount=FinalRefundDecimalValue.intValue();
            disBursalidReq.order_id=paymntUUid;
            disBursalidReq.order_uuid=orderUuid;
            disBursalidReq.country_name=country;
            disBursalidReq.email=emailId;
            disBursalidReq.phone_num=mobile;
            string Jsonbody = JSON.serialize(disBursalidReq);
            
            HTTP http = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse(); 
            req.setHeader('Content-Type', 'text/plain');    
            req.setHeader('Authtoken', 'GDHFGHF5645HJGJGJ564564JHGJGHKRG5654677523324325');
            req.setHeader('Disbursal_API_AUTHTOKEN', 'GDHFGHF5645HJGJGJ564564JHGJGHKRG5654677523324325');         
            req.setHeader('Country_Name', +countryCode);             
            req.setBody(Jsonbody);  
            req.setMethod('POST');        
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GenerateDisbursalId'].Endpoint__c);
            dbl.Request_Data__c =string.valueof(req)+'..Body..'+String.valueOf(Jsonbody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--Disbursal_API_AUTHTOKEN--'+req.getHeader('Disbursal_API_AUTHTOKEN')+'-----Authtoken----'+req.getHeader('Authtoken')+'-----Country_Name----'+req.getHeader('Country_Name');
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            system.debug('----Disbursal BODY----'+String.valueOf(Jsonbody));
            try
            {
                res = http.send(req); 
                system.debug('--Disbursal res--'+res);
                refundStatus ='';
                refundStatusMesssage='';
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
                {
                    system.debug('-----200-----');
                    dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                    map<String,Object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                    if((boolean)resMap.get('is_success'))
                    {
                        system.debug('----Disbursal Success----');
                        dbl.Exception_Description__c ='--Generated Disbursal Id successfully--';
                        refundStatus = 'Disbursal Id has created successfully'; 
                    }else{
                        system.debug('----Disbursal fail----');
                        dbl.Exception_Description__c ='---'+string.valueof(resMap.get('message'));
                        refundStatusMesssage =string.valueof(resMap.get('message'));
                    }
                }else{
                    refundStatusMesssage ='please wait--response body is empty from paas side';
                }
            }
            Catch(Exception e)
            {
                System.debug('error sending neft link..'+e);
                dbl.Exception_Description__c = String.valueOf(e);
                refundStatusMesssage = dbl.Exception_Description__c;
            }
            
            insert dbl;   
        }   
    } 
    @future(callout=true)
    public static void sendDisbursallinkForNewcase(string disbursalId)
    {      
        system.debug('--new case disbursalId--'+disbursalId);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Send DisbursalForm Link';
        List<Case> existDisBrslCaseLst = [Select id,CaseNumber,Issue_Type__c,status,Business_Unit_ct__c from Case Where issue_type__c='NEFT Refund' and Disbursal_Id__c=:disbursalId];
        CaseComment cc=new CaseComment();
        string comments='';
        HTTP http = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse(); 
        req = HttpRequestUtil.populateDisbursalHeaders(req); 
        string countryName='';
        If(String.isNotBlank(existDisBrslCaseLst[0].Business_Unit_ct__c) && BusinessUnitMapping__c.getValues(existDisBrslCaseLst[0].Business_Unit_ct__c)!=null){
            countryName = String.valueOf(BusinessUnitMapping__c.getValues(existDisBrslCaseLst[0].Business_Unit_ct__c).Country__c);
        }
        req.setHeader('Country_Name', +countryName); 
        req.setMethod('POST'); 
        try
        {
            if(!existDisBrslCaseLst.isEmpty()){  
                system.debug('-- 1 Case Number is updated--');
                HttpRequestWrappersUtil.DisbursalCaseNumberUpdate dsbrslCaseUpdt= new HttpRequestWrappersUtil.DisbursalCaseNumberUpdate ();
                dsbrslCaseUpdt.DisbursalID=disbursalId;
                dsbrslCaseUpdt.CaseID=existDisBrslCaseLst[0].casenumber;
                req.setBody(JSON.serialize(dsbrslCaseUpdt));
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Disbursal_CaseNumber_Update'].Endpoint__c);
                system.debug('----new case body--'+req.getBody()+'--endpoint--'+req.getEndpoint()+'--Country_Name--'+req.getHeader('Country_Name'));
                res = http.send(req); 
                
                if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
                {
                    system.debug('--Case Number is updated--');
                    comments='Case Number is updated';
                }
            }
            
            HttpRequestWrappersUtil.DisbursalRequestWrap disBursalReqWrap= new HttpRequestWrappersUtil.DisbursalRequestWrap();
            HttpRequestWrappersUtil.RequestedBy reqstBy= new HttpRequestWrappersUtil.RequestedBy ();
            
            reqstBy.SystemName='SF';
            reqstBy.UserName=UserInfo.getUsername();
            disBursalReqWrap.DisbursalID=disbursalId;
            disBursalReqWrap.RequestedBy=reqstBy;
            string Jsonbody = JSON.serialize(disBursalReqWrap);
            req.setBody(Jsonbody);  
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='SendDisbursalFormLink'].Endpoint__c);
            dbl.Request_Data__c =string.valueof(req)+'..Body..'+String.valueOf(Jsonbody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--AuthToken--'+req.getHeader('AuthToken')+'--Country_Name--'+req.getHeader('Country_Name');
            system.debug('----new case disbursal BODY----'+String.valueOf(Jsonbody));
            
            res = http.send(req); 
            system.debug('--new case disbursal res--'+res);
            
            if(res.getStatusCode()==200 && string.isNotBlank(res.getBody()))
            {
                dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
                map<String,Object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                if((boolean)resMap.get('IsSuccess'))
                {
                    cc.CommentBody=comments+'--Disbursal Form Link has shared successfully--';
                    system.debug('---New case disbursal Success----');
                }else{
                    cc.CommentBody='-case update-'+comments+'--'+string.valueof(resMap.get('ErrorMsg'));
                    system.debug('----New case disbursal fail----');
                }
            }
        }
        Catch(Exception e)
        { 
            cc.CommentBody=String.valueOf(e);
            System.debug('error sending neft link..'+e);
            dbl.Exception_Description__c = String.valueOf(e);
        }
        cc.parentId = existDisBrslCaseLst[0].id;
        insert cc;
        insert dbl;  
    }
    public PageReference UPIRefundPage() { 
        PageReference myVFPage;
        myVFPage = new PageReference('/apex/UPIRefund');
        myVFPage.setRedirect(true);
        myVFPage.getParameters().put('id', orItemId );
        //myVFPage.getParameters().put('mobile', mobile);
        return myVFPage;
    }
    public class Response
    {
        string PaymentItemId;
        string PgTransactionId;
        string PaymentStatus;
        string RbPgId;
        string IsOffline;
        string Amount;
        string PGType;
        string GatewayName;
    }
    public class refundResponse
    {
        public string InitiatedTime;
        public string CustRefundId;
        public string IsSuccess;
        public string ResponseMessage; 
    }
    
}