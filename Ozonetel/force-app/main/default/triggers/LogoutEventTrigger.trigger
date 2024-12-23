trigger LogoutEventTrigger on LogoutEventStream (after insert) {
    
    List<User_Details__c> usdToUpdate=new List<User_Details__c>();
	Map<string,DateTime> mapUserToTime = new Map<string,DateTime>();
	Map<string,String> mapUserToEvent = new Map<string,String>();
    
	
    For(LogoutEventStream event : Trigger.new){
		mapUserToTime.put(event.Username,event.EventDate);
		mapUserToEvent.put(event.Username,String.valueOf(event));
	}
	
	DateTime last24Hours = System.now().addHours(-24);
	Set<String> setProcessedUser = new Set<String>();
	
	for (User_Details__c ud : [SELECT id,User__c,username__c  FROM User_Details__c Where Logout_Time__c=Null AND Last_Login_Time__c >=:last24Hours AND username__c  IN:mapUserToTime.keySet() order by Last_Login_Time__c Desc limit 100])
	{   
        if (mapUserToTime.containsKey(ud.username__c) && !setProcessedUser.contains(ud.username__c))
		{
		 	ud.Logout_Time__c = mapUserToTime.get(ud.username__c);
			ud.Logout_Event__c = mapUserToEvent.get(ud.username__c);
			usdToUpdate.add(ud);
			setProcessedUser.add(ud.username__c);
		}
    }
	if(!usdToUpdate.isEmpty())
		Database.update(usdToUpdate,false);
}