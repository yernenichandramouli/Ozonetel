@isTest
public class deleteWFTGFTmask_Batch_Test
{
    static testMethod void deleteWFTGFTmask_Batch_Batch()
    {
        Order_Items__c o = new Order_Items__c();
        insert o;
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = o.id;
        insert w;

        deleteWFTGFTmask_Batch cls = new deleteWFTGFTmask_Batch();
        cls.query = 'SELECT Id,Name FROM WFT_GFT__c LIMIT 1';
        Id bid = Database.executeBatch(cls,1);
    }
}