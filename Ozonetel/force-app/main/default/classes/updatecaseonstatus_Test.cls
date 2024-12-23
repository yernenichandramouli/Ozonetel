@isTest
public class updatecaseonstatus_Test
{
    Static TestMethod void method1()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-TCTC';
        tsc.Category__c='Confirmed';
        tsc.Status__c='TRANSACTION_CONFIRM_TICKET_COMPLETE';
        Insert tsc;
        
        Transaction_Status_Category__c tsc1 = new Transaction_Status_Category__c();
        tsc1.Name='GFT-CF';
        tsc1.Category__c='GFT';
        tsc1.Status__c='CONFIRMATION_FAILED';
        Insert tsc1;
        
        RecTypesAndStatus__c rec = new RecTypesAndStatus__c();
        rec.Name='CONFIRMATION_FAILED';
        rec.Case_Type__c='Green Failed Transaction (GFT)';
        rec.Transaction_Status__c='CONFIRMATION_FAILED';
        Insert rec;
        
                      
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='TRANSACTION_CONFIRM_TICKET_COMPLETE';
        Insert ori;
        
        Case cs = new Case();
        cs.Transaction_ID__c=ori.Id;
        Insert cs;
        
        Test.StartTest();
        ori.status__c='CONFIRMATION_FAILED';
        Update ori;
        Test.StopTest();
    }
    Static TestMethod void method2()
    {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-C';
        tsc.Category__c='Confirmed';
        tsc.Status__c='CONFIRMED';
        Insert tsc;
        
        RecTypesAndStatus__c rec = new RecTypesAndStatus__c();
        rec.Name='CONFIRMATION_FAILED';
        rec.Case_Type__c='Green Failed Transaction (GFT)';
        rec.Transaction_Status__c='CONFIRMATION_FAILED';
        Insert rec;
        
        RecTypesAndStatus__c rec1 = new RecTypesAndStatus__c();
        rec1.Name='TENTATIVE_COMPLETED';
        rec1.Case_Type__c='White Failed Transaction (WFT)';
        rec1.Transaction_Status__c='TENTATIVE_COMPLETED';
        Insert rec1;
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='TENTATIVE_COMPLETED';
        Insert ori;
        
        
        Case cs = new Case();
        cs.Transaction_ID__c=ori.Id;
        Insert cs;
        
        Test.StartTest();
        ori.status__c='CONFIRMATION_FAILED';
        Update ori;
        Test.StopTest();
    }
     Static TestMethod void method3()
     {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-TCTC';
        tsc.Category__c='Confirmed';
        tsc.Status__c='TRANSACTION_CONFIRM_TICKET_COMPLETE';
        Insert tsc;
        
        RecTypesAndStatus__c rec = new RecTypesAndStatus__c();
        rec.Name='CONFIRMATION_FAILED';
        rec.Case_Type__c='Green Failed Transaction (GFT)';
        rec.Transaction_Status__c='CONFIRMATION_FAILED';
        Insert rec;
        
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CONFIRMED';
        Insert ori;
                
        Case cs = new Case();
        cs.Transaction_ID__c=ori.Id;
        cs.Status='Closed';
        
        Insert cs;
        
        Test.StartTest();
        ori.Status__c = 'TRANSACTION_CONFIRM_TICKET_COMPLETE';
        Update ori;
        Test.StopTest();
        
    }
    Static TestMethod void method4()
     {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-TCTC';
        tsc.Category__c='Confirmed';
        tsc.Status__c='TRANSACTION_CONFIRM_TICKET_COMPLETE';
        Insert tsc;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CONFIRMED';
        ori.Transaction_Latest_status__c='FAIL';
        Insert ori;
       
        Case cs = new Case();
        cs.Transaction_ID__c=ori.Id;
        Id recordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        cs.RecordTypeId = recordTypeId;
        cs.Status='New';
        Insert cs;
        
         Test.StartTest();
        ori.Transaction_Latest_status__c='SUCCESS';
        update ori;
        Test.StopTest();
              
      }
      Static TestMethod void method5()
      {
        Transaction_Status_Category__c tsc = new Transaction_Status_Category__c();
        tsc.Name='C-TCTC';
        tsc.Category__c='Confirmed';
        tsc.Status__c='CONFIRMED';
        Insert tsc;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CONFIRMED';
        ori.Transaction_Latest_status__c='FAIL';
        Insert ori;
        
        Case cs = new Case();
        cs.Transaction_ID__c=ori.Id;
        Id recordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('White Failed Transaction (WFT)').getRecordTypeId();
        cs.RecordTypeId = recordTypeId  ;
        cs.Status = 'New';
        Insert cs;
        
        Test.StartTest();
        ori.Transaction_Latest_status__c='SUCCESS';
        update ori;
        Test.StopTest();

      }
  
}