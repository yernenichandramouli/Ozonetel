/*
* Name           : fetchCallDetailsCtrl
* Created Date   : 21 MAY 2024
* Created By     : VR Sudarshan 
* Purpose        : To show the releated call details at transaction level.
* Test class     : fetchCallDetailsCtrlTest
* Jira Id        : CRM-1756
*/
public class fetchCallDetailsCtrl {
    @AuraEnabled(cacheable=true)
    public static List<Call_Details__c> getRelatedCallDetails(string transactionId){
        List<Call_Details__c> callDetailsToReturn = New List<Call_Details__c>();
        List<Order_Items__c> transactionList = [SELECT Id, OrderUuid__c FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        if(!transactionList.isEmpty()){
            callDetailsToReturn = [SELECT Id, Name, CreatedDate FROM Call_Details__c WHERE PredictedOrderUuid__c =:transactionList[0].OrderUuid__c];
        }
        return callDetailsToReturn;
    }
}