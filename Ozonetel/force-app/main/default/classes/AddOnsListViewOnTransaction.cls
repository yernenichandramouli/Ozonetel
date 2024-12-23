/**
 * (c) 2019 RedBus
 *
 * Name           : AddOnsListViewOnTransaction
 * Created Date   : 06 Nov 2019
 * Created By     : Sreenivas M
 * Purpose        : Controller class for addonslist view Page.
 *
 **/

global class AddOnsListViewOnTransaction

{
    public static string transactionId{get;set;}
    public static string endPoint{get;set;}
    public static List<Activities__c> listAddons{get;set;}
    public static list<Order_Items__c> listOrderItems{get;set;}
    public static Id recId{get;set;}
    public static Order_Items__c orItObj{get;set;}
   
    public AddOnsListViewOnTransaction(ApexPages.StandardController controller)
    {
        orItObj = new Order_Items__c();
        recId = controller.getId();
    }

    @AuraEnabled(cacheable=true)
    public static List<Activities__c> fetchAddons(String recdId)
    {
        orItObj = new Order_Items__c();
        orItObj = [SELECT id,name FROM Order_Items__c WHERE id=:recdId];
        system.debug('--orItObj Name--'+orItObj.name);
        listAddons = new List<Activities__c>();
//no email flow - start
//        listAddons = [Select id,Activity_Name__c,Transaction_Status__c,Name,Voucher_Id__c,Amount__c,Service_Start_Time__c,Voucher_Realization_Date__c,Activity_Type__c,Activity_uuid__c,Customer_Email_id__c,Order_Item__c,Order_Item__r.Email_Copy__c,Order_Item__r.Order_Item_Reference_No__c,Order_Item__r.Order_Id__c,Order_Item__r.Guid__c from Activities__c Where Order_Item_id__c=:orItObj.Name];
        listAddons = [Select id,Activity_Name__c,Transaction_Status__c,Name,Voucher_Id__c,Amount__c,Service_Start_Time__c,Voucher_Realization_Date__c,Activity_Type__c,Activity_uuid__c,Customer_Email_id__c,Order_Item__c,Order_Item__r.Email_Copy__c,Order_Item__r.Order_Item_Reference_No__c,Order_Item__r.Order_Id__c,Order_Item__r.Guid__c, order_Item__r.Mobile__c,Order_Item__r.Business_Unit__c from Activities__c Where Order_Item_id__c=:orItObj.Name];
// no email flow - end
        system.debug('--listAddonslistAddons--'+listAddons);
        return listAddons;
    }
    
    @AuraEnabled
    public static List<AddonsWrapper> checkIsCancellableStatus(List<Activities__c> listAllAddOns)
    {
        
        List<String> listAddUuids = new List<String>();
        Map<String,Activities__c> mapAddonUuidToAddon = new Map<String,Activities__c>();
        String orItEmail='';
        String orItTin='';
        String errMsg ='';
// no email flow - start
		String orItmobile =''; 
// no email flow - end 
        Order_Items__c orItem = new Order_Items__c();
        
        for(Activities__c act : listAllAddOns)
        {
            mapAddonUuidToAddon.put(act.Activity_uuid__c,act);
            
            if('CONFIRMED'.equalsIgnoreCase(act.Transaction_Status__c))
                    listAddUuids.add(act.Activity_uuid__c);
            
            
           
        }
        
        orItem = listAllAddOns[0].Order_Item__r;
		system.debug('<<listAllAddOns[0]'+listAllAddOns[0]);
        system.debug('<<orItem'+orItem);
        orItEmail = orItem.Email_Copy__c;
        orItTin = orItem.Order_Item_Reference_No__c;
// no email flow - start
		orItmobile = orItem.Mobile__c;
// no email flow - end         
        String finalActvtyUuids='';
        finalActvtyUuids = String.join(listAddUuids,'","');
// no email flow - start
//        string jsonBody='{"EmailId":"'+orItEmail+'","TicketNo":"'+orItTin+'","isRescheduled":false,"IsAdditionalServiceCancellation":true,"AdditionalServicesItemUUID":["'+finalActvtyUuids+'"]}';
        string jsonBody='{"EmailId":"'+orItEmail+'","TicketNo":"'+orItTin+'","isRescheduled":false,"IsAdditionalServiceCancellation":true,"AdditionalServicesItemUUID":["'+finalActvtyUuids+'"],"mobileno":"'+orItmobile+'"}';
// no email flow - end         
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsTicketCancellableURL'].Endpoint__c);
        req.setMethod('POST');
        req.setBody(jsonBody);
        Cancellation_Process_DB_Log__c cpl = new Cancellation_Process_DB_Log__c();
        cpl.Type__c ='Addons IsCancellable';
        cpl.TIN_Number__c = orItTin;
        cpl.Transaction_Name__c = orItem.id;
        cpl.Trip_Id__c = orItem.Order_Id__c;
        cpl.Business_Unit__c = 'REDBUS_IN';
        cpl.OrderItemUuid__c = orItem.Guid__c;
        
        cpl.IsCacellable_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(jsonBody)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency:INR';

        System.debug('Request body===>'+jsonBody);
        try
        {
            res = http.send(req);                      
            string responseValue = res.getBody();
            cpl.IsCacellable_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
            CPl.IsTicket_CancellableAPI_Request__c = true;
            system.debug('responseValue-->>'+responseValue+''+res.getbody());
           // responseValue ='{"toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"398.0","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0,"baseFare":0,"message":"","isPartialCancellation":false,"isTicketCancellable":false,"discount":"","refundTypeCSV":"","notes":null,"refundModes":null,"lstPassengerInfo":[],"refundTypesList":null,"totalDiscount":0,"ticketFare":0,"totalTax":0,"operatorDiscount":0,"fullCancellationBreakUp":null,"partialCancellationBreakUp":null,"cancellationPolicy":null,"currencytype":null,"currentCancellationPolicyIntl":null,"refundableAmount":398,"cancellationcharges":0,"isZcafeApplied":null,"zcafeDuration":null,"zcafeSponsoredByRedbus":null,"RescheduleFareBreakUp":null,"MPaxData":null,"OperatorId":null,"SourceId":null,"DestinationId":null,"IsReschedulable":false,"IsPrimaryPassengerCancellable":false,"SeatsToBeCancelled":null,"RecheduleConfigs":null,"cancelInitiated":false,"ReschedulePolicyMsg":null,"addons":[{"totalFare":398,"refundableAmount":398,"itemUuid":"0ad1d9b29619f0055722993402020101","itemType":"ACTIVITY","itemName":"NA","currency":"INR","isAddOnCancellable":true,"errorMsg":null,"cancellationPolicy":[{"description":"Before 9th Feb 11:59 PM","chargesValue":"Fully refundable"},{"description":"After 9th Feb 11:59 PM & Before 10th Feb 11:59 PM","chargesValue":"₹100"}]},{"totalFare":398,"refundableAmount":398,"itemUuid":"0ad1d9b29619f0055722993402020100","itemType":"ACTIVITY","itemName":"NA","currency":"INR","isAddOnCancellable":true,"errorMsg":null,"cancellationPolicy":[{"description":"Before 9th Feb 11:59 PM","chargesValue":"Fully refundable"},{"description":"After 9th Feb 11:59 PM & Before 10th Feb 11:59 PM","chargesValue":"₹100"}]}]}';
            
            if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue))
            {
                 map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                 List<AddonsWrapper> listAddonWrap = new List<AddonsWrapper>();
                 if(IsCan!=null && IsCan.containsKey('addons'))
                 {
                    System.debug('addons--'+JSON.serialize(String.valueOf(IsCan.get('addons'))));
                    List<HttpRequestWrappersUtil.AddonsCancellationResponse> listadonResp = new List<HttpRequestWrappersUtil.AddonsCancellationResponse>();
                    listadonResp = (List<HttpRequestWrappersUtil.AddonsCancellationResponse>)JSON.deserialize(JSON.serialize(IsCan.get('addons')),List<HttpRequestWrappersUtil.AddonsCancellationResponse>.class);
                    
                    Map<String,HttpRequestWrappersUtil.AddonsCancellationResponse> mapAddOnUuidToIsCanResp = new Map<String,HttpRequestWrappersUtil.AddonsCancellationResponse>();
                    
                    for(HttpRequestWrappersUtil.AddonsCancellationResponse canRes:listadonResp)
                    {
                        if(String.isNotBlank(canRes.itemType) && ('ACTIVITY'.equalsIgnoreCase(canRes.itemType) || 'FOOD'.equalsIgnoreCase(canRes.itemType)))
                        {
                            mapAddOnUuidToIsCanResp.put(canRes.itemUuid,canRes);
                            
                        }
                    }
                    
                    System.debug('mapAddOnUuidToIsCanResp...'+mapAddOnUuidToIsCanResp);
                    for(Activities__c acti : listAllAddOns)
                    {
                        HttpRequestWrappersUtil.AddonsCancellationResponse objResp = new HttpRequestWrappersUtil.AddonsCancellationResponse();
                        if(mapAddOnUuidToIsCanResp.containsKey(acti.Activity_uuid__c))
                        {
                            objResp = mapAddOnUuidToIsCanResp.get(acti.Activity_uuid__c);
                            listAddonWrap.add(new AddonsWrapper(acti,objResp.isAddOnCancellable,objResp.totalFare,objResp.refundableAmount,objResp.errorMsg));
                            cpl.isTicketCancellable__c= true;
                        
                        }
                        else {
                            listAddonWrap.add(new AddonsWrapper(acti,false,0,0,''));

                        }
                       
                        
                    }
                 }
                 System.debug('listAddonWrap=====>'+listAddonWrap);
                 DataBase.insert(cpl,false);
                 return listAddonWrap;
             }
             
             else
             {
                map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                cpl.Message_Valid__c = true;

                If(IsCan.containsKey('Message') && String.isNotBlank(string.valueof(IsCan.get('Message'))))
                    errMsg = string.valueof(IsCan.get('Message'));
                
                cpl.Message__c = errMsg;
                
                if(IsCan.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(IsCan.get('DetailedMessage'))))
                {
                   cpl.Detailed_Message__c = string.valueof(IsCan.get('DetailedMessage'));                   
                   errMsg = errMsg+' - '+string.valueof(IsCan.get('DetailedMessage'));
                }
                 
                throw new AuraHandledException(errMsg);
                
                
             }
        }
        
        Catch(Exception e)
        {
            System.debug('Exception ---'+errMsg);
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            system.debug(ex);
            DataBase.insert(cpl,false);
            throw ex;
          
        }
    }
    
    
    @AuraEnabled
    public static string cancelSelectedAddons(List<string> listSelAddonUuid,Integer toatlAddCnt,String email,String tin, String mobile)
    {
        String cancelErrMsg ='';
        String finalActvtyUuids=String.join(listSelAddonUuid,'","');
// no email flow - start
//        string jsonBody='{"EmailId":"'+email+'","TicketNo":"'+tin+'","isRescheduled":false,"IsAdditionalServiceCancellation":true,"AdditionalServicesItemUUID":["'+finalActvtyUuids+'"]}';
        string jsonBody='{"EmailId":"'+email+'","TicketNo":"'+tin+'","isRescheduled":false,"IsAdditionalServiceCancellation":true,"AdditionalServicesItemUUID":["'+finalActvtyUuids+'"],"mobileno":"'+mobile+'"}';
// no email flow - end         
        Cancellation_Process_DB_Log__c cpl = new Cancellation_Process_DB_Log__c();
        cpl.Type__c ='Addons Cancellation';
        Order_Items__c orItem = new Order_Items__c();
//no email flow - start
//                orItem = [SELECT id,Order_Id__c,Guid__c,Business_Unit__c FROM Order_Items__c WHERE Order_Item_Reference_No__c=:tin AND Email_Copy__c=:email LIMIT 1];
		orItem = [SELECT id,Order_Id__c,Guid__c,Business_Unit__c FROM Order_Items__c WHERE Order_Item_Reference_No__c=:tin AND ( Email_Copy__c=:email or mobile__c=:mobile ) LIMIT 1];
// no email flow - end
        cpl.TIN_Number__c = tin;
        cpl.Transaction_Name__c = orItem.id;
        cpl.Trip_Id__c = orItem.Order_Id__c;
        cpl.Business_Unit__c = orItem.Business_Unit__c;
        cpl.OrderItemUuid__c = orItem.Guid__c;
        cpl.NC_API_Ping__c = true;
        
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);
        req.setMethod('POST');
        req.setBody(jsonBody);
        cpl.NC_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(jsonBody)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency:INR';
        System.debug('Request body===>'+jsonBody);
        try
        {
            res = http.send(req);                      
            string responseValue =res.getBody();
            cpl.NC_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;  //'{"NewTicket":null,"Message":null,"Status":false,"RefundAmount":99.99,"CancellationCharges":0.0,"IsRefundSuccess":true,"NeftRefundSupported":false,"OrderId":null,"SalesChannel":null,"BusinessUnit":null,"Country":null,"SelectedLanguage":null,"SeatNames":null,"CancelledSeatNames":null,"CancelledAddons":[]}';//0ad1d9b29619f0055722993402020100
            
             system.debug('responseValue-->>'+responseValue+''+res.getbody());
             
             if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue))
             {
                HttpRequestWrappersUtil.CancelTicketResponse canResp = new HttpRequestWrappersUtil.CancelTicketResponse();
                canResp = (HttpRequestWrappersUtil.CancelTicketResponse)JSON.deserializeStrict(responseValue, HttpRequestWrappersUtil.CancelTicketResponse.class);
                cpl.NC_IsSuccess__c = true;
                
                if(canResp.CancelledAddons.isEmpty())
                {
                    cancelErrMsg = 'Selected Addiontional Services Cancellation Has Failed.Please Re-Try Again.-'+canResp.Message;
                    cpl.NC_Response_Message__c = cancelErrMsg;
                }
                if(canResp.CancelledAddons.size() == listSelAddonUuid.size())
                {
                    cpl.NC_Response_Message__c = 'Selected Addiontional Services Has Cancelled Successfully .Total Refunded Amount is - Rs. '+canResp.RefundAmount;
                    DataBase.insert(cpl,false);
                    return 'Selected Addiontional Services Has Cancelled Successfully .Total Refunded Amount is - Rs. '+canResp.RefundAmount;
                }

                else
                {
                    String respVal ='This UUIDs ';
                    for(String St:listSelAddonUuid)
                    {
                        if(!canResp.CancelledAddons.contains(st))
                            respVal = respVal+st+',';
                    }
                    System.debug('respVal...'+respVal);
                    respVal= respVal.removeEnd(',');
                    cancelErrMsg = respVal+' Cancellation Has Failed.Error Message -'+canResp.Message;
                }
                cpl.NC_Response_Message__c = cancelErrMsg;
                if(String.isNotBlank(cancelErrMsg))
                    throw new AuraHandledException(cancelErrMsg);

                return 'Something Went Wrong.Please Re-try';
            }

            else
             {
                map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                cpl.Message_Valid__c = true;

                If(IsCan.containsKey('Message') && String.isNotBlank(string.valueof(IsCan.get('Message'))))
                    cancelErrMsg = string.valueof(IsCan.get('Message'));
                
                cpl.Message__c = cancelErrMsg;
                
                if(IsCan.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(IsCan.get('DetailedMessage'))))
                {
                   cpl.Detailed_Message__c = string.valueof(IsCan.get('DetailedMessage'));                   
                   cancelErrMsg = cancelErrMsg+' - '+string.valueof(IsCan.get('DetailedMessage'));
                }
                   
                throw new AuraHandledException(cancelErrMsg);
                
                
             }

        }

        Catch(Exception e)
        {
            System.debug('Exception ---'+cancelErrMsg);
            DataBase.insert(cpl,false);
            AuraHandledException ex = new AuraHandledException(cancelErrMsg);
            ex.setMessage(cancelErrMsg);
            system.debug(ex);
            throw ex;
        }
    }

    public class AddonsWrapper
    {
        @AuraEnabled public Activities__c addOn{get;set;}
        @AuraEnabled public boolean isCancellable{get;set;}
        @AuraEnabled public double totalTktAmnt{get;set;}
        @AuraEnabled public double refundableAmnt{get;set;}
        @AuraEnabled public Boolean isSelect{get;set;}
        @AuraEnabled public String errMsg{get;set;}
        @AuraEnabled public Double cancellationCharge{get;set;}
      
       
        public AddonsWrapper(Activities__c act,Boolean cancellable,Double tktAmt,Double refAmnt,String errMessage)
        {
            this.addOn = act;
            this.isCancellable = cancellable;
            this.totalTktAmnt = tktAmt;
            this.refundableAmnt = refAmnt;
            this.isSelect = false;	
            this.errMsg = errMessage;
            this.cancellationCharge = this.totalTktAmnt - this.refundableAmnt;

        }

    }
}