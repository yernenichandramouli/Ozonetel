trigger MassExceptionalRefundTrigger on Mass_Exceptional_Refund__c (Before Insert) {

  if(Trigger.isBefore && Trigger.isInsert){
  
   for(Mass_Exceptional_Refund__c masExp:Trigger.new)
    {
       if(string.isBlank(masExp.Parent_Case_Number__c) || string.isBlank(masExp.Exceptional_Refund_Amount__c) || string.isBlank(masExp.Exceptional_Refund_Type__c) || string.isBlank(masExp.TIN_No__c)){
         masExp.addError('Few data is missing please check ParentCasenumber,Tin,Refund Type,Refund Amount');
       }
    }
  }
  
}