trigger UpdateCaseOwner on Case (before update) 
{
    for(Case c:Trigger.New)
    {
        if(c.OwnerId==Label.Default_Queue && Trigger.oldMap.get(c.Id).OwnerId!=NULL)
        {
            c.OwnerId=Trigger.oldMap.get(c.Id).OwnerId;
        }
    }
}