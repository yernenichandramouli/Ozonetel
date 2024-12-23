/**
* (c) 2017 RedBus
*
* Name           : ExceptionalRefundApprovalCntl
* Created Date   : 18 Dec 2017
* Created By     : Sreenivas M
* Purpose        : Handler class for Exceptional Refund Approval Page
* Test class     : ExceptionalRefundApprovalCntlTest
*
**/
public class ExceptionalRefundApprovalCntl 
{
    public List<case> caseList{get;set;}
    public Map<Id,Case> mapIdToCase;
    public string cId{get;set;}
    public Case cs{get;set;}
    public string caseComments{get;set;}
    public string b2cCaseComments{get;set;}
    
    
    public string seleStatus{get;set;}
    public Id selCsId{get;set;}
    public String query;
    public String detailMessage;
    public list<Cancellation_Process_DB_Log__c> listCp;
    public string excepRefReq;
    public string excepRefResp;
    public OAuthGeneric oauthObj; 
    public string userCountry;
    Case csObj = new Case();
    Case parCase = new Case();
    public string sellerCentralId{get;set;}
    public  DBLog_Summary__c expLogB2B;
    public string agentName;
    public string cureentname;
    public string loginUsername;
    public integer approveAmount;
    public string userTeam;
    public integer ZQPapproveAmount;
    public string selectedTeam{get;set;}
    public ExceptionalRefundApprovalCntl()
    {
        User u = [select Id,username,Team__c,user_level__c,Country  from User where Id = :UserInfo.getUserId()];
        if(u.user_level__c!=null){
        expLogB2B=new DBLog_Summary__c();
        oauthObj=new OAuthGeneric(); 
        csObj = new Case();
        parCase = new Case();
        query = 'SELECT ';
        
        if('Integration User'.equalsIgnoreCase(UserInfo.getName()) || 'Test User'.equalsIgnoreCase(UserInfo.getName()))
            agentName = '('+UserInfo.getUserName()+')';
        
        else
            agentName =UserInfo.getName()+'('+UserInfo.getUserName()+')';
        
        listCp = new List<Cancellation_Process_DB_Log__c>();
        for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.ExceptionalRefund.getFields()) {
            query += f.getFieldPath() + ', ';
        }   
        
         cureentname=UserInfo.getName();
         loginUsername='%'+cureentname +'%';
         userTeam=u.Team__c;
         
        userCountry =u.country;
        if('Peru'.equalsIgnoreCase(userCountry) || 'Colombia'.equalsIgnoreCase(userCountry)){
            query += 'Id,Dropping_Time__c,SH_Dropping_Time__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,Business_Unit_ct__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Service_Provider_Id__c,Parent.Business_Unit_ct__c ,parent.Insurance_Provider_Name__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' AND Status=\'Open\' AND (Country__c=\'Peru\' OR Country__c=\'Colombia\' or Country__c=\'RDC\')  LIMIT 75';
        }else if('Singapore'.equalsIgnoreCase(userCountry) || 'Malaysia'.equalsIgnoreCase(userCountry)){
            query += 'Id,Dropping_Time__c,SH_Dropping_Time__c,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Service_Provider_Id__c,Parent.Business_Unit_ct__c ,parent.Insurance_Provider_Name__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' AND Status=\'Open\' AND (Country__c=\'Singapore\' OR Country__c=\'Malaysia\')  LIMIT 75';   
        } else if('RDC'.equalsIgnoreCase(userCountry)){
            query += 'Id,SH_Dropping_Time__c,Dropping_Time__c,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Parent.Business_Unit_ct__c ,Service_Provider_Id__c,parent.Insurance_Provider_Name__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' AND Status=\'Open\' AND  Country__c=\'RDC\' LIMIT 75';
        }  
        else{
            query += 'Id,SH_Dropping_Time__c,Dropping_Time__c,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Parent.Business_Unit_ct__c,Service_Provider_Id__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,parent.Insurance_Provider_Name__c,Parent.Channel_ct__c,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' and Status=\'Open\' LIMIT 75';
        }
        
        
        refreshlist();
        }else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'User Level is Empty, Please Add User Level'));
           
        }
    }
    
    public void teamWisecases(){
        
        query = 'SELECT ';
         for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.ExceptionalRefund.getFields()) {
            query += f.getFieldPath() + ', ';
          }   
     if(string.isNotBlank(selectedTeam) && selectedTeam!='RDC'){
         query += 'Id,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,SH_Dropping_Time__c,Dropping_Time__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Parent.Business_Unit_ct__c,Service_Provider_Id__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,parent.Insurance_Provider_Name__c,Parent.Channel_ct__c,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' and Status=\'Open\' and User_Level_Team__c =:selectedTeam  LIMIT 75';
       }else if(selectedTeam=='RDC'){
        query += 'Id,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,SH_Dropping_Time__c,Dropping_Time__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Parent.Business_Unit_ct__c,Service_Provider_Id__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,parent.Insurance_Provider_Name__c,Parent.Channel_ct__c,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' and Status=\'Open\' and Country__c =\'RDC\'  LIMIT 75';
       }else{
         query += 'Id,Business_Unit_ct__c,My_Desk_Id__c,Case_Category__c, redCare_Status__c,Channel_ct__c,SH_Dropping_Time__c,Dropping_Time__c,Business_Type__c,CreatedBy.user_level__c,Exceptional_Refund_Count__c,Reason_For_Report__c,Inventory_Type__c,User_Level_Team__c,Parent.Business_Unit_ct__c,Service_Provider_Id__c,Parent.Issue_Type__c,parent.Claim_Type_ctp__c,parent.Issue_Sub_Category__c,parent.Claim_Status__c,parent.Claim_id__c,parent.Policy_Id__c,parent.TIN_No__c,Country__c,Type,parent.Insurance_Provider_Name__c,Parent.Channel_ct__c,Service_Providerr_Id__c  FROM Case Where Issue_Type__c=\'Exceptional Refund\' and Status=\'Open\' and Country__c =:userCountry LIMIT 75';
       }
        refreshlist();
    }
    
    public void refreshlist()
    {
        mapIdToCase = new Map<Id,Case>();
        caseList = new List<Case>();  
        list<case> cslst  =new list<case>();
        cslst = Database.query(query);
        
        dateTime curTime= system.now();
                for(case c : cslst){
           dateTime dropingTime =c.Dropping_Time__c!=null ? c.Dropping_Time__c : c.SH_Dropping_Time__c!=null ? c.SH_Dropping_Time__c:null;
           if(dropingTime!=null && curTime > dropingTime){
             caseList.add(c);
           }else if(dropingTime==null){
              caseList.add(c);
           }
        }
       
        
        for(Case c :caseList)
        {
           
            mapIdToCase.put(c.id,c);
        }
        
    }
    
    public PageReference initiateRefund()
    {
        
        if(String.isBlank(b2cCaseComments) || b2cCaseComments.length()<11)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Case Comments and Minimum length is 10 Characters'));
            return null;
        }
        csObj = new Case();
        parCase = new Case();
        csObj= mapIdToCase.get(selCsId);
        CaseComment csCom = new CaseComment();
        csCom.ParentId = selCsId;
        csCom.commentBody = b2cCaseComments;
        parCase.id = csObj.ParentId; 
        
        system.debug('>>>124>>>'+csObj);
       
        user currUser=[select id,user_level__c,Country from user where id=:UserInfo.getUserID()];
        If(!Test.isRunningTest()){
        if(currUser.user_level__c<=csObj.CreatedBy.user_level__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permission to approve this case!! Your above level user only can approve this case.'));
            return null;
        }
    }
        
        if(!'Open'.equalsIgnoreCase(csObj.status))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'It Seems To Be Refund Is Already Processed For This Case.Please Refresh Once'));
            return null;
        }
        if(String.valueOf(csObj.Business_Type__c)=='Hotel' && String.valueOf(csObj.Business_Unit_ct__c)=='REDBUS_HOTEL_IN'){
            if('Approve'.equalsIgnoreCase(seleStatus)){
                if(exceptionalRefundHotelsCtrl.approveExceptionalRefund(selCsId)){
                    try{
                        csObj.Exceptional_Refund_Initiated__c = true;
                        csObj.Refund_status__c='Exceptional Refund Approved';
                        csObj.Status = 'Approved For Exceptional Refund';
                        parCase.Refund_status__c='Exceptional Refund Approved';
                        csObj.Approved_By__c = agentName;
                        csObj.Approved_Rejected_Time__c = System.Now();   
                        update new list<Case>{csObj,parCase};
                        insert csCom;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Refund Has Initiated Successfully For Case -'+csObj.CaseNumber));
                        refreshlist();
                        return null;
                    }Catch(Exception e){
                        system.debug('Error while updating the case for exceptional refund-'+e.getMessage());
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Refund Has Initiated Successfully To Customer.Failed To Update The Case Data!-'+csObj.CaseNumber));
                        refreshlist();
                        return null;
                    }
                }else{
                    String errMessage = String.isNotBlank(detailMessage)?detailMessage:'Error While Processing Processing Refund.Please retry..!';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errMessage));
                    return null;
                }
            }
        }

        if(String.valueOf(csObj.Business_Type__c)=='Activities' && String.valueOf(csObj.Business_Unit_ct__c)=='SGMY Activites'){
            if('Approve'.equalsIgnoreCase(seleStatus)){
                if(sgmyActivitesExceptionalRefundCtrl.approveExceptionalRefund(selCsId,b2cCaseComments,agentname)){
                    try{
                        csObj.Exceptional_Refund_Initiated__c = true;
                        csObj.Refund_status__c='Exceptional Refund Approved';
                        csObj.Status = 'Approved For Exceptional Refund';
                        parCase.Refund_status__c='Exceptional Refund Approved';
                        update new list<Case>{csObj,parCase};
                        insert csCom;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Refund Has Initiated Successfully For Case -'+csObj.CaseNumber));
                        refreshlist();
                        return null;
                    }Catch(Exception e){
                        system.debug('Error while updating the case for exceptional refund-'+e.getMessage());
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Refund Has Initiated Successfully To Customer.Failed To Update The Case Data!-'+csObj.CaseNumber));
                        refreshlist();
                        return null;
                    }
                }else{
                    String errMessage = String.isNotBlank(detailMessage)?detailMessage:'Error While Processing Processing Refund.Please retry..!';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errMessage));
                    return null;
                } 
            }else{
                parCase.Refund_status__c='Exceptional Refund Rejected';
                csObj.Refund_status__c='Exceptional Refund Rejected';
                update csObj;
                update parCase;
                insert csCom;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request Has Processed Successfully For Case-'+csObj.CaseNumber));
                refreshlist();
                return null;
            }
        }
        
        
       for(Refund_Control_Level__mdt refundApproval :[select Approve_Amount__c,Approve_Level__c,Country__c from Refund_Control_Level__mdt where Approve_Level__c =:currUser.user_level__c and Country__c=:currUser.Country])
        {
          approveAmount= integer.valueof(refundApproval.Approve_Amount__c);
        }
     //ZQP validation 
       
        if(csObj.Issue_Sub_Category__c.contains('ZQP')){
        
           for(ZQP_Refund_Amount_Approve__mdt ZQPrefundApproval :[select Approve_Amount__c,Approve_Level__c from ZQP_Refund_Amount_Approve__mdt where Approve_Level__c =:currUser.user_level__c])
                {
                  ZQPapproveAmount= integer.valueof(ZQPrefundApproval.Approve_Amount__c);
                }
                
           if(csObj.Refund_Amount__c > ZQPapproveAmount){
                
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permission to approve ZQP case where refund amount more than Approval amount '+approveAmount+' rps'));
              return null;
           }
        }else if(csObj.Refund_Amount__c > approveAmount){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permission to approve the case where refund amount more than Approval amount '+approveAmount+' rps'));
            return null;
        }
        
        csObj.Approved_By__c = agentName;
        csObj.Approved_Rejected_Time__c = System.Now();   
        csObj.status = 'Approve'.equalsIgnoreCase(seleStatus)?'Approved For Exceptional Refund':'Rejected For Exceptional Refund';
        csObj.OwnerId = csObj.createdById;
        // CaseComment csCom = new CaseComment();
        // csCom.ParentId = selCsId;
        // csCom.commentBody = b2cCaseComments;
        // parCase.id = csObj.ParentId;   
        ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundReqInput();
        exceRfndReq.ticketNo = csObj.TIN_No__c;
        exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)?csObj.Booking_EMail_Copy__c:'';
        // no email flow - start
        exceRfndReq.mobileno = string.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'';
        //no email flow - end
        exceRfndReq.cancellationType = '1';        
        exceRfndReq.selectedSeat='';
        exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
        exceRfndReq.orderItemUuid = csObj.OrderItem_Uuid__c;
        exceRfndReq.createdby = csObj.Approved_By__c; 
        exceRfndReq.exceptionalRefundCount =integer.valueof(csObj.Exceptional_Refund_Count__c);
        

        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(',')); 
        
       if(('Instant refund - Collectible from BO'.equalsIgnoreCase(csObj.Issue_Sub_Category__c) ||'OTG'.equalsIgnoreCase(csObj.Issue_Sub_Category__c)) && csObj.Service_Providerr_Id__c!=null && instantRefundBoIds.contains(csObj.Service_Providerr_Id__c)){
            exceRfndReq.IsExceptionalRefundApproved =false;
        }else{
          if('Collectible From BO'.equalsIgnoreCase(csObj.Issue_Sub_Category__c) || 'Instant refund - Collectible from BO'.equalsIgnoreCase(csObj.Issue_Sub_Category__c) ||'OTG'.equalsIgnoreCase(csObj.Issue_Sub_Category__c))                 
            exceRfndReq.operatorContribution = csObj.Refund_Amount__c;
        }
        exceRfndReq.reason = csObj.Issue_Sub_Category__c;
        exceRfndReq.isExceptionalCancellation = true;
       /* if('Collectible From BO'.equalsIgnoreCase(csObj.Issue_Sub_Category__c) ||'OTG'.equalsIgnoreCase(csObj.Issue_Sub_Category__c))                 
            exceRfndReq.operatorContribution = csObj.Refund_Amount__c;
        */
        MoneyModel monyMod = new MoneyModel();
        monyMod.amount = csObj.Refund_Amount__c;
        monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)?csObj.Price_Paid_Currency_ctp__c:'INR';
        exceRfndReq.refund = monyMod;
        Boolean isAckoEnabled = Boolean.valueOf(System.Label.Enable_Acko_Flows);
        Boolean isIcIciEnabled = Boolean.valueOf(System.Label.EnableIciciUpdateFlow);
        
        if('Approve'.equalsIgnoreCase(seleStatus))
        {
            if(initiateExceptionalRefund(Json.serialize(exceRfndReq)))
            {
                try
                { 
                    system.debug('--ParentId--'+csObj.ParentId+'--busUnit--'+csObj.Parent.Business_Unit_ct__c+'--claimId--'+csObj.Parent.Claim_id__c+'--sub-'+csObj.Parent.Issue_Type__c+'--issueSub--'+csObj.parent.Issue_Sub_Category__c);
                    if((('Acko'.equalsIgnoreCase(csObj.Parent.Insurance_Provider_Name__c) && isAckoEnabled)|| ('ICICI'.equalsIgnoreCase(csObj.Parent.Insurance_Provider_Name__c) && isIcIciEnabled)) &&   String.isNotBlank(csObj.ParentId) &&'REDBUS_IN'.equalsIgnoreCase(csObj.Parent.Business_Unit_ct__c) && String.isNotBlank(csObj.Parent.Claim_id__c) && 'Bus Operator Service'.equalsIgnoreCase(csObj.Parent.Issue_Type__c) && 'Bus type changed'.equalsIgnoreCase(csObj.parent.Issue_Sub_Category__c))
                    {
                        ApproveorRejectstatus('Approved','Claim Approved Successfully','Claim Approval Failed');
                    }
                    database.upsert(listCp);
                    csObj.Exceptional_Refund_Initiated__c = true;
                    csObj.Refund_status__c='Exceptional Refund Approved';
                    parCase.Refund_status__c='Exceptional Refund Approved';
                    update new list<Case>{csObj,parCase};
                        insert csCom;
            if(csObj.User_Level_Team__c=='SelfHelp Bot Failure'){
              closeShBotParentCase(String.valueOf(csObj.ParentId));
            }
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Refund Has Initiated Successfully For Case -'+csObj.CaseNumber));
                     refreshlist();
                    return null;
                }
                
                Catch(Exception e)
                {
                    system.debug('Error while updating the case for exceptional refund-'+e.getMessage());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Refund Has Initiated Successfully To Customer.Failed To Update The Case Data!-'+csObj.CaseNumber));
                     refreshlist();
                    return null;
                }
               
            }
            
            else
            {
                database.upsert(listCp);
                String errMessage = String.isNotBlank(detailMessage)?detailMessage:'Error While Processing Processing Refund.Please retry..!';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,errMessage));
                return null;
            }       
        }
        
        else
        {
            try
            {
                if((('Acko'.equalsIgnoreCase(csObj.Parent.Insurance_Provider_Name__c) && isAckoEnabled)|| ('ICICI'.equalsIgnoreCase(csObj.Parent.Insurance_Provider_Name__c) && isIcIciEnabled)) && String.isNotBlank(csObj.ParentId) && String.isNotBlank(csObj.Parent.Claim_id__c) && 'REDBUS_IN'.equalsIgnoreCase(csObj.Parent.Business_Unit_ct__c) && 'Bus Operator Service'.equalsIgnoreCase(csObj.Parent.Issue_Type__c) && 'Bus type changed'.equalsIgnoreCase(csObj.parent.Issue_Sub_Category__c ))
                {
                    ApproveorRejectstatus('Rejected','Claim Rejected Successfully','Claim Reject Failed');
                    update new list<Case>{csObj,parCase};
                }
                else{                    
                    parCase.Refund_status__c='Exceptional Refund Rejected';
                    csObj.Refund_status__c='Exceptional Refund Rejected';
                    update csObj;
                    update parCase;
                    }
                
                insert csCom;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request Has Processed Successfully For Case-'+csObj.CaseNumber));
                refreshlist();
                return null;
            }
            
            Catch(Exception e)
            {
                system.debug('Error while updating the case data');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Failed To Update The Case Data!!-'+csObj.CaseNumber));
                return null;
            }
        }
        
    }
  
  public void closeShBotParentCase(String parentCaseId){
        if(parentCaseId!=null){
            List<case> caseList = [SELECT Id, status FROM case WHERE Id = :parentCaseId];
            List<case> caseListToUpdate = New List<case>();
            List<CaseComment> caseCmmToUpdate  = New List<CaseComment>();
            if(!caseList.isEmpty()){
                for(case cs : caseList){
                    CaseComment parentComments = New CaseComment();
                    parentComments.parentId = cs.ID;
                    parentComments.commentbody = 'Closed by Supervisor';
                    caseCmmToUpdate.add(parentComments);
                    cs.status = 'Closed';
                    caseListToUpdate.add(cs);
                }
            }

            if(!caseCmmToUpdate.isEmpty()){
                insert caseCmmToUpdate;
            }

            if(!caseListToUpdate.isEmpty()){
                Update caseListToUpdate;
            }

        }
    }
    
    public boolean initiateExceptionalRefund(String strExceRfndReq)
    {
        system.debug('-------------------BODY------------'+strExceRfndReq);
        String conBusUnit ='';String selcountry ='';String selCurrency='';
        listCp.clear();
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
        Boolean refundStatus=false;
        try
        {
            
            ExceptionalRefundReqInput exceRfndr = new ExceptionalRefundReqInput();      
            exceRfndr = (ExceptionalRefundReqInput)System.JSON.deserialize(strExceRfndReq,ExceptionalRefundReqInput.class);
            
            cp.Refund_Reason__c = exceRfndr.reason;
            cp.Amount_to_be_Refunded__c = exceRfndr.refund.amount;
            cp.TIN_Number__c = exceRfndr.ticketNo;
            Order_Items__c orIt = new Order_Items__c();
            orIt = [Select id from Order_Items__c where Order_Item_Reference_No__c=:cp.TIN_Number__c];
            cp.Transaction_Name__c = orIt!=null?orIt.id:'';
            cp.OrderItemUuid__c =exceRfndr.orderItemUuid;
            
            res = http.send(req);       
            string responseValue = res.getBody();
            cp.FC_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
            
            if(res.getStatusCode()==200 && !string.isBlank(responseValue))
            {
                refundStatus = true;
                ExceptionalCanResponse exceRespone = new ExceptionalCanResponse();
                cp.FC_API_Ping__c = true;
                exceRespone = (ExceptionalCanResponse)JSON.deserialize(responseValue,ExceptionalCanResponse.class);                        
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
                    detailMessage = string.valueof(exceFailRespone.get('DetailedMessage'));
                // database.upsert(cp);
                listCp.add(cp);
                return refundStatus;
            }
            
        }
        catch(exception e)
        {
            System.debug('Exception...'+e);
            cp.FC_API_Request_Response__c = string.valueof(e);    
            listCp.add(cp);
            return refundStatus;
        }
        listCp.add(cp);
        return refundStatus;
    }
    
    public void ApproveorRejectstatus(String claimSts,String claimsucStatus,String claimFailStatus){
        
        string policyid = String.isNotBlank(csObj.Parent.Policy_Id__c)?csObj.Parent.Policy_Id__c:'';
        String tin =String.isNotBlank(csObj.Parent.TIN_No__c)?csObj.Parent.TIN_No__c:'';
        String claimid = String.isNotBlank(csObj.Parent.Claim_id__c)?csObj.Parent.Claim_id__c:'';
        String claimtype =String.isNotBlank(csObj.Parent.Claim_Type_ctp__c)?csObj.Parent.Claim_Type_ctp__c:'BTM';
        String claimstatus = claimSts;
        system.debug('---Insurance--'+csObj.Parent.Insurance_Provider_Name__c+'--channel--'+csObj.Parent.Channel_ct__c);
        string insuranceVendor=String.isNotBlank(csObj.Parent.Insurance_Provider_Name__c)?csObj.Parent.Insurance_Provider_Name__c:'ACKO';
        
        string jsonbody='{"policy_id":"'+policyid+'","tin":"'+tin+'","claim_id":"'+claimid+'","claim_type":"'+claimtype+'","claim_status":"'+claimstatus+'"}';
        string endPointData  =[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Approve_Claim'].Endpoint__c;     
        Http h= new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req =HttpRequestUtil.populateAckoInsuranceHeaders(req);
        req.setHeader('Channel',insuranceVendor);
        req.setEndpoint(endPointData);
        req.setMethod('POST');
        system.debug('setbody==>>'+jsonbody);
        req.setBody(jsonbody);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = insuranceVendor+'Claim Process'+claimstatus;
        dbl.Request_Data__c = string.valueof(req)+'..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--Cache-Control--'+req.getHeader('Cache-Control')+'--AuthToken--'+req.getHeader('AuthToken')+'--Channel--'+req.getHeader('insuranceVendor')+'--country--'+req.getHeader('Country');
        //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+'..'+String.valueOf(jsonBody)+'---Header--Content-Type--'+req.getHeader('Content-Type')+'--setTimeout--'+req.getHeader('setTimeout')+'--Cache-Control--'+req.getHeader('Cache-Control')+'--AuthToken--'+req.getHeader('AuthToken')+'--Channel--'+req.getHeader('insuranceVendor')+'--country--'+req.getHeader('Country');
        system.debug('res==>>'+res);
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
        res=h.send(req);
        dbl.CallOut_Status__c = string.valueOf(res.getStatus());
        dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
        system.debug('res==>>'+res.getbody());
        dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
        //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
        if(res!=null && res.getStatusCode()==200 && String.isNotBlank(res.getBody()))
        {
            
            map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
            
            Boolean issuccess = (Boolean)resMap.get('success');
            if(issuccess!=null)
                parCase.Claim_Status__c = issuccess?claimsucStatus:claimFailStatus;
        }
        insert dbl;
    }
    
    public object B2BExceptionalRefund(){
        System.debug('calling B2BExceptionalRefund');
        if(!test.isrunningtest() && (String.isBlank(caseComments) || caseComments.length()<11))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Case Comments and Minimum length is 10 Characters'));
            return null;
        }
        
        csObj = new Case(); 
        parCase = new Case();
        csObj= mapIdToCase.get(selCsId);
        System.debug('csObj-->'+csObj);  
        List<case> parentCaseList = [SELECT Id, Refund_status__c, redCare_Status__c, Approved_By__c, Approved_Rejected_Time__c,Refund_Amount__c,Amount__c FROM Case WHERE Id=:csObj.ParentId];
        if(seleStatus=='Approve'){
            if(string.isBlank(sellerCentralId) && String.isBlank(String.valueOf(csObj.My_Desk_Id__c))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter seller central id'));
                return null;  
            }else{
                if(String.isNotBlank(String.valueOf(csObj.My_Desk_Id__c))){
                    list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
                    Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(',')); 
                    csObj.status = 'Approve'.equalsIgnoreCase(seleStatus)?'Approved For Exceptional Refund':'Rejected For Exceptional Refund';
                    if('Approve'.equalsIgnoreCase(seleStatus)){
                        csObj.Exceptional_Refund_Initiated__c = true;
                        csObj.Refund_status__c='Exceptional Refund Approved';
                        csObj.redCare_Status__c ='Instant resolution with refund-Approved';
                        // if(string.isNotBlank(csObj.Service_Providerr_Id__c) && instantRefundBoIds.contains(csObj.Service_Providerr_Id__c) ){
                        //     parCase.Case_Category__c='Instant resolution-BOLT';
                        // }
                        parentCaseList[0].Refund_status__c='Exceptional Refund Approved';
                        parentCaseList[0].redCare_Status__c='Instant resolution with refund-Approved';
                        parentCaseList[0].Approved_By__c = agentName;
                        parentCaseList[0].Approved_Rejected_Time__c = System.Now();
                        parentCaseList[0].Refund_Amount__c= csObj.Refund_Amount__c;
                        parentCaseList[0].Amount__c = csObj.Refund_Amount__c;
                        csObj.Seller_Central_Id__c=sellerCentralId;
                        csObj.Approved_By__c = agentName;
                        csObj.Approved_Rejected_Time__c = System.Now();
                        // update new list<Case>{csObj,parentCaseList};
                        update csObj;
                        CaseComment csCom = new CaseComment();
                        csCom.ParentId = selCsId;
                        csCom.commentBody = caseComments;
                        insert csCom;
                        if(parentCaseList.size()>0 && !test.isRunningTest()){
                            update parentCaseList;
                        }
        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Refund Has Initiated Successfully For Case -'+csObj.CaseNumber));
                        refreshlist();
                        return null;
                    }
                }
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();   
                string expType;
                
                
                if(csObj.Issue_Sub_Category__c=='Operator Refund' && csObj.Reason_For_Report__c=='Service Issue'){ // CRM - 1591
                    expType='exceptionalRefund';
                }else{
                    expType='ncu';
                }
                if(csObj.Issue_Sub_Category__c!='Customer delight'){
                    APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BExpOperatorRefund'];
                    ExceptionalOperatorRefund eor=new ExceptionalOperatorRefund();
                    user uObj=[select id,Phone,MobilePhone,email from user where id=:UserInfo.getUserID()];
                    eor.tin=csObj.tin_no__c;
                    eor.amount=csObj.Refund_Amount__c;
                    eor.description=csObj.description;
                    eor.agentId=uObj.email;
                    eor.type=expType;
                    eor.sellerCentralId=sellerCentralId;
                    eor.exceptionalRefundReason=csObj.Reason_For_Report__c;
                    String expOpJson=json.serialize(eor);  
                    System.debug('expOpJson-->'+expOpJson);
                    Http http = new Http();
                    HttpResponse res = new HttpResponse();
                    HttpRequest req = new HttpRequest();        
                    req.setEndpoint(APIMData.Endpoint__c);
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json');  
                    req.setBody(expOpJson);               
                    string oauthParams=oauthObj.sign(req,csObj.Inventory_Type__c);        
                    string endPoint=APIMData.Endpoint__c+'?'+oauthParams;
                    req.setEndpoint(endPoint);
                    System.debug('endPoint-->'+endPoint);
                    expLogB2B=new DBLog_Summary__c();
                    expLogB2B.type__c='B2B-Exceptional Refund';
                    expLogB2B.Request_Data__c=String.valueOf(req)+'--Body-->'+expOpJson;
                    expLogB2B.EndPoint__c = String.valueOf(req.getEndpoint());
                    Continuation con = new Continuation(120);         
                    con.continuationMethod='GetB2BExceptionalRefundResponse';
                    this.excepRefReq= con.addHttpRequest(req); 
                    return con;
                }else if(csObj.Issue_Sub_Category__c=='Customer delight'){
                    csObj = new Case(); 
                    csObj= mapIdToCase.get(selCsId);
                    csObj.Seller_Central_Id__c=sellerCentralId;
                    csObj.Approved_By__c = agentName;
                    csObj.Approved_Rejected_Time__c = System.Now();   
                    csObj.status = 'Approve'.equalsIgnoreCase(seleStatus)?'Approved For Exceptional Refund':'Rejected For Exceptional Refund';
                    update csObj;
                    CaseComment csCom = new CaseComment();
                    csCom.ParentId = selCsId;
                    csCom.commentBody = caseComments;
                    insert csCom;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Approved!!'));     
                    
                }
            }
        }else if(seleStatus=='Deny'){        
            csObj.status='Rejected For Exceptional Refund';
            if(String.isNotBlank(String.valueOf(csObj.My_Desk_Id__c))){
                csObj.redCare_Status__c ='Instant resolution with refund-Rejected';
                parentCaseList[0].Refund_status__c='Exceptional Refund Rejected';
                parentCaseList[0].redCare_Status__c ='Instant resolution with refund-Rejected';
                csObj.Status='Rejected For Exceptional Refund';
            }
            update csObj;
                        if(parentCaseList.size()>0){
                            update parentCaseList;
                        }
            // update csObj;
            // update new list<Case>{parCase};
            CaseComment csCom = new CaseComment();
            csCom.ParentId = selCsId;
            csCom.commentBody = caseComments;
            insert csCom;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Rejected!!'));     
            
            return null;
        }
        return null;
    }
    public object GetB2BExceptionalRefundResponse(){
        try{
            csObj = new Case(); 
            csObj= mapIdToCase.get(selCsId);
            csObj.Seller_Central_Id__c=sellerCentralId;
            csObj.Approved_By__c = agentName;
            csObj.Approved_Rejected_Time__c = System.Now();   
            csObj.status = 'Approve'.equalsIgnoreCase(seleStatus)?'Approved For Exceptional Refund':'Rejected For Exceptional Refund';
            HttpResponse response=new HttpResponse();
            response = Continuation.getResponse(this.excepRefReq);
            this.excepRefResp= response.getBody();                     
            expLogB2B.Response_Received__c=this.excepRefResp;
            expLogB2B.CallOut_Status__c = string.valueOf(response.getStatus());
            if( this.excepRefResp=='Success'){
                update csObj;
                CaseComment csCom = new CaseComment();
                csCom.ParentId = selCsId;
                csCom.commentBody = caseComments;
                insert csCom;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully approved!!'));     
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API Failed!! Please Contact Admin! Response->'+this.excepRefResp));  
            }
        }catch(Exception e){
            expLogB2B.Exception_Description__c=string.valueOf(e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Occured!! Please try again!'+string.valueOf(e)));  
        }
        insert expLogB2B;
        return null;
    }
    
    public class ExceptionalOperatorRefund{
        public string tin;
        public decimal amount;
        public string description;
        public string agentId;
       // public boolean isPartialRefund=true;
        public boolean partialRefund=true;
        public string type;
        public string sellerCentralId;
        public string exceptionalRefundReason;
    }   
    
    public class ExceptionalRefundReqInput
    {
        public string emailId {get; set; }
        public string ticketNo {get; set; }
        public string cancellationType {get; set; }
        public string selectedSeat {get; set; }
        public string selectedRefundType {get; set; }
        public boolean isZcafeApplied {get; set; } 
        // no email flow - start
        public string mobileno {get; set; }
        // no email flow - end           
        //Bus Cancellation and Exception Cancellation Request Params
        public string orderItemUuid{get; set; }
        public string createdby{get; set; }
        public string reason{get; set; } 
        public boolean isExceptionalCancellation{get; set; } 
        public boolean isBusCancellation{get; set; }
        public boolean isExceptionalBusCancellation{get; set; }
        public decimal operatorContribution{get; set; } 
        public string cnr{get; set; }   
        public MoneyModel refund{get; set; }    
        public boolean IsExceptionalRefundApproved{get;set;}
        public integer exceptionalRefundCount{get; set;}

    }
    
    public class MoneyModel
    {
        public decimal amount{get;set;}
        public String currencyType{get;set;}
    }
    
    public class ExceptionalCanResponse
    {
        public String status{get;set;}
        public Map<String,String> data{get;set;}
        public Cls_errors[] errors;
    }
    
    public class Cls_errors
    {
        
    }
 
}