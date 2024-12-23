/**
 * (c) 2018 RedBus
 *
 * Name           : MMTCabL1EscalationsBatch
 * Created Date   : 4th NOV 2021
 * Created By     : Mahendra k
 * Purpose        : Batch class to Escalate MMT-Cab-L1 escalation.
 **/
 
global class MMTCabL1EscalationsBatch implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public MMTCabL1EscalationsBatch(){}
  
    public MMTCabL1EscalationsBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MMT_Cab_L1'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MMT_Cab_L1'].Duration__c;
        System.schedule('MMTCabL1EscalationsBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new MMTCabL1EscalationsBatch(Query));
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
     global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
      System.debug('## ..'+listCase.size()+' records'+'..'+listCase);
      if(!listCase.isEmpty())
      {
        DateTime currTime = System.Now();
 
        List<case> listCasesToUpdate = new List<Case>();
        list<casecomment> listCommToInsert = new List<casecomment>();
        Id L2QuId = [Select id from Group where type='Queue' AND developername='Escalated_to_Fullfillment_L2'].id;
        Id L3QuId = [Select id from Group where type='Queue' AND developername='Escalated_to_Fullfillment_L3'].id;
        //Id L3QuId = [Select id from Group where type='Queue' AND developername='L3_Queue'].id;

        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];

        for(Case cs : listCase)
        {
            case c =new case();
            casecomment cc=new casecomment();
           
            datetime csDtime= cs.CreatedDate;
       
            decimal result = BusinessHours.diff(busns.id, csDtime,system.now());
            //Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
            Decimal resultingHours = result/(60*60*1000);
            system.debug('>>resultingHours>>'+resultingHours);
            //Populating result into our custom field & setting number of decimals
            decimal finaltime =resultingHours.setScale(1);
        if('Escalate to Support'.equalsIgnorecase(cs.status)){
            system.debug('>>finaltime>f>>'+resultingHours.setScale(1)+'===cs=='+cs.casenumber); 
         if((finaltime == 6.0 || (finaltime >6.0 && finaltime<=12.0))){
             system.debug('++1++');
             c.Escalation_Level__c='Level 1';
             c.ownerId=L2QuId;
             c.id=cs.id;
             cc.commentbody='No reply received. Escalated to L2---'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else if((finaltime==12.0 || (finaltime >12.0 && finaltime <=24.0))){
             system.debug('++2++');
             c.Escalation_Level__c='Level 2';
             c.ownerId=L3QuId;
             c.id=cs.id;
             cc.commentbody='No reply received. Escalated to L3--'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else if(finaltime >24.0){
             system.debug('++3++');
             c.Escalation_Level__c='Level 3';
             //c.ownerId=L3QuId;
             c.id=cs.id;
             cc.commentbody='No reply received. Close the case in customers favor--'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }
          
        
           }
        }
        
          
         if(!listCommToInsert.isEmpty())
          insert listCommToInsert;
        
         
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
       toAddresses.add('Mahendrareddy.k@redbus.com.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('MMT cab L1 Escalation Has Finished '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
  }