@isTest
public class ClosePayatBusCasesBatchTest {
    
    static testMethod void RTCtest(){
        
        list<Case> Cslist = new list<Case>();
        
        case cs = new case();
        cs.Country__c='Indonesia';
        cs.Issue_Type__c='Pay at bus';
        cs.SS_DOJ__c=system.now();
        Cslist.add(cs);
        insert Cslist;
        
        test.startTest(); 
        ClosePayatBusCasesBatch obj = new ClosePayatBusCasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('payatbusBatch', cronExp,obj);
        Test.stopTest();
    }
  }