@isTest
public class MarkLeadsAsDeadBatch_Test
{
    static testMethod void leadasdead()
    {
     Date curntdt =system.today(); 
        list<lead> leadlst= new list<lead>();
        Lead led = new Lead();
        led.status='RnR';
        led.LastName='test';
        led.phone='123345678';
        led.DOJStart__c =curntdt.addDays(-1);
       
        leadlst.add(led);
        insert leadlst;
       
        test.starttest();
        MarkLeadsAsDeadBatch errResch= new MarkLeadsAsDeadBatch();
         //Id bid = Database.executeBatch(errResch,1);
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, errResch);
        Test.stopTest();
    }
  }