/**
 * (c) 2022 RedBus
 *
 * Name           : SGMYBulkCloseCaseCtrl
 * Created Date   : 07 MAR 2023
 * Created By     : VR Sudarshan
 * Purpose        : CRM-1337 Controller to bulk close sgmy community cases.
 * Test class     : SGMYBulkCloseCaseCtrlTest
 *
 **/
public with sharing class SGMYBulkCloseCaseCtrl {
    @AuraEnabled(cacheable=true)
    public static List<Case> getSGMYcaseList() {
        // List<Case> caseList = [SELECT Id, CaseNumber, Issue_Type__c, Subject, Owner.Name, CreatedDate FROM Case WHERE recordtype.Name in ('SGMY HQBusdev','RDC Community Layout') AND status!='Closed' AND (OwnerId = :UserInfo.getUserId() OR Owner.Name='SGMY HQBusdev Queue' OR Owner.Name='RDC Community') LIMIT 50];
        List<Case> caseList = [SELECT Id, CaseNumber, Issue_Type__c, Subject, Owner.Name, CreatedDate FROM Case WHERE recordtype.Name = 'SGMY HQBusdev' AND status!='Closed' AND (OwnerId = :UserInfo.getUserId() OR Owner.Name='SGMY HQBusdev Queue') LIMIT 50];
        return caseList;
    }

    @AuraEnabled
    public static string closeSelectedCases(List<string> CaseIds, string IssueType, string casecommentToInsert){
        List<CaseComment> caseCommentListToInsert = New List<CaseComment>();
        List<case> caseListToUpdate = New List<case>();
        List<case> caseList = [SELECT Id, Issue_Type__c, Status FROM Case WHERE Id in: CaseIds];
        try{
            if(!caseList.isEmpty()){
                for(case c : caseList){
                    c.Issue_Type__c=IssueType;
                    c.Status='Closed';
                    caseListToUpdate.add(c);

                    casecomment cc=new casecomment();
                    cc.parentid=c.id;
                    cc.commentbody='Bulk Close --->'+casecommentToInsert;
                    caseCommentListToInsert.add(cc);
                }

                if(!caseCommentListToInsert.isEmpty()){
                    database.Insert(caseCommentListToInsert, false);
                }

                if(!caseListToUpdate.isEmpty()){
                    database.update(caseListToUpdate, false);
                }
                return 'success';
            }
        }catch(exception e){
            return string.valueOf(e.getMessage());
        }
        return 'No_Records';
    }


}