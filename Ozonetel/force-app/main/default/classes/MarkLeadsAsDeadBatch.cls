/**
* (c) 2019 RedBus
*
* Name           : MarkLeadsAsDeadBatch
* Created Date   : 05 Jan 2019
* Created By     : Mahendra K
* Purpose        : Scheduler/Batch to mark lead as dead 
*
**/

global class MarkLeadsAsDeadBatch implements Database.Batchable<sObject>,Schedulable
{      
    
    global final String query;
    DateTime currentTime;
    public MarkLeadsAsDeadBatch(){}
    public MarkLeadsAsDeadBatch (String q)
    {
        currentTime = System.now();
        if(String.isNotBlank(q))
           query = q;
        else
         
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MarkLeadsAsDead'].QueryDetails__c;
          
    }
    
    public void execute(SchedulableContext scon)
    {
       Database.executeBatch(new MarkLeadsAsDeadBatch(query),2000);

    }
  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, list<Lead> leadList)
    {
      List<lead> listleadsToUpdate = new List<lead>();  
      for(Lead led : leadList)
      {
         
          if(led.DOJStart__c<currentTime){
            led.Status='Dead lead';
            led.Non_Conversion_Reason__c='Trip date passed';
          }
          listleadsToUpdate.add(led);
      }
      
      try
      {  
        system.debug('listleadsToUpdate-->>'+listleadsToUpdate);
        List<Database.saveResult> updateResult = Database.update(listleadsToUpdate,false);
      }
      
      catch(Exception e)
      {
        System.debug('Exception in dead lead scheduler..'+e);
      
      }  
      
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
    
  
}