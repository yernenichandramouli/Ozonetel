global class GIMMTServiceAgeingInvoicingScheduler implements Schedulable{
    global void execute(SchedulableContext sc){
        GIMMTServiceAgeingInvoicingBatch busCan= new GIMMTServiceAgeingInvoicingBatch('');
        DataBase.executeBatch(busCan,Integer.valueOf(System.Label.BusCAgeingBatchSize));
    }
}