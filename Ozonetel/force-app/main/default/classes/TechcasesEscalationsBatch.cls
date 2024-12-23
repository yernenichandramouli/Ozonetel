/**
 * (c) 2018 RedBus
 *
 * Name           : TechcasesEscalationsBatch
 * Created Date   : 14 Aug 202021
 * Created By     : Mahendra k
 * Purpose        : Batch class to update status to Escalated to BD for RPW cases
 **/
 
global class TechcasesEscalationsBatch implements Database.Batchable<sObject>,Schedulable
{  
  
    global final String Query;
    
    public TechcasesEscalationsBatch(){}
  
    public TechcasesEscalationsBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
         else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Tech_Support_L'].QueryDetails__c;
    
    }
 
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Tech_Support_L'].Duration__c;
        System.schedule('TechcasesEscalationsBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new TechcasesEscalationsBatch(Query));
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

        BusinessHours busns= [SELECT Id FROM BusinessHours Where IsActive=True AND Name='TechEscalatedBusinessHours'];

        for(Case cs : listCase)
        {
            case c =new case();
            casecomment cc=new casecomment();
            datetime csDtime;
            if(cs.Re_Open_Time__c!=null){
              csDtime= cs.Re_Open_Time__c;
            }else{
              csDtime= cs.CreatedDate;
            }
            decimal result = BusinessHours.diff(busns.id, csDtime,system.now());
            //Result from the method is divided by 60*60*100 (milliseconds to be then converted into hours)
            Decimal resultingHours = result/(60*60*1000);
            system.debug('>>resultingHours>>'+resultingHours);
            //Populating result into our custom field & setting number of decimals
            decimal finaltime =resultingHours.setScale(1);
        if('Open'.equalsIgnorecase(cs.status)){
            system.debug('>>finaltime>f>>'+resultingHours.setScale(1)+'===cs=='+cs.casenumber); 
         if((finaltime == 2.0 || (finaltime >2.0 && finaltime<=24.0))){
             system.debug('++1++');
             c.Escalation_Level__c='Level 1';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve1 after --'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else if((finaltime==24.0 || (finaltime >24.0 && finaltime <=54.0))){
             system.debug('++2++');
             c.Escalation_Level__c='Level 2';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve2 after --'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else {
             system.debug('++3++');
             c.Escalation_Level__c='Level 3';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve3 after --'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }
          
          }else if('Re-Open'.equalsIgnorecase(cs.status) && cs.Re_Open_Time__c !=null){
             if((finaltime == 2.0 || (finaltime >2.0 && finaltime<=24.0))){
             system.debug('++1++');
             c.Escalation_Level__c='Level 1';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve1 after --'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else if((finaltime==24.0 || (finaltime >24.0 && finaltime <=54.0))){
             system.debug('++2++');
             c.Escalation_Level__c='Level 2';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve2 after --'+finaltime+'hrs';
             cc.parentid=cs.id;
             listCommToInsert.add(cc);
             listCasesToUpdate.add(c);
          }else{
             system.debug('++3++');
             c.Escalation_Level__c='Level 3';
             c.id=cs.id;
             cc.commentbody='System has been escalted to leve3 after --'+finaltime+'hrs';
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
       mail.setSubject('Case Assignment Has Finished '+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
  }