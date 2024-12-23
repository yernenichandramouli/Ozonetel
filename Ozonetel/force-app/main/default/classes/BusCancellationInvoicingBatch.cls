/**
 * (c) 2017 RedBus
 *
 * Name           : BusCancellationInvoicingBatch
 * Created Date   : 21 Mar 2022
 * Created By     : mahendra k
 * Purpose        : Batch class to process invoicing for Bus Cancellation Cases
 * Test class     : BusCancellationInvoicingSchedularTest
 *
 **/

global class BusCancellationInvoicingBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    public string query;

    public BusCancellationInvoicingBatch(String strQuery){
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCageAgeingRefundUpdateBatch'].QueryDetails__c;
        }
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug('query...'+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        List<case> listCaseToUpdate = new List<case>();
        Map<String,String> mapTinCsId = new Map<String,String>();
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();

        set<string> ccIds=new set<string>();
        List<casecomment> ccList=new List<casecomment>();
        list<RequestWrapper.orders> orList=new list<RequestWrapper.orders>();
        
        for(Case cs:lstcases )
        {
            
            RequestWrapper.orders orObj=new RequestWrapper.orders();
            orObj.orderItemUUID=cs.Transaction_id__r.Guid__c;
            orObj.tin=cs.tin_no__c;               
            orlist.add(orObj);  
            mapTinCsId.put(cs.TIN__c,cs.id);
        }
        
        string updateAction='Refunded as suggested by BO';
        
        RequestWrapper.BOSponcerWrapper rObj=new RequestWrapper.BOSponcerWrapper('SFA','Salesforce System update',updateAction,orlist);
        
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ExcepRefundBusCancellation'];
        string boJsonBody=JSON.serialize(rObj);
        System.debug('req body-->'+bojsonbody);
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        req.setEndpoint(APIMData.Endpoint__c);
        req.setMethod('POST');
        req.setBody(boJsonBody);
        try{
        resp = http.send(req);
        dbl.Type__c = 'Bus Cancellation Refunded Cases';
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'-Body-->'+boJsonBody;
        dbl.Request_Data__c = string.valueof(req)+'-Body-->'+boJsonBody;
        dbl.Order_Items_Process_Status__c=updateAction; 
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
        dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());

        if(resp!=null && String.isNotBlank(resp.getbody())){

        System.debug('tot req-->'+req);
        List<BOSponcerResponse> boResp=new List<BOSponcerResponse>();
        System.debug('res body-->'+resp.getbody());
        dbl.Response_Received__c=String.valueOf(resp+'..Body..'+resp.getBody());
        
        String mockJson='[{"tin":"TM4N54341643","status":"Success"},{"tin":"SGM4U26589393","status":"Success"}]';
        boResp = (List<BOSponcerResponse>)System.JSON.deserialize(resp.getbody(),List<BOSponcerResponse>.class);
        
        //  List<BOSponcerResponse> boRespList=new List<BOSponcerResponse>();
        List<DBLog_Summary__c> dblpList=new List<DBLog_Summary__c>();
        if(resp.getStatus()=='OK' && resp.getStatusCode()==200){
        for(BOSponcerResponse bObj:boResp){
        DBLog_Summary__c dblp = new DBLog_Summary__c();
        
            if(bObj.status=='Success'){
                Case cs = new Case();
                cs.id = mapTinCsId.get(bObj.tin); 
                //cs.id = caseMap.get(bObj.tin).id;  
                cs.status ='Closed';
                cs.notes__c =updateAction;
                System.debug('cs.id-->'+cs.id);
                if(cs.id!=null){
                    listCaseToUpdate.add(cs);
                    ccIds.add(cs.id);
                }
            } 
            dblp.Type__c='BusC Refunded Case'; 
            dblp.Order_Items_Process_Status__c=updateAction;  
            dblp.User_Id__c= bObj.tin;       
            dblp.Case_Number__c=mapTinCsId.get(bObj.tin);
            dblp.Payment_Request_Response_Data__c =bObj.status;
            dbl.Payment_Ping_Status__c= 'Records updated successfully!';
            dblpList.add(dblp);
        }     
        
        System.debug('--ccIds--->'+ccIds);

            for(string s:ccIds){
                casecomment ccObj=new casecomment();
                ccObj.CommentBody='System Update- Refunded By Ageing Scheduler Under Bus Cancellation- Refunded as suggested by BO';
                ccObj.parentid=s;
                ccList.add(ccObj);
        }
        
        String jsonB='{"reason":"BUS_CANCELLATION","refundedBy":"'+UserInfo.getName()+'('+UserInfo.getUserName()+')'+'","channel":"WEBDIRECT"}';
        
        
        System.debug('cList--->'+ccList);
        
        if(!listCaseToUpdate.isEmpty())
        {
            System.debug('listCaseToUpdate..size..'+listCaseToUpdate.size());
            try
            { 

                if(!dblpList.isEmpty())
                insert dblpList;

                if(!ccList.isEmpty())
                    insert ccList;
                
                update listCaseToUpdate;                               
            }         
            catch(Exception e)
            {
                System.debug('Exception ..'+e);
                dbl.Exception_Description__c=e.getMessage();

            } 
        }
        }else{
            dbl.Exception_Description__c='API failed, Please try again';

        }

        }
        else{
            dbl.Exception_Description__c='No Response from API';
        }

    } catch(Exception e){
            dbl.Exception_Description__c='Try catch Something went wrong Please try again';

        }
        insert dbl;        
    }

    public class BOSponcerResponse{
        public string tin;
        public string status;
    }

    global void finish(DataBase.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                            WHERE Id =:BC.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        //toAddresses.add('sreenivasa.mariyavula@redbus.com');
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com','sreenivasa.mariyavula@redbus.com'});
        mail.setSubject('Bus Cancellation Invoicing Processed..'+a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}