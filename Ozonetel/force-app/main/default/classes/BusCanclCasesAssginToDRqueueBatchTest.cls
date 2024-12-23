@isTest
public class BusCanclCasesAssginToDRqueueBatchTest {
    
    static testMethod void RPWtest(){
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Initiated';
        cs.Country__c='India';
        cs.issue_type__c='Bus Cancellation';
        cs.BD_Location__c='Hyderabad';
        cs.Type='bus booking';
        insert cs;
        Datetime yesterday = Datetime.now().addMinutes(-10);
        Test.setCreatedDate(cs.id, yesterday); 
       
        
        test.startTest(); 
        BusCanclCasesAssginToDRqueueBatch obj = new BusCanclCasesAssginToDRqueueBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('BusCanclCasesAssginToDR', cronExp,obj);
        Test.stopTest();
    }
  }