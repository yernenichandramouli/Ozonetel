/*
* Name           : RechargeItemsExtension 
* Created Date   : 21 Sep 2017
* Created By     : Veeramanikanta R
* Purpose        : To display Recharge transactions on Account side bar
* Test class     : RechargeItemsExtensionTest
*/
public class RechargeItemsExtension {
    
    public List<PostGres_Data__c> pgList{get;set;}
    
    public RechargeItemsExtension(ApexPages.StandardController controller) {
    List<Account> acclst = new list<Account>();
        string accId=ApexPages.CurrentPage().getParameters().get('Id');
        try{ 
        if(String.isNotBlank(accId)){
        acclst =[select id,PersonMobilePhone,PersonEmail from account where id=:accId];
        pgList =new List<PostGres_Data__c>();
        
        if(!acclst.isEmpty() && string.isBlank(acclst[0].personEmail))
        pgList=[select id,name,mobile__c,email__c,Order_Id__c,createddate,account__c,Created_Date_Time__c,status__c from PostGres_Data__c where mobile__c=:acclst[0].PersonMobilePhone OR account__c=:acclst[0].id];
        else
        pgList=[select id,name,mobile__c,email__c,Order_Id__c,createddate,account__c,Created_Date_Time__c,status__c from PostGres_Data__c where email__c=:acclst[0].PersonEmail OR mobile__c=:acclst[0].PersonMobilePhone OR account__c=:acclst[0].id];
        }
        }Catch(Exception e)
         {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Record is not available.'));
         }
     } 
}