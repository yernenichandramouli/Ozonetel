/*
* Name           : projectBlinkCtrl
* Created Date   : 31 OCT 2023
* Created By     : VR Sudarshan 
* Purpose        : To Enhance customer experience by Empowering CRM advisor with readable logs to resolve customer issues on real time
* Test class     : projectBlinkCtrlTest
* Jira Id        : CRM-1545
*/
public class projectBlinkCtrl {
    
    @Auraenabled
    public static string createExceptionalRefundCase(string transactionId){
        finalResponseToReturn respToReturn = New finalResponseToReturn();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Project Blink API 3';
        
        if(String.isNotBlank(transactionId)){
            string countryCode;
            List<Order_Items__c> transactionData = [SELECT Id, Date_of_Issue_New__c, Business_Unit__c, Order_Item_Reference_No__c FROM Order_Items__c WHERE Id=:transactionId LIMIT 1];
            If(String.isNotBlank(transactionData[0].Business_Unit__c) && BusinessUnitMapping__c.getValues(transactionData[0].Business_Unit__c)!=null){
                countryCode = String.valueOf(BusinessUnitMapping__c.getValues(transactionData[0].Business_Unit__c).Country__c);
            }else{
                string customErrorMessage= 'Invalid business unit. Please contact administartor';
                return customErrorMessage;
            }
            User currentUser = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
            String userTimeZone = currentUser.TimeZoneSidKey;
            dateTime uTCstartTime = transactionData[0].Date_of_Issue_New__c.addMinutes(-30);
            dateTime uTCendTime = transactionData[0].Date_of_Issue_New__c.addMinutes(30);
            // Format the start and end times using the user's time zone
            String startTime = uTCstartTime.format('yyyy-MM-dd HH:mm:ss', userTimeZone);
            String endTime = uTCendTime.format('yyyy-MM-dd HH:mm:ss', userTimeZone);
            // String startTime = uTCstartTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            // String endTime = uTCendTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            string jsonCM='{"country": "'+countryCode+'","start":"'+startTime+'","end": "'+endTime+'","tin": "'+transactionData[0].Order_Item_Reference_No__c+'"}';
            
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type','application/json');
                req.setHeader('Accept','application/json');
                req.setHeader('API-Version','1');
                req.setMethod('POST');
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='projectBlink_API_3'].Endpoint__c);
                req.setBody(jsonCM);
                req.setTimeout(30000);     
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-Accept--'+req.getHeader('Accept')+'-Headers-API-Version--'+req.getHeader('API-Version')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string responseValue = res.getBody();
                System.debug('::: responseValue '+responseValue);
                // responseValue = '{"data": [ { "Status": "CREATED", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:54", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "TENTATIVE_SUCCESSFUL", "ItemType": "BUS", "Tin": "", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:04:55", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] }, { "Status": "CONFIRMED", "ItemType": "BUS", "Tin": "TSBM79163087", "OrderId": "13585250352338594", "OrderUUID": "d2adf2d40876f0064df6863b02010100", "OrderItemId": "13585250352347090", "ItemUUID": "d2adf6fa0876f0064df6863b02020100", "TimeOfEvent": "2023-10-24 14:09:10", "DateOfIssue": "2023-10-24 14:04:54", "DateOfJourney": "2023-10-25 05:00:00", "DepartureTime": "2023-10-25 11:00:00", "ArrivalTime": "2023-10-25 16:30:00", "PrimaryBoardingTime": "2023-10-25 05:00:00", "PrimaryDroppingPointTime": "2023-10-25 11:00:00", "BoardingTime": "2023-10-25 05:00:00", "DroppingTime": "2023-10-25 11:00:00", "ConfirmationTime": "2023-10-24 14:09:10", "Name": "deepti chaurasia", "Mobile": "ec79eff0d6aaba6765c54f2c2ea68daff47839b697937debec861e60", "EmailId": "529eed2b2fc11934ca0f2912340f88fc3ad12d1d253f827a497ace8f", "UserSelectedDate": "25-Oct-2023", "ServiceProviderName": "IntrCity SmartBus", "BusType": "Volvo Eicher A/C Seater / Sleeper (2+1) ", "SourceLocation": "Delhi", "SrcLocationName": "Delhi", "DestinationLocation": "Rishikesh", "DstLocationName": "Rishikesh", "DepartureLandmark": "Under New Flyover (Rishikesh)", "StartingLocation": "Delhi", "BoardingPoint": "R.K. Ashram Marg - IntrCity Lounge", "BoardingGridPoint": "RK Ashram", "BoardingPointLandmark": "Opp Metro Pillar No.9, R.K. Ashram Marg Metro Station Panchkuian Marg (Delhi)", "DroppingPoint": "Nepali Farm", "TotalOrderItems": 1, "SubItemsCount": 1, "TicketFare": 504, "BaseFare": 480, "ServiceTax": 24, "OpOfferValue": "", "Discount": 0, "TransactionCharge": 0, "RescheduleCharge": 0, "SeatCount": 1, "ReschedulingFor": "", "OldItemReferenceNo": "", "JourneyType": "ONWARD", "BusinessUnit": "REDBUS_IN", "SalesChannel": "RB:MOBILEWEB#droidapp", "PurchaseItemCurrency": "INR", "SeatName": [ "3E" ], "SeatType": [ "SEATER" ] } ]}';
                // finalResponseToReturn responseData = new finalResponseToReturn();
                // responseData=(finalResponseToReturn)JSON.deserialize(responseValue, finalResponseToReturn.class);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    return responseValue;
                }else{
                    string customErrorMessage= 'Received InValid response from API. Please contact administartor.';
                    return customErrorMessage;
                }
            }catch(Exception e){
                System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
                string customErrorMessage= 'Exception occured, Please contact administartor.';
                return customErrorMessage;
            }
        }
        string customErrorMessage= 'Invalid Transaction Id. Please contact administartor';
        return customErrorMessage;
    }
    
    @AuraEnabled
    public static string GetWhatsappStatus(string transactionId){
        
        WhatsUpResponseWrap watsRespWpr = new WhatsUpResponseWrap();
        if(String.isNotBlank(transactionId)){
            string countryCode;
            List<Order_Items__c> transactionData = [SELECT Id,Order_Item_Reference_No__c,Mobile__c,Date_of_Issue_New__c,Corrected_Date_of_Journey__c FROM Order_Items__c WHERE Id=:transactionId LIMIT 1];
            If(String.isNotBlank(transactionData[0].Mobile__c) && transactionData[0].Date_of_Issue_New__c!=null){
                string dtofIssue =transactionData[0].Date_of_Issue_New__c.format('yyyy-MM-dd','UTC');
                
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type','application/json');
                req.setHeader('Country_Name','IND');
                req.setHeader('BusinessUnit','BUS');
                req.setHeader('Channel_Name','MOBILE_WEB');
                req.setHeader('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
                req.setTimeout(120000);     
                req.setMethod('GET');
                if(string.isNotBlank(transactionData[0].Order_Item_Reference_No__c)){
                    req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GetWhatsappStatus'].Endpoint__c+transactionData[0].Mobile__c+'&dateofsms='+dtofIssue+'&identifier='+transactionData[0].Order_Item_Reference_No__c);
                }else {
                    req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='GetWhatsappStatus'].Endpoint__c+transactionData[0].Mobile__c+'&dateofsms='+dtofIssue);
                }
                res = http.send(req);
                string resBody=res.getBody();
                
                string jsonHeaders='-Headers-Content-Type--'+req.getHeader('Content-Type');
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetWhatsappStatus',String.valueOf(req.getEndpoint()),transactionData[0].Order_Item_Reference_No__c,'',resBody,jsonHeaders,'');
                // '{"isSuccess":true,"data":[{"sentAt":"09/11/2023 4:58:04 PM","deliveredAt":"09/11/2023 4:58:04 PM","readAt":"","messageTag":"MTicket_WHATSAPP","requestedat":"09/11/2023 4:57:59 PM"}],"error":""}';
                
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(resBody)){
                    //watsRespWpr = (WhatsUpResponseWrap)JSON.deserialize(resBody,WhatsUpResponseWrap.class);
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resBody);
                    string errorVal=string.valueof(resMap.get('error'));
                    if(string.isNotBlank(errorVal)){
                        String customErrorMessage ='No records found'.equalsIgnoreCase(errorVal)?errorVal:'Received InValid Data from API. Please contact administrator.';
                        return customErrorMessage;
                    }else{
                        return resBody;
                    }
                }else{
                    string customErrorMessage= 'Received InValid response from API. Please contact administartor.';
                    return customErrorMessage;
                }
            }else{
                string customErrorMessage= 'Invalid Mobile No or DOJ. Please contact administartor.';
                return customErrorMessage;
            }
        }
        
        string customErrorMessage= 'Invalid Transaction Id. Please contact administartor';
        return customErrorMessage;
    }
    
    @AuraEnabled(cacheable=true)
    public static string GetUserMobileno(string emailAddress){
        
        if(String.isNotBlank(emailAddress)){
            string countryCode;
            If(String.isNotBlank(emailAddress)){
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='GetUserMobileno'];
                
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                
                for(string o:headers.keyset()){               
                    System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                    hlist.add(new HeadersWrapper(o,headers.get(o))); 
                }
                
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);
                
                
                string endPoint=APIMData.Endpoint__c+emailAddress;
                
                string jsonBody='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                
                system.debug('jsonBody-->>'+jsonBody);
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_Entangle'];
                system.debug('endpoint-->>'+APIMData.Endpoint__c);
                HTTP h = new HTTP();
                HTTPRequest req= new  HTTPRequest();
                HTTPResponse resp=new HTTPResponse();
                req = HttpRequestUtil.populateHeaders(req);
                req.setMethod('POST');
                req.setBody(jsonBody);
                req.setEndpoint(APIMData.Endpoint__c);
                system.debug('reqbdy-->>'+req.getbody());
                resp=h.send(req);
                system.debug('--respStatus-->>'+resp);
                system.debug('--resbdy-->>'+resp.getBody());
                string resBody=resp.getBody();
                
                string jsonHeaders='-Headers-Content-Type--'+req.getHeader('Content-Type');
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('GetUserMobileno',String.valueOf(req.getEndpoint()),'','',resBody,jsonHeaders,'');
                
                string  respMbleNo ='';  
                if(resp.getStatus()=='OK' && resp.getStatusCode()==200 && String.isNotBlank(resBody)){
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
                    respMbleNo=string.valueof(resMap.get('mobile'));
                    
                    respMbleNo=respMbleNo!=null ? 'Mobile No : -  '+respMbleNo.right(10):'Please Check Email Id';
                    return respMbleNo;
                }else{
                    string customErrorMessage= 'Received InValid response from API. Please contact administartor.';
                    return customErrorMessage;
                }
            }else{
                string customErrorMessage= 'Invalid emailAddress. Please contact administartor';
                return customErrorMessage;
            }
        }
        
        string customErrorMessage= 'Invalid emailAddress. Please contact administartor';
        return customErrorMessage;
    }
    
    //TICKET cANCELLATION
    @Auraenabled
    public static string getTicketCancellationEvents(string transactionId){
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Blink Ticket Cancellation';
        
        if(String.isNotBlank(transactionId)){
            string countryCode;
            List<Order_Items__c> transactionData = [SELECT Id, Date_of_Issue_New__c, Business_Unit__c, Order_Item_Reference_No__c FROM Order_Items__c WHERE Id=:transactionId LIMIT 1];
            If(String.isNotBlank(transactionData[0].Order_Item_Reference_No__c) && String.isNotBlank(transactionData[0].Business_Unit__c) && BusinessUnitMapping__c.getValues(transactionData[0].Business_Unit__c)!=null){
                countryCode = String.valueOf(BusinessUnitMapping__c.getValues(transactionData[0].Business_Unit__c).Country__c);
            }else{
                string customErrorMessage= 'Invalid business unit or Tin. Please contact administartor';
                return customErrorMessage;
            }
            
            dateTime currTime = System.now();
            dateTime uTCstartTime =currTime.addDays(-7);
            dateTime uTCendTime = currTime;
            String startTime = uTCstartTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            String endTime = uTCendTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            
            string tin=transactionData[0].Order_Item_Reference_No__c;
            string jsonCM='{"country": "'+countryCode+'","start":"'+startTime+'","end": "'+endTime+'","tin": "'+tin+'"}';
            system.debug('>>>jsonCM>>>'+jsonCM);
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type','application/json');
                req.setHeader('Accept','application/json');
                req.setHeader('API-Version','1');
                req.setMethod('POST');
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Blink_Ticket_Cancellation'].Endpoint__c);
                req.setBody(jsonCM);
                req.setTimeout(30000);     
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-Accept--'+req.getHeader('Accept')+'-Headers-API-Version--'+req.getHeader('API-Version')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string responseValue = res.getBody();
                System.debug('::: responseValue '+responseValue);
                
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    return responseValue;
                }else{
                    return responseValue;
                }
            }catch(Exception e){
                System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
                string customErrorMessage= 'Exception occured, Please contact administartor.';
                return customErrorMessage;
            }
        }
        string customErrorMessage= 'Invalid Transaction Id. Please contact administartor';
        return customErrorMessage;
    }
    
    //tc END
    
    //offer 
    @Auraenabled
    public static string getOfferEvents(string country,string phoneNo,string emailId){
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Blink Offer';
        
        
        if(String.isNotBlank(emailId) ||  String.isNotBlank(phoneNo)){
            string countryCode;
            string busUnit;
            if(country=='IND' && string.isNotBlank(phoneNo)){
                busUnit='REDBUS_IN';
                phoneNo='91'+phoneNo;
            }else if(country=='PER' && string.isNotBlank(phoneNo)){
                busUnit='REDBUS_PE';
                phoneNo='60'+phoneNo;
            }else if(country=='COL' && string.isNotBlank(phoneNo)){
                busUnit='REDBUS_CO';
                phoneNo='57'+phoneNo;
            }else if(country=='IDN' && string.isNotBlank(phoneNo)){
                busUnit='REDBUS_ID';
                phoneNo='62'+phoneNo;
            }else if(country=='MYS' && string.isNotBlank(phoneNo)){
                busUnit='REDBUS_MY';
                phoneNo='60'+phoneNo;
            }else if(country=='SGP'&& string.isNotBlank(phoneNo)){
                busUnit='REDBUS_SG';
                phoneNo='65'+phoneNo;
                
            }
            countryCode = country;
            //String.valueOf(BusinessUnitMapping__c.getValues(busUnit).Country__c);
            
            dateTime currTime = System.now();
            dateTime uTCstartTime =currTime.addDays(-7);
            dateTime uTCendTime = currTime;
            
            String startTime = uTCstartTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            String endTime = uTCendTime.format('YYYY-MM-dd HH:mm:ss', 'IST');
            
            
            string jsonCM='{"country": "'+countryCode+'","start":"'+startTime+'","end": "'+endTime+'","phone": "'+phoneNo+'","email": "'+emailId+'"}';
            system.debug('>>>jsonCM>>>'+jsonCM);
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type','application/json');
                req.setHeader('Accept','application/json');
                req.setHeader('API-Version','1');
                req.setMethod('POST');
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Blink_offer'].Endpoint__c);
                req.setBody(jsonCM);
                req.setTimeout(30000);     
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-Accept--'+req.getHeader('Accept')+'-Headers-API-Version--'+req.getHeader('API-Version')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string responseValue = res.getBody();
                System.debug('>>>::: responseValue '+responseValue);
                
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    return responseValue;
                }else{
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseValue);
                    
                    String status = (String) responseMap.get('status');
                    if(responseMap.containsKey('error')){
                        String error = (String) responseMap.get('error');
                        return error;
                    }
                    
                    return status;
                }
            }catch(Exception e){
                System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
                string customErrorMessage= 'Exception occured, Please contact administartor.';
                return customErrorMessage;
            }
        }
        string customErrorMessage= 'Invalid EmailId and Phone. Please contact administartor';
        return customErrorMessage;
    }
    
    //offer end
    
    public class responseReult{
        @AuraEnabled
        public string Status { get; set; }
        @AuraEnabled
        public string ItemType { get; set; }
        @AuraEnabled
        public string Tin { get; set; }
        @AuraEnabled
        public string OrderId { get; set; }
        @AuraEnabled
        public string OrderUUID { get; set; }
        @AuraEnabled
        public string OrderItemId { get; set; }
        @AuraEnabled
        public string ItemUUID { get; set; }
        @AuraEnabled
        public string TimeOfEvent { get; set; }
        @AuraEnabled
        public string DateOfIssue { get; set; }
        @AuraEnabled
        public string DateOfJourney { get; set; }
        @AuraEnabled
        public string DepartureTime { get; set; }
        @AuraEnabled
        public string ArrivalTime { get; set; }
        @AuraEnabled
        public string PrimaryBoardingTime { get; set; }
        @AuraEnabled
        public string PrimaryDroppingPointTime { get; set; }
        @AuraEnabled
        public string BoardingTime { get; set; }
        @AuraEnabled
        public string DroppingTime { get; set; }
        @AuraEnabled
        public string ConfirmationTime { get; set; }
        @AuraEnabled
        public string Name { get; set; }
        @AuraEnabled
        public string Mobile { get; set; }
        @AuraEnabled
        public string EmailId { get; set; }
        @AuraEnabled
        public string UserSelectedDate { get; set; }
        @AuraEnabled
        public string ServiceProviderName { get; set; }
        @AuraEnabled
        public string BusType { get; set; }
        @AuraEnabled
        public string SourceLocation { get; set; }
        @AuraEnabled
        public string SrcLocationName { get; set; }
        @AuraEnabled
        public string DestinationLocation { get; set; }
        @AuraEnabled
        public string DstLocationName { get; set; }
        @AuraEnabled
        public string DepartureLandmark { get; set; }
        @AuraEnabled
        public string StartingLocation { get; set; }
        @AuraEnabled
        public string BoardingPoint { get; set; }
        @AuraEnabled
        public string BoardingGridPoint { get; set; }
        @AuraEnabled
        public string BoardingPointLandmark { get; set; }
        @AuraEnabled
        public string DroppingPoint { get; set; }
        @AuraEnabled
        public Integer TotalOrderItems { get; set; }
        @AuraEnabled
        public Integer SubItemsCount { get; set; }
        @AuraEnabled
        public Integer TicketFare { get; set; }
        @AuraEnabled
        public Integer BaseFare { get; set; }
        @AuraEnabled
        public Integer ServiceTax { get; set; }
        @AuraEnabled
        public string OpOfferValue { get; set; }
        @AuraEnabled
        public double Discount { get; set; }
        @AuraEnabled
        public Integer TransactionCharge { get; set; }
        @AuraEnabled
        public Integer RescheduleCharge { get; set; }
        @AuraEnabled
        public Integer SeatCount { get; set; }
        @AuraEnabled
        public string ReschedulingFor { get; set; }
        @AuraEnabled
        public string OldItemReferenceNo { get; set; }
        @AuraEnabled
        public string JourneyType { get; set; }
        @AuraEnabled
        public string BusinessUnit { get; set; }
        @AuraEnabled
        public string SalesChannel { get; set; }
        @AuraEnabled
        public string PurchaseItemCurrency { get; set; }
        @AuraEnabled
        public List<string> SeatName { get; set; }
        @AuraEnabled
        public List<string> SeatType { get; set; }
    }
    
    public class finalResponseToReturn{
        @AuraEnabled
        public List<responseReult> data { get; set; }
    }
    
    public class HeadersWrapper
    {       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
    
    public class Datum
    {
        @AuraEnabled
        public string sentAt { get; set; }
        @AuraEnabled
        public string deliveredAt { get; set; }
        @AuraEnabled
        public string readAt { get; set; }
        @AuraEnabled
        public string messageTag { get; set; }
        @AuraEnabled
        public string requestedat { get; set; }
    }
    
    public class WhatsUpResponseWrap
    {
        @AuraEnabled
        public boolean isSuccess { get; set; }
        @AuraEnabled
        public List<Datum> data { get; set; }
        public string error { get; set; }
    }
    
}