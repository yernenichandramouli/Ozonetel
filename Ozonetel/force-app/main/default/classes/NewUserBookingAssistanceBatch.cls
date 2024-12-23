/**
* (c) 2023 RedBus
*
* Name           : NewUserBookingAssistanceBatch
* Created Date   : 02 Mar 2023
* Created By     : Sreenivas M
* Purpose        : Batch class to push new user not confirmed transactions to Ameyo CMAPI for calling
* Test class     : NewUserBookingAssistanceBatchTest
*
**/

global class NewUserBookingAssistanceBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
    global String query;
    DateTime startTime;
    DateTime endTime;
    DateTime currentTime;
    DateTime fromCreationHr;
    integer schudelrStartTime;
    integer schudelrEndTime;
    public NewUserBookingAssistanceBatch(){}
    
    public NewUserBookingAssistanceBatch (String q)
    {
        list<String> setMinutes = new list<String>(System.label.BookingAssistanceMinutes.split(','));
        system.debug('>>>setMinutes>>'+setMinutes[0]);
                
        currentTime = DateTime.now();
        startTime = currentTime.addMinutes(-integer.valueof(setMinutes[0]));
        endTime = currentTime.addMinutes(-integer.valueof(setMinutes[1]));
        
        schudelrStartTime =integer.valueof(setMinutes[2]);
        schudelrEndTime =integer.valueof(setMinutes[3]);

        system.debug('--timeRange-->>'+currentTime+'--10m--'+startTime+'--40m--'+endTime);     
        if(String.isNotBlank(q))
            query = q;
        else
            query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NewUserBookingAssistanceQuery'].QueryDetails__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('query-->>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext scon)
    {
        
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NewUserBookingAssistanceQuery'].Duration__c;
        Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();

        if(nextIntervalHour>=schudelrEndTime)
        {
            Datetime sysNextDate = System.now().addDays(1);
            String chron_exp = '0 0 8'+ ' ' + sysNextDate.day() + ' ' + sysNextDate.month() + ' ? ' + sysNextDate.year();
            System.schedule('NewUserBookingAssistanceBatch - '+String.valueOf(DateTime.now()),chron_exp, this);
        }
        else if(nextIntervalHour<=schudelrStartTime)
            System.schedule('NewUserBookingAssistanceBatch - '+String.valueOf(DateTime.now()), '0 0 8'+ ' ' + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year(),this);
        
        else
        {
            System.schedule('NewUserBookingAssistanceBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
            Database.executeBatch(new NewUserBookingAssistanceBatch(query));
        }
        
      }
        
    
    global void execute(DataBase.BatchableContext bc,List<Order_Items__c> lstOrderItems)
    {
        List<Order_Items__c> finallstOrderItems = new List<Order_Items__c>();
        
        Double limitPercentage = Double.valueOf(System.Label.BookingAssistanceLimit);
        if(!lstOrderItems.isEmpty())
        {
            Integer randomLimit = Integer.valueOf(lstOrderItems.size()*limitPercentage)<=0?1:Integer.valueOf(lstOrderItems.size()*limitPercentage);
            system.debug('>>>>randomLimit>>'+randomLimit);
            system.debug('>>>>lstOrderItems.size>>'+lstOrderItems.size()); 
            
            if(lstOrderItems.size()>randomLimit)
            {
                system.debug('>>>43>>>');
                RandomGeneric rg = new RandomGeneric(lstOrderItems);   
                system.debug('>>>46>>>'+rg); 
                
                List<Object> reqs = new List<Object>();
                reqs.Addall(rg.getNumberOfRandomRecords(randomLimit));
                
                system.debug('>>>47>>'+reqs);
                finallstOrderItems= (List<Order_Items__c>)JSON.deserialize(JSON.serialize(reqs),List<Order_Items__c>.class);
                
                system.debug('>>>47>>'+finallstOrderItems);                
            }
            else
            {
                finallstOrderItems.addAll(lstOrderItems);
            }
            
            
            List<HttpRequestWrappersUtil.CustomerAndCallbackRecord> listCBR = new List<HttpRequestWrappersUtil.CustomerAndCallbackRecord>();
            
            string setOrderIds;
            for(Order_Items__c item :finallstOrderItems)
            {
                HttpRequestWrappersUtil.CustomerRecord cr = new HttpRequestWrappersUtil.CustomerRecord();
                cr.phone1 = item.Mobile__c.right(10);
                cr.sfRecId = item.id;
                cr.callTime= String.valueOf(Datetime.now().addMinutes(30).format('dd-MM-yyyy HH:mm:ss'));
                cr.orderItemId = item.ID__c;
                cr.orderId = item.Order_Id__c;
                cr.reason='redBus Booking Assistance';
                setOrderIds = setOrderIds+cr.orderId+',';
                HttpRequestWrappersUtil.CustomerAndCallbackRecord cbr = new HttpRequestWrappersUtil.CustomerAndCallbackRecord();
                cbr.customerRecord = cr;
                listCBR.add(cbr);
                system.debug('---listCBR---'+listCBR);
            }
            
            if(!listCBR.isEmpty())
            {
                HttpRequestWrappersUtil.Properties p =new  HttpRequestWrappersUtil.Properties();
                p.updatedot_customer=true;
                p.migratedot_customer=true;
                
                HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper ameyoReq = new HttpRequestWrappersUtil.AmeyoCMAPIRequestWrapper();
                ameyoReq.campaignId ='80';
                ameyoReq.customerAndCallbackRecords = listCBR;
                ameyoReq.leadId ='18';
                ameyoReq.properties = p;
                ameyoReq.attempts = '0';
                ameyoReq.status = 'NOT_TRIED';
                
                //'{\"update.customer\":true,\"migrate.customer\":true}';
                
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.SentAt__c = system.now();
                dbl.Type__c = 'NewUser Booking Assistance';
                dbl.Payment_Request_Sent_Time__c = system.now();            
                dbl.Order_Items_Success__c = setOrderIds;
                
                String endPoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NewUserBookingAssistance'].Endpoint__c;
                endPoint = endPoint+'command=uploadContactAndAddCallback';
                
                string jsonAmeyoReq =JSON.Serialize(ameyoReq);
                string finalAmeyoReq=jsonAmeyoReq.replace('dot_','.');
                
                system.debug('>>>.finalAmeyoReq...'+finalAmeyoReq);
                
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
                
                dbl.Request_Data__c = string.valueof(req)+JSON.Serialize(jsonBody);
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                
                try
                {
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
                            dbl.Payment_Ping_Status__c = 'Ameyo New User Booking Assistance Success';
                            
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
                    
                }
                insert dbl;
                
                
                
            }
        }
        
        
        
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('sreenivasa.mariyavula@redbus.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('BusC Alternative Arrangement Refund Processing..'+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}