/**
 * (c) 2017 RedBus
 *
 * Name           : BusCancellationExceRefundSchedular
 * Created Date   : 23 Mar 2018
 * Created By     : Sreenivas M
 * Purpose        : Bacth class to Pedning Bus Cancellation Case Under Customer Delight Exeptional Refund
 * Test class     : BusCancellationExceRefundSchedularTest
 *
 **/
 
global class BusCancellationExceRefundSchedular implements DataBase.Batchable<sObject>,Database.AllowsCallouts
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        List<String> listTins = new List<String>();
        for(TempProcessing__c temp :[Select id,name,processed__c from TempProcessing__c where processed__c=false])
        {
            listTins.add(temp.name);
        }
// no email flow - start
//        return DataBase.getQueryLocator([Select OrderUuid__c,Order_Name__r.Guid__c,Id,Order_Item_Reference_No__c,Guid__c,Email__c From Order_Items__c Where Order_Item_Reference_No__c IN:listTins AND Refund_Status__c NOT IN('REFUND_SUCCESSFUL','REFUND_CREATED')]);
        return DataBase.getQueryLocator([Select OrderUuid__c,Order_Name__r.Guid__c,Id,Order_Item_Reference_No__c,Guid__c,Email__c, Mobile__c From Order_Items__c Where Order_Item_Reference_No__c IN:listTins AND Refund_Status__c NOT IN('REFUND_SUCCESSFUL','REFUND_CREATED')]);
// no email flow - end
    }
    
    global void execute(DataBase.BatchableContext bc,List<Order_Items__c> items)
    {
        List<String> updatedTins = new List<String>();
        List<String> updatedTrips = new List<String>();
        
        List<Cancellation_Process_DB_Log__c> listCp = new List<Cancellation_Process_DB_Log__c>();
        for(Order_Items__c orIt:items)
        {
            Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
            cp.Transaction_Name__c = orIt.id;
            HttpResponse res1 = new HttpResponse();
            Http http1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1 = HttpRequestUtil.populateHeaders(req1);                                   
            req1.setMethod('GET');
            req1.setTimeout(120000);
            req1.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='MaxRefundableAPI'].Endpoint__c+orIt.OrderUuid__c+'&tin='+orIt.Order_Item_Reference_No__c);
            cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency:INR';
                                    
            try
            {
                res1 = http1.send(req1);                                        
                string maxRefundResp = res1.getBody();
                system.debug('---------maxRefundResp-------'+maxRefundResp);
                cp.MAX_API_Request_Response__c = string.valueof(res1)+' Body : '+maxRefundResp;  
                
                if(res1.getStatusCode()==200 && string.IsNotBlank(maxRefundResp))
                {
                    Double refundValue = double.valueof(maxRefundResp);
                    CP.Max_Refundable_API__c = true;
                    CP.Max_Refundable_Amount__c = refundValue;
                    
                    if(refundValue>0)
                    {
                        ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
                        exceRfndReq.ticketNo = orIt.Order_Item_Reference_No__c;
                        exceRfndReq.emailId = String.isNotBlank(orIt.Email__c)?orIt.Email__c:'';
// no email flow - start
                        exceRfndReq.mobileno = String.isNotBlank(orIt.Mobile__c)?orIt.Mobile__c:''; 
// no email flow - end                         
                        exceRfndReq.cancellationType = '1';
                        exceRfndReq.selectedSeat='';
                        exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
                        exceRfndReq.orderItemUuid = orIt.Guid__c;
                        exceRfndReq.createdby = 'SF System Auto Refund';
                        exceRfndReq.reason = 'Bus Cancellation Exceptional Refund-Customer Delight';
                        exceRfndReq.isExceptionalCancellation = true;
                        if('Collectible From BO'.equalsIgnoreCase(exceRfndReq.reason))                 
                        exceRfndReq.operatorContribution = refundValue;

                        ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
                        monyMod.amount = refundValue;
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
                        res = http.send(req);       
                        string responseValue = res.getBody();
                    
                        if(res.getStatusCode()==200 && !string.isBlank(responseValue))
                        {
                        
                            ExceptionalRefundApprovalCntl.ExceptionalCanResponse exceRespone = new ExceptionalRefundApprovalCntl.ExceptionalCanResponse();
                            cp.FC_API_Ping__c = true;
                            exceRespone = (ExceptionalRefundApprovalCntl.ExceptionalCanResponse)JSON.deserialize(responseValue,ExceptionalRefundApprovalCntl.ExceptionalCanResponse.class);                        
                            cp.FC_IsSuccess__c = 'SUCCESS'.equalsIgnoreCase(String.valueof(exceRespone.Status))?true:false;
                            cp.FC_Response_Message__c = cp.FC_IsSuccess__c?'Refund has Initiated Successfully.':String.valueof(exceRespone.Status);
                            cp.FC_API_Request_Response__c = string.valueof(exceRespone)+' Body : '+responseValue;
                            if(exceRespone!=null && exceRespone.data!=null)
                            {                           
                                cp.FC_New_Tin__c = string.valueof(exceRespone.data.get('OrderItemUuid'));
                                cp.FC_Refund_Amount__c = refundValue;
                                updatedTins.add(orIt.Order_Item_Reference_No__c);
                                updatedTrips.add(orIt.Order_Id__c);
                            }

                        }
                    }
                }
              
            }
            Catch(Exception e)
            {
                System.debug('Error...'+e);
            }
            listCp.add(cp);
        }
        insert listCp;
        
        List<TempProcessing__c> listProcessedTins = new List<TempProcessing__c>();
        for(TempProcessing__c tempObj :[Select id,name,processed__c from TempProcessing__c where name IN:updatedTins])
        {
            tempObj.processed__c = true;
            listProcessedTins.add(tempObj);
        }
        update listProcessedTins;
        
        List<case> listCase = new List<case>();
        List<CaseComment> listComm = new List<CaseComment>();
        for(Case cs:[Select id,status,notes__c from case where Issue_Type__c='Bus Cancellation' AND Status!='Closed' AND (TIN_No__c IN:updatedTins OR Trip_Id_ct__c IN:updatedTrips)])
        {
            cs.Status ='Closed';
            cs.Notes__c ='Refund by redBus-Customer Delight';
            listCase.add(cs);
            
            CaseComment csComm = new CaseComment();
            csComm.ParentId = cs.id;
            csComm.commentBody = 'System Update- Bus Cancellation Customer Delight Under Exceptional Refund';
            listComm.add(csComm);
        
        }
        insert listComm;
        update listCase;
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Bus Cancellation Refund Processing..'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}