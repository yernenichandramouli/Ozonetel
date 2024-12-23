/**
* (c) 2017 RedBus
*
* Name           : LeadTrigger
* Created Date   : 26 July 2017
* Created By     : Sreenivas M
* Purpose        : Handle all DML Opertions on Leads
* Test class     : LeadTriggerTest
*
**/

trigger LeadTrigger on Lead (Before Insert,Before Update,After Update) 
{
  LeadTriggerHandler ld = new LeadTriggerHandler();
  // Before Insert
  
  if(Trigger.isInsert && Trigger.isBefore)
    LeadTriggerHandler.BeforeInsert(Trigger.new); 
   
  //Before Update
  if(Trigger.isUpdate && Trigger.isBefore)
  LeadTriggerHandler.BeforeUpdate(Trigger.new,Trigger.oldMap);
  
  //After Update
  if(Trigger.isAfter && Trigger.isUpdate){
  LeadTriggerHandler.AfterUpdate(Trigger.new,Trigger.oldMap);
  }
}