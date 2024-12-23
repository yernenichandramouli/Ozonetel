/**
 * (c) 2024 RedBus
 *
 * Name           : rpwAutomationCasesCtrl
 * Created Date   : 28 MAY 2024
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1778
 * Purpose        : Class to Automate the refund process based on the BO response from RPW.
 * Test class     : rpwAutomationCasesCtrlTest
 *
 **/

public class rpwAutomationCasesCtrl {

     // Method to create exceptional Refund case
    Public static void CreateExceptionalRefundCase(String parentCaseId){
        boolean refundCaseExists = false;
        boolean isReopenedCase = false;
       // string caseTabStatus;
        if(string.isNotBlank(parentCaseId)){
            List<Case> listCases = [Select id,Transaction_ID__c,All_Previous_Status_Dates__c,Brief_of_issue_Closure_comments__c,Max_Refund_Amount__c,Case_Category__c,Name_ct__c,Refund_status__c,status,redCare_Status__c,My_Desk_Id__c,Issue_Type__c,Amount__c,Trip_Id_ct__c,TIN_No__c,PNR__c,Channel_ct__c,Refund_Amount__c,Refund_Type__c,Inventory_Type__c,Service_Providerr_Id__c, Transaction_ID__r.Order_Item_Reference_No__c,Transaction_ID__r.Order_Id__c,Transaction_ID__r.Email__c,Transaction_ID__r.Business_Unit__c,Transaction_ID__r.Total_Fare_Currency__c,BO_Agreed_for_Refund__c,BO_Agreed_RB__c from Case where Id=:parentCaseId];
            string customerName = string.isNotBlank(listCases[0].Name_ct__c)?listCases[0].Name_ct__c:'Customer';
            
            // Check to verify whether the case has re-opened or not.
            String allPreviousStatus=String.isNotBlank(listCases[0].All_Previous_Status_Dates__c)?listCases[0].All_Previous_Status_Dates__c:'';
            List<String> values = allPreviousStatus.split(';');
            for(String value:values){
                if(value.Contains('Re-Open')){
                    isReopenedCase=true;
                }
            }


                // To check if there is any existing exceptional refund case.
                if(string.isNotBlank(listCases[0].Transaction_ID__r.Order_Item_Reference_No__c)){
                    List<Case> existCase = new List<Case>();   
                    string tinNumber = listCases[0].Transaction_ID__r.Order_Item_Reference_No__c;
                    String query;   
                    if(string.isNotBlank(listCases[0].My_Desk_Id__c)){
                        query = 'Select '+ System.Label.ExceRefundCheckQuery +' From CASE Where Issue_Type__c=\'Exceptional Refund\' AND  PNR_No__c=:tinNumber';
                    }else{
                        query = 'Select '+ System.Label.ExceRefundCheckQuery +' From CASE Where Issue_Type__c=\'Exceptional Refund\' AND Refund_status__c!=\'Exceptional Refund Approved\' AND Refund_status__c!=\'Exceptional Refund Rejected\' AND TIN_No__c=:tinNumber';
                    }
                    system.debug(':: Query = '+query);
                    existCase = Database.query(query);
                    refundCaseExists = existCase.isEmpty()?false:true;
                }

                if(refundCaseExists && listCases[0].BO_Agreed_RB__c=='agree'){
                    CaseComment csCom = new CaseComment();
                    csCom.ParentId = listCases[0].id;
                    csCom.commentBody ='The exceptional refund case has already been submitted for approval, so we will skip the RPW automation flow for this case.';
                    insert csCom;
                }

                // BO Agreed to process the refund
                if(!isReopenedCase && listCases[0].BO_Agreed_for_Refund__c && !String.isBlank(String.Valueof(listCases[0].Refund_Amount__c)) && listCases[0].Refund_Amount__c>0 && String.isNotBlank(listCases[0].BO_Agreed_RB__c) &&  listCases[0].BO_Agreed_RB__c=='agree' && !refundCaseExists && String.isNotBlank(string.valueOf(listCases[0].Max_Refund_Amount__c))){
                    if(string.isNotBlank(listCases[0].My_Desk_Id__c)){
                        // Create And Approve B2B Excetional Refund Case.
                        createAndApproveExceptionalRefundCase(parentCaseId,true);
                    }else{
                        // Create B2C Exceptional Refund Case.
                        createAndApproveExceptionalRefundCase(parentCaseId,false);
                    }
                }

                // Apology Cases
                if(!listCases[0].BO_Agreed_for_Refund__c && String.isBlank(String.Valueof(listCases[0].Refund_Amount__c)) && String.isNotBlank(listCases[0].BO_Agreed_RB__c) &&  listCases[0].BO_Agreed_RB__c=='agree'){
                    CaseComment csCom = new CaseComment();
                    csCom.ParentId = listCases[0].id;
                    csCom.commentBody ='(STC) Hi '+customerName+',\n We understand that your experience during the journey fell short of expectations. Your feedback has been shared with the bus operator so the quality of service can be improved. Please refer to the email sent to your booking email ID for further details.\n Stay safe, stay healthy!\n Team redBus';
                    insert csCom;

                    listCases[0].Status='Closed';
                    listCases[0].All_Previous_Status_Dates__c=listCases[0].status+','+String.valueOf(System.now())+';'+listCases[0].All_Previous_Status_Dates__c;
                    listCases[0].Refund_Type__c='Instant Closed with an Apology';
                    listCases[0].Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
                    Update listCases[0];
                }

                // BO Reject Cases
                if(!listCases[0].BO_Agreed_for_Refund__c && String.isNotBlank(listCases[0].BO_Agreed_RB__c) &&  listCases[0].BO_Agreed_RB__c=='disagree'){

                    CaseComment csCom = new CaseComment();
                    csCom.ParentId = listCases[0].id;
                    csCom.commentBody ='(STC) Dear '+customerName+',\n We did a prompt enquiry into this and it was confirmed that the bus operator did attempt to provide a reasonable solution because of which the refund has been denied by the bus operator against the ticket.\n Please refer to the email sent to your booking email ID for further details. \n Stay safe, stay healthy!\n Team redBus';
                    insert csCom;

                    listCases[0].Refund_status__c='Exceptional Refund Rejected';
                    listCases[0].status='Closed';
                    listCases[0].All_Previous_Status_Dates__c=listCases[0].status+','+String.valueOf(System.now())+';'+listCases[0].All_Previous_Status_Dates__c;
                    listCases[0].Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
                    if(string.isNotBlank(listCases[0].Channel_ct__c) && string.isNotBlank(listCases[0].My_Desk_Id__c) && (listCases[0].Channel_ct__c=='MMT' || listCases[0].Channel_ct__c=='GI')){
                        listCases[0].redCare_Status__c ='Instant resolution with refund-Rejected';
                    }
                    Update listCases[0];
                }
            // }
        }
    }
    
