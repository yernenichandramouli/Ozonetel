/**
*
* Name           : AccountTrigger 
* Created Date   : 15 June 2017
* Created By     : Veeramanikanta
* Purpose        : Allows all the trigger events and call to corresponding handler class methods
* Test class     : AccountTriggerTest
*
**/
trigger AccountTrigger on Account (After insert,After update) {
     API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
     APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Account_Trigger'];
     set<Id> accIds=new set<Id>();
    
    if(APIMData.EnableLog__c)
    {
    If(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
       //  AccountTriggerHandler.HFData(Trigger.new);
         for(Account acc:Trigger.new){
           accIds.add(acc.id);
         }
        if(!system.isFuture())
         AccountTriggerHandler.HFData(accIds);
    }
    }
    
}