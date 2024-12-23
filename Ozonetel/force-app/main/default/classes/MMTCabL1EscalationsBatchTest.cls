@isTest
public class MMTCabL1EscalationsBatchTest {
    
    static testMethod void techtest(){
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Escalate to Support';
        cs.Country__c='India';
        cs.Business_Type__c='L2 Support';
        insert cs;
        
       Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(cs.id, yesterday);
        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];
       /* decimal result = BusinessHours.diff(busns.id, csDtime,system.now());
        //Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
        Decimal resultingHours = result/(60*60*1000);
        system.debug('>>resultingHours>>'+resultingHours);
        //Populating result into our custom field & setting number of decimals
        decimal finaltime =resultingHours.setScale(1);*/
            decimal finaltime=2.0;
        test.startTest(); 
        MMTCabL1EscalationsBatch obj = new MMTCabL1EscalationsBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('Techescalated', cronExp,obj);
        Test.stopTest();
    }
      
    static testMethod void Negtest(){
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Escalate to Support';
        cs.Country__c='India';
        cs.Business_Type__c='L2 Support';
        cs.Re_Open_Time__c=system.now();
        insert cs;
Datetime yesterday = Datetime.now().addDays(-29);
        Test.setCreatedDate(cs.id, yesterday);
        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];
        test.startTest(); 
        MMTCabL1EscalationsBatch obj = new MMTCabL1EscalationsBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('TechRPWescalated', cronExp,obj);
        Test.stopTest();
    }
  }