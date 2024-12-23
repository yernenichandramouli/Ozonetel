global class RoundRobinBusHireBatch implements Database.Batchable<sObject>,Schedulable
{  
    global final String query;

    public RoundRobinBusHireBatch(){}
    public RoundRobinBusHireBatch (String q)
    {
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusHire'].QueryDetails__c;
    }
    
    public void execute(SchedulableContext scon)
    {
       System.abortJob(scon.getTriggerId());
       Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='RoundRobinBusHire'].Duration__c;
       Integer nextIntervalHour = DateTime.now().addMinutes(Integer.valueOf(nextInterval)).hour();
       
       if(nextIntervalHour>=20)
       {
            Datetime sysNextDate = System.now().addDays(1);
            String chron_exp = '0 0 8'+ ' ' + sysNextDate.day() + ' ' + sysNextDate.month() + ' ? ' + sysNextDate.year();
            System.schedule('BusHireRoundRobin - '+String.valueOf(DateTime.now()),chron_exp, this);
       }
       else if(nextIntervalHour<=6)
            System.schedule('BusHireRoundRobin - '+String.valueOf(DateTime.now()), '0 0 8'+ ' ' + System.now().day() + ' ' + System.now().month() + ' ? ' + System.now().year(),this);

       else
        {
           System.schedule('BusHireRoundRobin - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
           Database.executeBatch(new RoundRobinBusHireBatch(query));
        }
         
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query...'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Lead> leadList)
    {     
        DateTime currTime = System.Now();        
        Map<Id,User_Details__c> mapUserDetails = new Map<Id,User_Details__c>();
        Map<Id,Integer> mapUserIdToAssCont = new Map<Id,Integer>();
        List<Id> avilableUserIds = new List<Id>();
        
        for(User_Details__c usDet:[SELECT Id,Name,User__c,User__r.Id,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Assignment_Release_Time__c>=:currTime AND Team__c='Bus Hire' and Group__c='Group 2' AND Pending_Assignment_Count__c>0 ORDER BY Assignment_Percentage__c ASC])
        {
            avilableUserIds.add(usDet.User__r.Id);
            mapUserDetails.put(usDet.User__r.Id,usDet);
            mapUserIdToAssCont.put(usDet.User__r.Id,Integer.valueOf(usDet.Pending_Assignment_Count__c));
        }
        List<Lead> listLeadsToUpdate = new List<Lead>();
        
         for(Lead led : leadList)
        {
          if(!avilableUserIds.isEmpty())
          {
              led.OwnerId = avilableUserIds.get(0);
              avilableUserIds.remove(0);
              User_Details__c ud = new User_Details__c();
              ud=mapUserDetails.get(led.OwnerId);
              ud.Assigned_Cases_Count__c = mapUserDetails.get(led.OwnerId).Assigned_Cases_Count__c+1;
              mapUserDetails.put(led.OwnerId,ud);
              
              if((mapUserIdToAssCont.get(led.OwnerId)-1)<=0)
              {
                mapUserIdToAssCont.put(led.OwnerId,0);
              }
              
              else
              {
                avilableUserIds.add(led.OwnerId);
                mapUserIdToAssCont.put(led.OwnerId,(mapUserIdToAssCont.get(led.OwnerId)-1)); 
              }
            listLeadsToUpdate.add(led);
          }
        }
        
        update mapUserDetails.values();
        
        if(!listLeadsToUpdate.isEmpty())
            update listLeadsToUpdate;
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {      
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('mahendrareddy.k@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Lead Assignment Has Finished '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}