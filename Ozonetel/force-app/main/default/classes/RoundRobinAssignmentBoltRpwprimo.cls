global class RoundRobinAssignmentBoltRpwprimo implements Database.Batchable<sObject>,Schedulable
{    
    global final String Query;    
    public RoundRobinAssignmentBoltRpwprimo(){}  
    public RoundRobinAssignmentBoltRpwprimo(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BoltRpwPrimo'].QueryDetails__c;    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BoltRpwPrimo'].Duration__c;
        System.schedule('RoundRobinAssignmentBoltRpwprimo - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new RoundRobinAssignmentBoltRpwprimo(Query));
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
            Map<Id,Integer> userLimitMap = new Map<Id,Integer>();
            map<id,Integer> openCaseCountMap = new Map<id,Integer>();
             map<id,Integer> totalCaseCountMap = new Map<id,Integer>();
             map<id,Integer> dailyAssignmentMap = new Map<id,Integer>();
            List<Id> avilableUserIds = new List<Id>();
            Boolean primary = false;
            Boolean secondary = false;
            Boolean tertiary = false;
            
            for(User_Details__c usDet:[SELECT Id,Total_Cases_Assigned_Count__c,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Assignment_Release_Time__c>=:currTime AND Team__c='BoltPrimoRpw' AND Pending_Assignment_Count__c>0 ORDER BY Assignment_Percentage__c ASC])
            {
                System.debug('usDet...'+usDet.Assigned_Cases_Count__c);
                avilableUserIds.add(usDet.User__r.Id);
                mapUserDetails.put(usDet.User__r.Id,usDet);
                userLimitMap.put(usDet.User__r.Id,0);
                dailyAssignmentMap.put(usDet.User__r.Id,Integer.valueOf(usDet.Daily_Assignment_Limit__c));
                mapUserIToAssCont.put(usDet.User__r.Id,Integer.valueOf(usDet.Pending_Assignment_Count__c));
            }
            
            integer userIdSize = avilableUserIds.size();
            System.debug(' ::: Available User Id Size ::::' +userIdSize);
            List<AggregateResult> openCaseList = [SELECT count(id)openCaseCount, ownerId FROM Case WHERE ownerId in: avilableUserIds AND Case_Category__c='Instant resolution-BOLT' AND status in ('Open','BO Replied') GROUP BY ownerId];
            if(!openCaseList.isEmpty() && openCaseList.size()==avilableUserIds.size()){
                for(AggregateResult ar:openCaseList){
                    openCaseCountMap.put(string.valueOf(ar.get('ownerId')),integer.valueOf(ar.get('openCaseCount')));
                }
            }else if(openCaseList.isEmpty()){
                for(Id ownrID: avilableUserIds){
                    openCaseCountMap.put(ownrID,0);
                }
            }else{
                System.debug(':::: inside elseIf :::: ');
                for(Id ownrID: avilableUserIds){
                    openCaseCountMap.put(ownrID,0);
                }
                for(AggregateResult ar:openCaseList){
                    if(avilableUserIds.contains(string.valueOf(ar.get('ownerId')))){
                        System.debug(':::: record Exists :::: ');
                        openCaseCountMap.put(string.valueOf(ar.get('ownerId')),integer.valueOf(ar.get('openCaseCount')));
                    }
                }

            }
            
            // Total cases count 
            List<AggregateResult> totalCaseAssignCount = [SELECT count(id)caseCount, ownerId FROM Case WHERE ownerId in: avilableUserIds AND Case_Category__c='Instant resolution-BOLT' AND status not in ('Escalated to BD','Closed') GROUP BY ownerId];
               for(AggregateResult ar:totalCaseAssignCount){
                   if(avilableUserIds.contains(string.valueOf(ar.get('ownerId')))){
                     totalCaseCountMap.put(string.valueOf(ar.get('ownerId')),integer.valueOf(ar.get('caseCount')));
                   }
               }
               
               
            System.debug(':::: Map of Open cases :::: '+openCaseCountMap);
            Integer avilUserCnt = avilableUserIds.isEmpty()?0:avilableUserIds.size();
            List<case> listCasesToUpdate = new List<Case>();
            Map<string,List<case>> BoltcaseMap=new Map<string,List<case>>();
            Map<string,List<case>> RPWnonBolcaseMap=new Map<string,List<case>>();
            Map<string,List<case>> NonRpmBoltcaseMap=new Map<string,List<case>>();
            List<case> BoltstatuswiseCases =new list<case>();
            List<case> RPWnonBoltstatuswiseCases =new list<case>();
            List<case> NonBoltststatuswiseCases =new list<case>();
            Set<String> setCaseStatus = new Set<String>{'Open','Department Revert','BO Replied','Re-Open'};
            for(Case c : listCase)
            {
                if(c.status!=null && 'Instant resolution-BOLT'.EqualsIgnoreCase(c.Case_Category__c) && setCaseStatus.contains(c.status))
                {   
                   primary =true;
                   secondary = false;
                   tertiary =false;
                   
                    if(BoltcaseMap.containsKey(c.status)){            
                        BoltcaseMap.get(c.status).add(c);            
                    }else{            
                        BoltcaseMap.put(c.status,new list<case>{c});            
                
                    }    
                   system.debug('1222222222==>caseMap>>'+BoltcaseMap);
                   
               }
           
            }
                       
           if(BoltcaseMap.containsKey('Open')){
              BoltstatuswiseCases.addAll(BoltcaseMap.get('Open'));
            }
                
           /* if(BoltcaseMap.containsKey('Department Revert')){
               BoltstatuswiseCases.addAll(BoltcaseMap.get('Department Revert'));
            }
            */
            
            if(BoltcaseMap.containsKey('BO Replied')){
               BoltstatuswiseCases.addAll(BoltcaseMap.get('BO Replied'));
            }
            
           /* if(BoltcaseMap.containsKey('Re-Open')){
               BoltstatuswiseCases.addAll(BoltcaseMap.get('Re-Open'));
            }*/
         
          
         

        if(!BoltstatuswiseCases.isEmpty()){
            for(Case cs : BoltstatuswiseCases)
            {
                if(!avilableUserIds.isEmpty())
                {
                    System.debug('userLimitMap...'+userLimitMap);
                    cs.OwnerId = avilableUserIds.get(0);
                    string userid=avilableUserIds.get(0);
                    List<User> uName =  [select name from User where id=:userid];
                    cs.Round_Robin_Assigned_To__c= uName[0].name;
                    cs.RPW_Roundrobin_Assignment_Time__c=System.Now();
                    avilableUserIds.remove(0);
                    System.debug('cs.OwnerId..'+cs.OwnerId+'..avilableUserIds..'+avilableUserIds+'..key..'+mapUserDetails.containsKey(cs.OwnerId));
                    User_Details__c ud = new User_Details__c();
                    ud=mapUserDetails.get(cs.OwnerId);
                    System.debug('::: Case Limit :::: '+userLimitMap.get(cs.OwnerId));
                    System.debug('::: Open Case Count :::: '+openCaseCountMap.get(cs.OwnerId));
                    System.debug('::: daily assignment limit :::: '+dailyAssignmentMap.get(cs.OwnerId));
                    System.debug('::: totalCaseCountMap :::: '+totalCaseCountMap.get(cs.OwnerId));
                    ud.Total_Cases_Assigned_Count__c=totalCaseCountMap.get(cs.OwnerId);
                    
                    integer dailAsgnCount = integer.valueof(dailyAssignmentMap.get(cs.OwnerId));
                    integer totalAsgnCount =(totalCaseCountMap.get(cs.OwnerId)!=null)?totalCaseCountMap.get(cs.OwnerId):0;   
                    system.debug('==int=='+dailAsgnCount+'==total=='+totalAsgnCount);    
                                  
                    system.debug('==1=='+(userLimitMap.get(cs.OwnerId)<5)+'==2==='+(openCaseCountMap.get(cs.OwnerId)<5)+'===3=='+(totalAsgnCount < dailAsgnCount));
                    if(userLimitMap.get(cs.OwnerId)<10 && openCaseCountMap.get(cs.OwnerId)<10 && (totalAsgnCount < dailAsgnCount)){
                    integer counter = userLimitMap.get(cs.OwnerId)+1;
                    integer openCaseCount = openCaseCountMap.get(cs.OwnerId)+1;
                    ud.Assigned_Cases_Count__c = mapUserDetails.get(cs.OwnerId).Assigned_Cases_Count__c+1;
                    mapUserDetails.put(cs.OwnerId,ud);
                    openCaseCountMap.put(cs.OwnerId,openCaseCount);
                    userLimitMap.put(cs.OwnerId,counter);
                    
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
                    
                }System.debug(':::: Final Map :::: '+openCaseCountMap);
                }
            }
         
            update mapUserDetails.values();
            
            if(!listCasesToUpdate.isEmpty())
                update listCasesToUpdate;
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
        mail.setSubject('Case Assignment Has Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}