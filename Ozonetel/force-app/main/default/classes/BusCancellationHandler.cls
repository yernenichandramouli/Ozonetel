/**
* (c) 2017 RedBus
*
* Name           : BusCancellationHandler
* Created Date   : 04 Jan 2017
* Created By     : Sreenivas M
* Purpose        : Handeler class for BusCancellation Initiation and Updatations
* Test class     : BusCancellationExtnIntlTest
*
**/

public class BusCancellationHandler {
    
    Static String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='BusCancellation'].Endpoint__c;
    
    @future(Callout=true)
    public static void insertCancelItems(String jsonBody)
    {
        jsonBody = '['+jsonBody+']';
        System.debug('jsonBody.2..'+jsonBody);  
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        req.setEndpoint(System.Label.Bus_Cancellation_URI+'Insert');
        //req.setEndpoint(endPoint+'Insert');
        req.setMethod('POST');
        req.setBody(jsonBody);
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'Bus Cancellation Insert';
        dbl.Payment_Request_Sent_Time__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+jsonBody;
        dbl.SentAt__c = system.now();
        dbl.Order_Items_Data_Received_Ids__c = String.valueOf(((Map<String,Object>)((list<object>)JSON.deserializeUntyped(jsonbody))[0]).get('tin'));
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try
        {
            res = http.send(req);
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            string responseValue = res.getBody();
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'Bus Cancellation Initiation Success';
            
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
                System.debug('Bus cancel insert success...'+responseValue);
            }
            insert dbl ;
        }
        Catch(Exception e)
        {
            system.debug('---Exception in Bus cancel insert---------------'+e);
            dbl.Response_Received__c =  String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'Bus Cancellation Initiation Failed';
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());                  
            insert dbl ;
            
            if(ApexPages.currentPage()!=null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        
    }
    
    
    @future(callout=true)
    public static void getAllViaRoutesTins(String pjsonBody,List<String> opTypeApprovals,Set<String> setTin,Map<String,String> mapTinToCaseId)
    {
        
        List<JsonBodyWrapper> caselist = new  List<JsonBodyWrapper>();
        caselist = (List<JsonBodyWrapper>)System.JSON.deserialize(pjsonBody ,List<JsonBodyWrapper>.class);
        list<case> csDet=new list<case>();
         string comCurrency='';
        csDet = [SELECT Country__c,Business_Unit_ct__c FROM Case WHERE Business_Unit_ct__c!=NULL AND TIN_No__c IN:setTin LIMIT 1];  
        list<Order_Items__c> ordlist=[select id,Order_Item_Reference_No__c,Amount_Recieved_Currency__c,Business_Unit__c from Order_Items__c where Order_Item_Reference_No__c =: setTin LIMIT 1];
        if(!ordlist.isEmpty()){
           comCurrency=ordlist[0].Amount_Recieved_Currency__c;
        }
        String strBUnit ='REDBUS_IN';                 
        String strCountry = 'India';
        if(!csDet.isEmpty()){
        strBUnit ='REDBUS_'+csDet[0].Business_Unit_ct__c.split('_')[1];
        strCountry =csDet[0].Country__c;
        }
        system.debug('--strBUnit--'+strBUnit);
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        
        if('REDBUS_COM'.equalsIgnoreCase(strBUnit)){
           system.debug('--com---');
            req.setHeader('Channel_Name', 'WEB_DIRECT');
            req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('BusinessUnit', 'BUS');
            req.setHeader('Country_Name','RDC');
            req.setHeader('SelectedCurrency',comCurrency);
            req.setHeader('Currency',comCurrency);
        }else{
            req = HttpRequestUtil.populateCMAPIHeaders(req,strBUnit);   
        }
        req.setMethod('POST');
        req.setBody(pjsonBody);       
      //endpoint = endpoint.replace('cmapi.redbus.com','10.5.20.223');                    
        req.setEndpoint(endPoint+'Update');
        system.debug('<<endpoint'+endpoint);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'Bus Cancellation Update -'+opTypeApprovals.get(0);
        dbl.Payment_Request_Sent_Time__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+pjsonBody+'-Headers-currency--'+req.getHeader('SelectedCurrency')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key-'+req.getHeader('auth_key')+'--BusinessUnit--'+req.getHeader('BusinessUnit');
        dbl.Order_Items_Data_Received_Ids__c = String.valueOf(setTin);
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try
        {
            
            resp = http.send(req);
            dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
            system.debug('<<req'+req);
            system.debug('<<resp'+resp);            
            string responseValue = resp.getBody();
            dbl.Response_Received__c = String.valueOf(resp+'Resp Body..'+responseValue);
            dbl.Payment_Request_Response_Time__c = System.now();
            String opeartnType =opTypeApprovals.get(0);
            List<Case> listCasesToUpsert = new List<case>();
            
            if(resp.getStatus()=='OK' && resp.getStatusCode()==200)
            {
                
                dbl.Payment_Ping_Status__c = 'Bus Cancellation Update Success';        
                System.debug('Bus cancel update success...'+responseValue);
                List<ViaRouteTinsResponse> listTinsForViaRoute = new  List<ViaRouteTinsResponse>();
                listTinsForViaRoute = (List<ViaRouteTinsResponse>)System.JSON.deserialize(responseValue ,List<ViaRouteTinsResponse>.class);
                
                
                if('Approved'.equalsIgnorecase(opTypeApprovals.get(0)))
                {
                    
                    Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                    System.debug('Response...'+listTinsForViaRoute);
                    
                    Set<String> listTins = new Set<String>();
                    for(ViaRouteTinsResponse res : listTinsForViaRoute)
                    {
                        if(!setTin.contains(res.tin))
                            listTins.add(res.tin);
                    }
                    
                    dbl.Order_Items_Data_Received_Ids__c = String.valueOf(setTin+'....'+listTins);
                    Map<String,Id> mapTintoOrItemId = new Map<String,Id>();
                    Map<String,List<Case>> mapTintoCase = new Map<String,List<Case>>();
                    List<Case> listCaseToInsert = new List<Case>();
                    List<Case> listCaseToUpdate = new List<Case>();
                    
                    for(Order_Items__c orItem :[SELECT id,Order_Item_Reference_No__c,(SELECT id from cases1__r where recordTypeId=:RecTypeId) FROM Order_Items__c WHERE Order_Item_Reference_No__c IN :listTins])
                    {
                        mapTintoOrItemId.put(orItem.Order_Item_Reference_No__c,orItem.id);
                        mapTintoCase.put(orItem.Order_Item_Reference_No__c,orItem.cases1__r);                   
                    }
                    
                    for(ViaRouteTinsResponse res : listTinsForViaRoute)
                    {
                        if(!setTin.contains(res.tin))
                        {
                            Case cs = new Case();
                            cs.Status = 'Approved For Bus Cancellation';
                            cs.RecordTypeId = RecTypeId;
                            cs.TIN_No__c = res.tin;
                            cs.notes__c = res.notes;
                            cs.Issue_Type__c ='Bus Cancellation';
                            cs.Origin ='InBound Call';
                            cs.BOAgentContactBySPOC__c = opTypeApprovals.get(1);
                            cs.BOAgentNameBySPOC__c = opTypeApprovals.get(2);
                            cs.Approved_By__c = opTypeApprovals.get(3);
                            cs.Approved_Rejected_Time__c = System.now();
                            cs.Is_Secondary_SourceInfo__c = true;
                            
                            if(mapTintoOrItemId.containsKey(res.tin))
                            {
                                cs.Transaction_ID__c = mapTintoOrItemId.get(res.tin);
                                
                                if(mapTintoCase.get(res.tin)!=null && mapTintoCase.get(res.tin).size()>0)
                                {
                                    cs.Id = mapTintoCase.get(res.tin)[0].id;
                                    listCaseToUpdate.add(cs);
                                }
                                else
                                    listCasesToUpsert.add(cs);
                            }
                            
                            else
                                listCasesToUpsert.add(cs);
                        }     
                    }
                    
                    system.debug('---size...'+listCaseToUpdate.size()+'...'+listCasesToUpsert.size());
                    
                }
                
                //Revert Status Changed From Refunded By redBus To Approved
                else if('Refunded by redBus'.equalsIgnorecase(opeartnType))
                {
                    
                    for(ViaRouteTinsResponse res :listTinsForViaRoute)
                    {
                        if(!res.isSuccess)
                        {
                            Case cs = new Case();
                            cs.id = mapTinToCaseId.get(res.tin);
                            cs.status ='Approved For Bus Cancellation';
                            cs.notes__c ='';
                            listCasesToUpsert.add(cs);
                        }
                    }
                }
                
            }
            
            //API Ping is Failed
            else
            {
                if('Refunded by redBus'.equalsIgnorecase(opeartnType))
                {
                    for(String csTin:mapTinToCaseId.keySet())
                    {
                        Case cs = new Case();
                        cs.id = mapTinToCaseId.get(csTin);
                        cs.status ='Approved For Bus Cancellation';
                        cs.notes__c ='';
                        listCasesToUpsert.add(cs);
                    }
                }
                
                System.debug('Bus cancellation ERROR: '+resp.getStatusCode()+': '+resp.getStatus()+'..'+resp.getBody());
                dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'Bus Cancellation Update Failed';                         
                
                if(ApexPages.currentPage()!=null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error occured while processing request'+resp.getStatus()));
                
            }
            
            if(!listCasesToUpsert.isEmpty())
                DataBase.upsert(listCasesToUpsert,false);
            
            system.debug('<<dbl'+dbl);
            insert dbl;
            
        }
        
        Catch(Exception e)
        {
            system.debug('---Exception in Bus cancellation update---------------'+e);
            dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'Bus Cancellation Update Failed While Making Request';
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());                  
            insert dbl ;
            
            if(ApexPages.currentPage()!=null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        
    }
    
    public class ViaRouteTinsResponse
    {
        public string tin{get;set;}
        public string status{get;set;}
        public boolean isSuccess{get;set;}
        public string notes{get;set;}
        public integer routeId{get;set;}
    }
    public class JsonBodyWrapper
    {
        public string approvedBy{get;set;}
        public string boAgentContactBySPOC{get;set;}
        public string boAgentNameBySPOC{get;set;}
        public string status{get;set;}
        public string doj{get;set;}
        public string tin{get;set;}
        public string notes{get;set;}
        public Integer routeId{get;set;}       
        public string initiatedBy{get;set;}
        public string cancellationStatus{get;set;}
        public string createdTime{get;set;}
        public string updatedTime{get;set;}
        public string boAgentNameByCSE{get;set;}
        public string boAgentContactByCSE{get;set;}
        public string SPOCNameByCSE{get;set;} 
        public string orderItemUuid{get;set;} 
        public string localeName{get;set;}
        public string TransactionID{get;set;}
        
    }
}