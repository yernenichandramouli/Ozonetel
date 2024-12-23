/**
 * (c) 2017 RedBus
 *
 * Name           : BusCAgeingRefundBreakupCntrl
 * Created Date   : 25 Apr 2018
 * Created By     : Sreenivas M
 * Purpose        : Handler class for the BusCAgeingRefundBreakup Component
 * Test Class     : CaseReportCSVSchedulerTest
 *
 **/
public  class BusCAgeingRefundBreakupCntrl
{
    //To show or hide the section in vf component
    public Boolean showAgeingRefBreakup{get;set;}
    public Boolean showZeroDayBreakup{get;set;}
    public Boolean showRecoveredBreakup{get;set;}
    public Boolean showNotesRecoveredBreakup{get;set;}
    public Boolean showMTDCasesBreakup{get;set;}
    public Boolean showMTDAgeingCasesBreakup{get;set;}
    public Boolean showBotMetrics{get;set;}
    
    //To Store total record count for each breakup
    public Integer totalRecCount{get;set;}
    public Integer totalZeroDayRecCount{get;set;}
    public Integer totalRecovrableRecCount{get;set;}
    public Integer totalNotesRecovrableRecCount{get;set;}
    public Integer totalMTDRecCount{get;set;}
    public Integer totalMTDOpenRecCount{get;set;}
    public Integer totalMTDAgeingRecCount{get;set;}
    
    //To Store total amount for each breakup
    public Double totalAmount{get;set;}
    public Double totalRecovrableAmount{get;set;}
    public Double totalNotesRecoverableAmount{get;set;}
    public Double totalMTDAgeingRecoverableAmount{get;set;}
    
    public Map<String,Integer> mapStatusToRecCount{get;set;}
    public Map<String,Double> mapStatusToAmount{get;set;}
    
    public List<AggregateResult> getStatusBreakup()
    {
        List<AggregateResult> caseStatusAmountBreakup = new List<AggregateResult>();
        Set<String> setRTCOpIds = new Set<String>();
        setRTCOpIds.addAll(System.Label.RTC_BO_IDS.Split(','));
        caseStatusAmountBreakup = [SELECT Status csStatus,SUM(Transaction_ID__r.Total_Fare_Value__c) total,Count(id) recCount FROM Case WHERE Transaction_ID__c!=null AND Service_Provider_Id__c NOT IN:setRTCOpIds AND Transaction_Business_Type__c='REDBUS_IN' AND Issue_Type__c='Bus Cancellation' AND Status IN ('Initiated','Department Revert','Escalated to BD') AND Creation_Age__c>72 AND Date_Of_Journey_New__c<Today AND isAgening_Refund_Processed__c=false AND Origin!='BusC Prediction' AND Type!='B2B' AND CreatedDate>=2018-03-01T18:30:00.000+0000 GROUP BY Status];
        System.debug('..caseStatusAmountBreakup..'+caseStatusAmountBreakup);
        totalRecCount =0;
        totalAmount =0.0;
        for (AggregateResult ar : caseStatusAmountBreakup  )  
        {
            System.debug('..ar.get...'+ar.get('recCount'));
            totalRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
            totalAmount +=ar.get('total')!=null?Double.valueOf(ar.get('total')):0.0;
           
        }
        System.debug('..totalRecCount ..'+totalRecCount+'...totalAmount '+totalAmount);
        return caseStatusAmountBreakup;
    }
    
    public List<AggregateResult> getZeroDayBreakup()
    {
        List<AggregateResult> listZeroDayStatusBreakup = new List<AggregateResult>();
        listZeroDayStatusBreakup = [SELECT Status csStatus,Count(id) recCount FROM Case WHERE Type!='B2B' AND Issue_Type__c='Bus Cancellation' AND Creation_Age__c<96 AND Creation_Age__c>72 AND Origin!='BusC Prediction' GROUP BY Status];
        totalZeroDayRecCount =0;
        for (AggregateResult ar : listZeroDayStatusBreakup)  
        {
            System.debug('..ar.get...'+ar.get('recCount'));
            totalZeroDayRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
        }
        System.debug('..totalZeroDayRecCount ..'+totalZeroDayRecCount);
        return listZeroDayStatusBreakup;
    }
    
    public List<AggregateResult> getRecoveredBreakup()
    {
        List<AggregateResult> listRecoverableBreakup = new List<AggregateResult>();
        listRecoverableBreakup = [SELECT Status csStatus,SUM(Total_Fare_Value__c) total,Count(id) recCount FROM Case WHERE Issue_Type__c='Bus Cancellation' AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true AND Type!='B2B' AND CreatedDate>=2018-03-01T18:30:00.000+0000 GROUP BY Status];
        totalRecovrableRecCount =0;
        totalRecovrableAmount=0.0;
        
        for (AggregateResult ar : listRecoverableBreakup)  
        {
            totalRecovrableRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
            totalRecovrableAmount +=ar.get('total')!=null?Double.valueOf(ar.get('total')):0.0;
        }
        System.debug('..totalRecovrableRecCount ..'+totalRecovrableRecCount+'..totalRecovrableAmount..'+totalRecovrableAmount);
        return listRecoverableBreakup;
    }
    
