@isTest 
public class RedrailsRefundReconBatchTest {
@isTest
    public static void TestRedrailsRefundReconBatch(){
        list<Refund_Recon__c> redRailTest = new list<Refund_Recon__c>();
        Refund_Recon__c rr = new Refund_Recon__c();
        rr.pnr_no__c = '2356789869';
        rr.refund_amount__c= 1350;
        rr.Refunded_Amount__c= 50;
        rr.Status__c='Refund Processed Successfully';
        redRailTest.add(rr);
        
        Refund_Recon__c rr1 = new Refund_Recon__c();
        rr1.pnr_no__c = '2356789889';
        rr1.refund_amount__c= 1350;
        rr1.Refunded_Amount__c= 50;
        rr1.Status__c='';
        redRailTest.add(rr1);
        insert redRailTest;
        
        test.startTest();
        string json='{"status":"SUCCESS","errors":[{"pnr":"2356789869","error":"Error"},{"pnr":"2356789889","error":"Error"}],"data":[{"refundAmount":4751,"pnr":"2356789889"},{"refundAmount":4741,"pnr":"2356789869"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        string query = 'SELECT id,refunded_amount__c,status__c,pnr_no__c,refund_amount__c FROM Refund_Recon__c WHERE Status__c=NULL';
        RedrailsRefundReconBatch b=new RedrailsRefundReconBatch(query);
        Database.executeBatch(b);
        test.stopTest();


    }
    @istest
    public static void testRedrailsRefundReconBatch2(){
        Test.startTest();

        list<Refund_Recon__c> redRailTest = new list<Refund_Recon__c>();
        Refund_Recon__c pa = new Refund_Recon__c();
        pa.pnr_no__c = '2356789869';
        pa.refund_amount__c= 1350;
        pa.Refunded_Amount__c= 50;
        pa.Status__c='Refund Processed Successfully';
        redRailTest.add(pa);
        insert redRailTest;
        string query = '';
     RedrailsRefundReconBatch  p= new RedrailsRefundReconBatch(query);
     String sch = '0 0 8 13 2 ?';
     system.schedule('One Time Pro', sch, p);
       ID batchprocessid = Database.executeBatch(p);
    Test.stopTest();

    }
    
    @isTest
    public static void TestRedrailsRefundReconBatch3(){
        list<Refund_Recon__c> redRailTest = new list<Refund_Recon__c>();
        Refund_Recon__c rr = new Refund_Recon__c();
        rr.pnr_no__c = '2356789869';
        rr.refund_amount__c= 1350;
        rr.Refunded_Amount__c= 50;
        rr.Status__c='Refund Processed Successfully';
        redRailTest.add(rr);
        
        Refund_Recon__c rr1 = new Refund_Recon__c();
        rr1.pnr_no__c = '2356789889';
        rr1.refund_amount__c= 1350;
        rr1.Refunded_Amount__c= 50;
        rr1.Status__c='';
        redRailTest.add(rr1);
        insert redRailTest;
        
        test.startTest();
        string json='{"status":"SUCCESS","errors":[{"pnr":"2356789869","error":"Error"},{"pnr":"2356789889","error":"Error"}],"data":[{"refundAmount":4751,"pnr":"2356789889"},{"refundAmount":4741,"pnr":"2356789869"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(100, 'OK', json));
        string query = 'SELECT id,refunded_amount__c,status__c,pnr_no__c,refund_amount__c FROM Refund_Recon__c WHERE Status__c=NULL';
        RedrailsRefundReconBatch b=new RedrailsRefundReconBatch(query);
        Database.executeBatch(b);
        test.stopTest();


    }
}