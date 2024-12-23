global class RoundRobinBusHireBatchRegion implements Database.Batchable<sObject>,Schedulable
{  
 global final String query;

 public RoundRobinBusHireBatchRegion(){}
 
 public RoundRobinBusHireBatchRegion (String q)
 {
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusHireRegion'].QueryDetails__c;
       system.debug('query==>'+query);
 }
  
 global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
      } 
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       DataDeletionSetup__mdt ddObj=new DataDeletionSetup__mdt();
       ddObj=[SELECT Duration__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusHireRegion'];
       Decimal nextInterval=ddObj.Duration__c;
       Integer batchSize=integer.valueOf(ddObj.Batch_Size__c);
       Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();
       system.debug('nextIntervalHour-->>'+nextIntervalHour);
       if(nextIntervalHour>=20)
       {
            Datetime sysNextDate = System.now().addDays(1);
            String chron_exp = '0 0 8'+ ' ' + sysNextDate.day() + ' ' + sysNextDate.month() + ' ? ' + sysNextDate.year();
            System.schedule('RoundRobinBusHireRegion - '+String.valueOf(DateTime.now()),chron_exp, this);
       }
       else if(nextIntervalHour<=6)
            System.schedule('RoundRobinBusHireRegion - '+String.valueOf(DateTime.now()), '0 0 8'+ ' ' + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year(),this);

       else
        {
           System.schedule('RoundRobinBusHireRegion - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
           Database.executeBatch(new RoundRobinBusHireBatchRegion(query),batchSize);
        }
    }
    
    global void execute(Database.BatchableContext BC, list<Lead> leadList)
    {     
     
            DateTime currTime = System.Now();            
            Map<Id,User_Details__c> mapUserIDtoDetails = new Map<Id,User_Details__c>();
            Map<Id,Integer> mapUserIdToAssCont = new Map<Id,Integer>();
            Map<Id,Integer> mapUserBufIdToAssCont = new Map<Id,Integer>();
            Map<string,integer> leadassignCount = new Map<string,integer>();
            
            Map<string,List<User_Details__c >> primaryUsers=new Map<string,list<User_Details__c >>();
            Map<string,List<User_Details__c >> secondaryUsers=new Map<string,List<User_Details__c >>(); 
            
            Map<string,List<User_Details__c >> primaryBUsers=new Map<string,list<User_Details__c >>();
            Map<string,List<User_Details__c >> secondaryBUsers=new Map<string,List<User_Details__c >>(); 
           
            
            for(User_Details__c usDet:[SELECT Pending_Buffer_Assignment_Count__c,Buffer_Limit__c,Buffer_Assigned_Count__c,UserId__c,User__r.username,Primary__c,Secondary__c,Id,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c,Group__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Team__c='Bus Hire' AND Group__c='Group 1' AND (Pending_Assignment_Count__c>0 OR Pending_Buffer_Assignment_Count__c>0) AND Assignment_Release_Time__c>=:currTime AND user__r.Primary__c!=null and user__r.Secondary__c!=null ORDER BY Assignment_Percentage__c ASC])
            {
                mapUserIDtoDetails.put(usDet.UserId__c,usDet);
                mapUserIdToAssCont.put(usDet.UserId__c,Integer.valueOf(usDet.Pending_Assignment_Count__c));
                mapUserBufIdToAssCont.put(usDet.UserId__c,Integer.valueOf(usDet.Pending_Buffer_Assignment_Count__c));
                leadassignCount.put(usDet.UserId__c,0);
                System.debug('user-->'+usDet.id);
                 System.debug('pending ass-->'+usDet.Pending_Assignment_Count__c);
                if(usDet.Pending_Assignment_Count__c>0){
                if(primaryUsers.containsKey(usDet.Primary__c))            
                    primaryUsers.get(usDet.Primary__c).add(usDet);            
                else          
                    primaryUsers.put(usDet.Primary__c,new list<User_Details__c>{usDet});            
                                
                if(secondaryUsers.containsKey(usDet.Secondary__c))           
                    secondaryUsers.get(usDet.Secondary__c).add(usDet);            
                else           
                    secondaryUsers.put(usDet.Secondary__c,new list<User_Details__c>{usDet});  
                }else if (usDet.Pending_Assignment_Count__c<=0 && usDet.Pending_Buffer_Assignment_Count__c>0){
                   if(primaryBUsers.containsKey(usDet.Primary__c))            
                    primaryBUsers.get(usDet.Primary__c).add(usDet);            
                else          
                    primaryBUsers.put(usDet.Primary__c,new list<User_Details__c>{usDet});            
                                
                if(secondaryBUsers.containsKey(usDet.Secondary__c))           
                    secondaryBUsers.get(usDet.Secondary__c).add(usDet);            
                else           
                    secondaryBUsers.put(usDet.Secondary__c,new list<User_Details__c>{usDet}); 
                }                   
          
            }
           
            List<lead> listLeadsToUpdate = new List<lead>();          
            System.debug('primaryUsers-->'+primaryUsers+'secondaryUsers-->'+secondaryUsers);
            System.debug('primaryBUsers-->'+primaryBUsers+'secondaryBUsers-->'+secondaryBUsers);

            
            for(Lead led : leadList)
            {
                  
                User_Details__c ud = new User_Details__c();                
                list<user_details__c> listUserDetails=new list<user_details__c>();
                string region = led.Region__c;
                system.debug('region==>'+region); 
                system.debug('primaryRegion-->>'+primaryUsers.containsKey(region));             
                if(primaryUsers.containsKey(region) && !primaryUsers.get(region).isEmpty() && region.equalsIgnoreCase(primaryUsers.get(region)[0].primary__c) && mapUserIdToAssCont.get(primaryUsers.get(region)[0].UserId__c)>0)
                {
                    String userId=primaryUsers.get(region)[0].UserId__c;
                   system.debug('userId==>'+userId);
                    if(leadassignCount.containskey(userId) && leadassignCount.get(userId) <10)
                    {
                        led.ownerId=userId;
                        system.debug('led.ownerId==>>'+led.ownerId);
                        system.debug('leadassignUserid1==>>'+leadassignCount.get(userId));
                        leadassignCount.put(userId,leadassignCount.get(userId)+1);
                        system.debug('leadassignUserid2==>>'+leadassignCount.get(userId));
                        primaryUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(userId);                        
                        ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(userId).Assigned_Cases_Count__c+1;
                        mapUserIDtoDetails.put(userId,ud);
                        listLeadsToUpdate.add(led);
                        
                        if((mapUserIdToAssCont.get(userId)-1)<=0 || leadassignCount.get(userId)>=10)
                            mapUserIdToAssCont.put(userId,0);
                        
                        else if(leadassignCount.get(userId)<10)
                        {
                            primaryUsers.get(region).add(ud);                      
                            mapUserIdToAssCont.put(userId,(mapUserIdToAssCont.get(userId)-1)); 
                        }
                    }
                }
                      

                 else if(secondaryUsers.containsKey(region) && !secondaryUsers.get(region).isEmpty() && region.equalsIgnoreCase(secondaryUsers.get(region)[0].Secondary__c) && mapUserIdToAssCont.get(secondaryUsers.get(region)[0].UserId__c)>0)
                { 
                    system.debug('SecondaryRegion-->>'+secondaryUsers.containsKey(region));    
                    String secUserId=secondaryUsers.get(region)[0].UserId__c;
                   
                    if(leadassignCount.containskey(secUserId) && leadassignCount.get(secUserId) <10)
                    {
                        led.ownerId=secUserId;
                        leadassignCount.put(secUserId,leadassignCount.get(secUserId)+1);
                        secondaryUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(secUserId);                        
                        ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(secUserId).Assigned_Cases_Count__c+1;
                        mapUserIDtoDetails.put(secUserId,ud);
                        listLeadsToUpdate.add(led);
                        
                        if((mapUserIdToAssCont.get(secUserId)-1)<=0 || leadassignCount.get(secUserId)>=10)
                            mapUserIdToAssCont.put(secUserId,0);
                        
                        else if(leadassignCount.get(secUserId)<10)
                        {
                            secondaryUsers.get(region).add(ud);                      
                            mapUserIdToAssCont.put(secUserId,(mapUserIdToAssCont.get(secUserId)-1)); 
                        }
                    }
                }
                
                else if(primaryBUsers.containsKey(region) && !primaryBUsers.get(region).isEmpty() && region.equalsIgnoreCase(primaryBUsers.get(region)[0].primary__c) && mapUserBufIdToAssCont.get(primaryBUsers.get(region)[0].UserId__c)>0)
                {
                    String userId=primaryBUsers.get(region)[0].UserId__c;
                   system.debug('userId==>'+userId);
                    if(leadassignCount.containskey(userId) && leadassignCount.get(userId) <10)
                    {
                        led.ownerId=userId;
                        system.debug('led.ownerId==>>'+led.ownerId);
                        system.debug('leadassignUserid1==>>'+leadassignCount.get(userId));
                        leadassignCount.put(userId,leadassignCount.get(userId)+1);
                        system.debug('leadassignUserid2==>>'+leadassignCount.get(userId));
                        primaryBUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(userId);  
                        System.debug('map U-->'+mapUserIDtoDetails.get(userId));                      
                        ud.Buffer_Assigned_Count__c = mapUserIDtoDetails.get(userId).Buffer_Assigned_Count__c+1;
                        mapUserIDtoDetails.put(userId,ud);
                        listLeadsToUpdate.add(led);
                        
                        if((mapUserBufIdToAssCont.get(userId)-1)<=0 || leadassignCount.get(userId)>=10)
                            mapUserBufIdToAssCont.put(userId,0);
                        
                        else if(leadassignCount.get(userId)<10)
                        {
                            primaryBUsers.get(region).add(ud);                      
                            mapUserBufIdToAssCont.put(userId,(mapUserBufIdToAssCont.get(userId)-1)); 
                        }
                    }
                }
                else if(secondaryBUsers.containsKey(region) && !secondaryBUsers.get(region).isEmpty() && region.equalsIgnoreCase(secondaryBUsers.get(region)[0].Secondary__c) && mapUserBufIdToAssCont.get(secondaryBUsers.get(region)[0].UserId__c)>0)
                { 
                    system.debug('SecondaryBRegion-->>'+secondaryBUsers.containsKey(region));    
                    String secUserId=secondaryBUsers.get(region)[0].UserId__c;
                   
                    if(leadassignCount.containskey(secUserId) && leadassignCount.get(secUserId) <10)
                    {
                        led.ownerId=secUserId;
                        leadassignCount.put(secUserId,leadassignCount.get(secUserId)+1);
                        secondaryBUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(secUserId);                        
                        ud.Buffer_Assigned_Count__c = mapUserIDtoDetails.get(secUserId).Buffer_Assigned_Count__c+1;
                        mapUserIDtoDetails.put(secUserId,ud);
                        listLeadsToUpdate.add(led);
                        
                        if((mapUserBufIdToAssCont.get(secUserId)-1)<=0 || leadassignCount.get(secUserId)>=10)
                            mapUserBufIdToAssCont.put(secUserId,0);
                        
                        else if(leadassignCount.get(secUserId)<10)
                        {
                            secondaryBUsers.get(region).add(ud);                      
                            mapUserBufIdToAssCont.put(secUserId,(mapUserBufIdToAssCont.get(secUserId)-1)); 
                        }
                    }
                }
          
            }
            
            try
            {
                if(!listLeadsToUpdate.isEmpty())
                    update listLeadsToUpdate;
            
                if(!mapUserIDtoDetails.values().isEmpty())
                    update mapUserIDtoDetails.values();
            }
            
            Catch(Exception e)
            {
                System.debug('Exception...'+String.valueOf(e));
            }
    }

    global void finish(Database.BatchableContext BC) 
    {
         AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       toAddresses.add('veeramanikanta.r@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('BusHire Group1 Region New Lead Assignment-'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}