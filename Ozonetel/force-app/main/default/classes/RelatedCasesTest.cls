@isTest
public class RelatedCasesTest {
    @istest static void methodToTest(){

        case cs= new case();
        cs.status='Open';
        cs.Phone_No_ct__c='95021057156';
        insert cs;   
        
        case cse= new case();
        cse.status='Open';
        cse.Phone_No_ct__c=cs.Phone_No_ct__c;
        cse.ParentId=cs.id;
        insert cse;    
        
        RelatedCases.getParentCase(cse.id);
        RelatedCases.getrelatedCases(cse.id);
        RelatedCases.getChilidCases(cse.id);
    }
      @istest static void methodToTest1(){
        case cs= new case();
        cs.status='Open';
        cs.Booking_Mobile_No__c='4567890';
        insert cs;   
        
        case cse= new case();
        cse.status='Open';
        cse.Booking_Mobile_No__c=cs.Booking_Mobile_No__c;
        cse.ParentId=cs.id;
        insert cse;    
        RelatedCases.getParentCase(cse.id);
        RelatedCases.getrelatedCases(cse.id);
        RelatedCases.getChilidCases(cse.id);
      }
       @istest static void methodToTest2(){
        case cs= new case();
        cs.status='Open';
        cs.Email_Id_ct__c='test@gmai.com';
        insert cs;   
        
        case cse= new case();
        cse.status='Open';
        cse.Email_Id_ct__c=cs.Email_Id_ct__c;
        cse.ParentId=cs.id;
        insert cse;    
        RelatedCases.getParentCase(cse.id);
        RelatedCases.getrelatedCases(cse.id);
        RelatedCases.getChilidCases(cse.id);
      }
}