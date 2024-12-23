@isTest
public class NEFTcasesReportControllerTest {
    
    //Age 1: <= 24 HRS Records.
    @isTest static void testMethod1(){
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Open');
        insert cs;
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_CO',Status='Open');
        insert cs2;
        caselist.add(cs);
        caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
      
        testObj.getNeftCases();
    }
    //Age 2: 24 - 48 Hrs
    @isTest static void testMethod2(){

        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Open');
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_PE',Status='Open');
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-1));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-1));
        caselist.add(cs);caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
        testObj.getNeftCases();
    }
    //Age 3: 2 - 7 Days
    
    //Age 4: 7 - 15 Days
    @isTest static void testMethod4(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_PE',Status='Open');
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Open');
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-9));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-8));
        caselist.add(cs);caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
        testObj.getNeftCases();
    }
    //Age 5: 15 - 30 Days
    @isTest static void testMethod5(){
       
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_PE',Status='Open');
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Open');
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-16));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-16));
        caselist.add(cs);caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
        testObj.getNeftCases();
    }
    //Age 6: 1 Month +
    @isTest static void testMethod6(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_PE',Status='Open');
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Open');
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-50));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-50));
        caselist.add(cs);caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
        testObj.getNeftCases();
    }
    
     @isTest static void statusMehod(){
     
        list<case> caselist=new list<Case>();
        Case cs = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_PE',Status='Error in NEFT');
        Case cs2 = new Case(Issue_Type__c ='NEFT Refund',Business_Unit_ct__c='REDBUS_ID',Status='Rejected Exceptional Refund');
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-30));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-30));
        caselist.add(cs);caselist.add(cs2);
        NEFTcasesReportController testObj = New NEFTcasesReportController();
        testObj.getStatusGroup();
    }
    
  }