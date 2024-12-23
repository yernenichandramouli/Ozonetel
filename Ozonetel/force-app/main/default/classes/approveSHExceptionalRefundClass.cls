/**
 * (c) 2023 RedBus
 *
 * Name           : approveSHExceptionalRefundClass
 * Created Date   : 04 MAY 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM -1381
 * Purpose        : Generic class to process exceptional refund cases created through self help
 * Test class     : approveSHExceptionalRefundClassTest
 *
 **/
public class approveSHExceptionalRefundClass {
    string query;
    // public Datetime currentDateTime;

    public approveSHExceptionalRefundClass(string strQuery){
        if (String.isNotBlank(strQuery)) {
            System.debug('::IF:: ');
            query = strQuery;
        }else{
            System.debug('::Elswe:: ');
            query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName = 'selfHelpBoltAutomationCases'].QueryDetails__c;
        }
        System.debug('::Query in Approve:: '+query);
        invokeApprovalAPI(query);
    }

    @future(callout=true)
    public static void invokeApprovalAPI(string query){
        Datetime currentDateTime = System.now();
        List<case> lstcases = DataBase.query(query);
        System.debug('::lstcases ==' +lstcases);
        List<DBLog_Summary__c> listDBLogSumm = new List<DBLog_Summary__c>();
        System.debug(':: lstcases ::: '+lstcases);
        if(!lstcases.isEmpty()){
            list<case> parCsList = new List<case>();
            List<case> parentCaseListToUpdate = New List<case>();
            List<case> exceRefundListToUpdate = New List<case>();

            for (Case cObjLs : lstcases) {
                DBLog_Summary__c dbLogSumm = new DBLog_Summary__c();
                dbLogSumm.Type__c = 'SelfHelp Bolt Approval API Invoke';
                boolean refundStatus;
                parCsList = [SELECT id, Refund_Type__c FROM case WHERE id = :cObjLs.ParentId];
                System.debug('ApproveExceptionalRefund called-->' + cObjLs.id);
                case csObj = new case();
                csObj = cObjLs;
                case parCase = new Case();
                parCase.id = csObj.ParentId;
                dbLogSumm.Case_Number__c = String.valueOf(csObj.CaseNumber);
                ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput exceRfndReq = new ExceptionalRefundApprovalCntl.ExceptionalRefundReqInput();
                exceRfndReq.ticketNo = csObj.TIN_No__c;
                exceRfndReq.emailId = String.isNotBlank(csObj.Booking_Email_ID__c)?csObj.Booking_Email_ID__c:String.isNotBlank(csObj.Booking_EMail_Copy__c)? csObj.Booking_EMail_Copy__c:'';
                exceRfndReq.mobileno = string.isNotBlank(csObj.Booking_Mobile_No__c)? csObj.Booking_Mobile_No__c:'';
                exceRfndReq.cancellationType = '1';
                exceRfndReq.selectedSeat = '';
                exceRfndReq.selectedRefundType = 'BACK_TO_SOURCE';
                exceRfndReq.orderItemUuid = csObj.OrderItem_Uuid__c;
                exceRfndReq.createdby = UserInfo.getUserName();
                exceRfndReq.reason = csObj.Issue_Sub_Category__c;
                exceRfndReq.isExceptionalCancellation = true;
                exceRfndReq.IsExceptionalRefundApproved = false;
                exceRfndReq.exceptionalRefundCount = integer.valueof(csObj.Exceptional_Refund_Count__c);
                // exceRfndReq.exceptionalRefundCount = null;
                ExceptionalRefundApprovalCntl.MoneyModel monyMod = new ExceptionalRefundApprovalCntl.MoneyModel();
                monyMod.amount = csObj.Refund_Amount__c;
                monyMod.currencyType = String.isNotBlank(csObj.Price_Paid_Currency_ctp__c)? csObj.Price_Paid_Currency_ctp__c : 'INR';
                exceRfndReq.refund = monyMod;
                try{
                    ApproveExceptionalRefund ae = new ApproveExceptionalRefund();
                    refundStatus = ae.initiateExceptionalRefund(Json.serialize(exceRfndReq), csObj);
                    system.debug('::refundStatus::: '+refundStatus);
                    csObj.Scheduler_Attempts__c = csObj.Scheduler_Attempts__c==null?1:csObj.Scheduler_Attempts__c+1;
                    if(csObj.Scheduler_Attempts__c ==1){
                        csObj.Date_Submitted_ct__c=csObj.SH_Dropping_Time__c.addHours(6);
                    }else if(csObj.Scheduler_Attempts__c ==2){
                        csObj.Date_Submitted_ct__c=csObj.SH_Dropping_Time__c.addHours(12);
                    }else if(csObj.Scheduler_Attempts__c ==3){
                        csObj.User_Level_Team__c='SelfHelp Bot Failure';
                    }
                    system.debug('Scheduler_Attempts__c = '+csObj.Scheduler_Attempts__c);
                    system.debug('DateSubmitted = '+csObj.Date_Submitted_ct__c);
                    if (refundStatus) {
                        dbLogSumm.Order_Items_Success__c = 'Success';
                        csObj.Exceptional_Refund_Initiated__c = true;
                        csObj.Refund_status__c = 'Exceptional Refund Approved';
                        parCase.Refund_status__c = 'Exceptional Refund Approved';
                        csObj.status = 'Approved For Exceptional Refund';
                        csObj.Approved_By__c = UserInfo.getUserName();
                        csObj.Approved_Rejected_Time__c = System.Now();
                        csObj.OwnerId = csObj.createdById;
                    
                        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c, DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName = 'Bolt_Bo_Ids' LIMIT 1];
                        Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
                    
                        if (csObj.Issue_Sub_Category__c == 'Instant refund - Collectible from BO') {
                            if( !parCsList.isEmpty() && string.isNotBlank(parCsList[0].Refund_Type__c)){
                                csObj.Refund_Type__c = parCsList[0].Refund_Type__c;
                            }else {
                                csObj.Refund_Type__c = 'Instant resolution with refund';
                                parCase.Refund_Type__c = 'Instant resolution with refund';
                            }
                        }
                        CaseComment parcsCom = new CaseComment();
                        parcsCom.ParentId = parCase.id;
                        parcsCom.commentBody = 'Exceptional Refund case has been processed by scheduler.';
                        insert parcsCom;
                    
                        parCase.Status = 'Closed';

                        CaseComment csCom = new CaseComment();
                        csCom.ParentId = csObj.id;
                        csCom.commentBody = 'Exceptional Refund case is Approved';
                        insert csCom;
                    }else{
                        dbLogSumm.Order_Items_Success__c = 'Failed';
                    }
                    update new List<Case>{ csObj, parCase };
                }catch(Exception e){
                    system.debug('Error while invoking the API call '+e);
                    dbLogSumm.Exception_Description__c = String.valueOf(e);
                }
                listDBLogSumm.add(dbLogSumm);
            }
            insert listDBLogSumm;
        }
    }
}