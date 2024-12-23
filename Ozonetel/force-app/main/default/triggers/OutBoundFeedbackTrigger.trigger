trigger  OutBoundFeedbackTrigger on OutBound_Feedback_Calling__c (before insert,before update) {

 Id outbdFdbckQueue = [Select id from Group where type='Queue' AND developername='Outbound_Feedback_Queue'].id;

if(Trigger.isBefore && Trigger.isInsert){

   for(OutBound_Feedback_Calling__c outBndCallng:Trigger.new)
    {
       if(string.isBlank(outBndCallng.Phone_No__c) ){
         outBndCallng.addError('phone no is missing, Please add the phone no');
       }else{
        outBndCallng.OwnerId=outbdFdbckQueue;
       }
    }
  }
  
  if(Trigger.isBefore && Trigger.isUpdate){
    for(OutBound_Feedback_Calling__c outBndCallng:Trigger.new)
    {
     if((outBndCallng.Call_Disposition_Status__c=='Callback Requested' || outBndCallng.Call_Disposition_Status__c=='New RnR' || outBndCallng.Call_Disposition_Status__c=='RnR') && outBndCallng.Call_Back_Time__c==null){
        outBndCallng.Call_Back_Time__c=System.now().addHours(1);
      }
    }
   
   }
   
  
   
}