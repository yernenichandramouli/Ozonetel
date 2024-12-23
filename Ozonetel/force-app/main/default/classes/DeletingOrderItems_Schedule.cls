global class DeletingOrderItems_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        DeletingOrderItems orcls= new DeletingOrderItems();
        DataBase.executeBatch(orcls);
    }
}