/*
* Name           : CallBackRequestTimeCntrl
* Created Date   : 11 sep 2023
* Created By     : 
* Purpose        : To showl callback request case in hightLight Panel
* Test class     : CallBackRequestTimeCntrlTest
*/
public class CallBackRequestTimeCntrl{
    
    @AuraEnabled(Cacheable=true)  
    public static List<case> getCallBackReqCases(string selectedTabVal){
        List<case> cseList = new List<case>();
        dateTime curTime=system.now();

        system.debug('>>>>selectedTabVal>>>'+selectedTabVal);
        if(selectedTabVal=='todayTab'){
        cseList = [select id,caseNumber,AccountId,Account.Name, CallBack_Requested_Time__c,Issue_Type__c,Issue_Sub_Category__c from case where CallBack_Requested_Time__c!=null and CallBack_Requested_Time__c=today and ownerId=:userinfo.getuserid() and status != 'Closed'  order by CallBack_Requested_Time__c desc ];
          system.debug('>>>>cs>>>'+selectedTabVal+'--'+cseList.size());
        }else if(selectedTabVal=='expiredTab'){
        cseList = [select id,caseNumber,AccountId,Account.Name,CallBack_Requested_Time__c,Issue_Type__c,Issue_Sub_Category__c from case where CallBack_Requested_Time__c!=null and CallBack_Requested_Time__c <:curTime and ownerId=:userinfo.getuserid() and status != 'Closed' ORDER BY CallBack_Requested_Time__c desc ];
           system.debug('>>>>cs>>>'+selectedTabVal+'---'+cseList.size());
        }else if(selectedTabVal=='futureTab'){
         cseList = [select id,caseNumber,AccountId,Account.Name,CallBack_Requested_Time__c,Issue_Type__c,Issue_Sub_Category__c from case where CallBack_Requested_Time__c!=null and CallBack_Requested_Time__c >:curTime and ownerId=:userinfo.getuserid() and status != 'Closed' ORDER BY CallBack_Requested_Time__c desc];
        }
        else{
        cseList = [select id,caseNumber,AccountId,Account.Name,CallBack_Requested_Time__c,Issue_Type__c,Issue_Sub_Category__c from case where CallBack_Requested_Time__c!=null and ownerId=:userinfo.getuserid() and status != 'Closed' ORDER BY CallBack_Requested_Time__c desc];

        }
        
        return cseList;
    }
    
 }