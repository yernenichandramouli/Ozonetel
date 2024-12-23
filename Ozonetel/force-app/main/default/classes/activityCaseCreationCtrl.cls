/*
* Name           : activityCaseCreationCtrl
* Created Date   : 22 OCT 2023
* Created By     : VR Sudarshan 
* Purpose        : To create a case from activity page.
* Test class     : activityCaseCreationCtrlTest
* Jira Id        : CRM-1502
*/

public with sharing class activityCaseCreationCtrl {
    public list<Activities__c> activityList {get;set;}
    public Case cs {get;set;}
    public String orderId {get;set;}
    public Id csId;
    public string popupDescription {get;set;}
    public boolean displayPopup {get;set;}

    public activityCaseCreationCtrl(ApexPages.StandardController controller) {
        csId = ApexPages.CurrentPage().getParameters().get('tId');
        if(csId==null || string.isBlank(csId)){
            csId=controller.getid();
        }
        system.debug('csId---->>'+csId);
        cs = new Case();
        activityList = new list<Activities__c>();
        if(String.isNotBlank(csId)){
            activityList = [SELECT Id, Activity_Name__c,RecordType.DeveloperName,Amount__c, Order_Id__c, Activity_uuid__c, Booking_UserUserid__c, OrderUuid__c, Business_Unit__c, Booking_User_Email__c, Booking_User_Mobile__c, Booking_user_Name__c, Customer_Email_id__c, Customer_Mobile_No__c, Customer_Name__c, Date_Of_Purchase__c, Purchase_Item_Currency__c, Service_Provider_Id__c, Service_Provider_Name__c, Rb_User_ID__c, Transaction_Status__c, isPartial_Cancellation_Allowed__c, Voucher_Id__c FROM Activities__c WHERE Id=:csId LIMIT 1];
            if(!activityList.isEmpty()){
                orderId = activityList[0].Order_Id__c;
                cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('SGMY Activities').getRecordTypeId();
                cs.Phone_No_ct__c=activityList[0].Customer_Mobile_No__c;
                cs.Email_Id_ct__c=activityList[0].Customer_Email_id__c;
                cs.TAT_Notifier_Email__c=activityList[0].Customer_Email_id__c;
                cs.Activity_Id__c=activityList[0].Id;
              
                if(activityList[0].RecordType.DeveloperName=='Cargo'){
                    cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cargo').getRecordTypeId();
                    cs.Business_Unit_ct__c =activityList[0].Business_Unit__c;
                    cs.Business_Type__c ='Cargo';
                    cs.OwnerId=UserInfo.getUserId();
                    cs.country__c= OrderItemTransactionResource__c.getValues(activityList[0].Business_Unit__c)!= null?OrderItemTransactionResource__c.getValues(activityList[0].Business_Unit__c).Case_Country__c:'';
                }else if(activityList[0].RecordType.DeveloperName=='ONDC_Metro' || activityList[0].RecordType.DeveloperName=='ONDC_Mobility'){
                    if(activityList[0].RecordType.DeveloperName=='ONDC_Mobility'){
                        cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('ONDC Mobility').getRecordTypeId();
                    }else{
                        cs.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
                    }
                    cs.Business_Unit_ct__c =activityList[0].Business_Unit__c;
                    cs.Business_Type__c = 'Activities';
                    cs.OwnerId= [Select id from Group where type='Queue' AND developername='ONDC_Suppport'].id;
                    cs.Booking_Email_ID__c = activityList[0].Booking_User_Email__c;
                    cs.Booking_Mobile_No__c = activityList[0].Booking_User_Mobile__c;
                    cs.country__c=OrderItemTransactionResource__c.getValues(activityList[0].Business_Unit__c).Case_Country__c;
                }else{
                    cs.Business_Unit_ct__c = 'SGMY Activites';
                    cs.OwnerId=UserInfo.getUserId();
                    cs.Country__c = [SELECT id,name,Country from User WHERE Id=:UserInfo.getUserId()].Country;
                    cs.Business_Type__c = 'Activities';
                }
                cs.Amount__c = activityList[0].Amount__c;
                cs.Booking_Id__c = activityList[0].Booking_UserUserid__c;
                cs.Name_ct__c = activityList[0].Customer_Name__c;
                cs.Date_Submitted_ct__c = activityList[0].Date_Of_Purchase__c;
                cs.Price_Paid_Currency_ctp__c = activityList[0].Purchase_Item_Currency__c;
                cs.Service_Providerr_Id__c = activityList[0].Service_Provider_Id__c;
                cs.Signed_In_UserId__c = activityList[0].Rb_User_ID__c;
                cs.Total_Fare_Value__c = activityList[0].Amount__c;
                cs.Order_UUId__c = activityList[0].OrderUuid__c;
                cs.Order_Item_Id__c = activityList[0].Activity_uuid__c;
            }
        }
    }

    public pageReference showPopup(){
        System.debug('calling showPopup');
        system.debug('csId --->>'+csId);
        if(String.isNotBlank(csId)){
            list<case> clist=[select id,parentId,status,Activity_Id__c from Case where Activity_Id__c=:csId and Issue_Type__c =: cs.Issue_Type__c AND Issue_Sub_Category__c=:cs.Issue_Sub_Category__c];
            System.debug('size here-->'+clist.size()); 
            if(clist.size()>=1){  
                System.debug('size here 2-->'+clist.size());   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Open case is already exist for this Activity. Duplicate Case Creation is not allowed.'));              
                // displayPopup = true;
            }
            else{
                saveMethod();
                System.debug('after savemethod');
                if(string.isNotBlank(cs.Id)){
                    PageReference pRef = new PageReference('/'+cs.Id);
                    return pRef;  
                }
            } 
        }
        return null;
    }
    
    public void closePopup() {
        displayPopup = false;
    }

    public pageReference saveMethod(){
        try{
            if(cs.Does_Customer_Require_CallBack__c){
                cs.CallBack_Requested_Time__c = cs.CallBack_Requested_Time__c!=null?System.now().addHours(Integer.valueOf(cs.Call_Back_Time__c)):null;
            }
            Insert cs;
            System.debug('Customer Name after insert-->'+cs.Customer_Name__c);
            PageReference pRef = new PageReference('/'+cs.Id);
            return pRef;
        }
        catch(exception e){ApexPages.addMessages(e); return null;}
    
    }
}