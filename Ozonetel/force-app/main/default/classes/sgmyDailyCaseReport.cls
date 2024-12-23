/**
 * (c) 2023 RedBus
 *
 * Name           : sgmyDailyCaseReport
 * Created Date   : 14 JUL 2023
 * Created By     : VR Sudarshan
 * Jira Id        : CRM - 1455
 * Purpose        : Controller to summarise the SGMY closed cases on daily basis and send out an email using sgmyDailyCaseReport.component
 * Test class     : sgmyDailyCaseReportTest
 *
 **/
public class sgmyDailyCaseReport {
    public Integer totalRecCount{get;set;}
    public Boolean showSgmyCaseReport{get;set;}
    
    public List<AggregateResult> getStatusWiseClosedCases() {
        List<AggregateResult> statusWiseClosedList = new List<AggregateResult>();
        statusWiseClosedList = [SELECT Closed_By_Agent__c csOwner,Count(id) recCount FROM Case WHERE Status='Closed' AND owner.name!='Spam EMails Queue' AND createdDate = TODAY AND origin in('Email - hq_sgmy@redbus.my','hq_rdc@redbus.com') AND TAT_Notifier_Email__c NOT in ('noreply-depot@e-redbus.in','ticketmaster@redbus.my','ticketmaster@redbus.sg') AND Closed_By_Agent__c!=Null GROUP BY Closed_By_Agent__c];
        totalRecCount =0;
        List<AggregateResult> totalOpenCaseList  = [SELECT Count(id) recCount FROM Case WHERE Status !='Merged' AND owner.name!='Spam EMails Queue' AND createdDate = TODAY AND origin in('Email - hq_sgmy@redbus.my','hq_rdc@redbus.com') AND TAT_Notifier_Email__c NOT in ('noreply-depot@e-redbus.in','ticketmaster@redbus.my','ticketmaster@redbus.sg') AND Closed_By_Agent__c!=Null GROUP BY Closed_By_Agent__c];
        for (AggregateResult ar : totalOpenCaseList)  {
            totalRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
        }
        System.debug('::: totalRecCount = '+totalRecCount);
        return statusWiseClosedList;
    }
}