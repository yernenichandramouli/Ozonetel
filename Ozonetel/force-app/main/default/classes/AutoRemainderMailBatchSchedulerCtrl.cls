/**
 * (c) 2023 RedBus
 *
 * Name           : AutoRemainderMailBatchSchedulerCtrl
 * Created Date   : 12 JUL 2023
 * Created By     : VR Sudarshan
 * Purpose        : Schedular class to auto remainder for waiting for customer cases.
 * Test class     : AutoRemainderMailBatchSchedulerCtrlTest
 *
 **/
global class AutoRemainderMailBatchSchedulerCtrl implements Schedulable{
    global void execute(SchedulableContext sc)
    {
        AutoRemainderMailBatchCtrl busCan= new AutoRemainderMailBatchCtrl('');
        DataBase.executeBatch(busCan,Integer.valueOf(10));
    }
}