    // Method to create an exceptional refund cases
    public static void createAndApproveExceptionalRefundCase(string parentCaseId, boolean isMMtChannel){
        
        List<Case> listCases = [Select id,Transaction_ID__c,Track_Refund_Type__c,Brief_of_issue_Closure_comments__c,My_Desk_Id__c,Name_ct__c,Issue_Type__c,Amount__c,Max_Refund_Amount__c,Trip_Id_ct__c,TIN_No__c,PNR__c,Channel_ct__c,Refund_Amount__c,Refund_Type__c,Inventory_Type__c,Service_Providerr_Id__c, Transaction_ID__r.Order_Item_Reference_No__c,Transaction_ID__r.Order_Id__c,Transaction_ID__r.Email__c,Transaction_ID__r.Business_Unit__c,Transaction_ID__r.Total_Fare_Currency__c from Case where Id=:parentCaseId];
        list <case> listExpRefndCase = [Select id, status, Track_Refund_Type__c, Max_Refund_Amount__c, createddate,Refund_status__c, Exceptional_Refund_Count__c, Transaction_ID__c, Trip_Id_ct__c from Case where Issue_Type__c = 'Exceptional Refund' AND Refund_status__c='Exceptional Refund Approved' and TIN_No__c=:listCases[0].Transaction_ID__r.Order_Item_Reference_No__c ORDER BY createddate DESC];
        if(String.isNotBlank(listCases[0].Transaction_ID__c) && String.isBlank(listCases[0].Track_Refund_Type__c)){
            Case cs = new Case();
            if (listExpRefndCase.size()==0) {
                cs.Exceptional_Refund_Count__c =1;
            } else if(!listExpRefndCase.isEmpty() && listExpRefndCase.size()==1 && listExpRefndCase[0].Exceptional_Refund_Count__c==null){
                cs.Exceptional_Refund_Count__c =2;
            } else if(!listExpRefndCase.isEmpty() && listExpRefndCase[0].Exceptional_Refund_Count__c!=null) {
                cs.Exceptional_Refund_Count__c =listExpRefndCase[0].Exceptional_Refund_Count__c + 1;
            }
            cs.issue_type__c='Exceptional Refund';
            cs.Issue_Sub_Category__c='Collectible From BO';
            cs.Trip_Id_ct__c = isMMtChannel?listCases[0].Trip_Id_ct__c:listCases[0].Transaction_ID__r.Order_Id__c;
            cs.TIN_No__c = isMMtChannel?listCases[0].TIN_No__c:listCases[0].Transaction_ID__r.Order_Item_Reference_No__c;
            cs.Refund_Amount__c=listCases[0].Refund_Amount__c;
            cs.description='Since bo has agreed to process the refund, so the exceptionaln refund case has been created.';
            cs.Transaction_ID__c=listCases[0].Transaction_ID__c;
            cs.status='Open';
            cs.Booking_Email_ID__c = listCases[0].Transaction_ID__r.Email__c;
            cs.OwnerId = System.Label.ExceptionalRefundQueueId;
            cs.Origin='InBound Call';
            cs.Subject = 'Exceptional Refund- Collectible From BO';
            cs.Parentid=listCases[0].id;
            cs.Business_Unit_ct__c = listCases[0].Transaction_ID__r.Business_Unit__c;
            cs.User_Level_Team__c = 'RPW Automation';            
            cs.Reason_For_Report__c='Case created By RPW Automation';
            cs.Type=isMMtChannel?'B2B':'B2C';
            cs.Channel_ct__c = listCases[0].Channel_ct__c;
            cs.My_Desk_Id__c = isMMtChannel?String.valueOf(listCases[0].My_Desk_Id__c):'';
            cs.Name_ct__c = listCases[0].Name_ct__c;

            if(listCases[0].Refund_Amount__c < listCases[0].Max_Refund_Amount__c){
                cs.Track_Refund_Type__c='Partial Refund';
                listCases[0].Track_Refund_Type__c='Partial Refund';
            }else{
                cs.Track_Refund_Type__c='Full Refund';
                listCases[0].Track_Refund_Type__c='Full Refund';
            }
            
            if('REDBUS_COM'.equalsIgnoreCase(listCases[0].Transaction_ID__r.Business_Unit__c)){
                cs.country__c=OrderItemTransactionResource__c.getValues(listCases[0].Transaction_ID__r.Business_Unit__c).Case_Country__c;
                cs.Business_Type__c=OrderItemTransactionResource__c.getValues(listCases[0].Transaction_ID__r.Business_Unit__c).Case_Business_Type__c;
                cs.Price_Paid_Currency_ctp__c = listCases[0].Transaction_ID__r.Total_Fare_Currency__c;
            }else{
                String conBusUnit = 'REDBUS_'+listCases[0].Transaction_ID__r.Business_Unit__c.split('_')[1];
                cs.Business_Type__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c;
                cs.country__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c;
                cs.Price_Paid_Currency_ctp__c = listCases[0].Transaction_ID__r.Total_Fare_Currency__c;
            }
            try{
                insert cs;    
                update listCases[0];
                
                set<id> csIds=new set<id>();
                csIds.add(cs.id);
                invokeApprovalAPI(csIds);
            }Catch(DMLException de){
                System.debug('::: Exception occure ='+de.getMessage());
            }
        }
    }

