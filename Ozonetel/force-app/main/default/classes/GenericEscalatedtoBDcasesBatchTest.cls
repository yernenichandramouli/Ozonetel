@isTest
public class GenericEscalatedtoBDcasesBatchTest {
    
    static testMethod void RPWtest(){
          
        Id rpwId = [Select id from Group where type='Queue' AND developername='RPW_Queue'].id;

        list<Case> Cslist = new list<Case>();
        case cs = new case();
     
        cs.Status = 'Escalated to ISE';
        cs.Country__c='Indonesia';
        cs.RPW_Case__c=true;
        cs.issue_type__c='I felt unsafe during the journey';
        cs.Issue_Sub_Category__c='Issue with Boarding Address';
        cs.BD_Location__c='Hyderabad';
        cs.Assigned_to_BD__c=system.now();
         insert cs;
         Datetime yesterday = Datetime.now().addDays(-49);
        Test.setCreatedDate(cs.id, yesterday); 
        //Cslist.add(cs);
       
        
        test.startTest(); 
        GenericEscalatedtoBDcasesBatch obj = new GenericEscalatedtoBDcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('escalated', cronExp,obj);
        Test.stopTest();
    }
  }