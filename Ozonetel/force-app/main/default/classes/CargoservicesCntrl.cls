public inherited sharing class CargoservicesCntrl {
    @AuraEnabled(Cacheable = true)
    public static list<Activities__c> getActivites(String strTrackingNum,string streMailid,string strMobileNo) {
        
        if (String.isNotBlank(strTrackingNum)) {
            strTrackingNum =strTrackingNum;
            // '%' + strTrackingNum + '%';
        }
        
        if (String.isNotBlank(streMailid)) {
            streMailid = streMailid;
        }
        
        if (String.isNotBlank(strMobileNo)) {
            strMobileNo =  strMobileNo;
        }
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+strTrackingNum+'---'+streMailid+'---'+strMobileNo);
        Id CargorecTypeId = Schema.SObjectType.Activities__c.getRecordTypeInfosByName().get('Cargo').getRecordTypeId(); 
        list<Activities__c> lstAccs = [select id,Voucher_Id__c,Booking_User_Email__c,customer_Email_id__c,Booking_User_Mobile__c,Customer_Mobile_No__c,Transaction_Status__c,Order_Id__c,Activity_Type__c from Activities__c WHERE recordtypeid=:CargorecTypeId and ((Voucher_Id__c=:strTrackingNum or Order_Id__c=:strTrackingNum) or (Booking_User_Mobile__c=:strMobileNo or Customer_Mobile_No__c=:strMobileNo) or (Booking_User_Email__c=:streMailid or customer_Email_id__c=:streMailid))];
        if(lstAccs.isEmpty()) {
            throw new AuraHandledException('No Record Found..Please try with different filter search');
        }
        return lstAccs; 
    }
    
    
    @AuraEnabled
    public static string GetActivityDetails(string ItemId){
        list<Activities__c> lstAccs = [select id,Activity_uuid__c,First_Mile_Uuid__c from Activities__c WHERE id=:ItemId];
        string firstMileUuid='';
        string cargoUuid;
        string respUuids;
        if(!lstAccs.isEmpty()){
            firstMileUuid= lstAccs[0].First_Mile_Uuid__c;
            cargoUuid = lstAccs[0].Activity_uuid__c;
            respUuids='firstMileUuid-'+firstMileUuid+'/'+'cargoUuid-'+cargoUuid;
            system.debug('>>respUuids>>'+respUuids);
            return respUuids;
        }
        return 'No Cargo is found';
        
    }
    
    // cargo extran details with reciever , sender , bp , dp 
    @AuraEnabled
    public static string GetAdditionalDetails(string ItemId){
        list<Activities__c> lstAccs = [select id,Additional_Details__c from Activities__c WHERE id=:ItemId];
                
     if(!lstAccs.isEmpty() && string.isNotBlank(lstAccs[0].Additional_Details__c)){
        string jsonString =lstAccs[0].Additional_Details__c;
        //'{'+lstAccs[0].Additional_Details__c+'}';
        return jsonString;

    }
        return 'No Additional Details found';
        
    }
    
      @AuraEnabled
    public static string GetfirstAdditionalDetails(string ItemId){
        list<Activities__c> lstAccs = [select id,First_Additional_Details__c from Activities__c WHERE id=:ItemId];
                
     if(!lstAccs.isEmpty() && string.isNotBlank(lstAccs[0].First_Additional_Details__c)){
        string jsonString =lstAccs[0].First_Additional_Details__c;
        //'{'+lstAccs[0].Additional_Details__c+'}';
        return jsonString;

    }
        return 'No First Additional Details found';
        
    }
    //Cargo tracking start
    @AuraEnabled
    public static string UpdateTrackingDetails(string ItemId,string tracStageType,string tracStage,string tracStageStatus,string tracReason,string tracDelStatus,string tracStageDate,string tracAgentName,string tracPhoneNo,string tracComments){
        system.debug('--1-'+tracStageType+'--2-'+tracStage+'--3-'+tracStageStatus+'--4-'+tracReason+'--5-'+tracDelStatus+'--6-'+tracStageDate+'--7-'+tracAgentName+'--8--'+tracPhoneNo+'--9-'+tracComments);
        HttpRequestWrappersUtil.CargTrackingRequestWrapperDetails  cargoTrackingReq = new HttpRequestWrappersUtil.CargTrackingRequestWrapperDetails();
        
        HttpRequestWrappersUtil.ExtraDetails  extrDtls= new HttpRequestWrappersUtil.ExtraDetails();
        
        list<HttpRequestWrappersUtil.TrackingInfo> lstTrckngInfo= new list<HttpRequestWrappersUtil.TrackingInfo>();
        
        HttpRequestWrappersUtil.FirstMileDelivery  firstMilDlvry = new HttpRequestWrappersUtil.FirstMileDelivery();
        
        HttpRequestWrappersUtil.LastMileDelivery  lastMilDlvry = new HttpRequestWrappersUtil.LastMileDelivery();
        
        
        list<Activities__c> lstAccs = [select id,Activity_uuid__c,Business_Unit__c,First_Mile_Uuid__c,Cargo_Tracking_status__c,FirstMile_Tracking_Status__c,OrderUuid__c,Order_Id__c,Activity_Name__c,Transaction_Status__c,Activity_Type__c from Activities__c where id=:ItemId];
        try{
            if(!lstAccs.isEmpty()){
                
                string BusUnit=lstAccs[0].Business_Unit__c;
                
                // Get the current date and time
                DateTime now = DateTime.now();
                // Convert to Unix timestamp (epoch)
                integer epochTimestamp = integer.valueof(now.getTime() / 1000); // Convert milliseconds to seconds
                // Print or use the epoch timestamp as needed
                System.debug('Epoch Timestamp: ' + epochTimestamp);

                list<CargoStageHeader__mdt> cargoStageHdrData = [SELECT Id,Stage__c,StageHeader__c,Stage_id__c,DeveloperName FROM CargoStageHeader__mdt];
                Map<String, CargoStageHeader__mdt> stageHeaderMap = new Map<String, CargoStageHeader__mdt>();
                
                for(CargoStageHeader__mdt MapstageHeader : cargoStageHdrData) {
                    stageHeaderMap.put(MapstageHeader.Stage__c, MapstageHeader);
                }
                
                HttpRequestWrappersUtil.TrackingInfo  trckngInfo= new HttpRequestWrappersUtil.TrackingInfo();
                HttpRequestWrappersUtil.ExtraInfo  extrInf = new  HttpRequestWrappersUtil.ExtraInfo();
                
                List<String> extraInfoList = new List<String>();

                if(string.isNotBlank(tracAgentName)){
                    extraInfoList.add('Nombre del agente: ' +' '+ tracAgentName.capitalize());
                   trckngInfo.extraInfo = extraInfoList;
                }
                
                if(string.isNotBlank(tracPhoneNo)){
                   extraInfoList.add('Número de agente: ' +' '+tracPhoneNo);
                  trckngInfo.extraInfo = extraInfoList;
                }
                
                trckngInfo.stage=tracStage;
                trckngInfo.stageType=tracStageType;
                if(stageHeaderMap.containskey(tracReason)){
                    trckngInfo.stageHeader = stageHeaderMap.get(tracReason).StageHeader__c;
                    trckngInfo.stageId = integer.valueof(stageHeaderMap.get(tracReason).Stage_id__c);
                }
                trckngInfo.status=tracStageStatus;
                trckngInfo.reason=tracReason;  
                trckngInfo.updatedTime=epochTimestamp;
                trckngInfo.deliveryStatus=tracDelStatus;
                trckngInfo.stageDate =tracStageDate;
                trckngInfo.comments=tracComments;
                lstTrckngInfo.add(trckngInfo);
                
                firstMilDlvry.serviceProviderName='1st servcdtls';
                
                lastMilDlvry.serviceProviderName='2nd srvcdtls';
                
                extrDtls.trackingInfo=lstTrckngInfo;
                //extrDtls.firstMileDelivery=firstMilDlvry;
                // extrDtls.lastMileDelivery=lastMilDlvry;
                
                
                cargoTrackingReq.updateType ='append';
                cargoTrackingReq.extraDetails =extrDtls;
                
                system.debug('>>>>cargoRqst>>'+json.serialize(cargoTrackingReq));
                
                string jsonBody =json.serialize(json.serialize(cargoTrackingReq));
                
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_V1_Entangle'];
                String endPoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CargoTrackingUpdateAPI'].Endpoint__c;
                
                /*if(tracStageType=='CARGO'){
endPoint = endPoint+lstAccs[0].Activity_uuid__c;
}else if(tracStageType=='FIRST_MILE'){
endPoint = endPoint+lstAccs[0].First_Mile_Uuid__c;
}*/
                
                endPoint = endPoint+lstAccs[0].Activity_uuid__c;
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                
                for(string o:headers.keyset()){               
                    System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                    hlist.add(new HeadersWrapper(o,headers.get(o))); 
                }
                
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);           
                
                string genericJsonBody='{"action":"PATCH","body":'+jsonBody+',"endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                
                HTTP h = new HTTP();
                //HTTPRequest req= new  HTTPRequest();
                HTTPResponse resp=new HTTPResponse();
                HttpRequest req =HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),BusUnit,'');
                req.setMethod('POST');
                req.setBody(genericJsonBody);
                req.setEndpoint(APIMData.Endpoint__c);
                
                resp=h.send(req);
                string responseValue =resp.getBody();
                
                string jsonHeaders ='-endpoint--'+APIMData.Endpoint__c+'-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit')+'--SelectedCurrency--'+req.getHeader('SelectedCurrency')+'--Currency-'+req.getHeader('Currency');
                system.debug('>>>responseValue>>>'+responseValue);
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo Tracking Update',endPoint,lstAccs[0].Order_Id__c,genericJsonBody,responseValue,jsonHeaders,'');
                if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && responseValue!=null && string.isNotBlank(responseValue))
                {
                    //{"error_code":2,"error_message":"Invalid Order Item Uuid","status":"ERROR"}
                    map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(responseValue);
                    string respError=string.Valueof(resObj.get('error_message'));
                    if(string.isNotBlank(respError)){
                        return 'Received InValid response from API. Please contact administartor';
                    }else{
                        string respStatus=string.Valueof(resObj.get('status'));
                        system.debug('>>>respStatus>>>'+respStatus);
                        Map<String, Object> dataMap = (Map<String, Object>)resObj.get('data');
                        Map<String, Object> extraDetailsMap = (Map<String, Object>)dataMap.get('extraDetails');
                        
                        list<object>  trackingInfoObj= (List<Object>)extraDetailsMap.get('trackingInfo');
                        system.debug('>>trackingInfo'+trackingInfoObj);
                        
                        string respTrackingInfoDetails = string.Valueof(extraDetailsMap);
                        system.debug('>>>respTrackingInfoDetails>>>'+respTrackingInfoDetails);
                        if(respStatus=='SUCCESS'){
                            
                            if(tracStageType=='CARGO'){
                                respTrackingInfoDetails = respTrackingInfoDetails.replaceAll('\\.\\.\\.', '');
                                lstAccs[0].Cargo_Tracking_status__c=lstAccs[0].Cargo_Tracking_status__c+respTrackingInfoDetails;
                            }else if(tracStageType=='FIRST_MILE'){
                                lstAccs[0].FirstMile_Tracking_Status__c=lstAccs[0].FirstMile_Tracking_Status__c+respTrackingInfoDetails;
                            }
                            update lstAccs;
                            return 'Tracking Updated Successfully';
                        }else{
                            return 'Tracking Updated Failed.Received InValid respons from api';
                        } 
                    }       
                }else {
                    DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo Tracking Update',endPoint,lstAccs[0].Order_Id__c,genericJsonBody,responseValue,jsonHeaders,'');
                    return 'Received InValid response from API. Please contact administartor';
                }
            }
        } catch(Exception e){
            System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
            string customErrorMessage= 'Exception occured, Please contact administartor.';
            return customErrorMessage;
        }
        return 'No Cargo Activity is found'; 
    }
    
    
    //MaxRefund api start
    @AuraEnabled(Cacheable=true)
    public static list<object>  maxrefundApi(string ItemId){
        
        list<Activities__c> lstAccs = [select id,OrderUuid__c,Activity_uuid__c,First_Mile_Uuid__c,Cargo_Tracking_status__c,Business_Unit__c,FirstMile_Tracking_Status__c,Order_Id__c,Activity_Name__c,Transaction_Status__c,Activity_Type__c from Activities__c where id=:ItemId];
        try{     
            if(!lstAccs.isEmpty()){ 
                string BusUnit=lstAccs[0].Business_Unit__c;
                //String jsonString ='{"status":"SUCCESS","errors":[],"data":{"maxRefundable":{"GENERIC_ITEM":[{"CARGO":{"itemUuid":"4fcd0ead0abaf00679229b5e02020600","amount":998.0}},{"FIRST_MILE":{"itemUuid":"50ffbfd50abaf00679229b5e01020600","amount":10.0}}]},"currencyType":"PEN"}}';
                
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_V1_Entangle'];
                
                String maxRefundApi = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CargoMaxRefundAPI'].Endpoint__c;
                
                maxRefundApi = maxRefundApi+lstAccs[0].OrderUuid__c+'/maxRefundable?type=all';
                
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                
                for(string o:headers.keyset()){               
                    System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                    hlist.add(new HeadersWrapper(o,headers.get(o))); 
                }
                
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);           
                
                string genericJsonBody='{"action":"GET","body":"","endPoint":"'+maxRefundApi+'","headers":'+headerJson2+'}';
                
                HTTP h = new HTTP();
                HTTPResponse resp=new HTTPResponse();
                HttpRequest req =HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),BusUnit,'');
                req.setMethod('POST');
                req.setBody(genericJsonBody);
                req.setEndpoint(APIMData.Endpoint__c);
                
                resp=h.send(req);
                string recievedRespBody=resp.getBody();
                
                string jsonHeaders ='-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit')+'--SelectedCurrency--'+req.getHeader('SelectedCurrency')+'--Currency-'+req.getHeader('Currency');
                
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo MaxRefundapi',APIMData.Endpoint__c,lstAccs[0].Order_Id__c,genericJsonBody,recievedRespBody,jsonHeaders,'');
                
                if(resp.getStatusCode()==200 && resp.getstatus()=='OK' &&  recievedRespBody!=null)
                {
                    
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(recievedRespBody);
                    String status = (String)resMap.get('status');
                    
                    if(status=='SUCCESS'){
                        Map<String, Object> data = (Map<String, Object>)resMap.get('data');
                        
                        String currencyType = (String)data.get('currencyType');
                        Map<String, Object> maxRefundable = (Map<String, Object>)data.get('maxRefundable');
                        List<Object> genericItemList = (List<Object>)maxRefundable.get('GENERIC_ITEM');
                        
                        return genericItemList;
                    }else if(status=='ERROR'){
                        List<Object> errors = (List<Object>)resMap.get('errors');
                        return errors;
                    }
                    
                }else{
                    List<Object> lstEmptyObject = new list<object>();
                    return lstEmptyObject;
                }
            }
        } catch(Exception e){
            System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
            List<Object> lstEmptyObject = new list<object>();
            DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo MaxRefundapi','',lstAccs[0].Order_Id__c,'','','',String.valueOf(e.getMessage()));
            
            return lstEmptyObject;
        }   
        List<Object> lstEmptyObject = new list<object>();
        return lstEmptyObject;
    }
    
    
    // cancellation api start
    @AuraEnabled(Cacheable=true)
    public static string CancellationCargoAPI(string ItemId,string selReqJson,string cancelReason){
        
        list<Activities__c> lstAccs = [select id,Activity_uuid__c,Business_Unit__c,First_Mile_Uuid__c,Cargo_Tracking_status__c,FirstMile_Tracking_Status__c,OrderUuid__c,Order_Id__c,Activity_Name__c,Transaction_Status__c,Activity_Type__c from Activities__c where id=:ItemId];
        
        system.debug('>>>191>>>'+selReqJson);
        try{     
            if(!lstAccs.isEmpty()){  
                string BusUnit=lstAccs[0].Business_Unit__c;
                list<HttpRequestWrappersUtil.CargoCancellationRequest> cancelReqlst = new list<HttpRequestWrappersUtil.CargoCancellationRequest>();
                
                List<Object> selRequeList = (List<Object>)JSON.deserializeUntyped(selReqJson);
                
                for (Object obj : selRequeList) {
                    
                    HttpRequestWrappersUtil.CargoCancellationRequest cancelReq = new HttpRequestWrappersUtil.CargoCancellationRequest();
                    
                    Map<String, Object> itemMap = (Map<String, Object>)obj;
                    Integer selRfndAmnt = (Integer)itemMap.get('selRfndAmnt');

                   if (selRfndAmnt > 0 ){
                    String itemType = (String)itemMap.get('itemType');
                    String itemUuid = (String)itemMap.get('itemUuid');
                    string cnclReason = (String)itemMap.get('cnclReason');
                    Integer amount = (Integer)itemMap.get('amount');
                    Boolean isSelected = (Boolean)itemMap.get('isSelected');
                    
                    cancelReq.cancellationCharges=0;
                    cancelReq.refundAmount = integer.valueof(selRfndAmnt);
                    cancelReq.uuid =itemUuid;
                    cancelReq.nonRefundableCharges =0;
                    cancelReq.cancellationSource ='SF agent console';
                    cancelReq.businessUnit = 'REDBUS_PE';
                    cancelReq.channel = 'NEON';   
                    cancelReq.refundedBy =UserInfo.getUsername();
                    cancelReq.operatorCancellationStatus = 'OPERATOR_CANCELLATION_SUCCESS';
                    cancelReq.cancellationReason = cancelReason;
                    cancelReqlst.add(cancelReq);
                 }
               } 
                system.debug('>>>>cargoRqst>>'+json.serialize(cancelReqlst));
                
                string reqJsonBody = json.serialize(json.serialize(cancelReqlst));
                
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_V1_Entangle'];
                
                String cancellationApi = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CargoManualCancelAPI'].Endpoint__c;        
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                
                for(string o:headers.keyset()){               
                    System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                    hlist.add(new HeadersWrapper(o,headers.get(o))); 
                }
                
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);           
                
                string genericJsonBody='{"action":"POST","body":'+reqJsonBody+',"endPoint":"'+cancellationApi+'","headers":'+headerJson2+'}';
                
                
                HTTP h = new HTTP();
                HTTPResponse resp=new HTTPResponse();
                HttpRequest req =HttpRequestUtil.populateCAPICountryHeaders(new HttpRequest(),BusUnit,'');
                req.setMethod('POST');
                req.setBody(genericJsonBody);
                req.setEndpoint(APIMData.Endpoint__c);
                
                resp=h.send(req);
                
                string jsonHeaders ='-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit')+'--SelectedCurrency--'+req.getHeader('SelectedCurrency')+'--Currency-'+req.getHeader('Currency');
                
                system.debug('>>resp>>'+resp);
                string jsonString ='{"status":"SUCCESS","errors":[],"data":[{"status":"CANCELLATION_COMPLETED","serviceProviderId":"15108","selectedPaymentCurrency":"INR","refundAmount":10.0,"pnr":"","orderItemUuid":"4489c25c01c1f0068fc8999903020100","orderItemRefNumber":"S8V71689","orderItemId":13526235603669731,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","newOrderItemUuid":null,"cnr":"","clientIp":"","cancellationCharges":0,"backToSource":true},{"status":"CANCELLATION_COMPLETED","serviceProviderId":"15108","selectedPaymentCurrency":"INR","refundAmount":499.0,"pnr":"","orderItemUuid":"44802e5e01c1f0068fc8999903020100","orderItemRefNumber":"S8V65327","orderItemId":13526235598648051,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","newOrderItemUuid":null,"cnr":"","clientIp":"","cancellationCharges":0,"backToSource":true}]}';
                
                string recievedRespBody=resp.getBody();
                
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo Cancellation',APIMData.Endpoint__c,lstAccs[0].Order_Id__c,genericJsonBody,recievedRespBody,jsonHeaders,'');
                
                if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && recievedRespBody!=null)
                {            
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(recievedRespBody);
                    system.debug('>>>>resMap>>'+resMap);
                    
                    string respStatus=string.Valueof(resMap.get('status'));
                    
                    List<Object> errors = (List<Object>)resMap.get('errors');
                    system.debug('>>>errors>>'+errors);
                    if(respStatus=='SUCCESS'){
                        list<Object> respDatalst = (List<Object>)resMap.get('data');
                        system.debug('>>>>respData>>'+respDatalst);
                        for (Object data : respDatalst) {
                            Map<String, Object> dataMap = (Map<String, Object>)data;
                            String Status = (String)dataMap.get('status');
                            String cancellationStatus = (String)dataMap.get('operatorCancellationStatus');
                            system.debug('>>>cancellationStatus>>>'+cancellationStatus);
                            return cancellationStatus;   
                        }
                    }else{
                        return 'Cancellation Failed to update. Please contact administartor';   
                    }
                }else {
                    map<string,object> resObj = (map<string,object>)JSON.deserializeUntyped(recievedRespBody);
                    string respErrorMsg=string.Valueof(resObj.get('error_message'));
                    if(respErrorMsg=='Refund amount & Cancellation charge is greater than max refundable'){
                        return respErrorMsg;
                    }else {
                        return 'Received InValid response from API. Please contact administartor';
                    }
                }
            }
        } catch(Exception e){
            System.debug('Exception occured at line no:'+String.valueOf(e.getLineNumber())+'with error message as '+String.valueOf(e.getMessage())+'.Please contact administartor.');
            string customErrorMessage= 'Exception occured, Please contact administartor.';
            DblogforQuickActionLwcCtrl.dblogCaptureMethod('Cargo Cancellation','',lstAccs[0].Order_Id__c,'','','',String.valueOf(e.getMessage()));
            return customErrorMessage;
        }
        return 'No Cargo Activity is found'; 
    }
    
    //wrapper class
    public class HeadersWrapper
    {       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
    
    
}