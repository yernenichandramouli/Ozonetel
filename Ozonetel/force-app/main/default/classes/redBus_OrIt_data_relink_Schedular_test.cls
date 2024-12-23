@isTest
Public Class redBus_OrIt_data_relink_Schedular_test
{
    public static String CRON_EXP = string.valueOf(DateTime.now().addMinutes(2).format('s m H d M ? y'));
    Static TestMethod Void redBus_OrderIteam_data_relink_Batch()
    {
        String jobId = System.schedule('RedBus Data relink',
                        CRON_EXP, 
                        new redBus_OrIt_data_relink_Batch_Schedular());
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
    }
}