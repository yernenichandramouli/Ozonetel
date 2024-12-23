@isTest
Public class UpdateCaseOwner_Test
{
    Static testmethod Void MEthod1()
    {
        Case c=new Case();
        c.OwnerId=UserInfo.getUserId();
        insert c;
        c.OwnerId=Label.Default_Queue;
        update c;
    }
}