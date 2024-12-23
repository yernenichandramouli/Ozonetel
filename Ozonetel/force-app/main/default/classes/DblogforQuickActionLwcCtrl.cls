/*
* Name           : dblogforQuickActionLwcCtrl
* Created Date   : 07 feb 2023
* Created By     : 
* Purpose        : capturing the logs for the @AuraEnabled(Cacheable=true)
* Test class     : 
*/
public class DblogforQuickActionLwcCtrl{
 
  @future
  public static void dblogCaptureMethod(string dblTypeName,string strEndpoint,string itemID,string strRequest,string strResponse,string strHeaders,string strError){
    DBLog_Summary__c dbLog=new DBLog_Summary__c();
    system.debug('---strRequest---'+strRequest);
    system.debug('---strResponse---'+strResponse);
    dbLog.Type__c=dblTypeName;
    dbLog.Request_Data__c =strRequest;
    dbLog.EndPoint__c =strEndpoint;
    dbLog.Response_Received__c=strResponse;
    dbLog.Case_Number__c =itemID;
    dbLog.Exception_Description__c=strError;
    dbLog.Headers__c=strHeaders;
    insert dbLog;
    
    
    
  }
}