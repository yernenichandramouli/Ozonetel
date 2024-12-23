/**
 * (c) 2022 RedBus
 *
 * Name           : AutoCloseFTCasesScheduler
 * Created Date   : 25 AUG 2022
 * Created By     : VR Sudarshan
 * Purpose        : CRM - 1202 Scheduler to close FT cases if refund is initiated.
 * Test class     : AutoCloseFTCasesSchedulerTest
 *
 **/
global class AutoCloseFTCasesScheduler implements DataBase.Batchable<sObject>,Database.AllowsCallouts,Schedulable{
    public string query;
    public AutoCloseFTCasesScheduler(String strQuery){
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }
        else {
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Auto_Close_FT_Cases'].QueryDetails__c;
        }
    }

    public void execute(SchedulableContext scon){
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Auto_Close_FT_Cases'].Duration__c;
        System.schedule('AutoCloseFTCasesScheduler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new AutoCloseFTCasesScheduler(Query));
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> lstcases){
        Map<id,Case> caseMap = new Map<id,Case>();
        set<id> TransactionIdSet = New set<id>();
        List<case> caseListToUpdate = New List<Case>();
        List<CaseComment> caseCommentList = New List<CaseComment>();
        List<DBLog_Summary__c> listDBLogSumm = new List<DBLog_Summary__c>();
         Map<string,Case> caseMapIDNOrdrItmUuid = new Map<string,Case>();
        try{
            if(!lstcases.isEmpty()){
                for(case tempCase: lstcases){
                    caseMap.put(tempCase.Transaction_ID__c, tempCase);
                    
                    if(tempCase.Business_Unit_ct__c=='REDBUS_ID')
                    {
                      caseMapIDNOrdrItmUuid.put(tempCase.OrderItem_Uuid__c,tempCase);
                    }
                }
                
                System.debug(':: caseMap :: '+caseMap);
                for(Refund_Order_Items__c refundOrderItem: [SELECT Id, Order_Item_Name__c FROM Refund_Order_Items__c WHERE Order_Item_Name__c in :caseMap.keySet()]){
                    TransactionIdSet.add(refundOrderItem.Order_Item_Name__c);
                }
                System.debug(':: TransactionIdSet :: '+TransactionIdSet);
                System.debug(':: caseMapvalues :: '+caseMap.values());
                list<Order_Items__c> lstOrderItms =[select id,Rebooking_For__c from Order_Items__c where Rebooking_For__c in :caseMapIDNOrdrItmUuid.keySet() and status__c ='TR_CONFIRMED_PO_COMPLETED'];
                   
                if(!lstOrderItms.isEmpty()){
                   for(Order_Items__c oriT:lstOrderItms){
                           if(caseMapIDNOrdrItmUuid.containsKey(oriT.Rebooking_For__c)){
                               case cs=caseMapIDNOrdrItmUuid.get(oriT.Rebooking_For__c);
                                 //cs.id=caseMapIDNOrdrItmUuid.get(oriT.Rebooking_For__c).id;
                                cs.Status='Closed';
                                CaseComment csComment = new CaseComment();
                                csComment.ParentId = cs.Id;
                                csComment.commentBody = 'Closing the ticket as the rebooking is compeleted';
                                caseCommentList.add(csComment);
                                caseListToUpdate.add(cs);
                           }
                    }
                }
                
                for(case caseVal:caseMap.values()){
                    system.debug('::: Case Value ::: '+caseVal);
                    if(TransactionIdSet.contains(caseVal.Transaction_ID__c)){
                        caseVal.Status='Closed';
                        caseListToUpdate.add(caseVal);
                        CaseComment csComment = new CaseComment();
                        csComment.ParentId = caseVal.Id;
                        csComment.commentBody = 'Closing the ticket as the refund is initiated at '+System.now().format();
                        caseCommentList.add(csComment);
                        DBLog_Summary__c dbLogSumm = new DBLog_Summary__c();
                        dbLogSumm.type__c ='AutoCloseFTCasesScheduler';
                        dbLogSumm.Case_Number__c = String.valueOf(caseVal.caseNumber);
                        dbLogSumm.Payment_Transaction_Name__c = caseVal.Transaction_ID__c;
                        listDBLogSumm.add(dbLogSumm);
                    }
                }
            }
            System.debug(':: caseCommentList :: '+caseCommentList);
            System.debug(':: caseListToUpdate :: '+caseListToUpdate);
            System.debug(':: listDBLogSumm :: '+listDBLogSumm);
            if(!caseCommentList.isEmpty()){
                insert caseCommentList;
            }
            if(!caseListToUpdate.isEmpty()){
                DataBase.update(caseListToUpdate,false);
                //Update caseListToUpdate;
            }
            if(!listDBLogSumm.isEmpty()){
                insert listDBLogSumm;
            }

        }catch(Exception e){
            System.debug('::: Exception Occured ::: '+e+' :::: Exception Line Number ::::: ' +e.getLineNumber());
        }
        
    }

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('sudarshan.vr@redbus.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('AutoCloseFTCasesScheduler.'+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}