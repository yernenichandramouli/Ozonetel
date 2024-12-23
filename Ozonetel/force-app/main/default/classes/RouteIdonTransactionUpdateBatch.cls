global class RouteIdonTransactionUpdateBatch implements DataBase.Batchable<sObject>
{
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
      return DataBase.getQueryLocator(System.Label.RouteIdQuery); 
    
    }
  
    global void execute(DataBase.BatchableContext bc,List<Bus_Order_Item_Details__c> updateList)
    {
        update updateList;
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
    
    }
}