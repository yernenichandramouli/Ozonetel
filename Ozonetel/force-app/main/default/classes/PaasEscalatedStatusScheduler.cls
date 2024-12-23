/**
 * (c) 2020 RedBus
 *
 * Name           : PaasEscalatedStatusScheduler 
 * Created Date   : 1 Nov 2020
 * Created By     : Mahendra K
 * Purpose        : Schedular class to send alert for those cases crossed 24hrs for after PaasEscalted status.
 * Test class     : PaasEscaltedStatusSchedulerTest
 *
 **/
 
global class PaasEscalatedStatusScheduler implements Schedulable {
    
    
  global void execute(SchedulableContext sc) {
       // System.abortJob(sc.getTriggerId());
        //System.schedule('PaasEscaltedStatusScheduler...'+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.GFT_Scheduler_Time)).minute()+' */1 ? * *', this);
        SendEmailAlert();
    }
 public  static void SendEmailAlert() 
  {   
    list<case> caseList;
    
    DataDeletionSetup__mdt paasEscQuery=new DataDeletionSetup__mdt();
    paasEscQuery=[SELECT QueryDetails__c,DistributionList__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='PaasEscalatedStatusQuery'];
    caseList =(List<case>)Database.query(paasEscQuery.QueryDetails__c);

    if(!caseList.isEmpty()){
       map<string,case> mapCasedetails = new map<string,case>();
       List<string> allRelatedCases=new List<string>();
       Map<string,string> refundType=new Map<string,string>();
       Map<string,string> csStatus=new Map<string,string>();
       Map<string,DateTime> csEscaltedTime=new Map<string,DateTime>();
       Map<string,string>  csIssueType=new Map<string,string>();
       Map<string,DateTime>  csCreatedTime=new Map<string,DateTime>();

       for(Case cs : caseList)
         {
           system.debug('--cs-----'+cs);
           datetime passEscTime =cs.Paas_Escalated_time__c;
           datetime sendAlertTime =passEscTime+1.00008;
           datetime currTime =system.now();
           
            system.debug('--passEscTime-----'+passEscTime+'--sendAlertTime--'+sendAlertTime+'--currTime--'+currTime);

           if(passEscTime<=sendAlertTime && sendAlertTime<=currTime){
                allRelatedCases.add(cs.caseNumber);
                system.debug('--allRelatedCases---'+allRelatedCases);
                refundType.put(cs.casenumber,cs.Refund_reason__c);
                csStatus.put(cs.casenumber,cs.status);
                csEscaltedTime.put(cs.casenumber,cs.Paas_Escalated_time__c);
                csIssueType.put(cs.casenumber,cs.Issue_Type__c);
                csCreatedTime.put(cs.casenumber,cs.createddate);
                system.debug('--refundrES--'+refundType.get(cs.casenumber));
              }
           
         }  
     string fileStr='CaseNumber, Refund Reason, Status,Created Date,Escalated Time,Issue Type \n';
     
        for(string str:allRelatedCases){
          system.debug('--str---'+str);
         string refundResVal=refundType.get(str)==null?'':refundType.get(str);
         string statusVal=csStatus.get(str)==null?'':csStatus.get(str);
         dateTime escDateVal=csEscaltedTime.get(str)==null?null:csEscaltedTime.get(str);
         string csIssueTypeVal=csIssueType.get(str)==null?'':csIssueType.get(str);
         dateTime csCreatedDateVal=csCreatedTime.get(str)==null?null:csCreatedTime.get(str);

         string recordString = '"'+str+'","'+refundResVal+'","'+statusVal+'","'+csCreatedDateVal+'","'+escDateVal+'","'+csIssueTypeVal+'" \n';
         fileStr= fileStr+recordString;
         system.debug('--refundType---'+refundResVal+'-------'+refundType.get(str));
         system.debug('--fileStr---'+fileStr);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('PassEsc_Report.csv');
        efa.setBody(Blob.valueOf(fileStr));
        efa.setContentType('text/csv');
        email.setSubject('Cases Escalted to Paas Report');
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(paasEscQuery.DistributionList__c.Split(','));
        email.setToAddresses(toAddresses);    
       //email.setToAddresses( new String[] {'mahendracloud5@gmail.com'} );
        email.setHtmlBody('Hi,<br/><br/>Please find cases that are pending in Paas escalation queue for more than 24 hours.. <br/><br/>Thanks,<br/>CRM Team');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        if (results[0].success) {
        System.debug('-------The email was sent successfully.');
        } else {
        System.debug('----------The email failed to send: ' + results[0].errors[0].message);
        }     
        
     }
  }  
}