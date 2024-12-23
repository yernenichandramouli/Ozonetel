public class PaymentStatusUpdonCasecrt
{
    public static void PaymentStatus(Set<string> TripIds,List<WFT_GFT__c> ListOI)
    {
        string PayType = system.label.PaymentItemType;
        list<string> PaymentType = new list<string>();
        PaymentType = PayType.split(','); 
        list<string> PayItemList = new list<string>(); 
        system.debug('-----------PaymentType--------------'+PaymentType);
        map<string, WFT_GFT_Payment__c> PIMap = new map<string,WFT_GFT_Payment__c>();
        map<string, WFT_GFT__c> OIMap = new map<string,WFT_GFT__c>();
        Map<String,Payment_API_endpoint__c> mapauth = Payment_API_endpoint__c.getAll();
        List<DBLog_Summary__c> lstdbl = new List<DBLog_Summary__c>();
        System.debug('----ListOI----'+ListOI);
        for(WFT_GFT__c OI: ListOI)
        {
            OIMap.put(String.valueOf(OI.Transaction_Name__c).substring(0, 15),OI);
        }
        System.debug('----OIMap----'+OIMap);
        System.debug('----TripIds----'+TripIds);
        for(WFT_GFT_Payment__c pI: [select id, ID__c,GUID__c,Payment_System__c,Amount_Payable_Currency__c,Latest_Payment_Status__c, Order_Item_Name__c,Transaction_Source__c,Item_Type__c,PG_Type__c,Business_Unit__c from WFT_GFT_Payment__c where Order_Item_Name__c IN: TripIds and Payment_System__c IN: PaymentType])
        {
            system.debug('-------PI---------------'+pI);
            system.debug('-------.Transaction_Source__c----------------'+PI.Transaction_Source__c);
            system.debug('-------.Item_Type__c----------------'+PI.Item_Type__c);
            system.debug('-------.Business_Unit__c----------------'+PI.Business_Unit__c);
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
            for(OrderItemTransactionResource__c oi: oitr)
            {
                system.debug('-------OI---------------'+OI);
                oitrMap.put(oi.name,oi);
            }
            system.debug('-------oitrMap---------------'+oitrMap);
            for(string PayId : PayItemList)
            {
                string Channel_Name;
                string auth_key;
                string Country_Name;
                string BusinessUnit;
                string SelectedCurrency;
                
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                if(PIMap.KeySet().Contains(PayId))
                {
                    if(!string.isBlank(string.valueof(PIMap.get(PayId).Transaction_Source__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Transaction_Source__c))
                    {
                        Channel_Name = oitrMap.get(PIMap.get(PayId).Transaction_Source__c).Channel_Name__c;
                        auth_key = oitrMap.get(PIMap.get(PayId).Transaction_Source__c).Auth_Key__c;
                        system.debug('-------Channel_Name---------------'+Channel_Name);
                        system.debug('-------auth_key---------------'+auth_key);
                    }
                    if(!string.isBlank(string.valueof(PIMap.get(PayId).Item_Type__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Item_Type__c))
                    {
                        BusinessUnit  = oitrMap.get(PIMap.get(PayId).Item_Type__c).Auth_Key__c;
                        system.debug('-------BusinessUnit---------------'+BusinessUnit);
                    }
                    if(!string.isBlank(string.valueof(PIMap.get(PayId).Business_Unit__c)) && oitrMap.KeySet().Contains(PIMap.get(PayId).Business_Unit__c))
                    {
                        Country_Name = oitrMap.get(PIMap.get(PayId).Business_Unit__c).Auth_Key__c;
                        SelectedCurrency = oitrMap.get(PIMap.get(PayId).Business_Unit__c).Default_Currency__c;
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
                    system.debug('-------Ping---------------');
                    String payGuid=string.valueof(PIMap.get(PayId).Guid__c);
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(120000);
                    HttpResponse res = new HttpResponse();
                    Http http = new Http(); 
                    String endpoint = mapauth.get('End Point').End_Point__c+PayId+'&paymentUuid='+payGuid;
                    system.debug('-------mapcusauth---------------'+mapauth.get('End Point').End_Point__c);
                    system.debug('-------endpoint---------------'+endpoint);
                    //req.setEndpoint('http://cmapi-pp.redbus.com/api/Payment/v1/Status?paymentItemId='+PayId);
                    req.setEndpoint(endpoint);
                    req.setHeader('Channel_Name', Channel_Name);
                    req.setHeader('auth_key', auth_key);
                    req.setHeader('BusinessUnit', BusinessUnit);
                    req.setHeader('Country_Name', Country_Name);
                    req.setHeader('SelectedCurrency',SelectedCurrency);
                    req.setMethod('GET');
                    //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;
                    dbl.Request_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :'+BusinessUnit+',Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;

                    try
                    {
                        res = http.send(req);
                        string responseValue = res.getBody();
                        dbl.Payment_Request_Sent_Time__c = system.now();
                        dbl.Type__c = 'Payment Ping From Batch';
                        //dbl.Payment_Request_Response_Data__c = String.valueOf(res)+'--'+responseValue;//string.valueof(res.getBody());
                        dbl.Response_Received__c = String.valueOf(res)+'--'+responseValue;
                        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                        Response  resp = new Response();
                        if(res.getStatus()=='OK')
                        {
                            dbl.Payment_Ping_Status__c = 'Success';
                            resp = (Response)JSON.deserialize( responseValue, Response.class);
                            system.debug('---------resp---------------'+resp);
                            dbl.Payment_Request_Response_Time__c = system.now();
                            //dbl.Payment_Request_Response_Data__c = string.valueof(res.getBody()); 
                            dbl.Response_Received__c = string.valueof(res.getBody()); 
                            if(PIMap.Keyset().Contains(PayId))
                            {
                               dbl.Payment_Transaction_Name__c = OIMap.get(PIMap.get(PayId).Order_Item_Name__c).Transaction_Name__c;
                               if(!String.isBlank(resp.RbPgId) && string.valueof(resp.RbPgId)!= '0') 
                               {
                                   PIMap.get(PayId).PG_Reference_ID__c = string.valueof(resp.PgTransactionId);
                                   PIMap.get(PayId).Latest_Payment_Status__c = string.valueof(resp.PaymentStatus); 
                                   PIMap.get(PayId).Payment_Gateway_Type__c = string.valueof(resp.GatewayName);
                                   PIMap.get(PayId).PG_Type__c = string.valueof(resp.PGType); 
                                   if(OIMap.KeySet().contains(PIMap.get(PayId).Order_Item_Name__c))
                                   {
                                       OIMap.get(PIMap.get(PayId).Order_Item_Name__c).Transaction_Latest_Status__c = string.valueof(resp.PaymentStatus);
                                   }
                               }
                               else
                               {
                                   dbl.X0_PG_Reference_ID__c = TRUE;
                               }
                            }
                        }
                        else
                        {
                            dbl.Payment_Ping_Status__c = 'Failed';
                        }
                    }
                    catch(exception e)
                    {
                        dbl.Payment_Ping_Status__c = 'Fail';
                        //dbl.Payment_Request_Response_Data__c = String.valueOf(e);
                        dbl.Response_Received__c = String.valueOf(e);
                    }
                }
                lstdbl.add(dbl);
            }
        }
        if(!PIMap.isEmpty())
        {
            System.debug('------PIMap Update----'+OIMap);
            Database.update(PIMap.values(),false);
        }
        if(!OIMap.isEmpty())
        {
            System.debug('------OIMap Update----'+OIMap);
            Database.update(OIMap.values(),false);
        }
        if(!lstdbl.isEmpty())
        {
            System.debug('------lstdbl Update----'+OIMap);
            Database.insert(lstdbl,false);
        }
    }
    public class Response
    {
        string PaymentItemId;
        string PgTransactionId;
        string PaymentStatus;
        string RbPgId;
        string Amount;
        string PGType;
        string GatewayName;
    }
  
}