@isTest
public class SyncIssueNotificationsTest {
    @isTest static void testRefundMethod(){
        // Datetime yesterday = Datetime.now().addDays(-1);
        // DBLog_Summary__c testdblog1 = new DBLog_Summary__c(SyncedFrom__c = 'Redish_Rerun_WithFilteredPackets'); 
        // insert testdblog1;
        // Test.setCreatedDate(testdblog1.Id, yesterday); 

        // DBLog_Summary__c testdblog2 = new DBLog_Summary__c(SyncedFrom__c = 'CAuto_DOM'); 
        // insert testdblog2;
        // Test.setCreatedDate(testdblog2.Id, yesterday); 


        // DBLog_Summary__c testdblog3 = new DBLog_Summary__c(SyncedFrom__c = 'UserTrips'); 
        // insert testdblog3;
        // Test.setCreatedDate(testdblog3.Id, yesterday); 

        // Test.startTest();
        // string query='';
        // // System.scheduleBatch(new SyncIssueNotifications (''),'AutoMa',1);
        // SyncIssueNotifications syncBatchTest = new SyncIssueNotifications(query);
        // String cronExp ='0 00 1 3 * ?';
        // System.schedule('syncBatchTest', cronExp,syncBatchTest);
        // Test.stopTest();

        DBLog_Summary__c testdblog1 = new DBLog_Summary__c(SyncedFrom__c = 'Redish_Rerun_WithFilteredPackets');
        insert testdblog1;
        DBLog_Summary__c testdblog2 = new DBLog_Summary__c(SyncedFrom__c = 'CAuto_DOM');
        insert testdblog2;
        DBLog_Summary__c testdblog3 = new DBLog_Summary__c(SyncedFrom__c = 'UserTrips');
        insert testdblog3;
        Datetime yesterday = Datetime.now().addDays(-5);
        Test.setCreatedDate(testdblog1.id, Datetime.now().addDays(-1));
        Test.setCreatedDate(testdblog2.id, Datetime.now().addDays(-2));
        Test.setCreatedDate(testdblog3.id, Datetime.now().addDays(-3));
        Test.startTest();
        string Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncNotificationQuery'].QueryDetails__c;
        SyncIssueNotifications syncBatchTest = new SyncIssueNotifications(query);
        String cronExp ='0 00 1 3 * ?';
        System.schedule('syncBatchTest', cronExp,syncBatchTest);
        Test.stopTest();




    }
}