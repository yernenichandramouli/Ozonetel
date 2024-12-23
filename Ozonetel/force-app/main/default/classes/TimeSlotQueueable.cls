public class TimeSlotQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> timeSlotIds;

    // Constructor to pass the record IDs
    public TimeSlotQueueable(List<Id> timeSlotIds) {
        this.timeSlotIds = timeSlotIds;
    }

    public void execute(QueueableContext context) {
    
        List<DBLog_Summary__c> dlgInsert = new List<DBLog_Summary__c>();
        List<TimeSlot__c> timeSlotsToUpdate = new List<TimeSlot__c>();
        
        // Perform the callout for the TimeSlot__c records
        List<TimeSlot__c> timeSlots = [select Id,isSecondary__c,CaseId__c,Phone__c,Call_Unique_Id__c,caseNumber__c,Call_Start_time__c,Call_End_Time__c,Status__c,SupervisorName__c, StartTime__c, EndTime__c from TimeSlot__c WHERE Id IN :timeSlotIds];

        for (TimeSlot__c ts : timeSlots) {
            // Callout logic
                DateTime startTime = ts.StartTime__c;
                string caseId =ts.CaseId__c;
                string phone=ts.Phone__c;
                string caseURlView='caseURlView';
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                List<HttpRequestWrappersUtil.CustomerAndCallbackRecord> listCBR = new List<HttpRequestWrappersUtil.CustomerAndCallbackRecord>();
                try
                {
                HTTP h = new HTTP();
                HTTPRequest req= new  HTTPRequest();
                HTTPResponse res=new HTTPResponse();
                
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
                            ts.isSchedule__c=true;
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
                timeSlotsToUpdate.add(ts);  
                dlgInsert.add(dbl);
            }
            
           if (!dlgInsert.isEmpty()) {
            insert dlgInsert;
        }

        if (!timeSlotsToUpdate.isEmpty()) {
            update timeSlotsToUpdate;
        }
    }
}