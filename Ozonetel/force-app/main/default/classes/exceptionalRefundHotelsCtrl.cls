public class exceptionalRefundHotelsCtrl {

    @AuraEnabled
    public static maxRefundApiResponseWrap getMaxRefundAmount(string transactionId) {
        System.debug(':: transactionId = '+transactionId);
        maxRefundApiResponseWrap respWrap = new maxRefundApiResponseWrap();
        Order_Items__c orit = null;
        try {
            orit = [SELECT Id, Order_Uuid__c, Guid__c FROM Order_Items__c WHERE Id=:transactionId LIMIT 1];
        } catch (QueryException e) {
            orit = null;
        }

        if(orit!=null){
            string genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c; 
			Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            string endPoint  = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='hotelsMaxRefundApi'].Endpoint__c;
            endPoint = endPoint+orit.Order_Uuid__c+'/maxRefundable?itemUuid='+orit.Guid__c;
            System.debug(':: endPoint = '+endPoint);
            list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            for(string o:headers.keyset()){
                hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson); 
            string jsonCM='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            req = HttpRequestUtil.populateHeaders(req);           
            req.setEndpoint(genericEndpoint);
            req.setBody(jsonCM);
            req.setMethod('POST');

            try{
                res = http.send(req);                      
                string responseValue = res.getBody();
				System.debug(':: responseValue = '+responseValue);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    // Deserialize the JSON string into an instance of Root
                    respWrap = (maxRefundApiResponseWrap)JSON.deserialize(responseValue, maxRefundApiResponseWrap.class);
                }else{
                    map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                }
            }catch(Exception e){
                System.debug('Exception has occured at line no: '+e.getLineNumber()+' with an error message of '+e.getMessage());
            }
        }else{
            System.debug('No activity found with the given ID: ' + transactionId);
        }
        System.debug('respWrap to return: ' + respWrap);
        return respWrap;
    }

    @AuraEnabled
    public static boolean submitForApproval(string orItemId, Integer maxRefundAmount, Integer amountToRefund, string parentCase, string refundReason, string refundDescp) {
        boolean isSuccessful=false;
        Order_Items__c orIt=new Order_Items__c();
        orIt = [select id, id__c,status__c,Payment_Currency__c, Total_Fare_Value__c,Boarding_Time__c,Umbrella_TIN__c,Connected_Items__c,Corrected_Date_of_Journey__c,Total_Fare_Currency__c,Route_Id__c,Service_Provider_Id__c,Source__c,Destination__c,Mobile__c,OrderUuid__c,Service_Provider_Reference_No__c,Amount_Recieved_Currency__c,Order_Id__c,Seat_No__c,Guid__c,Order_Name__r.Guid__c,Business_Unit__c,Transaction_Status__c,Order_Item_Reference_No__c,Item_Type__c, Email__c, Email_Copy__c,(SELECT Id,Refund_Reason__c from Refund_Order_Items__r) from Order_Items__c where id=:orItemId limit 1];
        string tinNumber = orIt.Order_Item_Reference_No__c;
        boolean refundCaseExists;
        List<user> userInfo=[select id,Team__c from user where id=:userinfo.getuserid()];

        if(string.isBlank(userInfo[0].Team__c)){
            throw new AuraHandledException('Team name is not configured at user level');
        }

        if(amountToRefund<=0 || (amountToRefund>maxRefundAmount)){
            throw new AuraHandledException('Refund Amount should Greater than 0 and less than or equal to Max Refundable Amount..!!');
        }

        if(String.isBlank(refundDescp) || String.isBlank(parentCase)){
            throw new AuraHandledException('Please provide the Refund Description And Parent Case Number');
        }

        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));

        List<Case> listCases = new List<Case>();
        listCases =[Select id,Transaction_ID__c,Trip_Id_ct__c,is_ZQP__c,Refund_Type__c,Refund_Amount__c from Case where caseNumber=:parentCase];

        if(listCases.isEmpty() || (String.isNotBlank(listCases[0].Transaction_ID__c) && listCases[0].Transaction_ID__c!=orIt.id) || (String.isNotBlank(listCases[0].Trip_Id_ct__c) && listCases[0].Trip_Id_ct__c!=orIt.Order_Id__c)){
            throw new AuraHandledException('Please provide the valid Case Number');
        }  

        list <case> listExpRefndCase = [Select id, status, createddate,Refund_status__c, Exceptional_Refund_Count__c, Transaction_ID__c, Trip_Id_ct__c from Case where Issue_Type__c = 'Exceptional Refund' AND Refund_status__c='Exceptional Refund Approved' and TIN_No__c=:tinNumber ORDER BY createddate DESC];
        
        Case cs = new Case();
        cs.Issue_Type__c = 'Exceptional Refund';   
        if (listExpRefndCase.size()==0) {
            cs.Exceptional_Refund_Count__c =1;
        } else if(!listExpRefndCase.isEmpty() && listExpRefndCase.size()==1 && listExpRefndCase[0].Exceptional_Refund_Count__c==null){
            cs.Exceptional_Refund_Count__c =2;
        }else if(!listExpRefndCase.isEmpty() && listExpRefndCase[0].Exceptional_Refund_Count__c!=null) {
            cs.Exceptional_Refund_Count__c =listExpRefndCase[0].Exceptional_Refund_Count__c + 1;
        }
        cs.Issue_Sub_Category__c = refundReason;
        cs.Trip_Id_ct__c = orIt.Order_Id__c;
        cs.TIN_No__c = orIt.Order_Item_Reference_No__c;
        cs.Refund_Amount__c = amountToRefund;
        listCases[0].Refund_Amount__c = amountToRefund;
        cs.Description =refundDescp;
        cs.Transaction_ID__c = orIt.id;
        cs.status= 'Open';
        cs.Booking_Email_ID__c = orIt.Email__c;
        cs.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs.Origin='InBound Call';
        cs.Subject = 'Exceptional Refund- '+refundReason;
        // cs.New_Tin__c=ZQPtin;
        cs.ParentId = listCases[0].id;
        cs.Business_Unit_ct__c = orIt.Business_Unit__c;
        cs.User_Level_Team__c = userInfo[0].Team__c;
        if(cs.Issue_Sub_Category__c=='Instant refund - Collectible from BO' && instantRefundBoIds.contains(orIt.Service_Provider_Id__c)){
            cs.Refund_Type__c='Instant resolution with refund';
            listCases[0].Refund_Type__c='Instant resolution with refund';
        }else if(instantRefundBoIds.contains(orIt.Service_Provider_Id__c) && cs.Issue_Sub_Category__c=='Instant refund - customer delight'){
            cs.Refund_Type__c='Instant resolution - redBus Delight';
            listCases[0].Refund_Type__c='Instant resolution - redBus Delight';
        }
        cs.country__c='India';
        cs.Business_Type__c='Hotel';
        cs.Price_Paid_Currency_ctp__c = orIt.Payment_Currency__c;
        try{
            insert cs;            
            update listCases[0];
            isSuccessful=true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return isSuccessful;
    }

    // Exceptional Refund API
    public static boolean approveExceptionalRefund(Id caseId) {
        Boolean isSuccess = false;
        case cs = null;
        try {
            cs = [SELECT Id, Transaction_ID__r.Order_Uuid__c, Transaction_ID__r.Guid__c,Refund_Amount__c,Price_Paid_Currency_ctp__c FROM Case WHERE Id=:caseId LIMIT 1];
        } catch (QueryException e) {
            cs = null;
        }

        if(cs!=null){
            string genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c; 
			Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            string endPoint  = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='hotelsMaxRefundApi'].Endpoint__c;
            endPoint = endPoint+cs.Transaction_ID__r.Order_Uuid__c+'/exceptionalrefund';
            System.debug(':: endPoint = '+endPoint);
            list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            for(string o:headers.keyset()){
                hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson); 
            // JsBody
            string agentName = '('+UserInfo.getUserName()+')';
            string jsBody='{"refundedBy":"'+agentName+'","refund":{"currencyType":"'+cs.Price_Paid_Currency_ctp__c+'","amount":'+cs.Refund_Amount__c+'},"reason":"Exceptional Refund","orderItemUuid":"'+cs.Transaction_ID__r.Guid__c+'","channel":"SFA"}';
            jsBody=JSON.serialize(jsBody);
            System.debug(':: jsBody = '+jsBody);
            string jsonCM='{"action":"POST","body":'+jsBody+',"endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            req = HttpRequestUtil.populateHeaders(req);           
            req.setEndpoint(genericEndpoint);
            req.setBody(jsonCM);
            req.setMethod('POST');

            try{
                res = http.send(req);                      
                string responseValue = res.getBody();
                // DBLog_Summary__c dbl = new DBLog_Summary__c();
                // dbl.Type__c='Hotels ExceptionalRefund';   
                // dbl.Request_Data__c = string.valueOf(req.getBody())+jsonCM;
                // dbl.Response_Received__c = responseValue;
                // // insert dbl;
				System.debug(':: responseValue = '+responseValue);
                map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    If(IsCan.containsKey('status') && string.valueof(IsCan.get('status'))=='SUCCESS'){
                        isSuccess=true;
                    }
                }
            }catch(Exception e){
                System.debug('Exception has occured at line no: '+e.getLineNumber()+' with an error message of '+e.getMessage());
            }
        }else{
            System.debug('No activity found with the given ID: ' + caseId);
        }
        return isSuccess;
    }

    //Start MaxRefundable Wrapper
    public class Data
    {
        @AuraEnabled
        public Integer amount { get; set; }
        @AuraEnabled
        public Integer assurance { get; set; }
        @AuraEnabled
        public string currencyType { get; set; }
        @AuraEnabled
        public Integer insurance { get; set; }
    }

    public class maxRefundApiResponseWrap
    {
        @AuraEnabled
        public Data data { get; set; }
        @AuraEnabled
        public List<object> errors { get; set; }
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public string errorMessage { get; set; }
        @AuraEnabled
        public Boolean hasErrorOccured { get; set; }
        @AuraEnabled
        public string error_message { get; set; }
    }
    // End MaxRefundable Wrapper
    // Start ExceptionalRefund Wrapper
    public class Refund
    {
        public Integer amount { get; set; }
        public string currencyType { get; set; }
    }

    public class exceptionalRefundWrapper
    {
        public string orderItemUuid { get; set; }
        public string refundedBy { get; set; }
        public string channel { get; set; }
        public string reason { get; set; }
        public Refund refund { get; set; }
    }
    // End ExceptionalRefund Wrapper
}