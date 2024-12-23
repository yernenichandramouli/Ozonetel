global class RoundRobinAssignmentRPWcases implements Database.Batchable<sObject>,Schedulable
{    
    global final String Query;    
    public RoundRobinAssignmentRPWcases(){}  
    public RoundRobinAssignmentRPWcases(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RPWroundRobinAssignment'].QueryDetails__c;    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RPWroundRobinAssignment'].Duration__c;
        System.schedule('RoundRobinAssignmentRPWcases - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RoundRobinAssignmentRPWcases(Query));
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
            
            Map<Id,User_Details__c> mapUserDetails = new Map<Id,User_Details__c>();
            Map<Id,Integer> mapUserIToAssCont = new Map<Id,Integer>();
            List<Id> avilableUserIds = new List<Id>();
            
            for(User_Details__c usDet:[SELECT Id,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Assignment_Release_Time__c>=:currTime AND Team__c='RPW Team' AND Pending_Assignment_Count__c>0 ORDER BY Assignment_Percentage__c ASC])
            {
                System.debug('usDet...'+usDet.Assigned_Cases_Count__c);
                avilableUserIds.add(usDet.User__r.Id);
                mapUserDetails.put(usDet.User__r.Id,usDet);
                mapUserIToAssCont.put(usDet.User__r.Id,Integer.valueOf(usDet.Pending_Assignment_Count__c));
            }
            Integer avilUserCnt = avilableUserIds.isEmpty()?0:avilableUserIds.size();
            List<case> listCasesToUpdate = new List<Case>();
            Map<string,List<case>> caseMap=new Map<string,List<case>>();
            List<case> statuswiseCases =new list<case>();

            for(Case c : listCase)
            {
                if(c.status!=null){   
                    if(caseMap.containsKey(c.status)){            
                        caseMap.get(c.status).add(c);            
                    }else{            
                        caseMap.put(c.status,new list<case>{c});            
                      system.debug('1222222222==>caseMap>>'+caseMap);
                
                    }    
                }
 
            }
            
            if(caseMap.containsKey('Department Revert')){
               statuswiseCases.addAll(caseMap.get('Department Revert'));
            }
            
            if(caseMap.containsKey('BO Replied')){
               statuswiseCases.addAll(caseMap.get('BO Replied'));
            }
             
            if(caseMap.containsKey('Re-Open')){
              statuswiseCases.addAll(caseMap.get('Re-Open'));
            }
            
            if(caseMap.containsKey('Open')){
              statuswiseCases.addAll(caseMap.get('Open'));
            }
            
            for(Case cs : statuswiseCases)
            {
                if(!avilableUserIds.isEmpty())
                {
                    cs.OwnerId = avilableUserIds.get(0);
                    cs.RPW_Roundrobin_Assignment_Time__c=System.Now();
                    string userid=avilableUserIds.get(0);
                    List<User> uName =  [select name from User where id=:userid];
                    cs.Round_Robin_Assigned_To__c= uName[0].name;
                    avilableUserIds.remove(0);
                    System.debug('cs.OwnerId..'+cs.OwnerId+'..avilableUserIds..'+avilableUserIds+'..key..'+mapUserDetails.containsKey(cs.OwnerId));
                    User_Details__c ud = new User_Details__c();
                    ud=mapUserDetails.get(cs.OwnerId);
                    System.debug('...Assigned_Cases_Count__c.11.'+mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c);
                    System.debug('...Assigned_Cases_Count__c..'+ud.Assigned_Cases_Count__c);
                    ud.Assigned_Cases_Count__c = mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c+1;
                    mapUserDetails.put(cs.OwnerId,ud);
                    
                    if((mapUserIToAssCont.get(cs.OwnerId)-1)<=0)
                    {
                        mapUserIToAssCont.put(cs.OwnerId,0);
                    }
                    
                    else
                    {
                        avilableUserIds.add(cs.OwnerId);
                        mapUserIToAssCont.put(cs.OwnerId,(mapUserIToAssCont.get(cs.OwnerId)-1)); 
                    }
                    System.debug('..avilableUserIds..'+avilableUserIds);
                    listCasesToUpdate.add(cs);
                }
            }
            
            update mapUserDetails.values();
            
            if(!listCasesToUpdate.isEmpty())
                update listCasesToUpdate;
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
        mail.setSubject('Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}