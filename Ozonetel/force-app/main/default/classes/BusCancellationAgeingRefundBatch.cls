/**
 * (c) 2017 RedBus
 *
 * Name           : BusCancellationAgeingRefundBatch
 * Created Date   : 06 April 2018
 * Created By     : Sreenivas M
 * Purpose        : Batch class to process the pending Bus Cancellation Case Under Customer Delight Exceptional Refund
 * Test class     : BusCancellationAgeingRefundSchedularTest
 *
 **/
 
global class BusCancellationAgeingRefundBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts
{
    public string query;
      
    public BusCancellationAgeingRefundBatch(String strQuery)
    {
        if(String.isNotBlank(strQuery))
            Query = strQuery;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCancelAgeningQuery'].QueryDetails__c;
    }
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        System.Debug('query...'+Query);
        return Database.getQueryLocator(Query);
       
    }
    
    global void execute(DataBase.BatchableContext bc,List<Case> lstcases)
    {
        Set<Id> updatedTrans = new Set<Id>();
        Set<String> updatedTrips = new Set<String>();        
        List<Cancellation_Process_DB_Log__c> listCp = new List<Cancellation_Process_DB_Log__c>();
        Set<Id> setTransIds = new Set<Id>();
        
        Set<String> setRTCOpIds = new Set<String>();
        Set<String> setNonRefundableRTCIds = new Set<String>();
        setRTCOpIds.addAll(System.Label.RTC_BO_IDS_Ageing_BC.Split(','));
        setNonRefundableRTCIds.addAll(System.Label.BusC_Non_Auto_Refund_BO_Ids.Split(','));
        set<string> allRTCBOIds=new set<string>();
        allRTCBOIds.addAll(System.Label.RTC_BO_IDS.Split(','));
        Set<Id> setCaseIdsToProcess = new Set<Id>();
        ID autoRefundQueueId =[Select id from Group where type='Queue' AND developername='Bus_Cancellation_Auto_Refund_Queue'].id;
        Date rtcApplicableDate = Date.Parse(System.Label.RTC_AutoRefund_Applicable_Date);
        Set<String> setOldstatus = new Set<String>{'Department Revert','Re-Open'};
        boolean ProcessRefund=false;
        for(Case c:lstcases)
        {
            boolean isPreStatus=false;
            String allPreviousStatus=String.isNotBlank(c.All_Previous_Status_Dates__c)?c.All_Previous_Status_Dates__c:'';
            List<String> values = allPreviousStatus.split(';');
            for(String value:values){
                if(value.Contains('Re-Open')){
                    isPreStatus=true;
                }
            }
            
            system.debug('==status=='+c.status+'==old status=='+c.Previous_Status__c+'==setOldstatus=='+setOldstatus);
            if((c.status=='Initiated' ||  c.status=='Escalated to BD') && !setOldstatus.contains(c.Previous_Status__c) && !isPreStatus)
            {
                ProcessRefund=true;
            }else if(c.status=='Rejected For Bus Cancellation' && !setOldstatus.contains(c.Previous_Status__c))
            {
                ProcessRefund =false;
            }else if(c.status=='Department Revert' && !setOldstatus.contains(c.Previous_Status__c))
            {
                ProcessRefund =false;
            }
            
            if(ProcessRefund && String.isNotBlank(c.Service_Provider_Id__c) && !allRTCBOIds.contains(c.Service_Provider_Id__c))
            {
                setTransIds.add(c.Transaction_ID__c);
                setCaseIdsToProcess.add(c.id);
            }
         /*  
            if(String.isNotBlank(c.Service_Provider_Id__c) && !setRTCOpIds.contains(c.Service_Provider_Id__c))
            {
                setTransIds.add(c.Transaction_ID__c);
                setCaseIdsToProcess.add(c.id);
            }
            
            else if(String.isNotBlank(c.Service_Provider_Id__c) && setRTCOpIds.contains(c.Service_Provider_Id__c) && !setNonRefundableRTCIds.contains(c.Service_Provider_Id__c) && c.createddate>=rtcApplicableDate)
            {
                setTransIds.add(c.Transaction_ID__c);
                setCaseIdsToProcess.add(c.id);
            }*/
        }
//no email flow - start
//        for(Order_Items__c orIt:[Select id,Order_Item_Reference_No__c,Order_Id__c,Email__c,Guid__c from Order_Items__c Where Id In:setTransIds])
        for(Order_Items__c orIt:[Select id,Order_Item_Reference_No__c,Order_Id__c,Email__c,Guid__c,Mobile__c from Order_Items__c Where Id In:setTransIds])
// no email flow - end
        {
            Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
            cp.Transaction_Name__c = orIt.id;
            cp.Refund_Reason__c ='BusC Ageing Exceptional Refund';
            
            ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
            exceRfndReq.ticketNo = orIt.Order_Item_Reference_No__c;
            exceRfndReq.emailId = String.isNotBlank(orIt.Email__c)?orIt.Email__c:'';
// no email flow - start 
            exceRfndReq.mobileno = string.isNotBlank(orIt.Mobile__c)?orIt.Mobile__c:''; 
//no email flow - end                          
            exceRfndReq.cancellationType = '1';
            exceRfndReq.selectedSeat='';
            exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
            exceRfndReq.orderItemUuid = orIt.Guid__c;
            exceRfndReq.createdby = 'SF Auto Refund Scheduler';
            exceRfndReq.reason = 'Bus Cancellation Ageing Exceptional Refund';
            exceRfndReq.isExceptionalCancellation = true;
            exceRfndReq.isExceptionalBusCancellation = true;
            if('Collectible From BO'.equalsIgnoreCase(exceRfndReq.reason))                 
            exceRfndReq.operatorContribution = 0.0;

            ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
            monyMod.amount = 0.0;
            monyMod.currencyType = 'INR';
            exceRfndReq.refund = monyMod;

            HttpRequest req = new HttpRequest();
            req = HttpRequestUtil.populateCAPIHeaders(req);
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setBody(Json.serialize(exceRfndReq));
            HttpResponse res = new HttpResponse();
            Http http = new Http(); 
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);                        
                        
            cp.FC_API_Request_Data__c = string.valueof(req)+'Body :'+Json.serialize(exceRfndReq)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency :INR';
            try
            {
                res = http.send(req);       
                string responseValue = res.getBody();
                cp.FC_API_Ping__c = true;
                
                if(res.getStatusCode()==200 && string.isNotBlank(responseValue))
                {
                    ExceptionalRefundApprovalCntl.ExceptionalCanResponse exceRespone = new ExceptionalRefundApprovalCntl.ExceptionalCanResponse();                    
                    exceRespone = (ExceptionalRefundApprovalCntl.ExceptionalCanResponse)JSON.deserialize(responseValue,ExceptionalRefundApprovalCntl.ExceptionalCanResponse.class);                        
                    cp.FC_IsSuccess__c = 'SUCCESS'.equalsIgnoreCase(String.valueof(exceRespone.Status))?true:false;
                    cp.FC_Response_Message__c = cp.FC_IsSuccess__c?'BusC Ageing Refund has Initiated Successfully.':String.valueof(exceRespone.Status);
                    cp.FC_API_Request_Response__c = string.valueof(exceRespone)+' Body : '+responseValue;
                    if(exceRespone!=null && exceRespone.data!=null)
                    {                           
                        cp.FC_New_Tin__c = string.valueof(exceRespone.data.get('OrderItemUuid'));
                        updatedTrans.add(orIt.id);
                        updatedTrips.add(orIt.Order_Id__c);
                    }
                }
                else
                {
                    System.debug('Received invalid response from the API'+responseValue);
                    map<string,object> exceFailRespone = (map<string,object>)JSON.deserializeUntyped(responseValue);
                    cp.FC_API_Request_Response__c = string.valueof(exceFailRespone)+'--- Body : '+responseValue;
                    if(exceFailRespone.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(exceFailRespone.get('DetailedMessage'))))
                        cp.FC_Response_Message__c = string.valueof(exceFailRespone.get('DetailedMessage'));
                    
                }
            }
            
            Catch(Exception e)
            {
                cp.Message__c ='Error Occuerd..'+String.valueOf(e).left(244);
                System.debug('Error...'+e);
            }
            listCp.add(cp);
        }
    
              
        List<case> listCase = new List<case>();
        List<CaseComment> listComm = new List<CaseComment>();
        Set<Id> setUniqueCases = new Set<Id>();
        
        DBLog_Summary__c dbLog = new DBLog_Summary__c();
        dbLog.type__c ='BusC Ageing Refund Check';
        dbLog.Orders_Received_Data_Ids__c = String.valueOf(updatedTrans)+'.CaseIds.'+String.valueOf(setCaseIdsToProcess)+'..Trans..'+String.valueOf(setTransIds);

        try
        {
            Database.insert(listCp,false);
            List<DBLog_Summary__c> listDBLogSumm = new List<DBLog_Summary__c>();
            for(Case cs :[Select id,caseNumber,ownerId,status,isAgening_Refund_Processed__c,isAgeing_Refund_Success__c,Transaction_ID__c from Case where Id In:setCaseIdsToProcess])
            {
                DBLog_Summary__c dbLogSumm = new DBLog_Summary__c();
                dbLogSumm.Payment_Transaction_Name__c = cs.Transaction_ID__c;
                dbLogSumm.type__c ='BusC Ageing Refund Case Update';
                dbLogSumm.Order_Items_Process_Status__c =cs.CaseNumber;
                dbLogSumm.Orders_Process_Status__c = String.valueOf(cs.Transaction_ID__c);
                dbLogSumm.Orders_Received_Data_Ids__c = String.valueOf(updatedTrans)+'..'+String.valueOf(updatedTrans.contains(cs.Transaction_ID__c))+'..'+String.valueOf(setUniqueCases.contains(cs.Transaction_ID__c));
                                                       
                cs.isAgening_Refund_Processed__c = true;
                cs.Ageing_Status__c = cs.Status;
                if(updatedTrans.contains(cs.Transaction_ID__c))
                {
                   dbLogSumm.X0_PG_Reference_ID__c = true;
                   cs.isAgeing_Refund_Success__c = true;
                   setUniqueCases.add(cs.Transaction_ID__c);
                   
      
                     string STCcomment = [SELECT DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BusCancelAgeningQuery'].DistributionList__c;
                        CaseComment csComm = new CaseComment();
                        csComm.ParentId = cs.id;
                        csComm.commentBody = 'System Update- Refunded By Ageing Scheduler Under Bus Cancellation Customer Delight';
                        
                        
                        CaseComment cComm = new CaseComment();
                        cComm.ParentId = cs.id;
                        cComm.commentBody = STCcomment;
                        
                        dbLogSumm.Order_Items_Success__c =cs.Status;
                        cs.ownerId=autoRefundQueueId;
                        cs.Status ='Refunded By Ageing Scheduler';
                        dbLogSumm.Orders_Received_Data_Ids__c='Comments..'+String.valueOf(csComm);
                        listComm.add(csComm);
                        listComm.add(cComm);
                    
                   
                }
                
                dbLogSumm.Orders_Received_Data_Ids__c =+'Case..'+String.valueOf(cs);          
                
                
                /*    if(updatedTrans.contains(cs.Transaction_ID__c) && !setUniqueCases.contains(cs.Transaction_ID__c))
                    {
                       if(!'Escalated to BD'.equalsIgnoreCase(cs.Status))
                       {
                            cs.ownerId=autoRefundQueueId;
                            cs.Status ='Refunded By Ageing Scheduler';
                            csComm.commentBody = 'System Update- Refunded By Ageing Scheduler Under Bus Cancellation Customer Delight';
                       }                   
                     
                
                    }
                    
                    else if(setUniqueCases.contains(cs.Transaction_ID__c))
                    {
                        cs.status='Closed';
                        csComm.commentBody = 'System Update- This is a Duplicate Case For Same Transaction.Refunded Has Already Processed By Ageing Scheduler Under Bus Cancellation Customer Delight';
                    }
                */
                
                listCase.add(cs);
              
                listDBLogSumm.add(dbLogSumm);
            
            }
            dbLog.Payment_Ping_Status__c ='Processing Completed Successfully';
            insert listDBLogSumm;
            insert listComm;
            update listCase;
        }
        Catch(Exception e)
        {
            System.debug('Exception e..'+e);
            dbLog.Payment_Ping_Status__c ='Processing Complete Failed';
            dbLog.Exception_Description__c = String.valueOf(e);
        
        }
        insert dbLog;

    }
    
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
    //    toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com','sreenivasa.mariyavula@redbus.com'});
       mail.setSubject('Bus Cancellation Ageing Refund Processing..'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}