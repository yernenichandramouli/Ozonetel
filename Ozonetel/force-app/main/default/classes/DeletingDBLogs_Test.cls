@isTest
public class DeletingDBLogs_Test
{
    Static TestMethod void method()
    {
        DBLog_Summary__c dbs = new DBLog_Summary__c();
        Insert dbs;
        
        DB_Log__c db = new DB_Log__c();
        db.DBLog_Summary__c =dbs.Id;
        Insert db;
        
        
        Test.StartTest();
        DeletingDBLogs dbcls = new DeletingDBLogs();
        Database.executeBatch(dbcls);
        Test.StopTest();
    }
}