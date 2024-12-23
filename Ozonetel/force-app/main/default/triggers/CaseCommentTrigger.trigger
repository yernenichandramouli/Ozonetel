/**
*
* Name           : CaseCommentTrigger
* Created Date   : 04 Apr 2018
* Created By     : Veeramanikanta R
* Purpose        : Handling casecomment object events 
*
**/
trigger CaseCommentTrigger on CaseComment (after insert) {

CaseCommentTriggerHandler.CommentAction(Trigger.new);
   /* 
    set<id> ccIds=new set<id>();
    for(CaseComment cc:Trigger.new){
        if(String.isNotBlank(cc.commentbody) && cc.commentbody.startswith('(STC)')){
            ccIds.add(cc.parentid);
        }
    }
    if(!ccIds.isEmpty() && !System.isFuture() && !System.isBatch())
        CaseCommentTriggerHandler.pushNotification(ccIds,'commentInsert');
        */
}