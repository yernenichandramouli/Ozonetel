/**
* (c) 2017 RedBus
*
* Name           : CZentrixInfoTrigger
* Created Date   : 06 Jun 2017
* Created By     : Sreenivas M
* Purpose        : Trigger to link C-Zentrix Info to Account
* Test class     : CZentrixInfoTriggerTest
*
**/

trigger CZentrixInfoTrigger on CZentrix_Info__c (After Insert,After Update) 
{
    
 /*    System.debug('Inside trigger..');
   
    if(System.isFuture())
    {
        return;
    }
    
    else if([SELECT EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CZentrixTrigger'].EnableLog__c && !System.isFuture())
    {
        System.debug('Inside If trigger..');
        CZentrixInfoTriggerHandler.linkCZentrixtoAccount(JSON.Serialize(Trigger.new));
    }
  */  
    if([SELECT EnableLog__c FROM API_EndPoints__mdt where DeveloperName='CZentrixTrigger'].EnableLog__c && Trigger.Isinsert){
        CZentrixInfoTriggerHandler.LeadActions(Trigger.new);
    }
}