    public List<AggregateResult> getNotesRecoveredBreakup()
    {
        List<AggregateResult> listClosedNotesRecoverableBreakup = new List<AggregateResult>();
        listClosedNotesRecoverableBreakup = [SELECT Notes__c csNotes,SUM(Total_Fare_Value__c) total,Count(id) recCount FROM Case WHERE Status='Closed' AND Issue_Type__c='Bus Cancellation' AND Type!='B2B' AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true AND CreatedDate>=2018-03-01T18:30:00.000+0000 GROUP BY Notes__c];
    
        totalNotesRecovrableRecCount=0;
        totalNotesRecoverableAmount=0.0;
        
        for (AggregateResult ar : listClosedNotesRecoverableBreakup)  
        {
            totalNotesRecovrableRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
            totalNotesRecoverableAmount +=ar.get('total')!=null?Double.valueOf(ar.get('total')):0.0;
        }
        System.debug('..totalNotesRecovrableRecCount ..'+totalNotesRecovrableRecCount+'..totalNotesRecoverableAmount..'+totalNotesRecoverableAmount);
        return listClosedNotesRecoverableBreakup;
    }
  
    public List<AggregateResult> getMTDOpenCasesBreakup()
    {
        List<AggregateResult> listMTDOpenStatusBreakup = new List<AggregateResult>();
        listMTDOpenStatusBreakup = [SELECT Status csStatus,Count(id) recCount FROM Case WHERE Type!='B2B' AND Issue_Type__c='Bus Cancellation' AND Status NOT IN ('Closed','Rejected For Bus Cancellation') AND CreatedDate=THIS_MONTH AND Origin!='BusC Prediction' GROUP BY Status];
        totalMTDOpenRecCount =0;
        for (AggregateResult ar : listMTDOpenStatusBreakup)  
        {
          totalMTDOpenRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
        }
        System.debug('..totalMTDOpenRecCount ..'+totalMTDOpenRecCount);
        return listMTDOpenStatusBreakup;
    }
    
    public List<AggregateResult> getMTDCasesBreakup()
    {
        List<AggregateResult> listMTDStatusBreakup = new List<AggregateResult>();
        listMTDStatusBreakup = [SELECT Status csStatus,Count(id) recCount FROM Case WHERE Type!='B2B' AND Issue_Type__c='Bus Cancellation' AND CreatedDate=THIS_MONTH AND Origin!='BusC Prediction' GROUP BY Status];
        totalMTDRecCount =0;
        for (AggregateResult ar : listMTDStatusBreakup)  
        {
          totalMTDRecCount += ar.get('recCount')!=null?Integer.valueOf(ar.get('recCount')):0;
        }
        System.debug('..totalMTDRecCount ..'+totalMTDRecCount);
        return listMTDStatusBreakup;
    }
    
    public Map<String,Integer> getMTDAgeingRecoveredBreakup()
    {
        List<AggregateResult> listMTDAgeingRecoverableBreakup = new List<AggregateResult>();
        
        If(datetime.now().day()<=3)
        {
            listMTDAgeingRecoverableBreakup = [SELECT Ageing_Status__c agStatus,SUM(Total_Fare_Value__c) total,Count(id) recCount FROM Case WHERE Issue_Type__c='Bus Cancellation' AND Type!='B2B' AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true AND CreatedDate=LAST_MONTH GROUP BY Ageing_Status__c];
        }
        else
        {
            listMTDAgeingRecoverableBreakup = [SELECT Ageing_Status__c agStatus,SUM(Total_Fare_Value__c) total,Count(id) recCount FROM Case WHERE Issue_Type__c='Bus Cancellation' AND Type!='B2B' AND isAgening_Refund_Processed__c=true AND isAgeing_Refund_Success__c=true AND CreatedDate=THIS_MONTH GROUP BY Ageing_Status__c];
        }
        totalMTDAgeingRecCount=0;
        totalMTDAgeingRecoverableAmount=0.0;
        mapStatusToRecCount = new Map<String,Integer>();
        mapStatusToAmount = new Map<String,Double>();
        
        for (AggregateResult ar : listMTDAgeingRecoverableBreakup)  
        {
            if(ar.get('agStatus')!=null)
            {
              String finalStatus = 'Escalated to BD'.equalsIgnoreCase(String.valueOf(ar.get('agStatus')))?'Loss Booked Under Manoj':'Loss Boooked Under Sathish Krishnan';
              if(mapStatusToRecCount.containsKey(finalStatus) && ar.get('recCount')!=null)
              {
                  mapStatusToRecCount.put(finalStatus,mapStatusToRecCount.get(finalStatus)+Integer.valueOf(ar.get('recCount')));
                  totalMTDAgeingRecCount += Integer.valueOf(ar.get('recCount'));
              }
              else if(ar.get('recCount')!=null)
              {
                  mapStatusToRecCount.put(finalStatus,Integer.valueOf(ar.get('recCount')));
                  totalMTDAgeingRecCount +=Integer.valueOf(ar.get('recCount'));
              }
              
              if(mapStatusToAmount.containsKey(finalStatus) && ar.get('total')!=null)
              {
                  mapStatusToAmount.put(finalStatus,mapStatusToAmount.get(finalStatus)+Double.valueOf(ar.get('total')));
                  totalMTDAgeingRecoverableAmount+=Double.valueOf(ar.get('total'));
                  
              }
              else if(ar.get('total')!=null)
              {
                  mapStatusToAmount.put(finalStatus,Double.valueOf(ar.get('total')));
                  totalMTDAgeingRecoverableAmount+=Double.valueOf(ar.get('total'));
                  
              }
            }
        
        }
        if(totalMTDAgeingRecCount<1)
           showMTDAgeingCasesBreakup = false; 
        return mapStatusToRecCount;
       
    }
    
    public List<Metric__c> getBotBreakup()
    {
        System.debug('Entered inside the bot breakup----');
        
        return (List<Metric__c>)Database.query([Select QueryDetails__c FROM DataDeletionSetup__mdt Where DeveloperName='Bot_Metric_Last_N_Days'].QueryDetails__c);
    }
    
}