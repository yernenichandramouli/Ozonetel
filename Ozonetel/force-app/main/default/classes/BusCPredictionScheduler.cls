/*
* Name           : BusCPredictionScheduler
* Created Date   : 25 May 2018
* Created By     : Veeramanikanta R
* Purpose        : Scheduler for creating bus cancellation predication cases  
* Test class     : BusCPredictionSchedulerTest
*/
global class BusCPredictionScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        busCPredictionCallout();
    }
    
    @future(callout=true)
    public static void busCPredictionCallout()
    {        
        list<case> caseList = new list<case>();
        Set<String> setPaymentUUids = new Set<String>();
        
        date doj=date.today();
        datetime dt=datetime.now();
        //  string tim=string.valueof(dt.time());
        string  tinTime=string.valueof(dt.time()).substring(0, 2);
        String currentHour;
        if(tinTime=='16')
            currentHour='4pm';
        else if(tinTime=='18')
            currentHour='6pm'; 
        
        /* doj=doj.adddays(-12);
System.debug('up doj-->'+doj);
currentHour='4PM';
tinTime='16';
*/
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PredictionBC'];
        string ep=APIMData.Endpoint__c+currentHour+'&doj='+doj;
        string jsonCM='{"action":"GET","body":"","endPoint":"'+ep+'","headers":""}';
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setMethod('POST');
        req.setBody(jsonCM);
        req.setEndpoint(APIMData.Endpoint__c);
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'BuscPrediction Scheduler';
        dbl.Payment_Request_Sent_Time__c = system.now();
        dbl.Request_Data__c = string.valueof(req)+jsonCM;
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try{
            res=h.send(req);  
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            if(res.getStatus()=='OK' && res.getStatusCode()==200){
                System.debug('req-->'+req);
                System.debug('rr-->'+res.getStatus()); 
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'BusC Prediction Scheduler Success';  
                List<Response> tinList=new List<Response>();
                set<string> tins=new set<string>();
                list<case> listCases=new list<case>();
                Map<string,case> caseMap=new Map<string,case>();
                list<Order_Items__c> tList=new list<Order_Items__c>();
                Map<string,Order_Items__c> trnMap=new Map<string,Order_items__c>();
                list<case> casesToCreate=new list<case>();
                List<case> casesToUpdate=new List<case>();
                casesToCreate.clear();
                casesToUpdate.clear();
                
                string mJson='[{"tin":"TM5N62346289"},{"tin":"TM5R49721669"},{"tin":"TM5W91090115"},{"tin":"TM5J37938592"},{"tin":"TM5E61773593"},{"tin":"TM5X99580184"},{"tin":"TM5W15116204"},{"tin":"TM5H48294107"}]';
                List<Response> resTins=new List<Response>();
                resTins= (List<Response>)System.JSON.deserialize(res.getbody(),List<Response>.class);
                
                System.debug('res-->'+resTins);
                
                for(Response r:resTins){
                    tinList.add(r);
                    tins.add(r.tin);
                }
                
                listCases=[select id,tin_no__c,transaction_id__c,transaction_id__r.name,caseNumber,status from case where tin_no__c in:tins and Issue_Type__c='Bus Cancellation'];
                for(case c:listCases){
                    caseMap.put(c.tin_no__c,c);
                }
                
                tList=[select id,Order_Item_Reference_No__c,name from Order_Items__c where Order_Item_Reference_No__c in:tins];
                for(Order_Items__c t:tList){
                    trnMap.put(t.Order_Item_Reference_No__c,t);
                }
                Id RecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                System.debug('trnMap-->'+trnMap);
                System.debug('caseMap-->'+caseMap);
                for(Response r:resTins){
                    if(!caseMap.containskey(r.tin)){
                        Case cs = new Case();
                        cs.Status = 'Initiated';
                        cs.RecordTypeId = RecTypeId ;
                        cs.Issue_Type__c ='Bus Cancellation';
                        cs.Origin ='BusC Prediction';
                        cs.Is_Secondary_SourceInfo__c = false;
                        cs.tin_no__c=r.tin;
                        cs.BusC_PD_Time__c=tinTime;
                        cs.PD_DOJ__c=doj;
                        if(trnMap.get(r.tin)!=null)
                            cs.Transaction_ID__c=trnMap.get(r.tin).id;
                        casesToCreate.add(cs);
                    }else{
                        case cU=new case();
                        cu.id=caseMap.get(r.tin).id;
                        cu.BusC_PD_Time__c=tinTime;
                        cu.PD_DOJ__c=doj;
                        if(trnMap.get(r.tin)!=null)
                            cu.Transaction_ID__c=trnMap.get(r.tin).id;
                        casesToUpdate.add(cu);
                    }
                }
                if(!casesToCreate.isEmpty())
                    database.insert(casesToCreate,false);
                
                if(!casesToUpdate.isEmpty())
                    database.update(casesToUpdate,false);
                
            }else{
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'BusC Prediction Scheduler API Fail';
            } 
        } catch(Exception e){
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'BusC Prediction Scheduler Fail';
            dbl.Exception_Description__c = string.valueOf(e);
        }
        insert dbl;
    }
    public class Response{
        public string tin{get;set;}      
    }
}