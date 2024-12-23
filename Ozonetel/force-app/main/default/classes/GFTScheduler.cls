/**
 * (c) 2017 RedBus
 *
 * Name           : GFTScheduler 
 * Created Date   : 17 May 2017
 * Created By     : Sreenivas M
 * Purpose        : Schedular class to verify all GFT's before moving to agents queue
 * Test class     : GFTSchedulerTest
 *
 **/
 
global class GFTScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.abortJob(sc.getTriggerId());
        System.schedule('GFTScheduler '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.GFT_Scheduler_Time)).minute()+' */1 ? * *', this);
        sendTripIdCallout();
    }
      
    @future(callout=true)
    public static void sendTripIdCallout()
    {
           
        list<case> caseList = new list<case>();
        Set<String> setPaymentUUids = new Set<String>();
        
        caseList = [select id,Origin,Trip_ID__c,FT_Verified__c,Transaction_ID__r.Order_Name__r.Guid__c FROM case WHERE Createddate=today AND FT_Verified__c=false AND Transaction_ID__c!=null AND Transaction_ID__r.Order_Name__r.Guid__c!=null AND Transaction_ID__r.Business_Unit__c='REDBUS_IN' AND Origin='Failed Transaction' LIMIT 100];
        //select id,Trip_ID__c,FT_Verified__c,Transaction_ID__r.Order_Name__r.Guid__c FROM case WHERE Createddate=today AND FT_Verified__c=false AND Transaction_ID__c!=null AND Transaction_ID__r.Order_Name__r.Guid__c!=null AND Transaction_ID__r.Business_Unit__c='REDBUS_IN' AND OwnerId IN (SELECT id FROM Group WHERE DeveloperName IN ('GFT_Queue','New_user_GFT') and TYPE='Queue') LIMIT 100];
        
        if(!caseList.isEmpty())
        {
                String jsonBody = '{"orderId":"';
                for(Case cs : caseList)
                {
                    jsonBody = jsonBody+cs.Transaction_ID__r.Order_Name__r.Guid__c+',';
                }
                jsonBody = jsonBody.removeEnd(',')+'"}';
                System.debug('...jsonBody...'+jsonBody);
                
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                 
                HTTP http = new HTTP();
                HttpRequest req = new HttpRequest();
                HttpResponse resp = new HttpResponse();
                req.setHeader('Content-Type','application/json');
                req = HttpRequestUtil.populateHeaders(req); 
                req.setBody(jsonBody);
                req.setMethod('POST');
                API_EndPoints__mdt apiendPoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='LatestTransStatus'];
                req.setEndpoint(apiendPoint.Endpoint__c);
                
                dbl.SentAt__c = system.now();
                dbl.Type__c = 'GFT Schedular';
                dbl.Payment_Request_Sent_Time__c = system.now();
                //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonBody;
                dbl.Request_Data__c = string.valueof(req)+jsonBody;
                dbl.Order_Items_Data_Received_Ids__c = String.valueOf(jsonBody);
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
               
               
                try
                {
                    System.debug('req...'+req);
                    resp= http.send(req);
                    dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
                    dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
                    System.debug('resp..'+resp);
                    dbl.Response_Received__c = String.valueOf(resp+'Resp Body..'+resp.getBody()).left(9999);
                    // dbl.Payment_Request_Response_Data__c = String.valueOf(resp+'Resp Body..'+resp.getBody()).left(9999);
                     dbl.Payment_Request_Response_Time__c = System.now();
                     dbl.Payment_Ping_Status__c = 'GFT Schedular Success';  
                    
                    if(resp.getStatus()=='OK' && resp.getStatusCode()==200)
                    {
                        System.debug('Resp Body...'+resp.getBody());
                        Map<string,ItmesPaymentsWrapper> apiRespone = new Map<string,ItmesPaymentsWrapper>();
                        apiRespone = (Map<string,ItmesPaymentsWrapper>)System.JSON.deserialize(resp.getBody(),Map<string,ItmesPaymentsWrapper>.class);
                         System.debug('Resp Body..w.'+apiRespone );
                        for(String ord : apiRespone.keySet())
                        {
                            if(apiRespone.get(ord).payments!=null)
                                setPaymentUUids.addall(apiRespone.get(ord).payments.keySet());
                                
                        }
                        
                        Map<String,String> mapPIUidPSys = new Map<String,String>();
                        Map<String,String> mapItemtoStatus = new Map<String,String>();                      
                        
                        
                        for(Payment_Items__c pi:[Select Payment_System__c,Guid__c from Payment_Items__c Where Guid__c IN :setPaymentUUids])
                        {
                            mapPIUidPSys.put(pi.Guid__c,pi.Payment_System__c);
                        }
                        
                        for(String ord : apiRespone.keySet())
                        {
                            String PaymentStatus ='';
                            if(apiRespone.get(ord).payments!=null)
                            {
                                String onlinePGStatus ='';
                                String walletPGStatus ='';
                                
                                for(String pi : apiRespone.get(ord).payments.keySet())
                                {
                                    if((mapPIUidPSys.containskey(pi)) && ('ONLINE'.equalsIgnoreCase(mapPIUidPSys.get(pi))))
                                    {
                                        if(String.isBlank(onlinePGStatus) || (String.isNotBlank(onlinePGStatus) && !'COMPLETED'.equalsIgnoreCase(onlinePGStatus)))
                                            onlinePGStatus = apiRespone.get(ord).payments.get(pi);
                                    }    
                                    else if(mapPIUidPSys.containskey(pi) && ('WALLETCORE'.equalsIgnoreCase(mapPIUidPSys.get(pi)) || 'WALLET_CORE'.equalsIgnoreCase(mapPIUidPSys.get(pi))))
                                    {
                                        walletPGStatus = apiRespone.get(ord).payments.get(pi);
                                    }
                                }
                                
                                PaymentStatus = String.isBlank(onlinePGStatus)?walletPGStatus:onlinePGStatus;
                            }
                            
                            if( apiRespone.get(ord).items!=null && String.isNotBlank(PaymentStatus))
                            {
                                for(String oi : apiRespone.get(ord).items.keySet())
                                {
                                    String finalItemStatus = 'TR_'+apiRespone.get(ord).items.get(oi)+'_PO_'+PaymentStatus;
                                    mapItemtoStatus.put(oi,finalItemStatus.toUpperCase());
                                }
                            }
                                
                        }
                        
                                        
                        List<Order_items__c> listTripstoUpdate = new List<Order_items__c>();
                        System.debug('....mapItemtoStatus...'+mapItemtoStatus);
                        dbl.Orders_Received_Data_Ids__c = (String.valueOf(mapItemtoStatus)+'..'+String.valueOf(mapItemtoStatus.keyset())).left(24999);
                        Set<String> setNonGFTStatus = new Set<String>{'TR_CONFIRMED_PO_COMPLETED','TR_BUS_CANCELLATION_PO_COMPLETED','TR_CANCELLATION_SUCCESSFUL_PO_COMPLETED','CANCELLATION_SUCCESSFUL'}; 
                        Map<String,Integer> mapBONameToCount = new Map<String,Integer>();
                        
                        for(Order_items__c orIt : [SELECT id,Status__c,Guid__c,Service_Provider_Name__c from Order_items__c WHERE Guid__c IN : mapItemtoStatus.keySet()])
                        {
                            Order_items__c item = new Order_items__c();
                            item.id = orIt.id;
                            item.status__c = mapItemtoStatus.get(orIt.Guid__c);
                            listTripstoUpdate.add(item);   
                            if(!setNonGFTStatus.contains(item.status__c) && orIt.Service_Provider_Name__c!=null)
                            {
                                if(mapBONameToCount.containsKey(orIt.Service_Provider_Name__c))
                                {
                                    mapBONameToCount.put(orIt.Service_Provider_Name__c,mapBONameToCount.get(orIt.Service_Provider_Name__c)+1);
                                }
                                else
                                {
                                    mapBONameToCount.put(orIt.Service_Provider_Name__c,1);
                                }
                                    
                            }
                        }
                                    
                        for(Case cs: caseList)
                        {
                            cs.FT_Verified__c = true;
                        }
                        
                        dbl.Payment_Items_Data_Received_Ids__c = String.valueOf(listTripstoUpdate).left(9999);
                        System.debug('listTripstoUpdate..'+listTripstoUpdate+'..caseList..'+caseList);
                        
                         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        List<String> toAddresses = new List<String>();
                        toAddresses.addAll(Label.GFTSchedulerNotification.Split(','));
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('GFT\''+'s Count in Last 5 Mins is High at-'+Datetime.valueOf(System.now()).format());
                       
                       if (!mapBONameToCount.keyset().isEmpty())
                        {
                            String strhtmlBody = ' <html> <body style="font-family: Arial; font-size: 9pt;" >';
                            strhtmlBody += ' Hi Team, <br></br> <br></br>' + ' Please find the below detailed report for GFT Transactions'+'<br> </br><br></br> ' ;
                            strhtmlBody += ' <body style="font-family: Arial; font-size: 9pt;" >';          
                            strhtmlBody += ' <table border="1" cellpadding="4" cellspacing="1" > ';
                            strhtmlBody += ' <thead bgcolor="cyan"><tr> <th><B>Bus Operator Name</B></th> <th><B>GFT Count</B></th> </tr></thead><tbody>';
                            Integer totalGftCount = 0;                          
                            for(String boName : mapBONameToCount.keyset())
                            {
                                strhtmlBody += '<tr>';
                                strhtmlBody += '<td>' + boName + '</td>';
                                strhtmlBody += '<td>' + mapBONameToCount.get(boName) + '</td>';
                                strhtmlBody += '</tr>';
                                totalGftCount = totalGftCount+mapBONameToCount.get(boName);
                                
                            }
                            strhtmlBody+= '<tr><th><B>Total Count</B></th><td>'+totalGftCount+'</td></tr></table><br></br>';
                            strhtmlBody+='<br></br>This is a computer generated e-mail. No response is required.<br></br><br></br>Thank you.<br></br>Salesforce Administrator </body></html>';
                            
                            mail.setHtmlBody(strhtmlBody);
                            if(totalGftCount>Integer.valueOf(System.Label.GFT_Report_Threshold))
                                Messaging.sendEmail(New Messaging.SingleEmailMessage[] {mail});
                          
                        }
                        
                        if(!listTripstoUpdate.isEmpty())
                        {
                            Database.SaveResult[] srList = Database.update(listTripstoUpdate, false);
                            // Iterate through each returned result
                            for (Database.SaveResult sr : srList) {
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                                    dbl.Order_Items_Success__c = String.valueOf(dbl.Order_Items_Success__c+'..'+ sr.getId()).left(9999);
                                }
                                else {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('Account fields that affected this error: ' + err.getFields());
                                        dbl.Order_Items_Failed__c = dbl.Order_Items_Failed__c+'..'+err.getStatusCode() + ': ' + err.getMessage()+'::'+err.getFields();
                                    }
                                }

                            }
                            
                        }    
                        if(!caseList.isEmpty())
                        {
                            Database.SaveResult[] srList = Database.update(caseList, false);
                            // Iterate through each returned result
                            for (Database.SaveResult sr : srList) {
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                                    dbl.Payment_Sessions_Success__c = dbl.Payment_Sessions_Success__c+'..'+ sr.getId();
                                }
                                else {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('Account fields that affected this error: ' + err.getFields());
                                        dbl.Payment_Sessions_Failed__c = dbl.Payment_Sessions_Failed__c+'..'+err.getStatusCode() + ': ' + err.getMessage()+'::'+err.getFields();
                                    }
                                }
                        
                            }
                        }
                        
                    }
                }
                
                Catch(Exception ex)
                {
                  System.debug('Exception in GFT Schedular..'+ex);
                  dbl.Exception_Description__c = string.valueOf(ex);
                }
               
               if(apiEndPoint.EnableLog__c)
                 insert dbl;
        }
    }
    
    public class RepsoneWrapper
    {
      public string OrderId{get;set;}
      public string TransactionState{get;set;}
      
    } 
    
    public class ItmesPaymentsWrapper
    {
      public map<string, string> payments { get; set; }
      public map<string, string> items { get; set; }
    }   
}