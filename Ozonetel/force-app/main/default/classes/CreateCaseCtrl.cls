public class CreateCaseCtrl{
 
    @AuraEnabled
    public static Case CreateCase(Case cs) {
        if(cs.Does_Customer_Require_CallBack__c)
	 cs.CallBack_Requested_Time__c = System.now().addHours(Integer.valueOf(cs.Call_Back_Time__c));
        
        insert cs;
        return cs;
    }
    @AuraEnabled
    public static boolean DuplicateCheck(id tId){
        case cse = [select status from case where (status != 'Closed' and Transaction_ID__c =: tId) limit 1];
        if (cse != Null){
            return true;
        }
        else
            return false;	
    }
}