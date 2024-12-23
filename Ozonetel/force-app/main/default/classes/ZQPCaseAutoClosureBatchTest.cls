@isTest
public class ZQPCaseAutoClosureBatchTest {
    @isTest static void ClosureTestMethod(){
        
        Case cs = new Case();
        cs.Refund_Amount__c =123;
        cs.Order_UUId__c='test123';
        cs.Booking_Email_ID__c = 'test@mail.com';
        cs.Booking_Mobile_No__c = '432133445566';
        cs.Issue_Type__c ='Booking Error';
        cs.Issue_Sub_Category__c ='ZQP';
        cs.Subject='Booking Error';
        cs.Total_Fare_Value__c=250;
        cs.Price_Paid_Currency_ctp__c='INR';
        insert cs;
        
        Test.setCreatedDate(cs.Id, System.now().addMinutes(-60));
        
        Test.startTest();
        ZQPCaseAutoClosureBatchSchedular zqp= new ZQPCaseAutoClosureBatchSchedular();
        String sch = '0 0 8 13 2 ?';
        system.schedule('zqpAutomation', sch,zqp);
        Test.stopTest();
        
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :cs.Id];
    }
}