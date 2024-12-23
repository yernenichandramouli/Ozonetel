/**
* (c) 2022 RedBus
*
* Name           : MassBusCancellationBatch
* Created Date   : 8 Dec 2022
* Created By     : Mahendra k
* Purpose        : Batch class to process masS Bus Cancellation on bulk load
**/

global class MassBusCancellationBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts
{  
    
    global final String Query;
    
    public MassBusCancellationBatch(){}
    
    public MassBusCancellationBatch(String q)
    {
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Mass_BusCancellation_Query'].QueryDetails__c;
        
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='Mass_BusCancellation_Query'].Duration__c;
        System.schedule('MassBusCancellationBatch - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new MassBusCancellationBatch(Query));
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('--query..'+Query);        
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, list<Mass_BusCancellation__c> listMasBusCnlcases)
    {     
        System.debug('listMasBusCnlcases## ..'+listMasBusCnlcases.size()+' records'+'..'+listMasBusCnlcases);
        if(!listMasBusCnlcases.isEmpty())
        {
            
            DateTime currTime = System.Now();
            list<casecomment> listCommToInsert = new List<casecomment>();
            List<Mass_BusCancellation__c> listMasBusCnclUpdate= new List<Mass_BusCancellation__c>();
            list<Cancellation_Process_DB_Log__c> listCp = new List<Cancellation_Process_DB_Log__c>();
             
            for(Mass_BusCancellation__c busCnl: listMasBusCnlcases)
            {
                          Cancellation_Process_DB_Log__c cp = new Cancellation_Process_DB_Log__c();

                try{
                   
                    string country;
                    string selCurrency;
                    if('India'.equalsIgnoreCase(busCnl.Country__c)){
                        country='IND';
                        selCurrency='INR';
                    }else if('Singapore'.equalsIgnoreCase(busCnl.Country__c)){
                        country='SGP';
                        selCurrency='SGD';
                    } else if('Indonesia'.equalsIgnoreCase(busCnl.Country__c)){
                        country='IDN';
                        selCurrency='IDR';
                    }else if('Malaysia'.equalsIgnoreCase(busCnl.Country__c)){
                        country='MYS';
                        selCurrency='MYR';
                    }else if('Peru'.equalsIgnoreCase(busCnl.Country__c)){
                        country='PER';
                        selCurrency='PEN';
                    }else if('Colombia'.equalsIgnoreCase(busCnl.Country__c)){
                        country='COL';
                        selCurrency='COP';
                    }
                    
                    string cancellationReason;
                    if(string.isNotBlank(busCnl.Cancellation_Reason__c)){
                        cancellationReason=busCnl.Cancellation_Reason__c;
                    }else{
                        cancellationReason='SF_Mass_BusCancellation';
                    }
                    
                    cp.Type__c='Mass busCancellation Batch';
                    cp.TIN_Number__c=busCnl.TIN_No__c;
                    
                    Http http = new Http();
                    HttpResponse res = new HttpResponse();
                    HttpRequest req = new HttpRequest();
                    req = HttpRequestUtil.populateCAPIHeaders(req);
                    req.setHeader('Country_Name',country);
                    req.setHeader('SelectedCurrency',selCurrency); 
                    req.setTimeout(120000);              
                    req.setMethod('POST');
                    req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c); 
                    
                    string jsonbody = '{"isBusCancellation":true,"createdby":"SF System","CancellationType":"1","EmailId":"'+busCnl.Email__c+'","SelectedRefundType":"BACK_TO_SOURCE","TicketNo":"'+busCnl.TIN_No__c+'","reason":"'+cancellationReason+'"}';
                    req.setBody(jsonbody);
                    
                    cp.NC_API_Request_Data__c = string.valueof(req)+'Body :'+req.getBody()+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+'--SelectedCurrency :'+selCurrency+'';
                    
                    res = http.send(req);                    
                    string responseValue = res.getBody();                     
                    cp.NC_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
                    
                    if(res.getStatusCode()==200 && !string.isBlank(responseValue))
                    {
                        Mass_BusCancellation__c busCl =new  Mass_BusCancellation__c();
                        busCl.Excep_Description__c= responseValue;
                        busCl.Process_Status__c= 'Cancellation_Success';
                        busCl.id=busCnl.id;
                        listMasBusCnclUpdate.add(busCl); 
                         listCp.add(cp);           
                    }else if( !string.isBlank(responseValue)){
                        Mass_BusCancellation__c busC =new  Mass_BusCancellation__c();
                        map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                        if(IsCan.ContainsKey('DetailedMessage')){
                        busC.Process_Status__c= 'Cancellation_Failed';
                        busC.Excep_Description__c=string.valueof(IsCan.get('DetailedMessage'));
                        busC.id=busCnl.id;
                        listMasBusCnclUpdate.add(busC);
                         listCp.add(cp); 
                        }
                    }
                   
                    
                }
                Catch(Exception e)
                {
                    System.debug('Exception...'+e);
                    Mass_BusCancellation__c bus =new  Mass_BusCancellation__c();
                    cp.FC_API_Request_Response__c = string.valueof(e);  
                    bus.Excep_Description__c=string.valueof(e);
                    bus.id=busCnl.id;
                    listMasBusCnclUpdate.add(bus);
                    listCp.add(cp);
                }
            }
            
            if(!listCp.isEmpty())
                dataBase.insert(listCp,false);                
            
            if(!listMasBusCnclUpdate.isEmpty())
                DataBase.update(listMasBusCnclUpdate,false);
            
            
            
        }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {                 
        /* AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
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
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        
    }       
}