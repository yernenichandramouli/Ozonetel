@isTest
Private class IRDR_RoutingBatchClassTest {

    @isTest
    static void IR_queueTest(){
        case cs = new case();
        cs.Status = 'Open';
        cs.priority='Low';
        cs.Origin='Inbound Call';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c='Random pax picked up/ bus is crowded';
        cs.is_IRDR_Batch__c=false;
        cs.Service_Providerr_Id__c='4376';
        insert cs;

        test.startTest(); 
        IRDR_RoutingBatchClass obj = new IRDR_RoutingBatchClass();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('IRDR_RoutingBatch', cronExp,obj);
        Test.stopTest();
    }

    @isTest
    static void DR_queueTest(){
        case cs = new case();
        cs.Status = 'Open';
        cs.priority='Low';
        cs.Origin='Inbound Call';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c='Refunds';
        cs.Issue_Sub_Category__c='Failed Booking - WFT';
        cs.is_IRDR_Batch__c=false;
        cs.Service_Providerr_Id__c='4334543565465476';
        insert cs;

        test.startTest(); 
        IRDR_RoutingBatchClass obj = new IRDR_RoutingBatchClass();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('IRDR_RoutingBatch', cronExp,obj);
        Test.stopTest();
    }
    
    @isTest
    static void DR_queueTest1(){
        case cs = new case();
        cs.Status = 'Open';
        cs.priority='Low';
        cs.Origin='Inbound Call';
        cs.country__c='India';
        cs.Business_Type__c='Domestic-Bus';
        cs.Issue_Type__c='Refunds';
        cs.Issue_Sub_Category__c='Failed Booking - WFT';
        cs.is_IRDR_Batch__c=false;
        //cs.Service_Providerr_Id__c='4334543565465476';
        insert cs;

        test.startTest(); 
        IRDR_RoutingBatchClass obj = new IRDR_RoutingBatchClass();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('IRDR_RoutingBatch', cronExp,obj);
        Test.stopTest();
    }
}