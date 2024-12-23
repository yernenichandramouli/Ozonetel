@isTest
public class BPVerificationTriggerTest
{
    static testMethod void test()
    {
      Service_Provider__c srv =new Service_Provider__c();
       srv.Operator_Id__c='';
       srv.Location__c='';
       insert srv;
       BP_Verification__c bp =new BP_Verification__c();
       bp.Service_Provider_Id__c='';
       bp.BO_Region__c='';
       insert bp;
       
    }
    
     static testMethod void test1()
    {
       BP_Verification__c bp =new BP_Verification__c();
       bp.Service_Provider_Id__c='';
       bp.Call_Status__c='';
       bp.BO_Region__c='';
       insert bp;
       bp.Call_Status__c='Correct Number';
       update bp;
        
    }
    
     static testMethod void testCase()
    {
      
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Business_Type__c='Domestic-Bus';
        oritran.Case_Country__c='India';
        oritran.Name = 'REDBUS_IN';
        oritran.Case_Business_Type__c='REDBUS_IN';
        insert oritran;
        
        BP_Verification__c bp =new BP_Verification__c();
        bp.Service_Provider_Id__c='';
        bp.Call_Status__c='';
        bp.BP_Contact_No__c='123456';
        insert bp;
        bp.Call_Status__c='RnR1';
        update bp;
        
        case cs = new case();
        cs.BP_Contact_Number__c='123456';
        cs.BP_Verification__c=bp.id;
        cs.Business_Unit_ct__c='REDBUS_IN';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        insert cs;
    }
 }