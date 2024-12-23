@isTest
public class ConsoleCase_test
{
    Static TestMethod void ConsoleCasetest()
    {
        Account ac = new Account();
        ac.Name='SampleName';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        ac.RecordTypeId = recordTypeId;
        Insert ac;
        
        Case cs = new Case();
        cs.AccountId =ac.Id;
        cs.Customer_Name__c =ac.Id;
        cs.status = 'Closed';
        Insert cs;
               

        ApexPages.CurrentPage().getParameters().put('id',ac.Id);
        ApexPages.StandardController cls = new ApexPages.StandardController(ac);
        ConsoleCase lca = new ConsoleCase (cls);
        lca.getOpenCase();
        // pagereference pa = new pagereference(ac);
          
      
    }
}