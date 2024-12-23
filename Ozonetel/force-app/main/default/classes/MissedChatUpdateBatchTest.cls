@isTest
public class MissedChatUpdateBatchTest {
    public static void createTestData() {
        LiveChatVisitor lv = new LiveChatVisitor();
        insert lv;
        LiveChatTranscript chatTranscript = new LiveChatTranscript();
        chatTranscript.LiveChatVisitorId = lv.Id;
        chatTranscript.Status = 'Completed';
        insert chatTranscript;
    }
    
    @isTest static void ClosureTestMethod() {
        createTestData();
        MissedChatUpdateBatchSchedular missedChat = new MissedChatUpdateBatchSchedular();
        String sch = '0 0 8 13 2 ?';
        Test.startTest();
        system.schedule('missedChatUpdate', sch, missedChat);
        Test.stopTest();
        CronTrigger cronTrigger = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'missedChatUpdate'];
        System.assertNotEquals(null, cronTrigger, 'The scheduled job should exist.');
        System.assertEquals(sch, cronTrigger.CronExpression, 'The cron expression should match the one passed.');
    }

    @isTest static void testBatchExecution() {
        createTestData();
        String validQuery = 'SELECT Id, Status FROM LiveChatTranscript WHERE Status = \'Completed\'';
        MissedChatUpdateBatch batch = new MissedChatUpdateBatch(validQuery);
        Test.startTest();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();
        System.assertNotEquals(null, queryLocator, 'The query locator should return records for LiveChatTranscript with Completed status');
        List<LiveChatTranscript> chatList = [SELECT Id, Status FROM LiveChatTranscript WHERE Status = 'Completed'];
        batch.execute(null, chatList);
        List<LiveChatTranscript> updatedChats = [SELECT Id, Status FROM LiveChatTranscript WHERE Status = 'Missed'];
        System.assertEquals(chatList.size(), updatedChats.size(), 'The number of chats with status Missed should match the original number');
    }
}