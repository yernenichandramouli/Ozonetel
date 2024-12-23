@isTest
public class MetricsUpdateBatchTest
{
    Static testMethod void testmertc()
    {  
      
        
        Metric__c m= new Metric__c();
        m.Metric_Date__c = System.today().addDays(-1);
        m.Country__c = 'IDN';
        m.Messaging_Type__c = 'WhatsApp';
        m.Country__c='IDN';
        insert m;
       MetricsUpdateBatch cls = new MetricsUpdateBatch();
        Id bid = Database.executeBatch(cls,1);
    }
}