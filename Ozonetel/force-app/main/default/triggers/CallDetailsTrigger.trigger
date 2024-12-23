trigger CallDetailsTrigger on Call_Details__c (after insert) {
    List<Call_Details__c> cdList=new List<Call_Details__c>();
    set<string> tripIds=new set<string>();
    string tripId;
    for(Call_Details__c cd:Trigger.new){
        if(cd.OrderUuid__c!=null){
            tripId=cd.OrderUuid__c;
        }
    }
    if(tripId!=null && System.Label.CallDetailsTrigger=='TRUE' )
        CallDetailsTriggerHandler.OrderSync(tripId);  
}