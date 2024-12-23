public class CoPassengerHandler{
    
    @Auraenabled
    public static List<case> coPassengerCases(string caseId,string source){
        List<case> coPassRecords=new List<case>();
        case cObj=new case();
        cObj=[select id,Route_Id__c,SS_Route_Id__c,Date_Of_Journey_New__c,Service_Id__c from case where id=:caseId];
        String rId = String.isNotBlank(cObj.Route_Id__c)?cObj.Route_Id__c:cObj.SS_Route_Id__c;
        coPassRecords=[select id,casenumber,issue_type__c,status,createddate from case where Date_Of_Journey_New__c!=null AND Date_Of_Journey_New__c=:cObj.Date_Of_Journey_New__c and Service_Id__c!=''  and Service_Id__c=:cObj.Service_Id__c];
        return coPassRecords;
    }    
}