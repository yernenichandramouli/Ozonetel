/**
 * (c) 2017 RedBus
 *
 * Name           : API_redBus_Cancellation
 * Created Date   : 10 Mar 2017
 * Created By     : Sreenivas M
 * Purpose        : API to create bus cancellation cases from RB+ and SeatSeller
 *
 **/
 
@RestResource(urlMapping='/redBus/busCancellation/*')
global without sharing class API_redBus_Cancellation
{
    @HttpPost
    global static Response doPost()
    {
        Response resp = new Response();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String CsOrgin = req.headers.get('source');
        system.debug('-----------request data debug--------'+req.requestBody.toString()+'...'+req.headers.get('source'));
        
        try
        {
            List<BusCancelReq> data = (List<BusCancelReq>)JSON.deserialize(req.requestBody.toString(),List<BusCancelReq>.class);   
            system.debug('-----------request data serialized debug--------'+data );
            Set<String> setStatus = new Set<String>(System.Label.Bus_Cancellation_Status.split(','));
            
            if(!data.isempty())
            {
                set<string> routeid= new set<string>();
                set<string> tin= new set<string>();
                set<string> status = new set<String>();
                set<DateTime> doj= new set<DateTime>();
                set<string> opIds=new set<string>();
                
                Map<string,BusCancelReq > tinMap= new Map<string,BusCancelReq >();
                for(BusCancelReq rec : data)
                {
                    for(string tinval : rec.tin)
                    {
                        tinMap.put(tinval,rec);
                        tin.add(tinval); 
                        if(rec.operatorId!='')
                        opIds.add(rec.operatorId);                        
                    }
                    routeid.add(String.valueof(rec.routeId));
                    status.add(String.ValueOf(rec.status));           
                    doj.add(DateTime.valueof(rec.doj));
                }
                Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                List<Order_Items__c> ListOI = new List<Order_Items__c>();
                ListOI = [Select Id,Name,Service_Provider_Name__c,Guid__c,Corrected_Date_of_Journey__c,Service_Provider_Id__c,Route_Id__c,Order_Item_Reference_No__c,Customer_Name__c,Primary_Contact_Customer__c,ID__c,Order_Id__c from Order_Items__c where Order_Item_Reference_No__c IN :tin];
                system.debug('-----------ListOI  debug--------'+ListOI );
                
                List<Service_Provider__c> spList=new List<Service_Provider__c>();
                spList=[select id,Operator_Id__c,Location__c from Service_Provider__c where Operator_Id__c in:opIds];
                Map<string,Service_Provider__c> spMap=new Map<string,Service_Provider__c>();
                for(Service_Provider__c s:spList){
                  spMap.put(s.Operator_Id__c,s);
                }
                
                Map<string, Order_Items__c >  orderitemsmap = new Map<string, Order_Items__c >();
                for(Order_Items__c rec : ListOI)
                {
                    orderitemsmap.put(rec.Order_Item_Reference_No__c, rec);
                }
                system.debug('-----------orderitemsmap debug--------'+orderitemsmap);
               
                Case[] cobjAdd = new List<Case>();
                Case[] cobjUpdate = new List<Case>();
                Map<string,Case> maptintoCase = new Map<String,Case>();
                
                for(case cobj :[select TIN_No__c from case where TIN_No__c IN : tin])
                {
                    maptintoCase.put(cobj.TIN_No__c,cobj);
                }
                system.debug('-----------maptintoCase debug--------'+maptintoCase);
                
                List<BusCancelInitiationProcess.JsonWrapper> listWrap = new List<BusCancelInitiationProcess.JsonWrapper>();
                
                for(BusCancelReq item: data)
                {
                    if(setStatus.contains(item.status))
                        {
                            for(string tinval : item.tin)
                            {
                               
                                    system.debug('-----------item debug--------'+item);    
                                    case ct = new case();
                                    ct.RecordTypeId = recTypeId;   
                                    ct.Origin = CsOrgin;
                                    
                                    if('RB+'.equalsIgnoreCase(CsOrgin))
                                    {
                                        ct.Status='Closed';
                                        ct.Notes__c = item.status;
                                        ct.Type = 'B2C';
                                    }
                                    else
                                    {
                                        ct.Status= 'Initiated';
                                        ct.Type = 'B2B';
                                    }
                                  
                                    ct.TIN_No__c= tinval;
                                    ct.SS_DOJ__c = orderitemsmap.containsKey(tinval) ? orderitemsmap.get(tinval).Corrected_Date_of_Journey__c : Datetime.valueof(string.valueof(item.doj));
                                    ct.SS_Route_Id__c = item.routeId;
                                    ct.Issue_Sub_Category__c = 'Initiate Bus Cancellation';
                                    ct.Transaction_ID__c = orderitemsmap.containsKey(tinval) ? orderitemsmap.get(tinval).Id : null;
                                    ct.Issue_Type__c = 'Bus Cancellation';
                                    ct.Partner__c=item.partner;
                                    ct.AmountD__c=item.totalTicketAmount;
                                    ct.SourceT__c=item.source;
                                    ct.DestinationT__c=item.destination;
                                    ct.pnr__c=item.pnr;
                                    ct.Operator_Id__c=item.operatorId;
                                    ct.BD_Location__c=spMap.containsKey(item.operatorId) ?spMap.get(item.operatorId).location__c:null;
                                    ct.Partner_Acc_Number__c = item.accNum;
                                    
                                    if(maptintoCase.containsKey(tinval))
                                    {
                                        ct.id = maptintoCase.get(tinval).Id;
                                        cobjUpdate.add(ct);
                                    }
                                    else                    
                                        cobjUpdate.add(ct);

                                    system.debug('-----------cobjUpdate debug--------'+cobjUpdate);
                                    
                                    String orderItemUUId = orderitemsmap.containsKey(tinval) ? orderitemsmap.get(tinval).Guid__c:'';
                                    String pNotes = 'Refund by redBus'.equalsIgnoreCase(ct.Notes__c)?'Cancel Ticket':ct.Notes__c;
                                    String pStatus = 'Approved For Bus Cancellation'.equalsIgnoreCase(ct.status)?'APPROVED': ct.status.toUpperCase();                                              
                                    BusCancelInitiationProcess.JsonWrapper wrap = new BusCancelInitiationProcess.JsonWrapper(ct.TIN_No__c,pStatus,Datetime.valueOfGMT(String.valueOf(item.doj)).addDays(-1).formatGMT('yyyy-MM-dd 00:00:00'),Integer.valueof(ct.SS_Route_Id__c),orderItemUUId,String.valueof(System.now()),UserInfo.getUserName(),'','',pNotes);
                                    listWrap.add(wrap);
                                
                            }
                        }
                }
                
                try
                {
                    if(!cobjUpdate.isEmpty())
                        upsert cobjUpdate;
                        
                }
                catch(exception e)
                {
                    resp = new response();
                    resp.statusMessage = 'Exception while creating case';
                    resp.statusCode = '500';
                    system.debug('-----------resp Exception debug--------'+resp+'--Exception:'+e);              
                    return resp;
                }
                
                Map<String,String> mapTinToCaseId = new Map<String,String>();
                for(Case cs : [Select id,TIN_No__c from case where TIN_No__c in :tin])
                {
                    mapTinToCaseId.put(cs.TIN_No__c,cs.id);
                }
                List<String> opertionVals = new List<String>{'BusCancellationAPI','-NA-','BusCancellationAPI','BusCancellationAPI'};
                
                System.debug('listWrap....'+listWrap);
                
                if(!System.isFuture() && !System.isBatch())
                    BusCancellationHandler.getAllViaRoutesTins(JSON.serialize(listWrap),opertionVals,tin,mapTinToCaseId); 
                
                system.debug('****tin*****'+tin);
                
                List<case> cresult = [select TIN_No__c from case where TIN_No__c in :tin];
                system.debug('-----------cresult  debug--------'+cresult); 
                List<string> successtins = new List<string>();
                
                for(case ress : cresult)
                {
                    successtins.add(ress.TIN_No__c);
                }
                
                system.debug('-----------successtins debug--------'+successtins);
                
                if(successtins != null && !successtins.isEmpty())
                {
                    resp = new response();
                    resp.tin = successtins ;
                    resp.statusMessage = 'SUCCESS';
                    resp.statusCode = '200';
                }
                
                system.debug('-----------final resp  debug--------'+resp);
            }
        }
        catch(exception e)
        {
            resp = new response();
            resp.statusMessage = 'Exception while processing your request';
            resp.statusCode = '500';
            system.debug('-----------final resp Exception  debug--------'+e);
        }
        return resp;
    }
    

    global class BusCancelReq
    {
        public string routeId;
        public list<String> tin;        
        public string doj;  
        public string status;
        public string partner;
        public string totalTicketAmount;
        public string source;
        public string destination;
        public string operatorId;
        public string pnr;
        public string accNum;
    }
    
    global class Response
    {
        List<string> tin;
        public string statusMessage;
        public string statusCode;
        public Response()
        {
        
        }
    }
}