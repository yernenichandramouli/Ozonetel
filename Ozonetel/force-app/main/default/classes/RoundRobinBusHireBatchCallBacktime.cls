global class RoundRobinBusHireBatchCallBacktime implements Database.Batchable<sObject>,Schedulable
{  
    global final String query;
     DateTime lastCompletedDate;
     DateTime currentTime;
    public RoundRobinBusHireBatchCallBacktime(){}
    
    public RoundRobinBusHireBatchCallBacktime (String q)
    {
        currentTime = System.now();
    
        
       system.debug('currentTime-->>'+currentTime);     
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusCallBacktime'].QueryDetails__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('query-->>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusCallBacktime'].Duration__c;
       Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();
       
       if(nextIntervalHour>=20)
       {
            Datetime sysNextDate = System.now().addDays(1);
            String chron_exp = '0 5 8'+ ' ' + sysNextDate.day() + ' ' + sysNextDate.month() + ' ? ' + sysNextDate.year();
            System.schedule('RoundRobinBusCallBacktime - '+String.valueOf(DateTime.now()),chron_exp, this);
       }
       else if(nextIntervalHour<=6)
            System.schedule('RoundRobinBusCallBacktime - '+String.valueOf(DateTime.now()), '0 5 8'+ ' ' + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year(),this);

       else
        {
           System.schedule('RoundRobinBusCallBacktime - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
           Database.executeBatch(new RoundRobinBusHireBatchCallBacktime(query));
        }
    }
     global void execute(Database.BatchableContext BC, list<Lead> leadList)
    {     
     
            DateTime currTime = System.Now();            
            Map<Id,User_Details__c> mapUserIDtoDetails = new Map<Id,User_Details__c>();
            Map<Id,Integer> mapUserIdToAssCont = new Map<Id,Integer>();
            Set<Id> avilableUserIds = new Set<Id>();
           
            
            Map<string,List<User_Details__c >> primaryUsers=new Map<string,list<User_Details__c >>();
            Map<string,List<User_Details__c >> secondaryUsers=new Map<string,List<User_Details__c >>(); 
           
            
            for(User_Details__c usDet:[SELECT UserId__c,User__r.username,Primary__c,Secondary__c,Id,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c,Group__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Team__c='Bus Hire' AND Group__c='Group 1' AND (Assignment_Release_Time__c>=:currTime OR AgentStatus__c !='Logoff') AND user__r.Primary__c!=null and user__r.Secondary__c!=null ORDER BY Assignment_Percentage__c ASC])
            {
                mapUserIDtoDetails.put(usDet.UserId__c,usDet);
                mapUserIdToAssCont.put(usDet.UserId__c,Integer.valueOf(usDet.Pending_Assignment_Count__c));
                avilableUserIds.add(usDet.UserId__c);
                               
                if(primaryUsers.containsKey(usDet.Primary__c))            
                    primaryUsers.get(usDet.Primary__c).add(usDet);            
                else          
                    primaryUsers.put(usDet.Primary__c,new list<User_Details__c>{usDet});            
                                
                if(secondaryUsers.containsKey(usDet.Secondary__c))           
                    secondaryUsers.get(usDet.Secondary__c).add(usDet);            
                else           
                    secondaryUsers.put(usDet.Secondary__c,new list<User_Details__c>{usDet});            
          
            }
           
            List<lead> listLeadsToUpdate = new List<lead>();          
            System.debug('primaryUsers-->'+primaryUsers+'secondaryUsers-->'+secondaryUsers);
            
            for(Lead led : leadList)
            {
                string region = led.Region__c;
                string ledownerid=string.valueof(led.ownerid).left(15);
                Id firstDefUser;
                User_Details__c ud = new User_Details__c();                
                list<user_details__c> listUserDetails=new list<user_details__c>();
              
                system.debug('region==>'+region); 
                system.debug('primaryRegion-->>'+primaryUsers.containsKey(region));  
                System.debug('led.ownerid....'+led.ownerid);
                if(!avilableUserIds.isEmpty())
                     firstDefUser = new List<Id>(avilableUserIds).get(0);
                
                if(mapUserIDtoDetails.containskey(ledownerid)){
                        led.Consider_For_Assignment__c=false;   
                        ud=mapUserIDtoDetails.get(ledownerid);                        
                        //ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(ledownerid).Assigned_Cases_Count__c+1;
                        mapUserIDtoDetails.put(ledownerid,ud);
                        listLeadsToUpdate.add(led);
                        avilableUserIds.remove(ledownerid);
                        
                        if((mapUserIdToAssCont.get(ledownerid)-1)<=0 )
                        {
                            mapUserIdToAssCont.put(ledownerid,0);
                        }
                        
                        else
                         {                           
                            mapUserIdToAssCont.put(ledownerid,(mapUserIdToAssCont.get(ledownerid)-1));
                            avilableUserIds.add(ledownerid);
                         }
                }
                
                else if(primaryUsers.containsKey(region) && !primaryUsers.get(region).isEmpty() && region.equalsIgnoreCase(primaryUsers.get(region)[0].primary__c) && mapUserIdToAssCont.get(primaryUsers.get(region)[0].UserId__c)>0)
                {
                    String userId=primaryUsers.get(region)[0].UserId__c;
                   system.debug('userId==>'+userId);
                    
                      led.ownerId=userId;
                      led.Consider_For_Assignment__c=false;
                        system.debug('led.ownerId==>>'+led.ownerId);
                        primaryUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(userId);                        
                        ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(userId).Assigned_Cases_Count__c+1;
                        mapUserIDtoDetails.put(userId,ud);
                        listLeadsToUpdate.add(led);
                        avilableUserIds.remove(userId);
                        
                        if((mapUserIdToAssCont.get(userId)-1)<=0 )
                            mapUserIdToAssCont.put(userId,0);
                        
                        else 
                        {
                            primaryUsers.get(region).add(ud);                      
                            mapUserIdToAssCont.put(userId,(mapUserIdToAssCont.get(userId)-1));
                            avilableUserIds.add(userId);
                        }
                        
                    
                }
             
                else if(secondaryUsers.containsKey(region) && !secondaryUsers.get(region).isEmpty() && region.equalsIgnoreCase(secondaryUsers.get(region)[0].Secondary__c) && mapUserIdToAssCont.get(secondaryUsers.get(region)[0].UserId__c)>0)
                { 
                    system.debug('SecondaryRegion-->>'+secondaryUsers.containsKey(region));    
                    String secUserId=secondaryUsers.get(region)[0].UserId__c;
                   
                   
                        led.ownerId=secUserId;
                        led.Consider_For_Assignment__c=false;
                        secondaryUsers.get(region).remove(0);             
                        ud=mapUserIDtoDetails.get(secUserId);                        
                        ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(secUserId).Assigned_Cases_Count__c+1;
                        mapUserIDtoDetails.put(secUserId,ud);
                        listLeadsToUpdate.add(led);
                        avilableUserIds.remove(secUserId);
                        
                        if((mapUserIdToAssCont.get(secUserId)-1)<=0 )
                            mapUserIdToAssCont.put(secUserId,0);
                        
                        else 
                        {
                            secondaryUsers.get(region).add(ud);                      
                            mapUserIdToAssCont.put(secUserId,(mapUserIdToAssCont.get(secUserId)-1));
                            avilableUserIds.add(secUserId);
                        }
                }
                
                else if(!avilableUserIds.isEmpty() && mapUserIdToAssCont.get(firstDefUser)>0)
                {
                    led.ownerId=firstDefUser; 
                     led.Consider_For_Assignment__c=false;                  
                    ud=mapUserIDtoDetails.get(firstDefUser);                        
                    ud.Assigned_Cases_Count__c = mapUserIDtoDetails.get(firstDefUser).Assigned_Cases_Count__c+1;
                    mapUserIDtoDetails.put(firstDefUser,ud);
                    listLeadsToUpdate.add(led);
                    avilableUserIds.remove(firstDefUser);

                    if((mapUserIdToAssCont.get(firstDefUser)-1)<=0)
                        mapUserIdToAssCont.put(firstDefUser,0);

                    else 
                    {
                        mapUserIdToAssCont.put(firstDefUser,(mapUserIdToAssCont.get(firstDefUser)-1));
                        avilableUserIds.add(firstDefUser);
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
       mail.setToAddresses(toAddresses);
       mail.setSubject('BusHire Group1 Region New Lead Assignment-'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}