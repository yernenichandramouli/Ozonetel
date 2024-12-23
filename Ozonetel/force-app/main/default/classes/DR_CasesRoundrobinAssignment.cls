global class DR_CasesRoundrobinAssignment implements Database.Batchable<sObject>,Schedulable
{    
    global final String Query;    
    public DR_CasesRoundrobinAssignment(){}    
    public DR_CasesRoundrobinAssignment(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='DRcasesQuery'].QueryDetails__c;    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='DRcasesQuery'].Duration__c;
        System.schedule('DR_CasesRoundrobinAssignment -- '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new DR_CasesRoundrobinAssignment(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
        System.debug('## RoundRobin Records Size..'+listCase.size()+' records'+'..'+listCase);
        if(!listCase.isEmpty())
        {
            DateTime currTime = System.Now();
            
            List<Id> avilableUserIds = new List<Id>();
            list<Id>  listFinalavlUserIds = new list<Id>();
            Map<Id,User_Details__c> mapUserDetails = new Map<Id,User_Details__c>();
            
            map<id,Integer> totalopenCaseCountMap = new Map<id,Integer>();
            Map<string,List<case>> mapCaseStatusToCases=new Map<string,List<case>>();
            List<case> statusWiseCases =new list<case>();
            List<case> listCasesToUpdate = new List<Case>();
            Set<String> setCaseStatus = new Set<String>{'Open','BO revert','Department Revert','BO Replied','Re-Open','Initiated'};
               
                
                //Getting available User details from user details 
            for(User_Details__c usDet:[SELECT Id,UserId__c,ownerId,owner.name,Total_Cases_Assigned_Count__c,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Assignment_Release_Time__c>=:currTime AND Team__c='DRteam' ORDER BY Assignment_Percentage__c ASC])
            {
                avilableUserIds.add(usDet.User__r.Id);
                mapUserDetails.put(usDet.User__r.Id,usDet);
            }
            
            integer eachRunLimit = mapUserDetails.isEmpty()?5:Integer.valueOf(mapUserDetails.get(avilableUserIds[0]).Daily_Assignment_Limit__c);
            
            for(AggregateResult ar:[SELECT count(id)openCaseCount, ownerId FROM Case WHERE ownerId in: avilableUserIds AND Flow_Type__c='DR_Queue' AND status in ('Open','BO Replied','BO revert','Department Revert') GROUP BY ownerId]){
                
                
                totalopenCaseCountMap.put(string.valueOf(ar.get('ownerId')),integer.valueOf(ar.get('openCaseCount')));
            }
            
            for( id avlUsrId : avilableUserIds){
                
                 integer totalAssignedOpenCount =totalopenCaseCountMap.containsKey(avlUsrId)?totalopenCaseCountMap.get(avlUsrId):0;

                if( totalAssignedOpenCount < eachRunLimit){
                    listFinalavlUserIds.add(avlUsrId);    
                }               
            }
            
            //looping Query Cases details
            for(Case c : listCase)
            {
                if(c.status!=null && setCaseStatus.contains(c.status))
                {
                    if(mapCaseStatusToCases.containsKey(c.status)){            
                        mapCaseStatusToCases.get(c.status).add(c);  
                        system.debug('>>>>if 63>>');          
                    }else{  
                        system.debug('>>>>else 65>>>');                    
                        mapCaseStatusToCases.put(c.status,new list<case>{c});            
                        
                    }    
                }   
                
            }
            
            //Adding status wise cases to list
            
             if(mapCaseStatusToCases.containsKey('BO revert')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('BO revert'));
            }
            
            if(mapCaseStatusToCases.containsKey('BO Replied')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('BO Replied'));
            }
            
            if(mapCaseStatusToCases.containsKey('Department Revert')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('Department Revert'));
            }
            
            if(mapCaseStatusToCases.containsKey('Initiated')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('Initiated'));
            }
            
            
            if(mapCaseStatusToCases.containsKey('Re-Open')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('Re-Open'));
            }
            
            if(mapCaseStatusToCases.containsKey('Open')){
                statusWiseCases.addAll(mapCaseStatusToCases.get('Open'));
            }
            
            for(Case cs : statusWiseCases)
            {
                if(!listFinalavlUserIds.isEmpty())
                {
                    User_Details__c ud = new User_Details__c();
                    ud = mapUserDetails.get(listFinalavlUserIds[0]);
                    cs.OwnerId =listFinalavlUserIds.get(0);                                   
                    cs.Round_Robin_Assigned_To__c=ud.owner.name;
                    cs.RPW_Roundrobin_Assignment_Time__c=System.Now();
                    ud.Assigned_Cases_Count__c =ud.Assigned_Cases_Count__c+1;
                    listFinalavlUserIds.remove(0);
                    integer totalAssignedOpenCount =totalopenCaseCountMap.containsKey(cs.OwnerId)?totalopenCaseCountMap.get(cs.OwnerId):0;
                    ud.Open_Cases_Count__c = totalAssignedOpenCount+1;  
                    integer openCountRuntime =totalAssignedOpenCount+1;                        
                    mapUserDetails.put(cs.OwnerId,ud);
                    
                    if(openCountRuntime < eachRunLimit)
                    {
                        totalopenCaseCountMap.put(cs.OwnerId,integer.valueof(ud.Open_Cases_Count__c)); 
                        listFinalavlUserIds.add(cs.OwnerId);
                    }
                    listCasesToUpdate.add(cs);
                }
            }
            
            if(!mapUserDetails.isEmpty())
                update mapUserDetails.values();
            
            if(!listCasesToUpdate.isEmpty())
                Database.update(listCasesToUpdate);
            
            
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
        mail.setSubject('DR Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The DR batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}