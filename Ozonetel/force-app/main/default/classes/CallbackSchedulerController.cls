public with sharing class CallbackSchedulerController {
    @AuraEnabled
    public static List<TimeSlot__c> getAvailableSlots(Date subDate) {
        DateTime startDate = DateTime.newInstance(subDate.year(), subDate.month(), subDate.day(), 9, 0, 0);
        DateTime endDate = DateTime.newInstance(subDate.year(), subDate.month(), subDate.day(), 22, 0, 0);
        return [SELECT Id, StartTime__c, EndTime__c FROM TimeSlot__c WHERE StartTime__c >= :startDate AND StartTime__c < :endDate];
    }
    
    @AuraEnabled
    public static void bookTimeSlot(DateTime startTime,String caseNumber, string casePhoneNo,String caseId,String caseURlView) {
        
        DateTime endTime;
        DateTime slotEndTime;
        
        List<TimeSlot__c> existingSlots = new List<TimeSlot__c> ();
        if(startTime!=null){
            endTime = startTime.addMinutes(15);
            slotEndTime = startTime.addMinutes(15);
            
            existingSlots = [SELECT Id, StartTime__c, EndTime__c FROM TimeSlot__c WHERE (StartTime__c < :slotEndTime AND EndTime__c > :startTime)];
        }
        
       system.debug('>>>>existingSlots>>>'+existingSlots.size());
        
        if (!existingSlots.isempty() && existingSlots.size() >= 2) {
            throw new AuraHandledException('This slot is fully booked.');
        } else if (existingSlots.size() == 1) {
            TimeSlot__c existingSlot = existingSlots[0];
            TimeSlot__c newSlot = new TimeSlot__c(
                StartTime__c = existingSlot.EndTime__c, 
                EndTime__c = existingSlot.EndTime__c.addMinutes(15),
                CaseId__c = caseId,
                caseNumber__c = caseNumber, 
                Phone__c = casePhoneNo
            );
            insert newSlot;
            callBackAmeyoReqApi(startTime, caseId, casePhoneNo, caseURlView);
        } else {
            TimeSlot__c newSlot = new TimeSlot__c(
                StartTime__c = startTime, 
                EndTime__c = endTime,
                CaseId__c = caseId,
                caseNumber__c = caseNumber, 
                Phone__c = casePhoneNo
            );
            insert newSlot;
            callBackAmeyoReqApi(startTime, caseId, casePhoneNo, caseURlView);
        }
    }
    
    @future(callout=true)
    public static void callBackAmeyoReqApi(DateTime startTime,String caseId, String phone,String caseURlView) {
        system.debug('>>>>>Start--'+startTime+'--->-CaseId-'+caseId+'---<-Phone--'+phone+'--->>View---'+caseURlView);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        List<HttpRequestWrappersUtil.CustomerAndCallbackRecord> listCBR = new List<HttpRequestWrappersUtil.CustomerAndCallbackRecord>();
        try
        {
            
            HttpRequestWrappersUtil.CustomerRecord cr = new HttpRequestWrappersUtil.CustomerRecord();
            cr.phone1 = phone;
            cr.sfRecId = caseId;
            cr.callTime= String.valueOf(startTime.format('dd-MM-yyyy HH:mm:ss'));
            cr.callEndTime= String.valueOf(startTime.addMinutes(15).format('dd-MM-yyyy HH:mm:ss'));
            cr.reason='redBus Supervisor CallBack';
            HttpRequestWrappersUtil.CustomerAndCallbackRecord cbr = new HttpRequestWrappersUtil.CustomerAndCallbackRecord();
            cbr.customerRecord = cr;
            listCBR.add(cbr);
            
            HttpRequestWrappersUtil.Properties p =new  HttpRequestWrappersUtil.Properties();
            p.updatedot_customer=true;
            p.migratedot_customer=true;
            
            HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper ameyoReq = new HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper();
            ameyoReq.campaignId ='98';
            ameyoReq.customerAndCallbackRecords = listCBR;
            ameyoReq.leadId ='26';
            ameyoReq.properties = p;
            ameyoReq.attempts = '0';
            ameyoReq.status = 'NOT_TRIED';
            
            
            dbl.SentAt__c = system.now();
            dbl.Type__c = 'redBus Supervisor CallBack';
            dbl.Payment_Request_Sent_Time__c = system.now();            
            dbl.Order_Items_Success__c =caseId;
            
            String endPoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NewUserBookingAssistance'].Endpoint__c;
            endPoint = endPoint+'command=uploadContactAndAddCallback';
            
            string jsonAmeyoReq =JSON.Serialize(ameyoReq);
            string finalAmeyoReq=jsonAmeyoReq.replace('dot_','.');
            system.debug('>>>finalAmeyoReq>>>'+finalAmeyoReq);
            Map<String, String> formData = new Map<String, String>();
            formData.put('data', EncodingUtil.urlEncode(finalAmeyoReq, 'UTF-8'));
            String body = '';
            system.debug('>>>>formData>>>'+formData);
            for (String key : formData.keySet()) {
                system.debug('>>>>formData key>>>'+formData.get(key));
                if (body != '') {
                    body += '&';
                }
                body += key + '=' + formData.get(key);
            }
            system.debug('>>>body>>>'+body);
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            
            Map<String, String> headers = new Map<String, String>();
            headers.put('hash-key','bb07434efc81b1abeeda712ca7f454a6');
            headers.put('requesting-host','localhost');
            headers.put('policy-name', 'token-based-authorization-policy');
            headers.put('Content-Type','application/x-www-form-urlencoded');
            list<BDIntldevQueueController.HeadersWrapper> hlist=new list<BDIntldevQueueController.HeadersWrapper>();
            
            for(string o:headers.keyset()){               
                System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                hlist.add(new BDIntldevQueueController.HeadersWrapper(o,headers.get(o))); 
            }
            
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);
            
            system.debug('---headerJson2---'+headerJson2);
            
            string jsonBody='{"action":"POST","body":"'+body+'","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            
            system.debug('jsonBody-->>'+jsonBody);
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_V1_Entangle'];
            
            system.debug('endpoint-->>'+APIMData.Endpoint__c);
            HTTP h = new HTTP();
            HTTPRequest req= new  HTTPRequest();
            HTTPResponse res=new HTTPResponse();
            req = HttpRequestUtil.populateHeaders(req);
            req.setMethod('POST');
            req.setBody(jsonBody);
            req.setEndpoint(APIMData.Endpoint__c);
            system.debug('reqbdy-->>'+req.getbody());
            
            dbl.Request_Data__c = string.valueof(req)+JSON.Serialize(jsonBody)+'--jsonAmeyoReq---'+jsonAmeyoReq;
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            
            
            res=h.send(req);
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            system.debug('----Res body-->'+res.getBody());
            if(res.getStatus()=='OK' && res.getStatusCode()==200 )
            { 
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                string resBody =res.getBody();
                if(!resBody.contains('errorCode')){
                    dbl.Payment_Request_Response_Time__c = System.now();
                    dbl.Payment_Ping_Status__c = 'Ameyo Supervisor CallBack Success';
                    
                    set<string> tins=new set<string>();
                    list<case> listCases=new list<case>();
                    Map<string,Order_Items__c> trnMap=new Map<string,Order_items__c>();
                    
                    list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper> resTins=new list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>();
                    
                    resTins= (list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>)System.JSON.deserialize(res.getbody(),list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>.class);
                    system.debug('-----resTins---'+resTins);
                }else{
                    system.debug('-----errorcode---'+resBody);
                    dbl.Response_Received__c=resBody;
                }
            }
        }
        
        catch(Exception e)
        {
            dbl.Response_Received__c=string.valueof(e);
        }
        insert dbl;               
    }
    
    public static void callDispositionMethod(string callDispositionResp){
        
        CallDetails callDetails = (CallDetails) JSON.deserialize(callDispositionResp, CallDetails.class);
        
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(callDispositionResp);
        List<case> lstCs = [select id,Phone_No_ct__c,Booking_Mobile_No__c,Status,caseNumber,SupervisorCall_Status__c from case where id =:callDetails.caseId and SupervisorCall_Status__c !='CONNECTED'];
        set<String> setDespStatus = new Set<String>(System.label.CallDispositionStatus.split(','));
        
        TimeSlot__c latestTimeSlot = [SELECT Id,Phone__c,isSecondary__c, caseNumber__c,StartTime__c, CaseId__c,EndTime__c FROM TimeSlot__c where createdDate= today and EndTime__c!=null ORDER BY EndTime__c DESC LIMIT 1];
        list<TimeSlot__c> insertTs = new  list<TimeSlot__c>();
        List<casecomment> ccList=new List<casecomment>();
        
        if(!lstCs.isEmpty() && lstCs[0].caseNumber!=null){                          
            list<TimeSlot__c> lstTmSlt= [SELECT Id,isSecondary__c,Call_Unique_Id__c,caseNumber__c,Call_Start_time__c,Call_End_Time__c,Status__c,SupervisorName__c, StartTime__c, EndTime__c FROM TimeSlot__c where CaseId__c=:lstCs[0].id ORDER BY Status__c NULLS LAST, EndTime__c DESC];
             String casePhoneNo = String.isNotBlank(lstCs[0].Phone_No_ct__c)?lstCs[0].Phone_No_ct__c:String.isNotBlank(lstCs[0].Booking_Mobile_No__c)?lstCs[0].Booking_Mobile_No__c:'';
            Boolean createNewSlot = false; // Flag for whether to create a new time slot
            Integer rnrCount = 0; // Counter for RNR statuses
            Boolean rnr1Exists = false;
            
            for (TimeSlot__c tmSlt : lstTmSlt) {
                if (String.isBlank(tmSlt.Status__c)) {
                    if (callDetails.systemDisposition =='CONNECTED') {
                        // If the status is 'connected', close the case and update this slot
                        tmSlt.Status__c = callDetails.systemDisposition;
                        lstCs[0].SupervisorCall_Status__c =  tmSlt.Status__c ;
                        tmSlt.SupervisorName__c = callDetails.agentName;
                        tmslt.CaseId__c = lstCs[0].id;
                        tmSlt.Call_Unique_Id__c = callDetails.uniqueId;
                        tmSlt.Call_Start_time__c = datetime.valueof(callDetails.dialedTime.replace('T',' ')).addminutes(330);
                        tmSlt.Call_End_Time__c = datetime.valueof(callDetails.callEndTime.replace('T',' ')).addminutes(330);
                        casecomment cc=new casecomment();
                        cc.parentid= lstCs[0].id;
                        cc.commentbody='Call connected to the customer.';
                        ccList.add(cc);
                        
                        createNewSlot = false; // No new time slot
                        break; // Exit the loop as the case is closed
                    } else if (rnr1Exists) {
                        // If we already have a status '-1', update the blank slot to '-2'
                        tmSlt.Status__c = callDetails.systemDisposition + '-2'; // e.g., 'RNR-2'
                        lstCs[0].SupervisorCall_Status__c = tmSlt.Status__c;
                        tmSlt.SupervisorName__c = callDetails.agentName;
                        tmSlt.Call_Unique_Id__c = callDetails.uniqueId;
                        tmslt.CaseId__c = lstCs[0].id;
                        tmSlt.Call_Start_time__c = datetime.valueof(callDetails.dialedTime.replace('T',' ')).addminutes(330);
                        tmSlt.Call_End_Time__c = datetime.valueof(callDetails.callEndTime.replace('T',' ')).addminutes(330);
                        rnrCount = 2; // Second RNR occurrence
                        createNewSlot = false; // No need to create a new slot   
                        
                        casecomment cc=new casecomment();
                        cc.parentid= lstCs[0].id;
                        cc.commentbody='Tried to callBack the customer twice,but RNR, So we are closing the case.';
                        lstCs[0].status = 'Closed';
                        ccList.add(cc);
                    }else{
                        //Update blank status with "RNR-1" or equivalent
                        tmSlt.Status__c = callDetails.systemDisposition+'-1'; // e.g., 'RNR-1'
                        lstCs[0].SupervisorCall_Status__c = tmSlt.Status__c;
                        tmSlt.SupervisorName__c = callDetails.agentName;
                        tmslt.CaseId__c = lstCs[0].id;
                        tmSlt.Call_Unique_Id__c = callDetails.uniqueId;
                        tmSlt.Call_Start_time__c = datetime.valueof(callDetails.dialedTime.replace('T',' ')).addminutes(330);
                        tmSlt.Call_End_Time__c = datetime.valueof(callDetails.callEndTime.replace('T',' ')).addminutes(330);
                        rnrCount = 1; // First RNR occurrence
                        rnr1Exists = true; 
                        createNewSlot = true; // Flag to create a new time slot
                    }
                }else if (tmSlt.Status__c.endsWith('-1')) {
                    // If the status is already "-1", update it to "-2"
                    //tmSlt.Status__c = callDetails.systemDisposition+ '-2'; // e.g., 'RNR-2'
                    lstCs[0].SupervisorCall_Status__c = tmSlt.Status__c;
                    tmSlt.SupervisorName__c = callDetails.agentName;
                    tmslt.CaseId__c = lstCs[0].id;
                    tmSlt.Call_Unique_Id__c = callDetails.uniqueId;
                    tmSlt.Call_Start_time__c = datetime.valueof(callDetails.dialedTime.replace('T',' ')).addminutes(330);
                    tmSlt.Call_End_Time__c = datetime.valueof(callDetails.callEndTime.replace('T',' ')).addminutes(330);
                    rnr1Exists = true;  
                    
                    createNewSlot = false; // No new time slot    
                }else if (tmSlt.Status__c.endsWith('-2')) {
                    // If the status is already "-2", do not change anything
                    rnrCount = 2; // We already handled the second RNR
                    createNewSlot = false; // No new time slot
                }
                
                // Update the current time slot
                // update tmSlt;
                
                // If we already handled the second RNR or connected status, break the loop
                if (rnrCount == 2 || callDetails.systemDisposition =='CONNECTED' ) {
                    break;
                }
            }
            
            // If we need to create a new time slot after handling "RNR-1"
            if (createNewSlot && rnrCount == 1) {
                TimeSlot__c newTimeSlot = new TimeSlot__c();
                TimeSlot__c newSlot = new TimeSlot__c();
                newSlot.StartTime__c = latestTimeSlot.EndTime__c.addMinutes(15);
                newSlot.EndTime__c = latestTimeSlot.EndTime__c.addMinutes(30);
                newSlot.caseNumber__c = latestTimeSlot.caseNumber__c;
                newSlot.CaseId__c = latestTimeSlot.CaseId__c;
                newSlot.Phone__c =latestTimeSlot.Phone__c;
                newSlot.isSecondary__c=true;
                insertTs.add(newSlot);
                secondCallBackAmeyoReqApi(newSlot.StartTime__c,lstCs[0].id,casePhoneNo,'caseURlView');
            }
            insert ccList;
            if(!insertTs.isEmpty()){
                insert insertTs;
            }
            Update lstCs;
            update lstTmSlt;
            
        }
    }
    
    /*private Datetime adjustEndTime(Datetime endTime, Integer minutesToAdd) {
// Calculate the new end time by adding minutes
Datetime newEndTime = endTime.addMinutes(minutesToAdd);

// Define the allowed time range in UTC
Time startTimeLimit = Time.newInstance(9, 0, 0, 0);  // 9:00 AM
Time endTimeLimit = Time.newInstance(22, 0, 0, 0);   // 10:00 PM

// Extract the time component of the new end time in UTC
Time newEndTimeTime = newEndTime.time();

// Get the date component of the new end time
Date newEndDate = newEndTime.date();

// Check if the new end time is before the allowed start time
if (newEndTimeTime < startTimeLimit) {
// If new end time is before 9 AM, set to 9 AM of the same day
newEndTime = Datetime.newInstance(newEndDate, startTimeLimit);
} else if (newEndTimeTime > endTimeLimit) {
// If new end time is after 10 PM, set to 10 PM of the same day
newEndTime = Datetime.newInstance(newEndDate, endTimeLimit);
}

// Ensure the new end time doesn't go beyond 10 PM
if (newEndTime.time() > endTimeLimit) {
newEndTime = Datetime.newInstance(newEndDate, endTimeLimit);
}

// If the end time is still out of bounds, move to the next day at 9 AM
if (newEndTime.time() < startTimeLimit || newEndTime.time() > endTimeLimit) {
newEndTime = Datetime.newInstance(newEndDate.addDays(1), startTimeLimit);
}

return newEndTime;
}*/
    
    
    @future(callout=true)
    public static void secondCallBackAmeyoReqApi(DateTime startTime,String caseId, String phone,String caseURlView) {
        system.debug('>>>>>Start--'+startTime+'--->-CaseId-'+caseId+'---<-Phone--'+phone+'--->>View---'+caseURlView);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        List<HttpRequestWrappersUtil.CustomerAndCallbackRecord> listCBR = new List<HttpRequestWrappersUtil.CustomerAndCallbackRecord>();
        try
        {
            
            HttpRequestWrappersUtil.CustomerRecord cr = new HttpRequestWrappersUtil.CustomerRecord();
            cr.phone1 = phone;
            cr.sfRecId = caseId;
            cr.callTime= String.valueOf(startTime.format('dd-MM-yyyy HH:mm:ss'));
            cr.callEndTime= String.valueOf(startTime.addMinutes(15).format('dd-MM-yyyy HH:mm:ss'));
            cr.reason='redBus Supervisor CallBack';
            HttpRequestWrappersUtil.CustomerAndCallbackRecord cbr = new HttpRequestWrappersUtil.CustomerAndCallbackRecord();
            cbr.customerRecord = cr;
            listCBR.add(cbr);
            
            HttpRequestWrappersUtil.Properties p =new  HttpRequestWrappersUtil.Properties();
            p.updatedot_customer=true;
            p.migratedot_customer=true;
            
            HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper ameyoReq = new HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper();
            ameyoReq.campaignId ='98';
            ameyoReq.customerAndCallbackRecords = listCBR;
            ameyoReq.leadId ='26';
            ameyoReq.properties = p;
            ameyoReq.attempts = '0';
            ameyoReq.status = 'NOT_TRIED';
            
            
            dbl.SentAt__c = system.now();
            dbl.Type__c = 'redBus Second Supervisor CallBack';
            dbl.Payment_Request_Sent_Time__c = system.now();            
            dbl.Order_Items_Success__c =caseId;
            
            String endPoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NewUserBookingAssistance'].Endpoint__c;
            endPoint = endPoint+'command=uploadContactAndAddCallback';
            
            string jsonAmeyoReq =JSON.Serialize(ameyoReq);
            string finalAmeyoReq=jsonAmeyoReq.replace('dot_','.');
            system.debug('>>>finalAmeyoReq>>>'+finalAmeyoReq);
            Map<String, String> formData = new Map<String, String>();
            formData.put('data', EncodingUtil.urlEncode(finalAmeyoReq, 'UTF-8'));
            String body = '';
            system.debug('>>>>formData>>>'+formData);
            for (String key : formData.keySet()) {
                system.debug('>>>>formData key>>>'+formData.get(key));
                if (body != '') {
                    body += '&';
                }
                body += key + '=' + formData.get(key);
            }
            system.debug('>>>body>>>'+body);
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            
            Map<String, String> headers = new Map<String, String>();
            headers.put('hash-key','bb07434efc81b1abeeda712ca7f454a6');
            headers.put('requesting-host','localhost');
            headers.put('policy-name', 'token-based-authorization-policy');
            headers.put('Content-Type','application/x-www-form-urlencoded');
            list<BDIntldevQueueController.HeadersWrapper> hlist=new list<BDIntldevQueueController.HeadersWrapper>();
            
            for(string o:headers.keyset()){               
                System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                hlist.add(new BDIntldevQueueController.HeadersWrapper(o,headers.get(o))); 
            }
            
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);
            
            system.debug('---headerJson2---'+headerJson2);
            
            string jsonBody='{"action":"POST","body":"'+body+'","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            
            system.debug('jsonBody-->>'+jsonBody);
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_V1_Entangle'];
            
            system.debug('endpoint-->>'+APIMData.Endpoint__c);
            HTTP h = new HTTP();
            HTTPRequest req= new  HTTPRequest();
            HTTPResponse res=new HTTPResponse();
            req = HttpRequestUtil.populateHeaders(req);
            req.setMethod('POST');
            req.setBody(jsonBody);
            req.setEndpoint(APIMData.Endpoint__c);
            system.debug('reqbdy-->>'+req.getbody());
            
            dbl.Request_Data__c = string.valueof(req)+JSON.Serialize(jsonBody)+'--jsonAmeyoReq---'+jsonAmeyoReq;
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            
            
            res=h.send(req);
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            system.debug('----Res body-->'+res.getBody());
            if(res.getStatus()=='OK' && res.getStatusCode()==200 )
            { 
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                string resBody =res.getBody();
                if(!resBody.contains('errorCode')){
                    dbl.Payment_Request_Response_Time__c = System.now();
                    dbl.Payment_Ping_Status__c = 'Ameyo Supervisor CallBack Success';
                    
                    set<string> tins=new set<string>();
                    list<case> listCases=new list<case>();
                    Map<string,Order_Items__c> trnMap=new Map<string,Order_items__c>();
                    
                    list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper> resTins=new list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>();
                    
                    resTins= (list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>)System.JSON.deserialize(res.getbody(),list<HttpRequestWrappersUtil.AmeyoCMAPIResponseWrapper>.class);
                    system.debug('-----resTins---'+resTins);
                }else{
                    system.debug('-----errorcode---'+resBody);
                    dbl.Response_Received__c=resBody;
                }
            }
        }
        
        catch(Exception e)
        {
            dbl.Response_Received__c=string.valueof(e);
        }
        insert dbl;               
    }
    
    public class CallDetails {
        public String callEndTime { get; set; }
        public String caseId { get; set; }
        public String agentName { get; set; }
        public String dialedTime { get; set; }
        public string systemDisposition {get; set;}
        public string uniqueId {get; set;}
    }
}