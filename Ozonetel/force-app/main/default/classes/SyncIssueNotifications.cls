global class SyncIssueNotifications implements Database.Batchable<AggregateResult>,Schedulable
{    
    global final String Query;  
    public static boolean isDelayed = false;   
    public SyncIssueNotifications(){}  
    public SyncIssueNotifications(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncNotificationQuery'].QueryDetails__c;    
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='SyncNotificationQuery'].Duration__c;
        System.schedule('SyncIssueNotifications - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new SyncIssueNotifications(Query));
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext bc)
    {
        System.debug('query..'+Query);        
        return new AggregateResultIterable(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {     
        System.debug('## SyncNotification'+scope);
        List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();
        if(!scope.isEmpty())
        {
            Map<string,Integer> syncmtDataMap = new Map<string,Integer>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com','mahendrareddy.k@redbus.com','sreenivasa.mariyavula@redbus.com','veeramanikanta.r@redbus.com','subrahmanya.bhat@redbus.com','preethan.kumar@redbus.com','nilika.haldar@redbus.com'});
            //mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
            mail.setSubject('IND External Sync Details');
            string body = '<html><pre>Hi All ,</pre>';
            body = body+'<pre>There is a delay in syncing. For more information please refer to the below details.</pre></br></br><table cellspacing="0" cellpadding="5" border="0" style="border-collapse: collapse;width:100%;">';
            body += '<thead style="color:red;"><tr><th style="border: 1px solid black; ">Synced From</th><th style="border: 1px solid black;">Last Run Time</th><th style="border: 1px solid black;">Delayed By (Minute)</th><th style="border: 1px solid black;">Threshold (Minute)</th></tr><thead>';
            Long  CurrTime = System.Now().getTime();
            DateTime syncdatetime;
            for(Sync_Issue_Notification__mdt obj:[SELECT SyncedFrom__c,ThreshHold__c FROM Sync_Issue_Notification__mdt WHERE Country__c='IND']){
                syncmtDataMap.put((string)obj.SyncedFrom__c,(integer)obj.ThreshHold__c);
            }
            system.debug('::: syncmtDataMap ::::: '+syncmtDataMap);
            for(sObject sObj : scope) {
                AggregateResult a = (AggregateResult)sObj;
                syncdatetime = (DateTime)a.get('LastCreated'); 
                String syncName=(String)a.get('SyncedFrom__c'); 
                long syncdate =syncdatetime.getTime();
                Long milliseconds = CurrTime - syncdate;
                System.debug(':::: milliseconds :::: '+milliseconds);
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                if(syncmtDataMap.keyset().contains(syncName) && a.get('SyncedFrom__c')=='CAuto_DOM' && minutes>syncmtDataMap.get(syncName)){
                    isDelayed = true;   
                    body += '<tbody style = "text-align:center;"><tr style="background-color: #D6EEEE;"><td style="border: 1px solid black;">'+ a.get('SyncedFrom__c') +'</td><td style="border: 1px solid black;">'+ syncdatetime.format('dd-MM-yyyy h:mm a') +'</td><td style="border: 1px solid black;">'+ minutes +'</td><td style="border: 1px solid black;">'+ syncmtDataMap.get(syncName) +'</td></tr></tbody>';
                }else if(syncmtDataMap.keyset().contains(syncName) && a.get('SyncedFrom__c')=='Redish_Rerun_WithFilteredPackets' && minutes>syncmtDataMap.get(syncName)){
                    isDelayed = true;   
                    body += '<tbody style = "text-align:center;"><tr style="background-color: #D6EEEE;"><td style="border: 1px solid black;">'+ a.get('SyncedFrom__c') +'</td><td style="border: 1px solid black;">'+ syncdatetime.format('dd-MM-yyyy h:mm a') +'</td><td style="border: 1px solid black;">'+ minutes +'</td><td style="border: 1px solid black;">'+ syncmtDataMap.get(syncName) +'</td></tr></tbody>';
                }else if(syncmtDataMap.keyset().contains(syncName) && syncmtDataMap.get(syncName)!=null){
                    body += '<tbody style = "text-align:center;"><tr><td style="border: 1px solid black;">'+ a.get('SyncedFrom__c') +'</td><td style="border: 1px solid black;">'+ syncdatetime.format('dd-MM-yyyy h:mm a') +'</td><td style="border: 1px solid black;">'+ minutes +'</td><td style="border: 1px solid black;">'+ syncmtDataMap.get(syncName) +'</td></tr></tbody>';
                }else{
                    body += '<tbody style = "text-align:center;"><tr><td style="border: 1px solid black;">'+ a.get('SyncedFrom__c') +'</td><td style="border: 1px solid black;">'+ syncdatetime.format('dd-MM-yyyy h:mm a') +'</td><td style="border: 1px solid black;">'+ minutes +'</td><td style="border: 1px solid black;">'+ 'NA' +'</td></tr></tbody>';
                }
            }
            body += '</table></html><pre>Thanks</pre><pre>CRM Team</pre>';
            mail.setHtmlBody(body);
            maillist.add(mail);
            system.debug('maillist'+maillist);
            system.debug('::: isDelayed :::' +isDelayed);
            if(isDelayed == true){
                Messaging.sendEmail(maillist);
            }else{
                system.debug(':: There is no delayed in the Syc transaction ::::');
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
            ('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}