/**
 * (c) 2022 RedBus
 *
 * Name           : ReRatingLinkForProjectBoltCasesScheduler
 * Created Date   : 29 May 2022
 * Created By     : VR Sudarshan
 * Purpose        : Schedular class to process ReRatingLinkForProjectBoltCasesCtrlTest.
 * Test class     : ReRatingLinkForProjectBoltCasesCtrlTest
 *
 **/
global class ReRatingLinkForProjectBoltCasesScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ReRatingLinkForProjectBoltCasesCtrl busCan= new ReRatingLinkForProjectBoltCasesCtrl('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}