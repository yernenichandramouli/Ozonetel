/**
 * (c) 2023 RedBus
 *
 * Name           : selfHelpBoltAutomationScheduler
 * Created Date   : 26 APR 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM-1381
 * Purpose        : Schedular class to process selfHelpBoltAutomationBatchApex.
 * Test class     : approveSHExceptionalRefundClassTest
 *
 **/
global class selfHelpBoltAutomationScheduler implements Schedulable {
  public string query;
  public Datetime currentDateTime;

  public selfHelpBoltAutomationScheduler(String strQuery){
    currentDateTime = System.now();
    if(String.isNotBlank(strQuery)){
      Query = strQuery;
    }else{
      Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='selfHelpBoltAutomationCases'].QueryDetails__c+' AND Date_Submitted_ct__c <:currentDateTime AND (Scheduler_Attempts__c < 3 OR Scheduler_Attempts__c=null)';
    }
    System.debug('::: Query :: '+Query);
  }

  global void execute(SchedulableContext scon) {
    System.abortJob(scon.getTriggerId());
    Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='selfHelpBoltAutomationCases'].Duration__c;
    System.schedule('SHBoltApprovalScheuler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
    approveSHExceptionalRefundClass shBolt = new approveSHExceptionalRefundClass(Query);
  }
}