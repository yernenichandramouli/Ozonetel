@isTest
public class OutboundFeddbckCallingTriggerTest
{
    
 
    Static testMethod void fdbckCallTest(){
       OutBound_Feedback_Calling__c fb=new OutBound_Feedback_Calling__c();
        fb.Call_Unique_Id__c='FBC23456789';
        fb.Phone_No__c='1234567890';
        fb.OrderItem_Uuid__c='fg4567890';
        fb.TIN_no__c='TI567890';
        fb.Call_Back_Time__c=system.now();
        insert fb;
        
        fb.Call_Disposition_Status__c='open';
        update fb;
       
    }
}