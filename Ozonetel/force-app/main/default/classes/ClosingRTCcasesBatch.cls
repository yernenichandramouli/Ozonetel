global class ClosingRTCcasesBatch implements Database.Batchable<sObject>,Schedulable
{  
    global final String query;
    DateTime lastCompletedDate;
    DateTime currentTime;
    public ClosingRTCcasesBatch(){}
    
    public ClosingRTCcasesBatch (String q)
    {
        currentTime = System.now();
        system.debug('currentTime-->>'+currentTime);     
        if(String.isNotBlank(q))
            query = q;
        else
            query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Closing_RTC_cases'].QueryDetails__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('query-->>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext scon)
    {
        
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Closing_RTC_cases'].Duration__c;
        System.schedule('ClosingRTCcases - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new ClosingRTCcasesBatch(Query));
    }
    global void execute(Database.BatchableContext BC, list<Case> caseList)
    {     
        
        DateTime currTime = System.Now();            
        system.debug('---currTime--'+currTime);
        
        Set<String> setRTCsubIssues = new Set<String>(System.label.RTCsubIssuetypes.split('__'));
        Set<String> setRTCIssuTypes = new Set<String>(System.label.RTCissuetypes.split(','));
        Set<String> setRTCsrvbuscnclIssuType = new Set<String>(System.label.RTCServiceBucnclissuetypes.split(','));
        Set<String> setTotalRTC = new Set<String>(System.label.TotalRTCids.split('__'));
        set<string> setrtcClose = new Set<String>(System.label.RTCCloseIds.split(','));
        set<string> apsrtcClose = new Set<String>(System.label.APSRRTCCloseIds.split(','));
        set<string> tnstccClose = new Set<String>(System.label.TNSTCcloseIds.split(','));
        List<Case> listcaseToUpdate = new List<case>();          
        list<CaseComment> listCommToInsert=new list<CaseComment>();
        
        Map<String,RTCBODetails__c> mapRTCdtls = new Map<String,RTCBODetails__c>();
        
        for(RTCBODetails__c r: RTCBODetails__c.getAll().Values())
        {
            mapRTCdtls.put(r.ServiceOperatorID__c,r);
        }
        system.debug('==caseList=='+caseList);
        for(Case cs : caseList)
        {   
            CaseComment comm= new CaseComment();
            
           
            DateTime fifteenDays;
            DateTime twentyFiveDays;
            DateTime sixtyDays;
            if(cs.SS_DOJ__c!=null){
                fifteenDays= cs.SS_DOJ__c.addDays(15);
                twentyFiveDays= cs.SS_DOJ__c.addDays(25);
                sixtyDays=cs.SS_DOJ__c.addDays(60);
            }else{
                fifteenDays= cs.createddate.addDays(15);
                twentyFiveDays= cs.createddate.addDays(25);
                sixtyDays= cs.createddate.addDays(60);
            }
            
            DateTime EscBDTenDays;
            if(cs.Assigned_to_BD__c!=null){
              EscBDTenDays= cs.Assigned_to_BD__c.addDays(7);
            }
            
            system.debug('--fifteenDays--'+fifteenDays);
            system.debug('----59----'+setTotalRTC.contains(cs.Service_Providerr_Id__c));
            if((setTotalRTC.contains(cs.Service_Providerr_Id__c) || setTotalRTC.contains(cs.Service_Provider_Id__c))&& setRTCsubIssues.contains(cs.Issue_Sub_Category__c) && cs.RTCclosed__c==false){
                system.debug('--if 1---');
                cs.Status ='Closed';
                cs.RTCclosed__c=true;
                cs.Description='Sub Issuetype RTC';
                comm.commentbody='(STC) We regret to inform you,as per the RTC T&C ,this issue is not accepted by RTC.Hope to serve you better in the future.';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
                system.debug('--listCommToInsert--'+listCommToInsert+'--listcaseToUpdate--'+listcaseToUpdate);
            }else if('Escalated to BD'.equalsIgnoreCase(cs.status) && (setTotalRTC.contains(cs.Service_Providerr_Id__c) || setTotalRTC.contains(cs.Service_Provider_Id__c)) && setRTCIssuTypes.contains(cs.Issue_Type__c) && currTime > EscBDTenDays && cs.RTCclosed__c==false){
                system.debug('--if 2---');
                cs.RTCclosed__c=true;
                String optarName= String.isNotBlank(cs.Bus_Operator_Name__c)?cs.Bus_Operator_Name__c:String.isNotBlank(cs.Bus_Operator_Namee__c)?cs.Bus_Operator_Namee__c:'';

                if(mapRTCdtls.containsKey(cs.Service_Providerr_Id__c) || mapRTCdtls.containsKey(cs.Service_Provider_Id__c)){
                    cs.BO_Phone__c=mapRTCdtls.get(cs.Service_Providerr_Id__c).BOphone__c;
                    cs.BO_Email__c=mapRTCdtls.get(cs.Service_Providerr_Id__c).BOemail__c;
                }
                cs.Description='issueTypes days 10';
                cs.Status ='Closed';
                comm.commentbody='(STC)We regret the unpleasant experience.We had raised your complaint with the'+optarName+'.We have been multiple follow-ups from our end for the resolution. As on date, we have not received an update from'+' '+cs.Service_Provider_Name__c+'.Hence we would request you to take up the issue directly to RTC counter';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
            }else if((setrtcClose.contains(cs.Service_Providerr_Id__c) || setrtcClose.contains(cs.Service_Provider_Id__c)) && setRTCsrvbuscnclIssuType.contains(cs.Issue_Type__c) && cs.RTCclosed__c==false){
                system.debug('--if 3---');
                cs.RTCclosed__c=true;
                if(cs.Service_Provider_Id__c=='16884' || cs.Service_Providerr_Id__c=='16884'){
                    cs.Description='MSRTC closed';
                    comm.commentbody='(STC) you are requested to visit the nearest MSRTC booking counter with a valid Id proof and the ticket copy and meet the Counter/Depot Manager available on the working days between 9 AM to 5 PM.';
                }
                cs.Status ='Closed';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
            }else if((apsrtcClose.contains(cs.Service_Providerr_Id__c) || apsrtcClose.contains(cs.Service_Provider_Id__c))  && setRTCsrvbuscnclIssuType.contains(cs.Issue_Type__c) && currTime>fifteenDays&& cs.RTCclosed__c==false){
                system.debug('--if 4---');
                cs.RTCclosed__c=true;
                cs.Description='days 15';
                cs.Status ='Closed';
                comm.commentbody=' (STC) We regret to inform you, as per the RTC policy any issues raised post 15 days from the '+' '+cs.SS_DOJ__c+' '+'from the date of journey are not accepted. Hope to serve you better in the future.';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
            }else if((tnstccClose.contains(cs.Service_Providerr_Id__c) || tnstccClose.contains(cs.Service_Provider_Id__c))  && setRTCsrvbuscnclIssuType.contains(cs.Issue_Type__c) && currTime>twentyFiveDays && cs.RTCclosed__c==false){
                system.debug('--if 5---');
                cs.RTCclosed__c=true;
                cs.Description='days 25';
                cs.Status ='Closed';
                comm.commentbody='(STC) We regret to inform you, as per the RTC policy any issues raised post 25 days from the doj '+' '+cs.SS_DOJ__c+' '+'from the date of journey are not accepted. Hope to serve you better in the future.';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
            }else if((setTotalRTC.contains(cs.Service_Providerr_Id__c) || setTotalRTC.contains(cs.Service_Provider_Id__c))  && setRTCsrvbuscnclIssuType.contains(cs.Issue_Type__c) && currTime>sixtyDays && cs.RTCclosed__c==false){
                system.debug('--if 6---');
                cs.RTCclosed__c=true;
                cs.Description='days 60';
                cs.Status ='Closed';
                comm.commentbody='(STC) We regret to inform you, as per the RTC policy any issues raised post 60 days from the doj '+' '+cs.SS_DOJ__c+' '+'from the date of journey are not accepted. Hope to serve you better in the future.';
                comm.parentId = cs.id;
                listCommToInsert.add(comm);
                listcaseToUpdate.add(cs);
            }
            
        }
        
        try
        {
            if(!listcaseToUpdate.isEmpty()){
                system.debug('==listcaseToUpdate--'+listcaseToUpdate);
                DataBase.insert(listCommToInsert,false);
                DataBase.update(listcaseToUpdate,false);
            }
            
            
            
        }
        
        Catch(Exception e)
        {
            System.debug('Exception...'+String.valueOf(e));
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('mahendrareddy.k@redbus.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Rtc Close batch-'+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}