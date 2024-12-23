@isTest
public class BoltRefundTypesWiseReportControllerTest {
    
 @isTest static void refundMehod(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant Closed with an Apology');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
        
 @isTest static void refundMehod3(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution with refund');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
        
 @isTest static void refundMehod1(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - BO Accepted');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
        
 @isTest static void refundMehod2(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
     @isTest static void refundMehod4(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - BO contest Accepted');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
     @isTest static void refundMehod5(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - BO contest Rejected');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
     @isTest static void refundMehod6(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Outlier case');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
    @isTest static void refundMehod7(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Closed',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - BO contest');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getRefundTypeGroup();
    }
    
    @isTest static void  statusMehod(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='open',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
    
      @isTest static void  statusMehod1(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Escalated to BD',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
      @isTest static void  statusMehod2(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Re-Open',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
    
     @isTest static void  statusMehod3(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='BO Replied',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
      @isTest static void  statusMehod5(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Department Revert',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
    
      @isTest static void  statusMehod4(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Business_Unit_ct__c='REDBUS_IN',Status='Waiting for Customer',BD_Location__c='ROM',Case_Category__c ='Instant resolution-BOLT',Refund_Type__c='Instant resolution - redBus Delight');
        insert cs;
      
        BoltRefundTypesWiseReportController testObj = New BoltRefundTypesWiseReportController();
        testObj.getStatusGroup();
    }
    
 }