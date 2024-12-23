/**
*
* Name           : BPVerificationTrigger
* Created Date   : 02 Jul 2021
* Created By     : Mahendra
* Purpose        : To handle BO region details
* Test class     : BPVerificationTriggerTest
*
**/


Trigger BPVerificationTrigger on BP_Verification__c (before insert,after update) {
 
     //After Case Insert
    if(Trigger.isbefore && Trigger.isInsert)
    {
        BPVerificationTriggerHandler.BeforeInsert(Trigger.new);
    }
    
    //After Case Update
   if(Trigger.isAfter && Trigger.isUpdate)
    {
        BPVerificationTriggerHandler.AfterUpdate(Trigger.new,Trigger.oldMap);
        
    }
 
}