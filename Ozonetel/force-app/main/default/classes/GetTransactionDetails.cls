public class GetTransactionDetails {
    
    public static string recId{get; set;}
    public getTransactionDetails(ApexPages.StandardController sc) {
        system.debug('<<sc.getRecord().id'+sc.getRecord().id);
        recId = sc.getRecord().id;
    }
    
    @AuraEnabled
    public static string getShowDetails(string ordId){
        Order_Items__c ord=[select id,Transaction_Status__c,Primary_Boarding_Point_Time__c from Order_Items__c where id =: ordId];
        system.debug('<<<ordId'+ordId); 
        string errormsg = '';
        system.debug('status'+ord.Transaction_Status__c);
        if (ord.Transaction_Status__c != 'Booked'){
            errormsg = 'Driver details are available for only booked status';
        }
        system.debug('errormsg'+errormsg);
        return errormsg;
    }
    
    @AuraEnabled(cacheable=true) 
    public static HttpRequestWrappersUtil.priceBreakupResponse  getFareBifurcation( string ordId){
        try
        {
            Boolean isConnectedService = false;
            system.debug('enetered fare Method');
            if(ordId != Null){
                system.debug('ordId is not Null');
                Order_Items__c ord=[select id,Guid__c,Amount_Recieved_Currency__c,Order_Item_Reference_No__c,Umbrella_TIN__c,Business_Unit__c from Order_Items__c where id =: ordId];
                if(ord!=null){
                    isConnectedService = String.isNotBlank(ord.Umbrella_TIN__c)?true:false;
                    system.debug('tin is not Null');
                    if(ord.Guid__c != Null && ord.Guid__c != ''){            
                        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketDetails'].Endpoint__c;
                        endpoint = endpoint+ord.Guid__c;
                        string comCurrency=ord.Amount_Recieved_Currency__c;
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        if(!'REDBUS_COM'.equalsIgnoreCase(ord.business_unit__c)){
                            req = HttpRequestUtil.populateCMAPIHeaders(req,ord.Business_Unit__c);
                        }
                        if(!ord.business_unit__c.contains('REDBUS')){
                            system.debug('enetered contains if');
                            string[] strarray = ord.Business_Unit__c.split('_');
                            system.debug('<<'+strarray[0]);                          
                            if(strarray[0] != Null){
                                req.setHeader('Operator', strarray[0]);                                   
                            }   
                        }
                        
                        HttpResponse res = new HttpResponse();
                        req.setEndpoint(endpoint);
                        
                        if('REDBUS_COM'.equalsIgnoreCase(ord.business_unit__c)){
                            system.debug('--com---');
                            req.setHeader('Channel_Name', 'WEB_DIRECT');
                            req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                            req.setHeader('Content-Type', 'application/json');
                            req.setHeader('BusinessUnit', 'BUS');
                            req.setHeader('Country_Name','RDC');
                            req.setHeader('SelectedCurrency',comCurrency);
                            req.setHeader('Currency',comCurrency);
                        }
                        req.setMethod('GET');
                        system.debug('<<<req'+req);
                        res = http.send(req);
                        system.Debug('---res'+res);
                        System.debug(res.getBody());
                        if(res.getStatusCode() == 200){
                            if(isConnectedService){
                                map<string,object> tickDetails = (map<string,object>)JSON.deserializeUntyped(res.getBody());
                                List<Object> ticketsInfo = (List<Object>)tickDetails.get('ticketsInfo');
                                Map<String, Object> selectedTicket = null;
                                if (ticketsInfo != null && !ticketsInfo.isEmpty()) {
                                    for (Object ticketObj : ticketsInfo) {
                                        Map<String, Object> ticket = (Map<String, Object>)ticketObj;
                                        if (ticket.get('TicketNo') == ord.Order_Item_Reference_No__c) {
                                            selectedTicket = ticket;
                                            String tempString = JSON.serialize(selectedTicket);
                                            system.debug('::: tempString = '+tempString);
                                            HttpRequestWrappersUtil.priceBreakupResponse priceBreakup = new HttpRequestWrappersUtil.priceBreakupResponse();
                                            priceBreakup = (HttpRequestWrappersUtil.priceBreakupResponse)system.JSON.deserialize(tempString, HttpRequestWrappersUtil.priceBreakupResponse.class); 
                                            return priceBreakup;
                                        }
                                    }
                                }
                            }else{
                                HttpRequestWrappersUtil.priceBreakupResponse priceBreakup = new HttpRequestWrappersUtil.priceBreakupResponse();
                                priceBreakup = (HttpRequestWrappersUtil.priceBreakupResponse)system.JSON.deserialize(res.getbody(), HttpRequestWrappersUtil.priceBreakupResponse.class); 
                                return priceBreakup;
                            }
                        }
                        else {
                            System.debug(res.getBody());
                        }
                    }
                    else{
                        HttpRequestWrappersUtil.priceBreakupResponse priceBreakupResponse = new HttpRequestWrappersUtil.priceBreakupResponse();
                        priceBreakupResponse.errorMsg='Unable to fetch price details';    
                        return priceBreakupResponse;
                    }
                }
            }            
        }        
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }  
        return Null;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static HttpRequestWrappersUtil.busAssignmentResponse getBusAssignmentDetails( string ordId){
        HttpRequestWrappersUtil.busAssignmentResponse details = new HttpRequestWrappersUtil.busAssignmentResponse();      
        try
        {
            if(ordId != Null){
                Order_Items__c ord=[select id,Order_Item_Reference_No__c,Service_Provider_Id__c,Service_Provider_Name__c,ServiceID__c,Boarding_Time__c from Order_Items__c where id =: ordId ];
                if(ord!=null){
                    if(ord.Service_Provider_Id__c != Null &&ord.Service_Provider_Id__c !=''&& ord.ServiceID__c != null && ord.ServiceID__c !=''){
                        string doj = string.valueOf(ord.Boarding_Time__c);
                        List<string> dojList= doj.split(' ');

                        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Bus_Details'].Endpoint__c;
                        endpoint = endpoint + 'rbOpId='+ord.Service_Provider_Id__c+'&doj='+dojList[0]+'&serviceId='+ord.ServiceID__c;
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setHeader('Content-Type', 'application/json');
                        HttpResponse res = new HttpResponse();
                        req.setEndpoint(endpoint);
                        system.debug('<<endpoint'+endpoint);  
                        req.setMethod('GET');
                        system.debug('req'+req);
                        res = http.send(req);      
                        system.debug('endpoint'+req.getEndpoint());
                        system.debug('<<<res'+res);
                        system.debug('body'+res.getBody());
                        if(res.getStatusCode() == 200){
                            if(res.getBody() != NUll){
                                details = (HttpRequestWrappersUtil.busAssignmentResponse)system.JSON.deserialize(res.getBody(),HttpRequestWrappersUtil.busAssignmentResponse.class);
                                details.operator=ord.Service_Provider_Name__c;   
                            }                           
                            else {
                                System.debug(res.getBody());
                                details.showError = 'true';
                            }
                        }
                        else {
                            System.debug(res.getBody());
                            details.showError = 'true';
                        }
                        system.debug('<<details'+details);
                        return details;
                    }
                    else{
                        details.showError = 'true';
                        return details;
                    }
                }
            }            
        }        
        catch(Exception e)
        {
            details.showError ='true';
            System.debug('Error..'+e);            
        }  
        return details;        
    }
    
    @AuraEnabled(cacheable=true)
    public static  responseWrapperToreturn yourBusTracking(string ordId){
        set<string> apsrtcId = new Set<String>(System.label.APSRRTCCloseIds.split(','));
        Order_Items__c oI = [select Business_Unit__c,Inventory_Type__c,Amenities__c,Date_of_Boarding_Time__c,Transaction_Status__c,Order_Item_Reference_No__c,Service_Provider_Id__c,ServiceID__c FROM Order_Items__c where id=:ordId];  
        responseWrapperToreturn resWrapper = New responseWrapperToreturn();
        resWrapper.orderItem = oI;
        if(oI.Inventory_Type__c=='GOIBIBO' || oI.Inventory_Type__c=='MMT'){
            resWrapper.isMMTGITransaction=true;
            resWrapper.mmtGiServiceId = fetchYbTrackingLink(oI.Id);
        }
        return resWrapper;
    }

    //Method to return Yourbus Tracking Link
    @AuraEnabled(cacheable=true)
    public static string fetchYbTrackingLink(String transactionId){
        string serviceIdToReturn;
        if(String.isNotBlank(transactionId)){
            List<Order_Items__c> ordList = [SELECT Id,ServiceID__c,Route_Id__c,Corrected_Date_of_Journey__c,Service_Provider_Id__c FROM Order_Items__c WHERE Id=:transactionId AND Inventory_Type__c in ('MMT','GOIBIBO') LIMIT 1];
            if(ordList[0].ServiceID__c == ordList[0].Route_Id__c){
                serviceIdToReturn = ordList[0].ServiceID__c;
            }else{
                serviceIdToReturn =fetchGiMmtServiceId(ordList[0].Route_Id__c);
            }
        }
        return serviceIdToReturn;
    }

    //Method to fetch the service Id from omega by passing Route Id
    // CRM -1855
    @AuraEnabled(cacheable=true)
    public static string fetchGiMmtServiceId(String routeId){
        if(String.isNotBlank(routeId)){
            try{
                API_EndPoints__mdt APIMData2 = new API_EndPoints__mdt();
                APIMData2=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];  
                string GenericAPIEndpoint=APIMData2.Endpoint__c;
                API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='FetchServiceIdFromOmega'];
                string endpoint=APIMData.Endpoint__c+routeId;
                Map<String, String> headers = new Map<String, String>();
                list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                for(string o:headers.keyset()){
                    hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
                } 
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson); 
                string genericJson='{"action":"GET","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                System.debug('genericJson-->'+genericJson);

                Http http = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req = HttpRequestUtil.populateHeaders(req); 
                req.setMethod('POST');
                req.setEndpoint(GenericAPIEndpoint);
                req.setBody(genericJson);
                res = http.send(req);
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Fetch Service Id',String.valueOf(req.getEndpoint()),routeId,'--EndPoint--'+req.getEndpoint()+' -- Request Body --'+req.getBody(),String.valueOf(res+'Response Body = '+res.getBody()),'','');
                string responseValue=res.getBody();
                System.debug('res body--->'+res.getBody());
                giMMtresponseWrapper resWrapper = New giMMtresponseWrapper();
                resWrapper = (giMMtresponseWrapper)JSON.deserialize(responseValue, giMMtresponseWrapper.class);
                System.debug('::: resWrapper = '+resWrapper);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    resWrapper.isSuccess = true;
                    return resWrapper.ServiceId;
                }
                return null;
            }catch(Exception e){
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Fetch Service Id','',routeId,'','','',string.valueOf(e));
                System.debug('An exception occurred: ' + e.getMessage());
                return null;
            }
        }
        return null;
    }

    public class giMMtresponseWrapper
    {
        @AuraEnabled
        public String VendorId { get; set; }
        @AuraEnabled
        public String VRouteId { get; set; }
        @AuraEnabled
        public String TravelsName { get; set; }
        @AuraEnabled
        public Integer SourceId { get; set; }
        @AuraEnabled
        public String ServiceId { get; set; }
        @AuraEnabled
        public String RouteId { get; set; }
        @AuraEnabled
        public Integer DestinationId { get; set; }
        @AuraEnabled
        public Boolean isSuccess { get; set; }
    }

    public class responseWrapperToreturn{
        @AuraEnabled
        public Order_Items__c orderItem { get; set; }
        @AuraEnabled
        public boolean isMMTGITransaction { get; set; }
        @AuraEnabled
        public string mmtGiServiceId { get; set; }
    }
}