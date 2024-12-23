@isTest
public class RPWQueueAssignmentBatchTest {
    
    static testMethod void RPWtest(){
          
        Id rpwId = [Select id from Group where type='Queue' AND developername='BD_Queue'].id;

        list<Case> Cslist = new list<Case>();
        case cs = new case();
     
        cs.Status = 'Department Revert';
        cs.Country__c='India';
        cs.RPW_Case__c=true;
        cs.ownerid=rpwId;
         insert cs;
       
        //Cslist.add(cs);
       
        
        test.startTest(); 
        RPWQueueAssignmentBatch obj = new RPWQueueAssignmentBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RPWQueueAssignmentBatch', cronExp,obj);
        Test.stopTest();
    }
  }