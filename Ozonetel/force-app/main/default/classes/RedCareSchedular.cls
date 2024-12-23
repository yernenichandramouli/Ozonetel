/**
*
* Name           : RedCareSchedular 
* Created Date   : 25 Apr 2018
* Created By     : Veeramanikanta R
* Purpose        : Used for crediting amount to the customer wallet if case is not resolved with in TAT. Program Name: redCare
* Test Class     : RedCareSchedularTest
*
**/

global class RedCareSchedular implements Schedulable 
{
    global void execute(SchedulableContext ctx) {
        string rStatus = '%API%';       
        list<case> caseList=[select id,casenumber,Closure_Delay__c,Expected_Closure_Time__c,tin_no__c,Trip_Id_ct__c,redCare_Amount__c,redCare_Status__c from case where (redCare_Amount__c!=null  OR redCare_Status__c LIKE : rStatus) AND redCare_Status__c NOT IN ('T_Amount is Credited','S_Amount is Credited','T_Wallet/User Id does not exist','S_Wallet/User Id does not exist','T_Wallet is not Active','S_Wallet is not Active') AND Transaction_ID__r.Business_Unit__c='REDBUS_IN' AND redCare_Multiple__c=false AND Closure_Delay__c>=0 ];
        list<id> caseIds=new list<id>(); 
        list<string> caseTrips=new list<string>();
        System.debug('caseList bf-->'+caseList);
        decimal amountLimit=decimal.valueof(System.Label.redCare_Amount_Limit);
        list<string> cdList=new list<string>();
        integer days;integer hours;string minutes;
        for(case c:caseList){        
            if(c.Closure_Delay__c>=0 && c.Trip_Id_ct__c!=null && c.redCare_Amount__c!=null &&(c.Closure_Delay__c*c.redCare_Amount__c>=amountLimit || (c.redCare_Status__c!=null && c.redCare_Status__c.contains('API'))) ){
                caseIds.add(c.id);
                caseTrips.add(c.Trip_Id_ct__c);
            }
        }
        if(!caseIds.isEmpty()){
            System.debug('case Ids-->'+caseIds+'--caseTrips-->'+caseTrips.size());
            CaseTriggerHandler.redCare_WalletCredit(caseIds,caseTrips,'S_');      
        }
    } 
}