    // Method to approve exceptional refund cases
    @future(callout=true)
    public static void invokeApprovalAPI(set<id> caseIds){
        boolean refundStatus;
        string caseCommentToInsert;
        List<case> cObjLs=new List<case>();
        list<Cancellation_Process_DB_Log__c> listCp=new list<Cancellation_Process_DB_Log__c>();
        cObjLs=[select Id,Brief_of_issue_Closure_comments__c,ParentId,caseNumber,My_Desk_Id__c, Name_ct__c, Approved_Rejected_Time__c, Service_Providerr_Id__c,Channel_ct__c,Track_Refund_Type__c,Category__c,Refund_Type__c,Exceptional_Refund_Count__c,createdById,status,TIN_No__c,Booking_Email_ID__c,Booking_EMail_Copy__c,Booking_Mobile_No__c,OrderItem_Uuid__c,Issue_Sub_Category__c,Refund_Amount__c,Price_Paid_Currency_ctp__c,Exceptional_Refund_Initiated__c,Refund_status__c,Business_Unit_ct__c,Service_Provider_Id__c from case where id in:caseIds];
        List<DBLog_Summary__c> listDBLogSumm = new List<DBLog_Summary__c>();
        case csObj=new case();
        string customerName;

        if(!cObjLs.isEmpty() && string.isBlank(cObjLs[0].My_Desk_Id__c)){
            DBLog_Summary__c dbLogSumm = new DBLog_Summary__c();
            dbLogSumm.Type__c = 'Automatic RPW Apprvoed flow cases';
            list<case> parCsList=new List<case>();
            parCsList=[select id,Refund_Type__c from case where id=:cObjLs[0].ParentId];
            System.debug('ApproveExceptionalRefund called-->'+cObjLs[0].id);
            csObj=cObjLs[0];
            customerName = string.isNotBlank(csObj.Name_ct__c)?csObj.Name_ct__c:'Customer';
            dbLogSumm.Case_Number__c = String.valueOf(csObj.CaseNumber);
            List<Cancellation_Process_DB_Log__c> cpList=new List<Cancellation_Process_DB_Log__c>();
            List<case> csUpList=new List<case>();
            case parCase = new Case();
            parCase.id = csObj.ParentId;  

            ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
            exceRfndReq.ticketNo = csObj.TIN_No__c;
            exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)?csObj.Booking_EMail_Copy__c:'';
            exceRfndReq.mobileno = string.isNotBlank(csObj.Booking_Mobile_No__c)?csObj.Booking_Mobile_No__c:'';
            exceRfndReq.cancellationType = '1';      
            exceRfndReq.selectedSeat='';
            exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
            exceRfndReq.orderItemUuid = csObj.OrderItem_Uuid__c;
            exceRfndReq.createdby = UserInfo.getUserName();   
            exceRfndReq.reason = csObj.Issue_Sub_Category__c;
            exceRfndReq.isExceptionalCancellation = true;
            exceRfndReq.exceptionalRefundCount =integer.valueof(csObj.Exceptional_Refund_Count__c);
            exceRfndReq.operatorContribution = csObj.Refund_Amount__c;
            ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
            monyMod.amount = csObj.Refund_Amount__c;
            monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)?csObj.Price_Paid_Currency_ctp__c:'INR';
            exceRfndReq.refund = monyMod; 
            try{
                ApproveExceptionalRefund ae=new ApproveExceptionalRefund();
                refundStatus = ae.initiateExceptionalRefund(Json.serialize(exceRfndReq),csObj);
                database.upsert(listCp);
                if (refundStatus) {
                    dbLogSumm.Order_Items_Success__c = 'Success';
                    csObj.Exceptional_Refund_Initiated__c = true;
                    csObj.Refund_status__c='Exceptional Refund Approved';
                    parCase.Refund_status__c='Exceptional Refund Approved';
                    csObj.status='Approved For Exceptional Refund';
                    csObj.Approved_By__c = UserInfo.getUserName();
                    csObj.Approved_Rejected_Time__c = System.Now();   
                    csObj.OwnerId = csObj.createdById;
                    parCase.status='Closed';
                    parCase.All_Previous_Status_Dates__c=parCase.status+','+String.valueOf(System.now())+';'+parCase.All_Previous_Status_Dates__c;
                    csObj.Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
                    parCase.Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
                    parCase.User_Level_Team__c = 'RPW Automation'; 
                    parCase.Approved_Rejected_Time__c = System.Now();              
                    parCase.Reason_For_Report__c='Case created By RPW Automation';
                    CaseComment parCaseCom = new CaseComment();
                    parCaseCom.ParentId = parCase.id;
                    parCaseCom.commentBody ='(STC) Hi '+customerName+',\n We are delighted to share your refund status - \n Refunded Amount: Rs.'+csObj.Refund_Amount__c+'\n Initiated on:'+csObj.Approved_Rejected_Time__c.format('yyyy-MM-dd HH:mm:ss', 'IST')+'\n Source: Original mode of payment\n As per the standard banking procedure the amount will be refunded within 5 to 7 bank working days for Debit/Credit/Net Banking and 48 hours for UPI in the name of IBIBO Group Pvt/redBus.. Please refer to the email sent to your booking email ID for further details.\n Stay safe, stay healthy!\n Team redBus';
                    insert parCaseCom;

                    update new list<Case>{csObj,parCase};
                    CaseComment csCom = new CaseComment();
                    csCom.ParentId = csObj.id;
                    csCom.commentBody =caseCommentToInsert;
                    insert csCom;
                }else{
                    dbLogSumm.Order_Items_Success__c = 'Failed';
                }
                // update new List<Case>{ csObj, parCase };
            } catch(Exception e){
                system.debug('Error while invoking the API call '+e);
                dbLogSumm.Exception_Description__c = String.valueOf(e);
            }
            listDBLogSumm.add(dbLogSumm);
        }else if(!cObjLs.isEmpty() && string.isNotBlank(cObjLs[0].My_Desk_Id__c)){
            csObj=cObjLs[0];
            case parCase = new Case();
            parCase.id = csObj.ParentId;  
            csObj.status = 'Approved For Exceptional Refund';
            csObj.Refund_status__c='Exceptional Refund Approved';
            csObj.Exceptional_Refund_Initiated__c = true;
            csObj.Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
            csObj.redCare_Status__c ='Instant resolution with refund-Approved';
            csObj.Approved_Rejected_Time__c = System.Now();   
            customerName = string.isNotBlank(csObj.Name_ct__c)?csObj.Name_ct__c:'Customer';

            CaseComment csCom = new CaseComment();
            csCom.ParentId = csObj.id;
            csCom.commentBody ='(STC) Hi '+customerName+',\n We are delighted to share your refund status - \n Refunded Amount: Rs.'+csObj.Refund_Amount__c+'\n Initiated on:'+csObj.Approved_Rejected_Time__c.format('yyyy-MM-dd HH:mm:ss', 'IST')+'\n Source: Original mode of payment\n As per the standard banking procedure the amount will be refunded within 5 to 7 bank working days for Debit/Credit/Net Banking and 48 hours for UPI in the name of IBIBO Group Pvt/redBus.. Please refer to the email sent to your booking email ID for further details.\n Stay safe, stay healthy!\n Team redBus';
            insert csCom;

            CaseComment pcsCom = new CaseComment();
            pcsCom.ParentId = parCase.id;
            pcsCom.commentBody ='(STC) Hi '+customerName+',\n We are delighted to share your refund status - \n Refunded Amount: Rs.'+csObj.Refund_Amount__c+'\n Initiated on:'+csObj.Approved_Rejected_Time__c.format('yyyy-MM-dd HH:mm:ss', 'IST')+'\n Source: Original mode of payment\n As per the standard banking procedure the amount will be refunded within 5 to 7 bank working days for Debit/Credit/Net Banking and 48 hours for UPI in the name of IBIBO Group Pvt/redBus.. Please refer to the email sent to your booking email ID for further details.\n Stay safe, stay healthy!\n Team redBus';
            insert pcsCom;

            parCase.Refund_status__c='Exceptional Refund Approved';
            parCase.redCare_Status__c='Instant resolution with refund-Approved';
            parCase.Approved_By__c = UserInfo.getUserName();
            parCase.Brief_of_issue_Closure_comments__c = 'RPW Service Case Automation';
            parCase.Approved_Rejected_Time__c = System.Now();
            parCase.Amount__c = cObjLs[0].Refund_Amount__c;
            parCase.Status='Closed';
            parCase.All_Previous_Status_Dates__c=parCase.status+','+String.valueOf(System.now())+';'+parCase.All_Previous_Status_Dates__c;
            update new List<Case>{ csObj, parCase };
        }
        insert listDBLogSumm;
    }
}