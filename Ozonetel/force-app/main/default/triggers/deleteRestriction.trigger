trigger deleteRestriction on EmailMessage (Before Delete) 
{
    Set<String> profNames = new Set<String>();
    profNames = Email_Message_Deletion_Profiles__c.getAll().KeySet();
    Map<Id,String> mapProfIds = new Map<Id,String>();
    
    for(Profile p : [SELECT Id,Name FROM Profile])
    {
        mapProfIds.put(p.Id,p.Name);
    }
    
    
    for(EmailMessage em : Trigger.Old)
    {
        if(!profNames.Contains(mapProfIds.get(UserInfo.getProfileId())))
        {
            em.addError('You cannot delete..!!');
        }
    }
}