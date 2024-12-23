/**
 * (c) 2018 RedBus
 *
 * Name           : WFTGFTFollowupCaseCreationBatch
 * Created Date   : 15 Nov 2018
 * Created By     : Sreenivas M
 * Purpose        : Batch class to create a follow-up cases for WFT and GFT after 30 minutes 
 * Test class     : WFTGFTFollowupCaseCreationBatchTest
 *
 **/
 
global class WFTGFTFollowupCaseCreationBatch implements DataBase.Batchable<sObject>,Database.AllowsCallouts,Schedulable
{
    public string query;
      
    public WFTGFTFollowupCaseCreationBatch()
    {
    }
    
    public WFTGFTFollowupCaseCreationBatch(String strQuery)
    {
       query = strQuery;
    }
    
    public void execute(SchedulableContext sc)
    {

      System.abortJob(sc.getTriggerId());
      System.schedule('UnpaidVouchersScheduler '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(Label.GFT_Scheduler_Time)).minute()+' */1 ? * *', this);
      Database.executeBatch(new WFTGFTFollowupCaseCreationBatch(''),90);

    }
    
    global DataBase.QueryLocator start(DataBase.BatchableContext bc)
    {
        if(String.isBlank(query))
        {
            query = [Select QueryDetails__c from DataDeletionSetup__mdt Where DeveloperName='WFT_FollowUp_Case'].QueryDetails__c;
            return DataBase.getQueryLocator(query);
        }
        else
            return DataBase.getQueryLocator(query);
    
    }
    
    global void execute(DataBase.BatchableContext bc,List<Payment_Items__c> listPI)
    {
        List<Case> listCases = new list<Case>();
        List<Payment_Items__c> listPIToUpdate = new list<Payment_Items__c>();
        list<DBLog_Summary__c> listDBlogs = new List<DBLog_Summary__c>();
        map<string,OrderItemTransactionResource__c> oitrMap = new map<string,OrderItemTransactionResource__c>();
        
        for(OrderItemTransactionResource__c oi: OrderItemTransactionResource__c.getall().values())
            oitrMap.put(oi.name,oi);
        Id wftQueueId = [Select id from Group where type='Queue' AND developername='WFT_Unpaid_Vouchers_Queue'].id;
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('WFT/Unpaid Vouchers').getRecordTypeId();
        for(Payment_Items__c pi: listPI)
        {
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c ='WFT/Voucher Calling';
            dbl.Payment_Ping_Status__c ='Headers Config is Missing';
            dbl.Payment_Transaction_Name__c = pi.Order_Item_Name__c;
            
            String Channel_Name;String auth_key;String Country_Name;String SelectedCurrency;
            
            if(string.isNotBlank(string.valueof(pi.Order_Item_Name__r.Transaction_Source__c)) && oitrMap.KeySet().Contains(pi.Order_Item_Name__r.Transaction_Source__c))
            {
                Channel_Name = oitrMap.get(pi.Order_Item_Name__r.Transaction_Source__c).Channel_Name__c;
                auth_key = oitrMap.get(pi.Order_Item_Name__r.Transaction_Source__c).Auth_Key__c;                
            }
            
            if(!string.isBlank(string.valueof(pi.Order_Item_Name__r.Business_Unit__c)) && oitrMap.KeySet().Contains(pi.Order_Item_Name__r.Business_Unit__c))
            {
                Country_Name = oitrMap.get(pi.Order_Item_Name__r.Business_Unit__c).Auth_Key__c;
                SelectedCurrency = oitrMap.get(pi.Order_Item_Name__r.Business_Unit__c).Default_Currency__c;
            }
            
            if(String.isNotBlank(pi.Amount_Payable_Currency__c))
                SelectedCurrency = pi.Amount_Payable_Currency__c;
            
            if(String.isBlank(SelectedCurrency))
                SelectedCurrency = 'INR';
            
            if(!string.IsBlank(Channel_Name) && !string.IsBlank(auth_key) && !string.IsBlank(Country_Name))
            {
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setTimeout(5000);
                Map<String,Payment_API_endpoint__c> mapauth = Payment_API_endpoint__c.getAll();
                String endpoint = mapauth.get('End Point').End_Point__c+pi.name+'&paymentUuid='+pi.Guid__c;

                req.setEndpoint(endpoint);
                req.setHeader('Channel_Name', Channel_Name);
                req.setHeader('auth_key', auth_key);
                req.setHeader('BusinessUnit', 'BUS');
                req.setHeader('Country_Name', Country_Name);
                req.setHeader('SelectedCurrency',SelectedCurrency);
                req.setMethod('GET');
                //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :BUS,Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;
                dbl.Request_Data__c = string.valueof(req)+': Headers Info: Channel_Name :'+Channel_Name+',auth_key :'+auth_key+',BusinessUnit :BUS,Country_Name :'+Country_Name+',SelectedCurrency:'+SelectedCurrency;
                try
                {
                    res = http.send(req);
                    string responseValue = res.getBody();
                    dbl.Payment_Request_Response_Time__c = system.now();
                    dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                    dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                    //dbl.Payment_Request_Response_Data__c = string.valueof(res.getBody());    
                    dbl.Response_Received__c = string.valueof(res.getBody());    
                    HttpRequestWrappersUtil.PaymentResponse resp = new HttpRequestWrappersUtil.PaymentResponse();
                    
                    if(res.getStatus()=='OK' && String.isNotBlank(responseValue))
                    {
                        dbl.Payment_Ping_Status__c = 'Success';    
                        resp = (HttpRequestWrappersUtil.PaymentResponse)JSON.deserialize( responseValue, HttpRequestWrappersUtil.PaymentResponse.class);
                                
                        if(String.isNotBlank(resp.RbPgId) && string.valueof(resp.RbPgId)!= '0') 
                        {
                           pi.PG_Reference_ID_Ping__c =  string.valueof(resp.RbPgId);
                           pi.PG_Reference_ID__c =  string.valueof(resp.PgTransactionId);
                           pi.Latest_Payment_Status__c = string.valueof(resp.PaymentStatus); 
                           pi.Payment_Gateway_Type__c = string.valueof(resp.GatewayName);
                           pi.PG_Type__c = string.valueof(resp.PGType);
                           pi.IsOffline__c = Boolean.valueOf(resp.IsOffline);
                           pi.FT_FollowUp_Created__c = true;
                           
                           if(pi.IsOffline__c)
                           {
                                Case cs = new Case();
                                cs.Country__c = 'Indonesia';
                                cs.Business_Type__c='Indonesia-Bus';
                                cs.Issue_Type__c='WFT/Voucher Outbound Calling';
                                cs.Transaction_id__c = pi.Order_Item_Name__c;
                                cs.Booking_Email_ID__c = pi.Order_Item_Name__r.Email_Copy__c;
                                cs.Booking_Mobile_No__c =pi.Order_Item_Name__r.Mobile__c;
                                cs.Name_ct__c =pi.Order_Item_Name__r.Primary_Proof_Name__c;
                                cs.Email_Id_ct__c =cs.Booking_Email_ID__c;
                                cs.Phone_No_ct__c = cs.Booking_Mobile_No__c;
                                cs.SourceT__c =pi.Order_Item_Name__r.Source__c;
                                cs.DestinationT__c = pi.Order_Item_Name__r.Destination__c;
                                cs.SS_DOJ__c =pi.Order_Item_Name__r.Corrected_Boarding_Time__c;
                                cs.Bus_Operator_Namee__c =pi.Order_Item_Name__r.Service_Provider_Name__c;
                                cs.Payment_Initiation_Time__c =pi.Creation_Time__c;
                                cs.PG_Name__c =pi.Payment_Gateway_Type__c;
                                cs.PG_Type__c =pi.PG_Type__c;
                                cs.ownerId =wftQueueId;
                                cs.recordTypeId = recTypeId;
                                cs.Origin = 'Salesforce System';
                                listCases.add(cs); 
                           }
                           listPIToUpdate.add(pi);
                        }
                    }
                }
                
                Catch(Exception e)
                {
                    dbl.Exception_Description__c = String.valueOf(e);
                }
            }
            listDBlogs.add(dbl);
        }
        
        try
        {
            DataBase.insert(listDBlogs,false);
            DataBase.update(listPIToUpdate,false);
            DataBase.insert(listCases,true);
        }
        catch(Exception e)
        {
            System.debug('Exception...'+e);
        }
        
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add('sreenivasa.mariyavula@redbus.com');
       mail.setToAddresses(toAddresses);
       mail.setSubject('Unpaid Vocuhers Followup Case Creation Failure.'+a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       if(a.NumberOfErrors>0)
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}