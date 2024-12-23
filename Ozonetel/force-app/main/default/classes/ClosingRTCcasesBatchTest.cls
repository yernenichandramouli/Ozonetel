@isTest
public class ClosingRTCcasesBatchTest {
    
    static testMethod void RTCtest(){
           
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='10283'; 
        insert o;
        
        list<Case> Cslist = new list<Case>();
        case cs = new case();
       
        cs.Transaction_ID__c=o.id;
        cs.Status = 'Open';
        cs.Country__c='India';
        cs.Issue_Sub_Category__c='Poor bus quality';
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        
        test.startTest(); 
        ClosingRTCcasesBatch obj = new ClosingRTCcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCcasesBatch', cronExp,obj);
        // Database.QueryLocator ql = rodR.start(null);
        //obj.execute(null,Cslist);
        Test.stopTest();
    
    }
       
    static testMethod void RTCtest1(){
           
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='10283'; 
        insert o;
        
        list<Case> Cslist = new list<Case>();
        case cs = new case();
       
        cs.Transaction_ID__c=o.id;
        cs.Status = 'open';
        cs.Country__c='India';
        cs.Issue_Type__c='Bus Operator Service';
        cs.Service_Providerr_Id__c='16884';
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        test.startTest(); 
        ClosingRTCcasesBatch obj = new ClosingRTCcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCcasesBatch', cronExp,obj);
        // Database.QueryLocator ql = rodR.start(null);
        //obj.execute(null,Cslist);
        Test.stopTest();
    
    }

    static testMethod void RTCtest2(){  
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='16227'; 
        insert o;
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Transaction_ID__c=o.id;
        cs.Status = 'Escalated to BD';
        cs.Issue_Type__c='Bus Operator Service';
        cs.Country__c='India';
        cs.Assigned_to_BD__c=system.now().addDays(7);
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        Test.setCreatedDate(Cslist[0].Id, DateTime.newInstance(2023,01,01));
        test.startTest(); 
        ClosingRTCcasesBatch obj = new ClosingRTCcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCcasesBatch', cronExp,obj);
        Test.stopTest();
    
    }
     static testMethod void RTCtest3(){  
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='10283'; 
        insert o;
        datetime tm=system.now();
        datetime  tmm=tm.adddays(12);
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Transaction_ID__c=o.id;
        cs.Status = 'Open';
        cs.Country__c='India';
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        Test.setCreatedDate(Cslist[0].Id, DateTime.newInstance(2023,01,01));
        test.startTest(); 
        ClosingRTCcasesBatch obj = new ClosingRTCcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCcasesBatch', cronExp,obj);
        Test.stopTest();
}
static testMethod void RTCtest4(){  
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='17101'; 
        insert o;
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Transaction_ID__c=o.id;
        cs.Status = 'Open';
        cs.Country__c='India';
        cs.Issue_Type__c='Bus Operator Service';
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        Test.setCreatedDate(Cslist[0].Id, DateTime.newInstance(2023,01,01));
        test.startTest(); 
        ClosingRTCcasesBatch obj = new ClosingRTCcasesBatch();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCcasesBatch', cronExp,obj);
        Test.stopTest();
}
}