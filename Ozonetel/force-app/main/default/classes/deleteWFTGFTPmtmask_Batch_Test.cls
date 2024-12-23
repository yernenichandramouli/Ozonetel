@isTest
public class deleteWFTGFTPmtmask_Batch_Test
{
    static testMethod void deleteWFTGFTPmtmask_Batch_Batch()
    {
        Payment_Items__c p = new Payment_Items__c();
        insert p;
        WFT_GFT_Payment__c w = new WFT_GFT_Payment__c();
        w.Payment_Items_Name__c = p.id;
        insert w;

        deleteWFTGFTPmtmask_Batch cls = new deleteWFTGFTPmtmask_Batch();
        cls.query = 'SELECT Id,Name FROM WFT_GFT_Payment__c LIMIT 1';
        Id bid = Database.executeBatch(cls,1);
    }
}