global class RoundRobinAssignmentSITBatch implements Database.Batchable<sObject>,Schedulable
{      
    global final String Query;
    global String ownerName;    
    public RoundRobinAssignmentSITBatch(){}    
    public RoundRobinAssignmentSITBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinSIT'].QueryDetails__c;        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinSIT'].Duration__c;
        System.schedule('RoundRobinSITAssignemnt - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RoundRobinAssignmentSITBatch(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       /* string Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinSIT'].QueryDetails__c;
        System.debug('query..'+Query); 
        System.debug('query result-->'+Database.getQueryLocator(Query));*/
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
        if(!listCase.isEmpty())
        {
            DateTime currTime = System.Now();            
            Map<Id,User_Details__c> mapUserDetails = new Map<Id,User_Details__c>();
            Map<Id,Integer> mapUserIdToAssCont = new Map<Id,Integer>();
             
            Map<string,List<User_Details__c >> primaryUsers=new Map<string,list<User_Details__c >>();
            Map<string,List<User_Details__c >> secondaryUsers=new Map<string,List<User_Details__c >>();
            Map<string,List<User_Details__c >> tertiaryUsers=new Map<string,List<User_Details__c >>();
                    
            for(User_Details__c usDet:[SELECT UserId__c,user__r.Primary__c,user__r.Secondary__c,user__r.Tertiary__c,Id,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Team__c='SIT' AND Pending_Assignment_Count__c>0 AND Assignment_Release_Time__c>=:currTime AND user__r.Primary__c!=null and user__r.Secondary__c!=null and user__r.tertiary__c!=null ORDER BY Assignment_Percentage__c ASC])
            {
                System.debug('usDet...'+usDet.Assigned_Cases_Count__c);
                mapUserDetails.put(usDet.UserId__c,usDet);
                mapUserIdToAssCont.put(usDet.UserId__c,Integer.valueOf(usDet.Pending_Assignment_Count__c));
                
                if(primaryUsers.containsKey(usDet.user__r.Primary__c)){            
                    primaryUsers.get(usDet.user__r.Primary__c).add(usDet);            
                }else{            
                    primaryUsers.put(usDet.user__r.Primary__c,new list<User_Details__c>{usDet});            
                }  
                
                if(secondaryUsers.containsKey(usDet.user__r.Secondary__c)){            
                    secondaryUsers.get(usDet.user__r.Secondary__c).add(usDet);            
                }else{            
                    secondaryUsers.put(usDet.user__r.Secondary__c,new list<User_Details__c>{usDet});            
                }            
                
                if(tertiaryUsers.containsKey(usDet.user__r.tertiary__c)){            
                    tertiaryUsers.get(usDet.user__r.tertiary__c).add(usDet);            
                }else{          
                    tertiaryUsers.put(usDet.user__r.tertiary__c,new list<User_Details__c>{usDet});
                }
                
              
            }
            
            List<case> listCasesToUpdate = new List<Case>();          
            System.debug('primaryUsers-->'+primaryUsers);
            System.debug('secondaryUsers-->'+secondaryUsers);
            System.debug('tertiaryUsers-->'+tertiaryUsers);            
            for(Case cs : listCase)
            {
                System.debug('map-->'+mapUserIdToAssCont);               
            
                System.debug('mapUserDetails--->'+mapUserDetails);
                System.debug('cs id-->'+cs.id+'owner name-->'+cs.owner.name);
                System.debug('map c-->'+mapUserIdToAssCont+'count-->'+mapUserIdToAssCont.get(cs.OwnerId));               
                    
                User_Details__c ud = new User_Details__c();                
                string primaryKeyS=string.valueof(primaryUsers.keyset());
                
                System.debug('primaryKey-->'+primaryUsers.keyset()+'<---tfff'+primaryUsers.get(string.valueof(cs.owner.name)));
                System.debug('tertiaryKey-->'+tertiaryUsers.keyset()+'<---tfff'+tertiaryUsers.get(string.valueof(cs.owner.name)));
                System.debug('ter key-->'+tertiaryUsers.get(string.valueof(cs.owner.name)));
                
                string primaryKey;
                string secondaryKey;
                string tertiaryKey;
                list<user_details__c> udl=new list<user_details__c>();
                  System.debug('owner ctrl 1-->'+ownerName);
                if(!Test.isRunningTest())
                ownerName = cs.owner.name;
                
                System.debug('owner ctrl-->'+ownerName);
                if(primaryUsers.containsKey(ownerName) && !primaryUsers.get(ownerName).isEmpty() && ownerName.equalsIgnoreCase(primaryUsers.get(ownerName)[0].user__r.primary__c) && mapUserIdToAssCont.get(primaryUsers.get(ownerName)[0].UserId__c)>0)
                {
                    cs.ownerId=primaryUsers.get(ownerName)[0].UserId__c;
                    primaryUsers.get(ownerName).remove(0);             
                    ud=mapUserDetails.get(cs.OwnerId);                        
                    ud.Assigned_Cases_Count__c = mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c+1;
                    mapUserDetails.put(cs.OwnerId,ud);
                                    
                    if((mapUserIdToAssCont.get(cs.OwnerId)-1)<=0)
                        mapUserIdToAssCont.put(cs.OwnerId,0);
                                  
                    else
                    {
                        primaryUsers.get(ownerName).add(ud);                      
                        mapUserIdToAssCont.put(cs.OwnerId,(mapUserIdToAssCont.get(cs.OwnerId)-1)); 
                    }
              
                }
                
                else if(secondaryUsers.containsKey(ownerName) && !secondaryUsers.get(ownerName).isEmpty() && ownerName.equalsIgnoreCase(secondaryUsers.get(ownerName)[0].user__r.secondary__c) && mapUserIdToAssCont.get(secondaryUsers.get(ownerName)[0].UserId__c)>0)
                {
                        cs.ownerId=secondaryUsers.get(ownerName)[0].UserId__c;
                        secondaryUsers.get(ownerName).remove(0);             
                        ud=mapUserDetails.get(cs.OwnerId);                        
                        ud.Assigned_Cases_Count__c = mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c+1;
                        mapUserDetails.put(cs.OwnerId,ud);
                        System.debug('sec map owner-->'+cs.OwnerId+'--count-->'+mapUserIdToAssCont.get(cs.OwnerId));
                        
                        if((mapUserIdToAssCont.get(cs.OwnerId)-1)<=0)
                            mapUserIdToAssCont.put(cs.OwnerId,0);
                                                     
                        else
                        {                
                            secondaryUsers.get(ownerName).add(ud);
                            mapUserIdToAssCont.put(cs.OwnerId,(mapUserIdToAssCont.get(cs.OwnerId)-1)); 
                        }  
                }
                
                else if(tertiaryUsers.containsKey(ownerName) && !tertiaryUsers.get(ownerName).isEmpty() && ownerName.equalsIgnoreCase(tertiaryUsers.get(ownerName)[0].user__r.tertiary__c) && mapUserIdToAssCont.get(tertiaryUsers.get(ownerName)[0].UserId__c)>0)
                {
                    cs.ownerId=tertiaryUsers.get(ownerName)[0].UserId__c;
                    tertiaryUsers.get(ownerName).remove(0);             
                    ud=mapUserDetails.get(cs.OwnerId);                        
                    ud.Assigned_Cases_Count__c = mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c+1;
                    mapUserDetails.put(cs.OwnerId,ud);
                    System.debug('ter owner-->'+cs.OwnerId+'--count-->'+mapUserIdToAssCont.get(cs.OwnerId));
                    
                    if((mapUserIdToAssCont.get(cs.OwnerId)-1)<=0)
                        mapUserIdToAssCont.put(cs.OwnerId,0);
                           
                    else
                    {
                        tertiaryUsers.get(ownerName).add(ud);                       
                        mapUserIdToAssCont.put(cs.OwnerId,(mapUserIdToAssCont.get(cs.OwnerId)-1)); 
                    }  
                }
                listCasesToUpdate.add(cs);              
            }
            try
            {
                if(!mapUserDetails.values().isEmpty())
                    update mapUserDetails.values();
                
                if(!listCasesToUpdate.isEmpty())
                    update listCasesToUpdate;
            }
            Catch(Exception e)
            {
                DBLog_Summary__c dbLog = new DBLog_Summary__c();
                dbLog.type__c ='SIT RoundRobin Exception';
                dbLog.Exception_Description__c = String.valueOf(e);
                insert dbLog;
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {                 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addall(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('SIT RoundRobin Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}