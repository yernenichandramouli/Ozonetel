@isTest
public class TechcasesEscalationsBatchTest {
    
    static testMethod void techtest(){
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Open';
        cs.Country__c='India';
        cs.Business_Type__c='L2 Support';
        insert cs;
        
        datetime csDtime=cs.createddate;

        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];
       /* decimal result = BusinessHours.diff(busns.id, csDtime,system.now());
        //Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
        Decimal resultingHours = result/(60*60*1000);
        system.debug('>>resultingHours>>'+resultingHours);
        //Populating result into our custom field & setting number of decimals
        decimal finaltime =resultingHours.setScale(1);*/
            decimal finaltime=2.0;
        test.startTest(); 
        TechcasesEscalationsBatch obj = new TechcasesEscalationsBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('TechRPWescalated', cronExp,obj);
        Test.stopTest();
    }
      
    static testMethod void Negtest(){
          
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Status = 'Re-Open';
        cs.Country__c='India';
        cs.Business_Type__c='L2 Support';
        cs.Re_Open_Time__c=system.now();
        insert cs;

        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];
        test.startTest(); 
        TechcasesEscalationsBatch obj = new TechcasesEscalationsBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('TechRPWescalated', cronExp,obj);
        Test.stopTest();
    }
  }