/**
* (c) 2017 RedBus
*
* Name           : CaseTrigger
* Created Date   : 04 Jan 2017
* Created By     : Sreenivas M
* Purpose        : CaseTrigger to handle all duplicate checks/bus cancellation upserts in Trex D
* Test class     : CaseTriggerTest
*
**/

Trigger CaseTrigger on Case (Before Insert,Before Update, After Insert,after update) 
{
       
    // Before Case Insert  
    if(Trigger.isBefore && Trigger.isInsert && !CaseTriggerHandler.stopBeforeInsertDuplicateTATCheck)
    {
        CaseTriggerHandler.stopBeforeInsertDuplicateTATCheck=true;
        CaseTriggerHandler.updateTATValue(Trigger.new,Trigger.oldMap,Trigger.newMap);
        //CaseTriggerHandler.duplicateCheck(Trigger.new,Trigger.oldMap);
       
    }
    if(Trigger.isBefore && Trigger.isInsert){
        caseTriggerHandler.mapYourBusDetails(Trigger.New);
        caseTriggerHandler.UpdateBDmailId(Trigger.New);
    }
    
    //Before Case Update    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
           
            for(Case c:Trigger.new)
            {
                System.debug('Before update..'+c.ownerId);
                if(c.OwnerId==Label.Default_Queue && Trigger.oldMap.get(c.Id).OwnerId!=NULL)
                c.OwnerId=Trigger.oldMap.get(c.Id).OwnerId;
                System.debug('After update..'+c.ownerId);
            }

            if(!CaseTriggerHandler.stopBeforeUpdateDuplicateTATCheck)
            {   
                CaseTriggerHandler.stopBeforeUpdateDuplicateTATCheck=true;
                CaseTriggerHandler.updateTATValue(Trigger.new,Trigger.oldMap,Trigger.newMap);
                //CaseTriggerHandler.duplicateCheck(Trigger.new,Trigger.oldMap);
            }
            caseTriggerHandler.updateAgentAssignedTime(Trigger.New, Trigger.OldMap);
            //caseTriggerHandler.UpdateBDmailId(Trigger.New);
       
    }
    
    
    //After Case Insert
    if(Trigger.isAfter && Trigger.isInsert)
    {
        CaseTriggerHandler.caseAfterInsert(Trigger.new,Trigger.oldMap);
        caseTriggerHandler.closeChildCases(Trigger.new,Trigger.newMap);        
    }
    
    //After Case Update
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        caseTriggerHandler.closeChildCases(Trigger.new,Trigger.oldMap);
        CaseTriggerHandler.caseAfterUpdate(Trigger.new,Trigger.oldMap);
        
    }
}