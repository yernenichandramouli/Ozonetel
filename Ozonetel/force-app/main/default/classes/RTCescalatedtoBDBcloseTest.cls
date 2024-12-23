@isTest
public class RTCescalatedtoBDBcloseTest {
    
   static testMethod void RTCtest2(){  
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='15499'; 
        insert o;
        list<Case> Cslist = new list<Case>();
        case cs = new case();
        cs.Transaction_ID__c=o.id;
        cs.Status = 'Escalated to BD';
        cs.Issue_Type__c='Bus Operator Service';
        cs.Country__c='India';
        cs.Assigned_to_BD__c=system.now().addDays(-9);
        cs.RTCclosed__c=false;
        Cslist.add(cs);
        insert Cslist;
        //Test.setCreatedDate(Cslist[0].Id, DateTime.newInstance(2023,01,01));
        test.startTest(); 
        RTCescalatedtoBDBclose obj = new RTCescalatedtoBDBclose();
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RTCescalatedtoBDBclose', cronExp,obj);
        Test.stopTest();
        }
    
    }