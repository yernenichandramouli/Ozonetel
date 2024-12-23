@isTest
public class SyncAllWFTTest
{
    Static testMethod void TestSyncIntl()
    {
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Guid__c='34512345';        
        insert ordtm;      
        WFT_GFT__c w=new WFT_GFT__c();
        w.Transaction_Name__c=ordtm.id;
        w.sync_processed__c=false;
        insert w;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(w.Id, yesterday);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());  
        
        SyncAllWFT sw = new SyncAllWFT('');
        DataBase.executeBatch(sw);
        Test.stopTest();
    }
    Static testMethod void TestSyncDome()
    {
        Order_Items__c ordtm = new Order_Items__c();
        ordtm.Order_Item_Reference_No__c = 'PEN3X26540057';
        ordtm.Order_Id__c = '12410791449275457';
        ordtm.Guid__c='34512345';
        ordtm.Business_unit__c='REDBUS_IN';
        insert ordtm;
        WFT_GFT__c w=new WFT_GFT__c();
        w.Transaction_Name__c=ordtm.id;
        w.sync_processed__c=false;
        insert w;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(w.Id, yesterday);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());    
        SyncAllWFT sw = new SyncAllWFT('');
        DataBase.executeBatch(sw);
        
        
        String sch = '0 0 8 13 2 ?';
        system.schedule('One Time Pro', sch,sw);
     
        Test.stopTest();
    }    
}