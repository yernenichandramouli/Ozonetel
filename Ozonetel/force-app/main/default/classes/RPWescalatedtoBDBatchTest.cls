@isTest
public class RPWescalatedtoBDBatchTest {
    
    static testMethod void RPWtest(){
          
        Id rpwId = [Select id from Group where type='Queue' AND developername='RPW_Queue'].id;

        list<Case> Cslist = new list<Case>();
        case cs = new case();
     
        cs.Status = 'Open';
        cs.Country__c='India';
        cs.RPW_Case__c=true;
        cs.issue_type__c='I felt unsafe during the journey';
        cs.RTCclosed__c=false;
        cs.ownerid=rpwId;
        cs.BD_Location__c='Hyderabad';
         insert cs;
         Datetime yesterday = Datetime.now().addDays(-49);
        Test.setCreatedDate(cs.id, yesterday); 
        //Cslist.add(cs);
       
        
        test.startTest(); 
        RPWescalatedtoBDBatch obj = new RPWescalatedtoBDBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RPWescalated', cronExp,obj);
        Test.stopTest();
    }
  }