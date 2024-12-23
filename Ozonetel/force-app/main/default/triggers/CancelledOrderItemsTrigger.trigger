trigger CancelledOrderItemsTrigger on Cancelled_Order_Items__c (After insert,after update) {
    
    API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
    set<string> canTripIds=new set<string>();
    
    APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CancelledOrderItemsTrigger'];
    if(APIMData.EnableLog__c){
        system.debug('--update--');
        CancelledOrderItemsHandler.createCase(Trigger.new,Trigger.oldMap);
    }
    
    
    //   && cOrd.Cancellation_Reason__c!=Trigger.oldMap.get(cOrd.id).Cancellation_Reason__c
    if(Trigger.isAfter && Trigger.isInsert){
        for(Cancelled_Order_Items__c cOrd:Trigger.new){
            if((cOrd.Cancellation_Reason__c=='BUS_CANCELLED' || cOrd.Cancellation_Reason__c=='SFA_Bus_Cancellation' ||cOrd.Cancellation_Reason__c=='Bus Cancelled') && cOrd.Business_Unit__c=='REDBUS_IN' && string.isNotBlank(cOrd.Order_Id__c) )
                canTripIds.add(cOrd.Order_Id__c);
            
        }
    }else if(Trigger.isAfter && Trigger.isUpdate){
        for(Cancelled_Order_Items__c cOrd:Trigger.new){
            if((cOrd.Cancellation_Reason__c=='BUS_CANCELLED' || cOrd.Cancellation_Reason__c=='SFA_Bus_Cancellation' ||cOrd.Cancellation_Reason__c=='Bus Cancelled') && cOrd.Business_Unit__c=='REDBUS_IN' && string.isNotBlank(cOrd.Order_Id__c) && cOrd.Cancellation_Reason__c!=Trigger.oldMap.get(cOrd.id).Cancellation_Reason__c )
                canTripIds.add(cOrd.Order_Id__c);            
        }
    }
    if(!canTripIds.isEmpty() && TransactionTriggerHandler.stopBusCClosedCase){
        TransactionTriggerHandler.stopBusCClosedCase=false;
        TransactionTriggerHandler.closeBusCanCases(canTripIds);
    }          
}