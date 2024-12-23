/**
* (c) 2019 RedBus
*
* Name           : BusHireDialerErrorResetCntrl
* Created Date   : 18 Oct 2019
* Created By     : Sreenivas M
* Purpose        : Controller class for resetting BusHireAutoDailer errors.
*
**/

Public class BusHireDialerErrorResetCntrl
{
  @future
  public static void resetError(String userId)
  {
    System.debug('Reset error for ..'+userId);
    List<User_Details__c> listusDet = new List<User_Details__c>();
    listusDet = [SELECT id,is_Error_Occurred__c,Error_Description__c,Error_Time__c ,Next_Call_Time__c  from User_Details__c where Id=:userId AND is_Error_Occurred__c=True AND CreatedDate=Today limit 1];
   
    if(!listusDet.isEmpty())
    {
        listusDet[0].is_Error_Occurred__c =False;
        listusDet[0].Error_Description__c = '';
        listusDet[0].Error_Time__c =null;
        listusDet[0].Next_Call_Time__c = System.now();    
        Database.saveResult updateResult = Database.update(listusDet[0],false) ;
        
        if(updateResult.isSuccess())
        {
          System.debug('BHire Error reset update is success');
        }
        
        else
        {
          System.debug('BHire Error reset exception.'+ string.valueof(updateResult.getErrors()));
        }
    }  
  }
}