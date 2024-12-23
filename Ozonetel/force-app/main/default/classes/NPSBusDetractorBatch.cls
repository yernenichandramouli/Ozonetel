/**
 * (c) 2018 RedBus
 *
 * Name           : NPSBusDetractorBatch
 * Created Date   : 02 Huly 2018
 * Created By     : Sreenivas M
 * Purpose        : Batch class to process create NPS Bus Detractor Cases
 * Test class     : NPSBusDetractorBatchTest
 *
 **/
 
global class NPSBusDetractorBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
    public string query;
      
    public NPSBusDetractorBatch()
    {
    }
      
    public void execute(SchedulableContext scon)
    {
      Database.executeBatch(new NPSBusDetractorBatch(),200);
    }
    
    global List<Case> start(DataBase.BatchableContext bc)
    {
       list<case> caseList = new list<case>();
       date fromDate=System.today().adddays(-1);
       date toDate=System.today();
       string npsEndpoint=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='NPSDetractor'].Endpoint__c;
       string finalNPSEndpoint=npsEndpoint+fromDate+'&toDate='+toDate+'&bu='+1;
       string jsonCM='{"action":"GET","body":"","endPoint":"'+finalNPSEndpoint+'","headers":""}';
      
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        System.debug('jsonCM-->'+jsonCM);
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setMethod('POST');
        req.setBody(jsonCM);
        req.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c);
        dbl.SentAt__c = system.now();
        dbl.Type__c = 'NPS Bus Scheduler Batch';
        dbl.Payment_Request_Sent_Time__c = system.now();
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonCM;
        dbl.Request_Data__c = string.valueof(req)+jsonCM;
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        
        try
        {
            res=h.send(req);  
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
                System.debug('req-->'+req);
                System.debug('rr-->'+res.getbody()); 
                //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Response_Received__c = String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);
                dbl.Payment_Request_Response_Time__c = System.now();
                dbl.Payment_Ping_Status__c = 'NPS bus Scheduler Success';
                
                set<string> tins=new set<string>();
                list<case> listCases=new list<case>();
                Map<string,Order_Items__c> trnMap=new Map<string,Order_items__c>();
                      
                List<HttpRequestWrappersUtil.NPSBusDectractorsResponse> resTins=new List<HttpRequestWrappersUtil.NPSBusDectractorsResponse>();
                resTins= (List<HttpRequestWrappersUtil.NPSBusDectractorsResponse>)System.JSON.deserialize(res.getbody(),List<HttpRequestWrappersUtil.NPSBusDectractorsResponse>.class);
                               
                for(HttpRequestWrappersUtil.NPSBusDectractorsResponse r:resTins)
                {
                    if(String.isNotBlank(r.tin))
                         tins.add(r.tin);
                    
                }
                            
                for(Order_Items__c t:[select id,Order_Item_Reference_No__c,name from Order_Items__c where Order_Item_Reference_No__c in:tins]){
                    trnMap.put(t.Order_Item_Reference_No__c,t);
                }
               
                Id  grpId = [Select id from Group where type='Queue' AND developername='NPS_Queue'].id;
                
                for(HttpRequestWrappersUtil.NPSBusDectractorsResponse r:resTins)
                {                 
                    Case cs = new Case();
                    cs.Request_Id__c= string.valueof(r.RequestId);
                    cs.SS_DOJ__c=date.valueof(r.DateOfJourney);
                    cs.TIN_No__c=r.tin;
                    cs.Phone_No_ct__c=r.MobileNumber;
                    cs.Email_Id_ct__c=r.EmailId;
                    cs.NP_Score__c=r.NPS;
                    cs.Bus_Operator_Namee__c =r.Travels;
                    cs.Service_Providerr_Id__c=r.OperatorId;
                    cs.Feedback__c=r.Feedback;
                    cs.Status = r.status;
                    cs.Source_And_Destination__c=r.Routes;
                    cs.No_of_Seats__c=string.valueof(r.NoofSeats);
                    cs.Issue_Type__c ='NPS';
                    cs.Issue_Sub_Category__c='NPS Bus';
                    cs.Origin ='NPS Bus';
                    cs.ownerId = grpId;
                    cs.Country__c='India';
                    cs.Nps_Response_Date__c= datetime.valueof((string)r.CreateDate);
                    if(trnMap.get(r.tin)!=null)
                        cs.Transaction_ID__c=trnMap.get(r.tin).id;
                    
                    caseList.add(cs);
                }
            }
        }
        Catch(Exception e)
        {
            dbl.Exception_Description__c = String.valueOf(e);
        }
        insert dbl;
        return caseList;
    }
    
    global void execute(DataBase.BatchableContext bc,List<Case> lstcases)
    {
        try
        {
            DataBase.insert(lstcases,false);
        }
        catch(Exception e)
        {
            System.debug('Exception ..'+e);
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