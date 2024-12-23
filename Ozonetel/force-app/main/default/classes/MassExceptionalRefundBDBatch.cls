/**
* (c) 2022 RedBus
*
* Name           : MassExceptionalRefundBDBatch
* Created Date   : 27 May 2022
* Created By     : Mahendra k
* Purpose        : Batch class to process mass exceptional refund for the bulk cases
**/

global class MassExceptionalRefundBDBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts
{  
    
    global final String Query;
    
    public MassExceptionalRefundBDBatch(){}
    
    public MassExceptionalRefundBDBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Mass_Exceptional_Refund_Query'].QueryDetails__c;
        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Mass_Exceptional_Refund_Query'].Duration__c;
        System.schedule('RPWescalatedtoBDBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new MassExceptionalRefundBDBatch(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<Mass_Exceptional_Refund__c> listMasExpcases)
    {     
        System.debug('MassExcept## ..'+listMasExpcases.size()+' records'+'..'+listMasExpcases);
        if(!listMasExpcases.isEmpty())
        {
            
            DateTime currTime = System.Now();
            List<case> listCases= new List<Case>();
            list<order_items__c> orItLs=new list<order_items__c>();
            list<casecomment> listCommToInsert = new List<casecomment>();
            List<Mass_Exceptional_Refund__c> listMasExpUpdate= new List<Mass_Exceptional_Refund__c>();
            list<Cancellation_Process_DB_Log__c> listCp = new List<Cancellation_Process_DB_Log__c>();
            Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
            
            for(Mass_Exceptional_Refund__c expcs: listMasExpcases)
            {
                string masExpRefundAmount = expcs.Exceptional_Refund_Amount__c;
                if(expcs.Parent_Case_Number__c!=null){
                    listCases=[select id,Booking_Email_ID__c,Service_Providerr_Id__c,Booking_Mobile_No__c,OrderItem_Uuid__c,Order_UUId__c from case where casenumber=:expcs.Parent_Case_Number__c];
                }
                
                if(!listCases.isEmpty()){
                    orItLs=[select id,Order_Item_Reference_No__c,Guid__c,OrderUuid__c from order_items__c where Order_Item_Reference_No__c=:expcs.TIN_No__c];
                }
                
                string orderItemUuid=String.isNotBlank(listCases[0].OrderItem_Uuid__c)?listCases[0].OrderItem_Uuid__c:String.isNotBlank(orItLs[0].Guid__c)?orItLs[0].Guid__c:'';
                String orderUUID = String.isNotBlank(listCases[0].Order_UUId__c)?listCases[0].Order_UUId__c:String.isNotBlank(orItLs[0].OrderUuid__c)?orItLs[0].OrderUuid__c:'';
                HttpResponse res = new HttpResponse();
                Http http1 = new Http();
                HttpRequest req = new HttpRequest();
                req = HttpRequestUtil.populateHeaders(req); 
                req.setMethod('GET'); 
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CapiMaxRefundableAPI'].Endpoint__c+orderUUID+'&tin='+expcs.TIN_No__c);
                try
                { 
                    cp.Type__c='Mass Exceptional Refund Batch';
                    cp.MAX_API_Request_Data__c = string.valueof(req)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency:INR';
                    res = http1.send(req);                                        
                    string maxRefundRespamount = res.getBody();
                    cp.MAX_API_Request_Response__c = string.valueof(res)+' Body : '+maxRefundRespamount;  
                    boolean excpRefundlessMaxrefund=false;
                    system.debug('==rseBody=='+res.getBody());
                    if(res.getStatusCode()==200 && maxRefundRespamount!='0')
                    {
                        
                        if(string.IsNotBlank(maxRefundRespamount))
                        {
                            cp.Max_API_Ping__c=True;
                            
                            expcs.Max_Refundapi_Amount__c=maxRefundRespamount;
                            system.debug('--masExpRefundAmount--'+masExpRefundAmount+'--maxRefundRespamount--'+maxRefundRespamount);
                            // integer maxApirespAmount =integer.valueof(maxRefundRespamount);
                            maxRefundRespamount= maxRefundRespamount.substringBefore('.');
                            
                            integer expRefund=integer.valueof(masExpRefundAmount);
                            integer maxapiResppRefund=integer.valueof(maxRefundRespamount);
                            
                            CP.Max_Refundable_Amount__c=maxapiResppRefund;
                                
                            system.debug('--expRefund--'+expRefund+'--maxapiResppRefund--'+maxapiResppRefund);
                            
                            if(expRefund <= maxapiResppRefund){
                                system.debug('--8--'+excpRefundlessMaxrefund);
                                excpRefundlessMaxrefund=True;
                                system.debug('--8--'+excpRefundlessMaxrefund+'==listMasExpUpdate=='+listMasExpUpdate);
                                
                                
                                system.debug('===refund-='+maxRefundRespamount+'==boolean='+excpRefundlessMaxrefund);
                                
                                //calling exceptional refund api
                                
                                ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput  exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
                                exceRfndReq.ticketNo = expcs.TIN_No__c;
                                exceRfndReq.emailId = String.isNotBlank(listCases[0].Booking_Email_ID__c)?listCases[0].Booking_Email_ID__c:String.isNotBlank(listCases[0].Booking_EMail_Copy__c)?listCases[0].Booking_EMail_Copy__c:'';
                                exceRfndReq.mobileno = string.isNotBlank(listCases[0].Booking_Mobile_No__c)?listCases[0].Booking_Mobile_No__c:'';
                                exceRfndReq.cancellationType = '1';        
                                exceRfndReq.selectedSeat='';
                                exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
                                exceRfndReq.orderItemUuid =orderItemUuid;
                                exceRfndReq.createdby = expcs.Approved_By__c;  
                                
                                if(listCases[0].Service_Providerr_Id__c!=null && System.Label.Instant_Exceptional_Refund_BOs.contains(listCases[0].Service_Providerr_Id__c)){
                                    exceRfndReq.IsExceptionalRefundApproved =false;
                                }else{
                                    if('Collectible From BO'.equalsIgnoreCase(expcs.Exceptional_Refund_Type__c) ||'OTG'.equalsIgnoreCase(expcs.Exceptional_Refund_Type__c))                 
                                        
                                        exceRfndReq.operatorContribution = Decimal.valueof(masExpRefundAmount);
                                }
                                exceRfndReq.reason =expcs.Exceptional_Refund_Type__c;
                                exceRfndReq.isExceptionalCancellation = true; 
                                
                                ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
                                monyMod.amount = Decimal.valueof(masExpRefundAmount);
                                monyMod.currencyType ='INR';
                                exceRfndReq.refund = monyMod;   
                                
                                Http http = new Http();
                                HttpRequest reqq = new HttpRequest();
                                reqq = HttpRequestUtil.populateCAPIHeaders(req);
                                reqq.setTimeout(120000);
                                reqq.setMethod('POST');
                                HttpResponse resp = new HttpResponse();
                                string jsonBody=Json.serialize(exceRfndReq);
                                reqq.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);
                                
                                Boolean refundStatus=false;
                                /*Map<string,WhiteLabelOperators__c> mapWloptrs = WhiteLabelOperators__c.getAll();
string wlOperName='';
system.debug('----case---'+csObj+'==='+csObj.Service_Provider_Id__c+'=='+csObj.Business_Unit_ct__c);
if(!csObj.Business_Unit_ct__c.startsWithIgnoreCase('REDBUS') && csObj.Service_Provider_Id__c!=null){
if(mapWloptrs.containskey(csObj.Service_Provider_Id__c)){
System.debug('========= ...');
wlOperName = csObj.Business_Unit_ct__c.split('_')[0];
req.setHeader('Operator',wlOperName);
}
}*/
                                
                                cp.FC_API_Request_Data__c = string.valueof(req)+'Body :'+jsonBody+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency :INR';
                                reqq.setBody(Json.serialize(exceRfndReq));   
                                
                                
                                cp.Refund_Reason__c = expcs.Exceptional_Refund_Type__c;
                                cp.Amount_to_be_Refunded__c = Decimal.valueof(masExpRefundAmount);
                                cp.TIN_Number__c =  exceRfndReq.ticketNo;
                                Order_Items__c orIt = new Order_Items__c();
                                orIt = [Select id from Order_Items__c where Order_Item_Reference_No__c=:cp.TIN_Number__c];
                                cp.Transaction_Name__c = orIt!=null?orIt.id:'';
                                cp.OrderItemUuid__c =orderItemUuid;
                                
                                resp = http.send(reqq);       
                                string responseValue = resp.getBody();
                                system.debug('---Tickt--'+resp.getBody());
                                cp.FC_API_Request_Response__c = string.valueof(resp)+' Body : '+responseValue;
                                
                                if(resp.getStatusCode()==200 && !string.isBlank(responseValue))
                                {
                                    refundStatus = true;
                                    ExceptionalRefundApprovalCntl.ExceptionalCanResponse exceRespone = new ExceptionalRefundApprovalCntl.ExceptionalCanResponse();
                                    cp.FC_API_Ping__c = true;
                                    exceRespone = (ExceptionalRefundApprovalCntl.ExceptionalCanResponse)JSON.deserialize(responseValue,ExceptionalRefundApprovalCntl.ExceptionalCanResponse.class);                        
                                    cp.FC_IsSuccess__c = 'SUCCESS'.equalsIgnoreCase(String.valueof(exceRespone.Status))?true:false;
                                    cp.FC_Response_Message__c = cp.FC_IsSuccess__c?'Refund has Initiated Successfully.':String.valueof(exceRespone.Status);
                                    cp.FC_API_Request_Response__c = string.valueof(exceRespone)+' Body : '+responseValue;
                                    if(exceRespone!=null && exceRespone.data!=null)
                                    {                           
                                        cp.FC_New_Tin__c = string.valueof(exceRespone.data.get('OrderItemUuid'));
                                        cp.FC_Refund_Amount__c = cp.Amount_to_be_Refunded__c;
                                    }
                                    expcs.Exception_Status__c=cp.FC_IsSuccess__c?'Refund has Initiated Successfully.':String.valueof(exceRespone.Status);
                                    expcs.Description__c='Refund has Initiated Successfully';
                                    listMasExpUpdate.add(expcs);
                                    listCp.add(cp);
                                }
                                else
                                {
                                    System.debug('==Received invalid response from the API=='+responseValue);
                                    map<string,object> exceFailRespone = (map<string,object>)JSON.deserializeUntyped(responseValue);
                                    if(exceFailRespone.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(exceFailRespone.get('DetailedMessage')))){
                                        cp.Detailed_Message__c = string.valueof(exceFailRespone.get('DetailedMessage'));
                                        expcs.Exception_Status__c='Cancellation API Failed';
                                        expcs.Max_Refundapi_Amount__c=maxRefundRespamount;
                                        expcs.Description__c=string.valueof(exceFailRespone.get('DetailedMessage'));
                                        listMasExpUpdate.add(expcs);
                                        listCp.add(cp);
                                        system.debug('==207=listCp=='+listCp);
                                    }
                                    
                                    
                                }
                                
                            }else{
                                expcs.Max_Refundapi_Amount__c=maxRefundRespamount;
                                expcs.Exception_Status__c='Max refund amount Failed';
                                cp.MAX_API_Request_Response__c='Sytsem message:-Failed because Exp Refund amount is grater than Max Refund api Amount'; 
                                expcs.Description__c='Refund amount is grater than Max Refund api Amount';
                                listMasExpUpdate.add(expcs);
                            }
                            
                        }
                    }else{
                        expcs.Max_Refundapi_Amount__c=res.getBody();
                        expcs.Exception_Status__c='MAX Refund api failed';
                        expcs.Description__c='MAX Refund api failed';
                        listMasExpUpdate.add(expcs);
                        
                    }  
                }Catch(Exception e)
                {
                    System.debug('Exception...'+e);
                    cp.FC_API_Request_Response__c = string.valueof(e);  
                    expcs.Description__c=string.valueof(e);
                    listMasExpUpdate.add(expcs);
                    listCp.add(cp);
                }
            }
            
            system.debug('==207=listCp=='+listCp+'==listMasExpUpdate=='+listMasExpUpdate);
            
            if(!listCp.isEmpty())
            {
              dataBase.insert(listCp,false);                
            }
            
            
            if(!listMasExpUpdate.isEmpty())
              DataBase.update(listMasExpUpdate,false);

               
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {                 
        /* AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
WHERE Id =:BC.getJobId()];

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
List<String> toAddresses = new List<String>();
toAddresses.add('Mahendrareddy.k@redbus.com.com');
mail.setToAddresses(toAddresses);
mail.setSubject('Case Assignment Has Finished '+a.Status);
mail.setPlainTextBody
('The batch Apex job processed ' + a.TotalJobItems +
' batches with '+ a.NumberOfErrors + ' failures.');
if(a.NumberOfErrors>0)
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
    }
}