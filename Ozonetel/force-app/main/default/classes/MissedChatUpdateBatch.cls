global class MissedChatUpdateBatch implements DataBase.Batchable<sObject>,Schedulable{
    global final string Query;

    public MissedChatUpdateBatch (String strQuery){
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }else{
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MissedChatUpdate'].QueryDetails__c;
        }
    }

    public void execute(SchedulableContext scon){
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='MissedChatUpdate'].Duration__c;
        System.schedule('MissedChatUpdateScheduler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new MissedChatUpdateBatch(Query),200);
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.debug('query..'+Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(DataBase.BatchableContext bc,List<LiveChatTranscript> lstchat){
        List<LiveChatTranscript> chatUpList=new List<LiveChatTranscript>();

        for (LiveChatTranscript chat : lstchat) {
            try{
                chat.Status='Missed';
                chatUpList.add(chat);
            }catch(Exception e){
                System.debug('Exception occured at line no: '+e.getLineNumber()+' with as error message = '+e.getMessage());
            }
        }

        if (!chatUpList.isEmpty()) {
            try {
                update chatUpList;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
    }
    
    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
        WHERE Id =:bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add('angela.tony@redbus.com');
        toAddresses.add('sudarshan.vr@redbus.com');
        toAddresses.add('sreenivasa.mariyavula@redbus.com');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Missed chat mapping status - '+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        // if(a.NumberOfErrors>0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        // }
    }
}