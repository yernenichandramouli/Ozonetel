public class ApproveExceptionalRefund{
    public static list<Cancellation_Process_DB_Log__c> listCp;
    public static boolean refundStatus=false;

    @future(callout=true)
    public static void InitiateRefund(set<id> caseId){
    
        List<case> cObjLs=new List<case>();
        listCp=new list<Cancellation_Process_DB_Log__c>();
       // cObjLs=[select Id,ParentId,Business_Unit_ct__c,CreatedBy.user_level__c,Reason_For_Report__c,Inventory_Type__c,Parent.Business_Unit_ct__c,Service_Provider_Id__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,parent.Insurance_Provider_Name__c,Parent.Channel_ct__c,Service_Providerr_Id__c from case where id=:caseId];
        cObjLs=[select Id,ParentId,caseNumber, Service_Providerr_Id__c,Category__c,Refund_Type__c,Exceptional_Refund_Count__c,createdById,status,TIN_No__c,Booking_Email_ID__c,Booking_EMail_Copy__c,Booking_Mobile_No__c,OrderItem_Uuid__c,Issue_Sub_Category__c,Refund_Amount__c,Price_Paid_Currency_ctp__c,Exceptional_Refund_Initiated__c,Refund_status__c,Business_Unit_ct__c,Service_Provider_Id__c from case where id in:caseId];

        if(!cObjLs.isEmpty()){
        list<case> parCsList=new List<case>();
        parCsList=[select id,Refund_Type__c from case where id=:cObjLs[0].ParentId];
        System.debug('ApproveExceptionalRefund called-->'+cObjLs[0].id);
        case csObj=new case();
        csObj=cObjLs[0];
        List<Cancellation_Process_DB_Log__c> cpList=new List<Cancellation_Process_DB_Log__c>();
        List<case> csUpList=new List<case>();
        case parCase = new Case();
        parCase.id = csObj.ParentId;   
        
        ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
        exceRfndReq.ticketNo = csObj.TIN_No__c;
        exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)?csObj.Booking_EMail_Copy__c:'';
        // no email flow - start
        exceRfndReq.mobileno = string.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'';
        //no email flow - end
        exceRfndReq.cancellationType = '1';        
        exceRfndReq.selectedSeat='';
        exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
        exceRfndReq.orderItemUuid = csObj.OrderItem_Uuid__c;
        exceRfndReq.createdby = UserInfo.getUserName();   
        exceRfndReq.reason = csObj.Issue_Sub_Category__c;
        exceRfndReq.isExceptionalCancellation = true;
        //exceRfndReq.IsExceptionalRefundApproved = false;
        exceRfndReq.exceptionalRefundCount =integer.valueof(csObj.Exceptional_Refund_Count__c);
        ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
        monyMod.amount = csObj.Refund_Amount__c;
        monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)?csObj.Price_Paid_Currency_ctp__c:'INR';
        exceRfndReq.refund = monyMod; 
        ApproveExceptionalRefund ae=new ApproveExceptionalRefund();
        ae.initiateExceptionalRefund(Json.serialize(exceRfndReq),csObj);
        database.upsert(listCp);
            if(refundStatus){
                csObj.Exceptional_Refund_Initiated__c = true;
                csObj.Refund_status__c='Exceptional Refund Approved';
                parCase.Refund_status__c='Exceptional Refund Approved';
                csObj.status='Approved For Exceptional Refund';
                csObj.Approved_By__c = UserInfo.getUserName();
                csObj.Approved_Rejected_Time__c = System.Now();   
                csObj.OwnerId = csObj.createdById;
                csObj.Category__c='Exceptional Refund - Auto Approved';
                parCase.Category__c='Exceptional Refund - Auto Approved';

                list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
                Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));

                if(csObj.Issue_Sub_Category__c=='Instant refund - Collectible from BO' && instantRefundBoIds.contains(csObj.Service_Providerr_Id__c)){
                    if(!parCsList.isEmpty() && string.isNotBlank(parCsList[0].Refund_Type__c)){
                        csObj.Refund_Type__c=parCsList[0].Refund_Type__c;
                    }else{
                        csObj.Refund_Type__c='Instant resolution with refund';
                        parCase.Refund_Type__c='Instant resolution with refund';
                    }
                }else if(instantRefundBoIds.contains(csObj.Service_Providerr_Id__c) && csObj.Issue_Sub_Category__c=='Instant refund - customer delight'){
                    csObj.Refund_Type__c='Instant resolution - redBus Delight';
                    parCase.Refund_Type__c='Instant resolution - redBus Delight';
                }
                update new list<Case>{csObj,parCase};
                CaseComment csCom = new CaseComment();
                csCom.ParentId = csObj.id;
                csCom.commentBody = 'Exceptional Refund case is Approved';
                insert csCom;
            }
        }
    }

    public boolean initiateExceptionalRefund(String strExceRfndReq,case csObj)
    {
        DBLog_Summary__c dbl = New DBLog_Summary__c();
        dbl.type__c = 'Initiate Exceptional Refund';
        listCp=new list<Cancellation_Process_DB_Log__c>();
        system.debug('-------------------BODY------------'+strExceRfndReq);
        String conBusUnit ='';String selcountry ='';String selCurrency='';
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setTimeout(120000);
        req.setMethod('POST');
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);
        conBusUnit = String.isNotBlank(csObj.Business_Unit_ct__c)?'REDBUS_'+csObj.Business_Unit_ct__c.split('_')[1]:'REDBUS_IN';
        System.debug('conBusUnit ...'+conBusUnit);
        
        Map<string,WhiteLabelOperators__c> mapWloptrs = WhiteLabelOperators__c.getAll();
        string wlOperName='';
        system.debug('----case---'+csObj+'==='+csObj.Service_Provider_Id__c+'=='+csObj.Business_Unit_ct__c);
        if(!csObj.Business_Unit_ct__c.startsWithIgnoreCase('REDBUS') && csObj.Service_Provider_Id__c!=null){
            if(mapWloptrs.containskey(csObj.Service_Provider_Id__c)){
                System.debug('========= ...');
                wlOperName = csObj.Business_Unit_ct__c.split('_')[0];
                req.setHeader('Operator',wlOperName);
            }
        }
        
        if('REDBUS_COM'.equalsIgnoreCase(csObj.Business_Unit_ct__c)){
            string busUnit='';
            if('SGD'.equalsIgnoreCase(csObj.Price_Paid_Currency_ctp__c)){
                busUnit='REDBUS_SG';
            }else if('IDR'.equalsIgnoreCase(csObj.Price_Paid_Currency_ctp__c)){
                busUnit='REDBUS_ID';
            }else if('COP'.equalsIgnoreCase(csObj.Price_Paid_Currency_ctp__c)){
                busUnit='REDBUS_CO';
            }else if('PEN'.equalsIgnoreCase(csObj.Price_Paid_Currency_ctp__c)){
                busUnit='REDBUS_PE';
            }else if('MYR'.equalsIgnoreCase(csObj.Price_Paid_Currency_ctp__c)){
                busUnit='REDBUS_MY';
            }else{
                busUnit='REDBUS_IN';
            }
            String comBusUnit = 'REDBUS_'+busUnit.split('_')[1];
            selcountry=OrderItemTransactionResource__c.getValues(csObj.Business_Unit_ct__c).Case_Country__c;
            selCurrency= OrderItemTransactionResource__c.getValues(comBusUnit).Default_Currency__c;
        }else{
            selcountry = OrderItemTransactionResource__c.getValues(conBusUnit).Auth_Key__c;
            selCurrency= OrderItemTransactionResource__c.getValues(conBusUnit).Default_Currency__c;
        }
        
        req.setHeader('SelectedCurrency',selCurrency);
        req.setHeader('Country_Name',selcountry);
        
        Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();
        cp.FC_API_Request_Data__c = string.valueof(req)+'Body :'+strExceRfndReq+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+selcountry+',SelectedCurrency :'+selCurrency;
        req.setBody(strExceRfndReq);
        try
        {
            
            ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndr = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();      
            exceRfndr = (ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput)System.JSON.deserialize(strExceRfndReq,ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput.class);
            
            cp.Refund_Reason__c = exceRfndr.reason;
            cp.Amount_to_be_Refunded__c = exceRfndr.refund.amount;
            cp.TIN_Number__c = exceRfndr.ticketNo;
            List<Order_Items__c> orIt = new List<Order_Items__c>();
            orIt = [Select id from Order_Items__c where Order_Item_Reference_No__c=:cp.TIN_Number__c];
            if(!orIt.isEmpty()){
                cp.Transaction_Name__c = orIt!=null?orIt[0].id:'';
            }
            
            cp.OrderItemUuid__c =exceRfndr.orderItemUuid;
            
            res = http.send(req);    
            dbl.Request_Data__c = req.getbody() + '--req---' + string.valueof(req);
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.Case_Number__c = string.valueOf(csObj.CaseNumber);
            string responseValue = res.getBody();
            system.debug('responseValue--->'+responseValue);
            cp.FC_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
            
            if(res.getStatusCode()==200 && !string.isBlank(responseValue))
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
                
            }
            else
            {
                System.debug('Received invalid response from the API'+responseValue);
                map<string,object> exceFailRespone = (map<string,object>)JSON.deserializeUntyped(responseValue);
                if(exceFailRespone.containsKey('DetailedMessage') && String.isNotBlank(string.valueof(exceFailRespone.get('DetailedMessage'))))
                insert dbl;
                    listCp.add(cp);
                return refundStatus;
            }
            
        }
        catch(exception e)
        {
            dbl.Exception_Description__c=string.valueOf(e);
            System.debug('Exception...'+e);
            cp.FC_API_Request_Response__c = string.valueof(e);    
            insert dbl;
            listCp.add(cp);
            return refundStatus;
        }
        listCp.add(cp);
        return refundStatus;
    }
    
    public class ExceptionalRefundRequestApprove{
        public boolean isApproved;
        public string orderItemUuid;
        public string orderUuid;
        public string approvedBy;
        public string channel;
        public OperatorContribution operatorContribution;
    }
    public class OperatorContribution{
        public string currencyType;
        public decimal amount;
    }
    
}