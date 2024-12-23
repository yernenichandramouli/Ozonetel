@isTest
public class RefundsPendingReportControllerTest {
    
    //Age 1: <= 24 HRS Records.
    @isTest static void testMethod1(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        insert cs;
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs2;
        caselist.add(cs);
        caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.PaasAgeGrouping=true;
        testObj.GroupByPGType=true;
        testObj.getPaasEscalatedCases();
    }
    //Age 2: 24 - 48 Hrs
    @isTest static void testMethod2(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-1));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-1));
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPaasEscalatedCases();
    }
    //Age 3: 2 - 7 Days
    @isTest static void testMethod3(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-3));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-3));
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPaasEscalatedCases();
    }
    //Age 4: 7 - 15 Days
    @isTest static void testMethod4(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-9));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-8));
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPaasEscalatedCases();
    }
    //Age 5: 15 - 30 Days
    @isTest static void testMethod5(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-16));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-16));
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPaasEscalatedCases();
    }
    //Age 6: 1 Month +
    @isTest static void testMethod6(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN', ownerId=testGroup.Id);
        insert cs;insert cs2;
        Test.setCreatedDate(cs.id,  Date.Today().addDays(-50));
        Test.setCreatedDate(cs2.id,  Date.Today().addDays(-50));
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPaasEscalatedCases();
    }
    //PAYU
    @isTest static void testMethod7(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='PAYU', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='PAYU', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //PhonePe
    @isTest static void testMethod8(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='PhonePe', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='PhonePe', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //UPI
    @isTest static void testMethod9(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='UPI', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='UPI', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //JusPay
    @isTest static void testMethod10(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='JusPay', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='JusPay', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //Razorpay
    @isTest static void testMethod11(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='Razorpay', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='Razorpay', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //PayuUPI
    @isTest static void testMethod12(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='PayuUPI', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='PayuUPI', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //AmazonPay
    @isTest static void testMethod13(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='AmazonPay', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='AmazonPay', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }
    //PayTm
    @isTest static void testMethod14(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='PayTm', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='PayTm', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }

    //GPay
    @isTest static void testMethod15(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='GPay', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='GPay', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }

    //Airtel
    @isTest static void testMethod16(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='Airtel', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='Airtel', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }

    //Simpl
    @isTest static void testMethod17(){
        Group testGroup = new Group(Name='Paas Escalation Queue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        list<case> caselist=new list<Case>();
        Case cs = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_RAILS_IN',PG_Type_Select__c='Simpl', ownerId=testGroup.Id);
        Case cs2 = new Case(Status ='Escalated to Paas',Business_Unit_ct__c='REDBUS_IN',PG_Type_Select__c='Simpl', ownerId=testGroup.Id);
        insert cs;insert cs2;
        caselist.add(cs);caselist.add(cs2);
        RefundsPendingReportController testObj = New RefundsPendingReportController();
        testObj.getPGTypeGroup();
    }


}